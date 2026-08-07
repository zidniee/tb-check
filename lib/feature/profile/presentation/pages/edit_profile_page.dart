import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'whatsapp_profile_cropper_page.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_date_picker_field.dart';
import '../widgets/profile_dropdown_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  // Patient-specific controllers
  late TextEditingController _birthDateController;
  late TextEditingController _addressController;
  late TextEditingController _nikController;
  late TextEditingController _kkNumberController;

  // Doctor-specific controllers
  late TextEditingController _specializationController;
  late TextEditingController _strNumberController;

  String _selectedGender = 'Laki-laki';
  bool _bcgVaccinated = true;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isDoctor = auth.userRole == UserRole.doctor;
    final profile = Provider.of<ProfileProvider>(context, listen: false);

    _fullNameController = TextEditingController(text: isDoctor ? profile.doctorName : profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: isDoctor ? profile.doctorPhone : profile.phone);
    
    // Patient values
    _birthDateController = TextEditingController(text: profile.birthDate);
    _addressController = TextEditingController(text: profile.address);
    _nikController = TextEditingController(text: profile.nik);
    _kkNumberController = TextEditingController(text: profile.kkNumber);

    // Doctor values
    _specializationController = TextEditingController(text: profile.doctorSpecialization);
    _strNumberController = TextEditingController(text: profile.doctorStrNumber);

    _selectedGender = profile.gender;
    _bcgVaccinated = profile.bcgVaccinated;
    _selectedImagePath = profile.profilePicturePath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _nikController.dispose();
    _kkNumberController.dispose();
    _specializationController.dispose();
    _strNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime initialDate = DateTime.tryParse(_birthDateController.text) ?? DateTime(1995, 6, 15);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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

    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama lengkap harus minimal 3 karakter';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final cleanPhone = value.trim();
    final phoneRegex = RegExp(r'^(08|\+628)[0-9]{7,13}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Format nomor telepon tidak valid (mulai 08 / +628)';
    }
    return null;
  }

  String? _validateNik(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIK tidak boleh kosong';
    }
    final cleanVal = value.trim();
    if (cleanVal.length != 16) {
      return 'NIK harus tepat 16 digit';
    }
    if (int.tryParse(cleanVal) == null) {
      return 'NIK hanya boleh berupa angka';
    }
    return null;
  }

  String? _validateKk(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor KK tidak boleh kosong';
    }
    final cleanVal = value.trim();
    if (cleanVal.length != 16) {
      return 'Nomor KK harus tepat 16 digit';
    }
    if (int.tryParse(cleanVal) == null) {
      return 'Nomor KK hanya boleh berupa angka';
    }
    return null;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ubah Profil',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Header Section
                  Center(
                    child: GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E2D3D), Color(0xFF3D6285)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: _buildAvatarImage(_selectedImagePath, isDoctor),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (isDoctor) ...[
                    // --- DOCTOR FIELDS ---
                    _buildSectionTitle('Informasi Dokter'),
                    const SizedBox(height: 12),
                    _buildCardContainer([
                      CustomTextField(
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap dokter',
                        controller: _fullNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Email',
                        hintText: 'Email Anda',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Nomor Telepon',
                        hintText: 'Contoh: 08129876543',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android_rounded,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Spesialisasi',
                        hintText: 'Contoh: Spesialis Paru (Sp.P)',
                        controller: _specializationController,
                        prefixIcon: Icons.medical_services_outlined,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Nomor STR (Surat Tanda Registrasi)',
                        hintText: 'Contoh: STR-12345678',
                        controller: _strNumberController,
                        prefixIcon: Icons.assignment_ind_outlined,
                      ),
                    ]),
                  ] else ...[
                    // --- PATIENT FIELDS ---
                    // --- GROUP 1: PERSONAL INFO ---
                    _buildSectionTitle('Informasi Pribadi'),
                    const SizedBox(height: 12),
                    _buildCardContainer([
                      CustomTextField(
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        controller: _fullNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Email',
                        hintText: 'Email Anda',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      ProfileDropdownField(
                        label: 'Jenis Kelamin',
                        initialValue: _selectedGender,
                        items: const ['Laki-laki', 'Perempuan'],
                        prefixIcon: Icons.wc_rounded,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedGender = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ProfileDatePickerField(
                        label: 'Tanggal Lahir',
                        hintText: 'Pilih tanggal lahir',
                        controller: _birthDateController,
                        prefixIcon: Icons.calendar_month_outlined,
                        onTap: () => _selectBirthDate(context),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // --- GROUP 2: LEGAL IDENTITIES ---
                    _buildSectionTitle('Dokumen Kependudukan'),
                    const SizedBox(height: 12),
                    _buildCardContainer([
                      CustomTextField(
                        label: 'NIK (Nomor Induk Kependudukan)',
                        hintText: '16 Digit Nomor NIK',
                        controller: _nikController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.badge_outlined,
                        validator: _validateNik,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Nomor Kartu Keluarga (KK)',
                        hintText: '16 Digit Nomor KK',
                        controller: _kkNumberController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.credit_card_outlined,
                        validator: _validateKk,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // --- GROUP 3: CONTACT INFO ---
                    _buildSectionTitle('Informasi Kontak'),
                    const SizedBox(height: 12),
                    _buildCardContainer([
                      CustomTextField(
                        label: 'Nomor Telepon',
                        hintText: 'Contoh: 08123456789',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android_rounded,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Alamat Lengkap',
                        hintText: 'Masukkan nama jalan, nomor rumah, RT/RW, kota',
                        controller: _addressController,
                        prefixIcon: Icons.home_outlined,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // --- GROUP 4: MEDICAL HISTORY ---
                    _buildSectionTitle('Riwayat Medis'),
                    const SizedBox(height: 12),
                    _buildCardContainer([
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sudah Vaksin BCG?',
                                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Imunisasi vaksin BCG untuk TBC',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _bcgVaccinated,
                            activeThumbColor: AppColors.primary,
                            onChanged: (bool val) {
                              setState(() {
                                _bcgVaccinated = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ]),
                  ],
                  const SizedBox(height: 36),

                  // SAVE BUTTON
                  CustomButton(
                    text: 'Simpan Perubahan',
                    isLoading: profileProvider.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = isDoctor
                            ? await profileProvider.updateDoctorProfile(
                                fullName: _fullNameController.text.trim(),
                                phone: _phoneController.text.trim(),
                                specialization: _specializationController.text.trim(),
                                strNumber: _strNumberController.text.trim(),
                                profilePicturePath: _selectedImagePath,
                              )
                            : await profileProvider.updateProfile(
                                fullName: _fullNameController.text.trim(),
                                phone: _phoneController.text.trim(),
                                gender: _selectedGender,
                                birthDate: _birthDateController.text,
                                address: _addressController.text.trim(),
                                nik: _nikController.text.trim(),
                                kkNumber: _kkNumberController.text.trim(),
                                bcgVaccinated: _bcgVaccinated,
                                profilePicturePath: _selectedImagePath,
                              );

                        if (!context.mounted) return;
                        if (success) {
                          SnackBarUtils.showSuccess(context, 'Profil berhasil diperbarui');
                          Navigator.of(context).pop();
                        } else if (profileProvider.errorMessage != null) {
                          SnackBarUtils.showError(context, profileProvider.errorMessage!);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
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

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 12),
              Text(
                'Pilih Sumber Foto',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Galeri Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndCompressImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndCompressImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndCompressImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );

      if (pickedFile != null && mounted) {
        final String? croppedPath = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => WhatsAppProfileCropperPage(
              imagePath: pickedFile.path,
            ),
          ),
        );

        if (croppedPath != null && mounted) {
          setState(() {
            _selectedImagePath = croppedPath;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Gagal mengambil gambar: $e');
      }
    }
  }

  Widget _buildAvatarImage(String? path, bool isDoctor) {
    final defaultIcon = Icon(
      isDoctor ? Icons.medical_services_rounded : Icons.person_rounded,
      color: Colors.white,
      size: 56,
    );

    if (path == null || path.isEmpty) {
      return defaultIcon;
    }

    if (File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(
          File(path),
          width: 100,
          height: 100,
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
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                fullUrl,
                headers: (token != null && token.isNotEmpty)
                    ? {'Authorization': 'Bearer $token'}
                    : null,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => defaultIcon,
              ),
            );
          },
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          fullUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultIcon,
        ),
      );
    }

    return defaultIcon;
  }
}
