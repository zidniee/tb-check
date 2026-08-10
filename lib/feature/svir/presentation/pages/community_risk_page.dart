import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../providers/svir_provider.dart';

class CommunityRiskPage extends StatefulWidget {
  const CommunityRiskPage({super.key});

  @override
  State<CommunityRiskPage> createState() => _CommunityRiskPageState();
}

class _CommunityRiskPageState extends State<CommunityRiskPage> {
  double _radiusKm = 10.0;
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadRiskData();
  }

  Future<void> _loadRiskData() async {
    setState(() {
      _fetchingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          SnackBarUtils.showInfo(context, 'Layanan GPS lokasi tidak aktif.');
        }
        setState(() {
          _fetchingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            SnackBarUtils.showInfo(context, 'Izin lokasi ditolak.');
          }
          setState(() {
            _fetchingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          SnackBarUtils.showInfo(context, 'Izin lokasi ditolak secara permanen. Ubah di pengaturan HP.');
        }
        setState(() {
          _fetchingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        await context.read<SvirProvider>().loadCommunityRisk(
              lat: position.latitude,
              lon: position.longitude,
              radiusKm: _radiusKm,
            );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Gagal mendapatkan lokasi GPS: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _fetchingLocation = false;
        });
      }
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRiskText(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return 'Risiko Tinggi';
      case 'MEDIUM':
        return 'Risiko Sedang';
      case 'LOW':
        return 'Risiko Rendah';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SvirProvider>();
    final risk = provider.communityRisk;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Risiko TBC Komunitas'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRiskData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location status banner
              if (_fetchingLocation)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Sedang melacak koordinat GPS Anda...'),
                    ],
                  ),
                ),

              // Radius Selector Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Radius Pencarian',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<double>(
                      value: _radiusKm,
                      items: const [
                        DropdownMenuItem(value: 5.0, child: Text('5 KM')),
                        DropdownMenuItem(value: 10.0, child: Text('10 KM')),
                        DropdownMenuItem(value: 25.0, child: Text('25 KM')),
                        DropdownMenuItem(value: 50.0, child: Text('50 KM')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _radiusKm = val;
                          });
                          _loadRiskData();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Risk Indicator card
              if (provider.isLoading && risk == null)
                const Center(child: CircularProgressIndicator())
              else if (risk == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text('Gagal memuat data risiko daerah.'),
                  ),
                )
              else ...[
                // Main Risk Indicator Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tingkat Kerawanan Daerah Anda',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _getRiskColor(risk.riskLevel).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: _getRiskColor(risk.riskLevel),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _getRiskText(risk.riskLevel),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 22,
                          color: _getRiskColor(risk.riskLevel),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics Detail Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Detail Statistik Kasus Regional',
                        style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _buildStatRow('Total Skrining Terdata', risk.totalScreenings.toString()),
                      const SizedBox(height: 12),
                      _buildStatRow('Kasus Positif TBC', risk.positiveCases.toString(), color: Colors.red),
                      const SizedBox(height: 12),
                      _buildStatRow('Kasus Negatif TBC', risk.negativeCases.toString(), color: Colors.green),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Rasio Positif (Infection Rate)',
                        "${(risk.infectionRatio * 100).toStringAsFixed(1)}%",
                        color: _getRiskColor(risk.riskLevel),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String val, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          val,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
