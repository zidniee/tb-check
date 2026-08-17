import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import '../../../../core/config/env_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/cache_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../patient/presentation/providers/dashboard_provider.dart';
import '../../../doctor/presentation/providers/doctor_dashboard_provider.dart';
import '../../../patient/presentation/providers/care_notifier.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_page.dart';
import 'profile_picture_viewer_page.dart';
import 'notification_settings_page.dart';
import 'help_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      provider.fetchProfile();
      provider.updateGPSLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDoctor = authProvider.userRole == UserRole.doctor;
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profil Pengguna',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 12.0,
            bottom: 130.0, // Unified bottom spacing clearance to prevent overlap with the floating bottom bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Profile Header (Avatar, Name, Email, Badge)
              _buildProfileHeader(context),
              const SizedBox(height: 24),

              // 2. Stats Row / Doctor Info Row
              _buildStatsRow(isDoctor, profileProvider),
              const SizedBox(height: 28),

              // 3. Settings Groups
              _buildSectionTitle('Akun'),
              const SizedBox(height: 8),
              _buildMenuCard([
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.primaryLight,
                  title: 'Informasi Pribadi',
                  subtitle: isDoctor ? 'Kelola data spesialisasi dan STR Anda' : 'Kelola data diri dan kontak Anda',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
                    );
                  },
                ),
                if (!isDoctor) ...[
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment_ind_outlined,
                    iconColor: AppColors.secondary,
                    iconBgColor: AppColors.secondaryLight,
                    title: 'Riwayat Medis',
                    subtitle: 'Lihat catatan dan hasil skrining TBC',
                    onTap: () => SnackBarUtils.showInfo(context, 'Fitur riwayat medis segera hadir.'),
                  ),
                ],
              ]),
              const SizedBox(height: 24),

              _buildSectionTitle('Preferensi & Aplikasi'),
              const SizedBox(height: 8),
              _buildMenuCard([
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_none_rounded,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successLight,
                  title: 'Pengaturan Notifikasi',
                  subtitle: 'Atur preferensi pengingat Anda',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
                    );
                  },
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.translate_rounded,
                  iconColor: Colors.orange,
                  iconBgColor: const Color(0xFFFFF3E0),
                  title: 'Bahasa',
                  subtitle: 'Bahasa Indonesia (Default)',
                  onTap: () => SnackBarUtils.showInfo(context, 'Bahasa default saat ini adalah Bahasa Indonesia.'),
                ),
                _buildDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  iconColor: Colors.blueGrey,
                  iconBgColor: Colors.blueGrey.shade50,
                  title: 'Pusat Bantuan & FAQ',
                  subtitle: 'Butuh bantuan tentang TBCheck?',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpCenterPage()),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),

              _buildSectionTitle('Aksi'),
              const SizedBox(height: 8),
              _buildMenuCard([
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  iconColor: Colors.redAccent,
                  iconBgColor: const Color(0xFFFFEBEE),
                  title: 'Keluar',
                  titleColor: Colors.redAccent,
                  subtitle: 'Keluar dari akun Anda saat ini',
                  showChevron: false,
                  onTap: () => _showLogoutDialog(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDoctor = authProvider.userRole == UserRole.doctor;
    return Column(
      children: [
        // Avatar stack with edit button
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePictureViewerPage(
                      imagePath: profileProvider.profilePicturePath,
                      isDoctor: isDoctor,
                    ),
                  ),
                );
              },
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E2D3D), Color(0xFF3D6285)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _buildAvatarImage(profileProvider.profilePicturePath, isDoctor),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          isDoctor ? profileProvider.doctorName : profileProvider.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Email
        Text(
          profileProvider.email.isNotEmpty ? profileProvider.email : 'demo@email.com',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isDoctor ? 'Dokter' : 'Pasien',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDoctor, ProfileProvider profile) {
    if (isDoctor) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.medical_services_outlined, 'Spesialisasi', profile.doctorSpecialization.isNotEmpty ? profile.doctorSpecialization : '-'),
            const Divider(height: 24, thickness: 0.5),
            _buildInfoRow(Icons.assignment_ind_outlined, 'Nomor STR', profile.doctorStrNumber.isNotEmpty ? profile.doctorStrNumber : '-'),
            const Divider(height: 24, thickness: 0.5),
            _buildInfoRow(Icons.phone_android_rounded, 'Nomor Telepon', profile.doctorPhone.isNotEmpty ? profile.doctorPhone : '-'),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerVertical() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing Chevron
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        color: AppColors.border,
        height: 1,
        thickness: 0.5,
      ),
    );
  }

  void _showLogoutDialog(BuildContext pageContext) {
    showDialog(
      context: pageContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Konfirmasi Keluar',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: AppTextStyles.bodyMedium,
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Batal',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(pageContext, listen: false);
                final profileProvider = Provider.of<ProfileProvider>(pageContext, listen: false);

                Navigator.of(dialogContext).pop();

                await authProvider.logout();
                profileProvider.clearProfile();
                
                // Clear patient and doctor dashboards
                if (pageContext.mounted) {
                  Provider.of<DashboardProvider>(pageContext, listen: false).clearDashboard();
                  Provider.of<DoctorDashboardProvider>(pageContext, listen: false).clearDashboard();
                  
                  // Invalidate Riverpod care notifier state
                  ProviderScope.containerOf(pageContext).invalidate(careNotifierProvider);
                  
                  // Clean up all cache service data
                  await CacheService().clearAllCache();
                }

                if (pageContext.mounted) {
                  SnackBarUtils.showSuccess(pageContext, 'Berhasil keluar akun.');
                  Navigator.of(pageContext, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Keluar',
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarImage(String? path, bool isDoctor) {
    final defaultIcon = Icon(
      isDoctor ? Icons.medical_services_rounded : Icons.person_rounded,
      color: Colors.white,
      size: 54,
    );

    if (path == null || path.isEmpty) {
      return defaultIcon;
    }

    if (File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: Image.file(
          File(path),
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultIcon,
        ),
      );
    }

    final String fullUrl = (path.startsWith('http://') || path.startsWith('https://'))
        ? path
        : (path.startsWith('/') ? '${EnvConfig.apiBaseUrl}$path' : '');

    if (fullUrl.isNotEmpty) {
      final bool isInternalApi = fullUrl.startsWith(EnvConfig.apiBaseUrl);

      if (isInternalApi) {
        return FutureBuilder<String?>(
          future: SecureStorageService().getAccessToken(),
          builder: (context, snapshot) {
            final token = snapshot.data;
            return ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Image.network(
                fullUrl,
                headers: (token != null && token.isNotEmpty)
                    ? {'Authorization': 'Bearer $token'}
                    : null,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => defaultIcon,
              ),
            );
          },
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: Image.network(
          fullUrl,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultIcon,
        ),
      );
    }

    return defaultIcon;
  }
}
