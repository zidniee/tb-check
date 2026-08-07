import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'edit_profile_page.dart';

class ProfilePictureViewerPage extends StatelessWidget {
  final String? imagePath;
  final bool isDoctor;

  const ProfilePictureViewerPage({
    super.key,
    required this.imagePath,
    this.isDoctor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Foto profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            tooltip: 'Edit Foto Profil',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Hero(
          tag: 'profile_avatar_hero',
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: _buildFullImage(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFullImage(BuildContext context) {
    final defaultWidget = Container(
      width: 280,
      height: 280,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.textPrimary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        isDoctor ? Icons.medical_services_rounded : Icons.person_rounded,
        color: Colors.white,
        size: 140,
      ),
    );

    if (imagePath == null || imagePath!.isEmpty) {
      return defaultWidget;
    }

    if (File(imagePath!).existsSync()) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => defaultWidget,
      );
    }

    final String fullUrl = (imagePath!.startsWith('http://') || imagePath!.startsWith('https://'))
        ? imagePath!
        : (imagePath!.startsWith('/') ? '${EnvConfig.apiBaseUrl}$imagePath' : '');

    if (fullUrl.isNotEmpty) {
      final bool isInternalApi = fullUrl.startsWith(EnvConfig.apiBaseUrl);

      if (isInternalApi) {
        return FutureBuilder<String?>(
          future: SecureStorageService().getAccessToken(),
          builder: (context, snapshot) {
            final token = snapshot.data;
            return Image.network(
              fullUrl,
              headers: (token != null && token.isNotEmpty)
                  ? {'Authorization': 'Bearer $token'}
                  : null,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => defaultWidget,
            );
          },
        );
      }

      return Image.network(
        fullUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => defaultWidget,
      );
    }

    return defaultWidget;
  }
}
