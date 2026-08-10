import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/models/appointment_models.dart';
import '../providers/appointment_provider.dart';

class DoctorSchedulePage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialization;

  const DoctorSchedulePage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
  });

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  final _screeningIdController = TextEditingController();
  
  DoctorSchedule? _selectedSchedule;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadSchedules(widget.doctorId);
    });
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _screeningIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    if (dayOfWeek >= 0 && dayOfWeek < days.length) {
      return days[dayOfWeek];
    }
    return 'Hari';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pilih Jadwal Dokter'),
        centerTitle: true,
      ),
      body: provider.isLoading && provider.schedules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Doctor Brief Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryLight,
                            child: const Icon(Icons.person, color: AppColors.primary, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctorName,
                                  style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.specialization,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Date Selection
                    Text(
                      'Tanggal Kunjungan',
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text(
                              "${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}",
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Schedules List
                    Text(
                      'Jadwal Praktik Tersedia',
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    if (provider.schedules.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Tidak ada jadwal aktif untuk dokter ini.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.schedules.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final sched = provider.schedules[index];
                          final isSelected = _selectedSchedule?.scheduleId == sched.scheduleId;
                          final hasSlots = sched.availableSlots > 0;

                          return InkWell(
                            onTap: hasSlots
                                ? () {
                                    setState(() {
                                      _selectedSchedule = sched;
                                    });
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryLight.withOpacity(0.3) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getDayName(sched.dayOfWeek),
                                        style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${sched.startTime} - ${sched.endTime}",
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        hasSlots ? 'Sisa ${sched.availableSlots} slot' : 'Kuota Penuh',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: hasSlots ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // Complaint Input
                    Text(
                      'Keluhan Medis',
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _complaintController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan keluhan Anda secara singkat...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Keluhan wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Optional Screening Result ID
                    Text(
                      'ID Hasil Skrining (Opsional)',
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _screeningIdController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan ID hasil tes batuk AI jika ada',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Booking Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_selectedSchedule == null) {
                                SnackBarUtils.showInfo(context, 'Pilih jadwal praktik terlebih dahulu!');
                                return;
                              }
                              if (_formKey.currentState!.validate()) {
                                final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
                                final req = CreateAppointmentRequest(
                                  scheduleId: _selectedSchedule!.scheduleId,
                                  appointmentDate: dateStr,
                                  complaint: _complaintController.text,
                                  screeningResultId: _screeningIdController.text.isNotEmpty
                                      ? _screeningIdController.text
                                      : null,
                                );

                                final ok = await context.read<AppointmentProvider>().createAppointment(req);
                                if (!context.mounted) return;
                                if (ok) {
                                  SnackBarUtils.showSuccess(context, 'Janji temu berhasil diajukan!');
                                  Navigator.pop(context);
                                } else {
                                  SnackBarUtils.showError(context, provider.errorMessage ?? 'Gagal membuat janji temu');
                                }
                              }
                            },
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Ajukan Janji Temu',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
