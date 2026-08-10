import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/appointment_provider.dart';

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  String? _selectedStatus;
  int? _selectedMonth;
  int? _selectedYear;
  int _currentPage = 1;

  final List<String> _statuses = ['COMPLETED', 'CANCELLED', 'REJECTED', 'NO_SHOW'];
  final List<int> _months = List.generate(12, (index) => index + 1);
  final List<int> _years = [2024, 2025, 2026, 2027];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadHistory(
            status: _selectedStatus,
            month: _selectedMonth,
            year: _selectedYear,
            page: _currentPage,
            pageSize: 10,
          );
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.grey;
      case 'REJECTED':
        return Colors.red;
      case 'NO_SHOW':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final historyData = provider.historyResponse;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Riwayat Janji Temu'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Status Filter Dropdown
                  DropdownButton<String>(
                    hint: const Text('Status'),
                    value: _selectedStatus,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Status')),
                      ..._statuses.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedStatus = val;
                        _currentPage = 1;
                      });
                      _fetchHistory();
                    },
                  ),
                  const SizedBox(width: 16),

                  // Month Filter Dropdown
                  DropdownButton<int>(
                    hint: const Text('Bulan'),
                    value: _selectedMonth,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Bulan')),
                      ..._months.map((e) => DropdownMenuItem(value: e, child: Text("Bulan $e"))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedMonth = val;
                        _currentPage = 1;
                      });
                      _fetchHistory();
                    },
                  ),
                  const SizedBox(width: 16),

                  // Year Filter Dropdown
                  DropdownButton<int>(
                    hint: const Text('Tahun'),
                    value: _selectedYear,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Tahun')),
                      ..._years.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedYear = val;
                        _currentPage = 1;
                      });
                      _fetchHistory();
                    },
                  ),
                ],
              ),
            ),
          ),

          // History list
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyData == null || historyData.items.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(20.0),
                              itemCount: historyData.items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = historyData.items[index];
                                return Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(item.status).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(item.status),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item.appointmentDate,
                                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item.doctor.fullName,
                                        style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${item.doctor.specialization} • ${item.doctor.hospitalName}",
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                      if (item.cancelReason.isNotEmpty) ...[
                                        const Divider(height: 20),
                                        Text(
                                          "Alasan Batal: ${item.cancelReason}",
                                          style: AppTextStyles.bodySmall.copyWith(color: Colors.red[800]),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Pagination Controls
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() {
                                            _currentPage--;
                                          });
                                          _fetchHistory();
                                        }
                                      : null,
                                  child: const Text('Sebelumnya'),
                                ),
                                Text('Halaman $_currentPage'),
                                ElevatedButton(
                                  onPressed: (historyData.items.length == 10 && historyData.total > (_currentPage * 10))
                                      ? () {
                                          setState(() {
                                            _currentPage++;
                                          });
                                          _fetchHistory();
                                        }
                                      : null,
                                  child: const Text('Berikutnya'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_outlined, size: 72, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada riwayat janji temu',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
