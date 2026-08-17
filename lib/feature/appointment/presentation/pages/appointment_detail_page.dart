import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/models/appointment_models.dart';
import '../providers/appointment_provider.dart';

class AppointmentDetailPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailPage({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final _rescheduleReasonController = TextEditingController();
  final _cancelReasonController = TextEditingController();
  
  DateTime _newDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAppointmentById(widget.appointmentId);
    });
  }

  @override
  void dispose() {
    _rescheduleReasonController.dispose();
    _cancelReasonController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.amber;
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.grey;
      case 'REJECTED':
        return Colors.red;
      case 'RESCHEDULE_REQUESTED':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    if (dayOfWeek >= 0 && dayOfWeek < days.length) {
      return days[dayOfWeek];
    }
    return 'Hari';
  }

  void _showCancelDialog(Appointment item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan Janji Temu'),
          content: TextField(
            controller: _cancelReasonController,
            decoration: const InputDecoration(
              hintText: 'Alasan pembatalan...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                if (_cancelReasonController.text.isEmpty) {
                  SnackBarUtils.showInfo(context, 'Alasan pembatalan wajib diisi!');
                  return;
                }
                final req = CancelRequest(reason: _cancelReasonController.text);
                final ok = await this.context.read<AppointmentProvider>().cancelAppointment(item.appointmentId, req);
                if (ok && context.mounted) {
                  SnackBarUtils.showSuccess(context, 'Janji temu berhasil dibatalkan');
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: const Text('Batalkan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRescheduleDialog(Appointment item) {
    TimeOfDay _newTime = const TimeOfDay(hour: 8, minute: 0);
    try {
      final parts = item.appointmentTime.split(':');
      if (parts.length == 2) {
        _newTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ubah Jadwal Janji'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _newDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() {
                          _newDate = picked;
                        });
                      }
                    },
                    child: Text("Pilih Tanggal: ${_newDate.day}-${_newDate.month}-${_newDate.year}"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _newTime,
                      );
                      if (picked != null) {
                        setState(() {
                          _newTime = picked;
                        });
                      }
                    },
                    child: Text("Pilih Jam: ${_newTime.hour.toString().padLeft(2, '0')}:${_newTime.minute.toString().padLeft(2, '0')}"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rescheduleReasonController,
                    decoration: const InputDecoration(
                      hintText: 'Alasan pengajuan ubah jadwal...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_rescheduleReasonController.text.isEmpty) {
                      SnackBarUtils.showInfo(context, 'Alasan ubah jadwal wajib diisi!');
                      return;
                    }
                    final dateStr = "${_newDate.year}-${_newDate.month.toString().padLeft(2, '0')}-${_newDate.day.toString().padLeft(2, '0')}";
                    final timeStr = "${_newTime.hour.toString().padLeft(2, '0')}:${_newTime.minute.toString().padLeft(2, '0')}";
                    final req = RescheduleRequest(
                      newScheduleId: item.schedule?.scheduleId,
                      newDate: dateStr,
                      newTime: timeStr,
                      reason: _rescheduleReasonController.text,
                    );
                    final ok = await this.context.read<AppointmentProvider>().rescheduleAppointment(item.appointmentId, req);
                    if (ok && context.mounted) {
                      SnackBarUtils.showSuccess(context, 'Permintaan ubah jadwal berhasil diajukan');
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajukan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final item = provider.currentAppointment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Detail Janji Temu'),
        centerTitle: true,
      ),
      body: provider.isLoading || item == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Header
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status Janji Temu',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(item.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID Janji Temu',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              item.appointmentId.substring(0, 8).toUpperCase(),
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Doctor Brief details
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penyedia Layanan Medis',
                          style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight,
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.doctor.fullName,
                                    style: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item.doctor.specialization} • ${item.doctor.hospitalName}",
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Booking Details
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rencana Kunjungan',
                          style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              item.appointmentDate,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              item.schedule != null
                                  ? "${_getDayName(item.schedule!.dayOfWeek)}, ${item.schedule!.startTime} - ${item.schedule!.endTime}"
                                  : item.appointmentTime,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Complaints and Notes
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Keluhan',
                          style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.complaint,
                          style: AppTextStyles.bodyMedium,
                        ),
                        if (item.notes.isNotEmpty) ...[
                          const Divider(height: 24, color: AppColors.border),
                          Text(
                            'Catatan Dokter / Admin',
                            style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.notes,
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.green[800]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons (Only for PENDING status)
                  if (item.status == 'PENDING') ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _showRescheduleDialog(item),
                      child: const Text('Ajukan Ubah Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _showCancelDialog(item),
                      child: const Text('Batalkan Janji Temu', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
