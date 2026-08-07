import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/care_provider.dart';

class CareSettingsPage extends StatefulWidget {
  const CareSettingsPage({super.key});

  @override
  State<CareSettingsPage> createState() => _CareSettingsPageState();
}

class _CareSettingsPageState extends State<CareSettingsPage> {
  DateTime _selectedStartDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareProvider>(context, listen: false).loadCareData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final careProvider = Provider.of<CareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manajemen Terapi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: careProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: careProvider.treatment == null
                  ? _buildSetupTreatmentForm(context, careProvider)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTreatmentStatusCard(context, careProvider),
                        const SizedBox(height: 20),
                        _buildComplianceStatsCard(careProvider),
                        const SizedBox(height: 20),
                        _buildAlarmsManagementCard(context, careProvider),
                        const SizedBox(height: 40),
                      ],
                    ),
            ),
    );
  }

  Widget _buildSetupTreatmentForm(BuildContext context, CareProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Icon(
              Icons.healing_rounded,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Daftarkan Terapi Baru',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Dengan mendaftarkan tanggal mulai terapi, Anda akan mendapatkan pengingat minum obat secara terjadwal untuk meningkatkan kepatuhan terapi paru-paru.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Tanggal Mulai Terapi',
            style: AppTextStyles.labelMedium.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedStartDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() {
                  _selectedStartDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedStartDate),
                    style: AppTextStyles.bodyMedium,
                  ),
                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Zona Waktu Pengingat',
            style: AppTextStyles.labelMedium.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateTime.now().timeZoneName,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.public_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final dateStr = "${_selectedStartDate.year}-${_selectedStartDate.month.toString().padLeft(2, '0')}-${_selectedStartDate.day.toString().padLeft(2, '0')}";
              final tz = DateTime.now().timeZoneName;
              provider.setupTreatment(timezone: tz, startDate: dateStr);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Aktifkan Terapi'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentStatusCard(BuildContext context, CareProvider provider) {
    final treatment = provider.treatment!;
    final date = DateTime.tryParse(treatment.startDate) ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Terapi',
                style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
              ),
              Switch(
                value: treatment.reminderEnabled,
                onChanged: (val) {
                  provider.updateTreatmentReminder(val);
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mulai Terapi',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                DateFormat('dd MMMM yyyy').format(date),
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zona Waktu',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                treatment.timezone,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          OutlinedButton(
            onPressed: () => _showStopTreatmentDialog(context, provider),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hentikan Terapi'),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceStatsCard(CareProvider provider) {
    final stats = provider.statistics;
    if (stats == null) return const SizedBox();

    // The backend returns complianceRate as 0-100 (percentage)
    final double compliancePercentage = stats.complianceRate;
    // If no doses taken or missed yet, set compliance to 0% to avoid fake 100%
    final double realPercentage = (stats.totalTaken + stats.totalMissed) > 0 
        ? compliancePercentage 
        : 0.0;
    final double progressFraction = realPercentage / 100.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Kepatuhan',
            style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Radial Gauge
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: progressFraction,
                          strokeWidth: 6,
                          backgroundColor: AppColors.border.withOpacity(0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${realPercentage.toStringAsFixed(0)}%',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Legend Info
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Diminum', stats.totalTaken, AppColors.success),
                    _buildStatRow('Terlewat', stats.totalMissed, Colors.redAccent),
                    _buildStatRow('Menunggu', stats.totalPending, AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          Text(
            '$value kali',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsManagementCard(BuildContext context, CareProvider provider) {
    final schedules = provider.schedules;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jadwal Alarm',
                style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
              ),
              TextButton.icon(
                onPressed: () => _addNewAlarm(context, provider),
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: Text(
                  'Tambah',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Belum ada jadwal alarm. Daftarkan alarm Anda untuk mendapatkan notifikasi pengingat minum obat.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.border),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alarm_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            schedule.reminderTime,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => provider.deleteSchedule(schedule.scheduleId),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _addNewAlarm(BuildContext context, CareProvider provider) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final hour = pickedTime.hour.toString().padLeft(2, '0');
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final timeStr = "$hour:$minute";
      provider.addSchedule(timeStr);
    }
  }

  void _showStopTreatmentDialog(BuildContext context, CareProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hentikan Terapi?'),
          content: const Text(
            'Apakah Anda yakin ingin menghentikan terapi ini? Semua jadwal alarm dan data kepatuhan akan terhapus permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTreatment();
                Navigator.pop(context);
              },
              child: const Text('Ya, Hentikan', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
