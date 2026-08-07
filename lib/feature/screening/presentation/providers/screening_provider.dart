import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../../../../core/native/audio_channel.dart';
import '../../../../core/ai/tflite_service.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/screening_remote_data_source.dart';
import '../../data/repositories/screening_repository_impl.dart';
import '../../domain/entities/screening_result.dart';
import '../../domain/repositories/screening_repository.dart';

enum ScreeningState { idle, recording, processing, analyzing, resultReady, error }

class ScreeningProvider extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioChannel _audioChannel = AudioChannel();
  late final ScreeningRepository _screeningRepository;

  ScreeningProvider({ScreeningRepository? repository}) {
    _screeningRepository = repository ??
        ScreeningRepositoryImpl(
          remoteDataSource: ScreeningRemoteDataSourceImpl(
            apiService: ApiService(),
          ),
        );
  }

  // Unified Wizard Step (0: Questionnaire, 1: Cough Recording)
  int _currentStep = 0;

  // Questionnaire States (FR-003)
  int? _age;
  final Map<int, bool> _answers = {
    0: false, // Batuk Lama
    1: false, // Batuk Berdarah
    2: false, // Demam
    3: false, // Berat Badan Turun
    4: false, // Keringat Malam
    5: false, // Nyeri Dada
    6: false, // Nafsu Makan Turun
    7: false, // Lemas/Malaise
    8: false, // Kontak Erat TBC
    9: false, // Riwayat Merokok
  };

  ScreeningState _state = ScreeningState.idle;
  String? _errorMessage;
  String? _recordedFilePath;
  Float32List? _mfccData;
  double _recordingProgress = 0.0; // Seconds elapsed (0.0 to 5.0)
  Timer? _timer;
  ScreeningResult? _screeningResult;
  String? _submittedReportId;

  // Getters
  int get currentStep => _currentStep;
  int? get age => _age;
  Map<int, bool> get answers => _answers;
  ScreeningState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get recordedFilePath => _recordedFilePath;
  Float32List? get mfccData => _mfccData;
  double get recordingProgress => _recordingProgress;
  ScreeningResult? get screeningResult => _screeningResult;
  String? get submittedReportId => _submittedReportId;

  // Setters & Actions
  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setAge(int? value) {
    _age = value;
    notifyListeners();
  }

  void setAnswer(int index, bool value) {
    _answers[index] = value;
    notifyListeners();
  }

  void toggleAnswer(int index) {
    _answers[index] = !(_answers[index] ?? false);
    notifyListeners();
  }

  /// Validates the age input
  bool validateQuestionnaire() {
    if (_age == null || _age! <= 0 || _age! > 120) {
      _state = ScreeningState.error;
      _errorMessage = 'Usia harus diisi dengan angka yang valid (1 - 120).';
      notifyListeners();
      return false;
    }
    _state = ScreeningState.idle;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Encodes questionnaire answers to a binary list of 1s and 0s (FR-003)
  List<int> getEncodedAnswers() {
    return List.generate(10, (index) => (_answers[index] ?? false) ? 1 : 0);
  }

  Map<String, dynamic> getClinicalAnswersMap() {
    return {
      'age': _age,
      'batuk_lama': _answers[0] ?? false,
      'batuk_berdarah': _answers[1] ?? false,
      'demam': _answers[2] ?? false,
      'berat_badan_turun': _answers[3] ?? false,
      'keringat_malam': _answers[4] ?? false,
      'nyeri_dada': _answers[5] ?? false,
      'nafsu_makan_turun': _answers[6] ?? false,
      'malaise': _answers[7] ?? false,
      'kontak_tbc': _answers[8] ?? false,
      'riwayat_merokok': _answers[9] ?? false,
    };
  }

  /// Starts the 5-second cough recording
  Future<void> startRecording() async {
    _state = ScreeningState.recording;
    _errorMessage = null;
    _recordingProgress = 0.0;
    _mfccData = null;
    _submittedReportId = null;
    notifyListeners();

    try {
      if (!await _recorder.hasPermission()) {
        _state = ScreeningState.error;
        _errorMessage = 'Izin mikrofon ditolak. Silakan berikan izin di pengaturan.';
        notifyListeners();
        return;
      }

      final tempDir = Directory.systemTemp;
      final path = '${tempDir.path}/cough_record.wav';
      
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      _recordedFilePath = path;

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        _recordingProgress += 0.1;
        if (_recordingProgress >= 5.0) {
          _recordingProgress = 5.0;
          timer.cancel();
          await stopAndProcessRecording();
        } else {
          notifyListeners();
        }
      });
    } catch (e) {
      _state = ScreeningState.error;
      _errorMessage = 'Gagal memulai rekaman: $e';
      notifyListeners();
    }
  }

  /// Stops recording and immediately invokes native MFCC extraction
  Future<void> stopAndProcessRecording() async {
    _timer?.cancel();
    if (_state != ScreeningState.recording) return;

    _state = ScreeningState.processing;
    notifyListeners();

    try {
      final path = await _recorder.stop();
      if (path == null) {
        _state = ScreeningState.error;
        _errorMessage = 'Perekaman terhenti dengan file kosong.';
        notifyListeners();
        return;
      }

      _recordedFilePath = path;

      final mfcc = await _audioChannel.extractMfcc(path);
      if (mfcc.isEmpty) {
        _state = ScreeningState.error;
        _errorMessage = 'Gagal melakukan ekstraksi MFCC secara native: Data kosong.';
        notifyListeners();
      } else {
        _mfccData = mfcc;
        await runAiInference();
      }
    } catch (e) {
      _state = ScreeningState.error;
      _errorMessage = 'Terjadi kesalahan pemrosesan audio: $e';
      notifyListeners();
    }
  }

  /// Runs AI inference using local TFLite model AND submits report to backend API
  Future<void> runAiInference() async {
    if (_mfccData == null || _mfccData!.isEmpty) {
      _state = ScreeningState.error;
      _errorMessage = 'Data fitur MFCC kosong. Tidak dapat melakukan inferensi AI.';
      notifyListeners();
      return;
    }

    // ============================================================================
    // Input Validation (Added 2026-08-04)
    // ============================================================================
    // Validate MFCC data to detect abnormal patterns that could affect inference
    final validationResult = _validateMfccData(_mfccData!);
    if (!validationResult.isValid) {
      developer.log(
        'MFCC validation warning: ${validationResult.message}',
        name: 'ScreeningProvider',
      );
      // Continue with inference but log the warning
      // In production, you might want to alert the user or abort
    }

    _state = ScreeningState.analyzing;
    notifyListeners();

    try {
      final tfliteService = TfliteService();
      final result = await tfliteService.runInference(_mfccData!);
      _screeningResult = result;

      // Submit report to Backend API
      final submitRes = await _screeningRepository.submitReport(
        probabilityScore: result.probabilityScore,
        predictionStatus: result.screeningStatus,
        mfccMeanVector: _mfccData!.toList(),
        clinicalAnswers: getClinicalAnswersMap(),
      );

      submitRes.fold(
        (failure) {
          // Keep local result ready even if remote save fails
          _submittedReportId = null;
        },
        (reportDTO) {
          _submittedReportId = reportDTO.reportId;
        },
      );

      _state = ScreeningState.resultReady;
      notifyListeners();
    } catch (e) {
      _state = ScreeningState.error;
      _errorMessage = 'Gagal menjalankan inferensi AI: $e';
      notifyListeners();
    }
  }

  /// Validates MFCC data to detect abnormal patterns
  /// Added: 2026-08-04 - Part of quantization bug fix
  ValidationResult _validateMfccData(Float32List data) {
    // Check for NaN or Infinity
    for (var val in data) {
      if (val.isNaN || val.isInfinite) {
        return ValidationResult(
          isValid: false,
          message: 'MFCC contains NaN or Infinity values',
        );
      }
    }

    // Compute statistics
    double minVal = data[0];
    double maxVal = data[0];
    double sum = 0.0;
    
    for (var val in data) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
      sum += val;
    }
    
    final mean = sum / data.length;
    final absMax = maxVal > minVal.abs() ? maxVal : minVal.abs();

    // Expected: CMVN normalized data (mean ≈ 0, std ≈ 1)
    if (mean.abs() > 0.5) {
      return ValidationResult(
        isValid: false,
        message: 'MFCC mean too far from 0: ${mean.toStringAsFixed(3)} (expected ≈0)',
      );
    }

    if (absMax > 5.0) {
      return ValidationResult(
        isValid: false,
        message: 'MFCC max value abnormal: ${absMax.toStringAsFixed(3)} (expected <3)',
      );
    }

    // Check for saturation (too many identical values)
    final uniqueValues = data.toSet().length;
    final saturationRatio = uniqueValues / data.length;
    if (saturationRatio < 0.3) {
      return ValidationResult(
        isValid: false,
        message: 'MFCC appears saturated: ${(saturationRatio * 100).toStringAsFixed(1)}% unique values',
      );
    }

    return ValidationResult(isValid: true, message: 'OK');
  }

  void reset() {
    _state = ScreeningState.idle;
    _errorMessage = null;
    _recordedFilePath = null;
    _mfccData = null;
    _recordingProgress = 0.0;
    _timer?.cancel();
    _currentStep = 0;
    _age = null;
    _screeningResult = null;
    _submittedReportId = null;
    for (var i = 0; i < 10; i++) {
      _answers[i] = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}

/// Helper class for MFCC validation results
class ValidationResult {
  final bool isValid;
  final String message;
  
  ValidationResult({required this.isValid, required this.message});
}
