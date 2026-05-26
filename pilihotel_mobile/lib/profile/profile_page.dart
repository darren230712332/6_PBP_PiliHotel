import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/loading_dialog.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'edit_name_dialog.dart';
import 'edit_email_dialog.dart';
import 'logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  late Future<Map<String, dynamic>> _profileFuture;
  File? selectedImageFile;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authService.getProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _authService.getProfile();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final result = await _imagePicker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 60,
    );
    if (result != null) {
      // For web, we need to read bytes from XFile directly
      // For mobile, we can use File from path
      late File file;
      if (kIsWeb) {
        // On web, read bytes and create a temporary File-like object
        final bytes = await result.readAsBytes();
        // We'll pass bytes directly to upload
        await _uploadPhotoBytes(result.name, bytes);
        // For preview, create a display-only reference
        setState(() {
          selectedImageFile = File(result.path);
        });
      } else {
        file = File(result.path);
        // Show preview immediately
        setState(() {
          selectedImageFile = file;
        });
        // Upload in background
        await _uploadPhoto(file);
      }
    }
  }

  Future<void> _uploadPhotoBytes(String filename, List<int> bytes) async {
    await showPiliLoadingDialog(context, message: 'Mengupload foto profil...');

    try {
      final response = await _authService.uploadPhotoBytes(
        filename: filename,
        bytes: bytes,
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (response['success'] == true) {
        await showPiliDialog(
          context,
          icon: Icons.check,
          title: 'Berhasil',
          message: 'Foto profil berhasil diperbarui.',
        );
        setState(() {
          selectedImageFile = null;
        });
        _refreshProfile();
      } else {
        await showPiliDialog(
          context,
          icon: Icons.warning,
          title: 'Gagal',
          message: response['message'] ?? 'Gagal mengupload foto',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await showPiliDialog(
        context,
        icon: Icons.error,
        title: 'Error',
        message: 'Error: $e',
      );
    }
  }

  Future<void> _uploadPhoto(File photo) async {
    await showPiliLoadingDialog(context, message: 'Mengupload foto profil...');

    try {
      final response = await _authService.uploadPhoto(photo: photo);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (response['success'] == true) {
        await showPiliDialog(
          context,
          icon: Icons.check,
          title: 'Berhasil',
          message: 'Foto profil berhasil diperbarui.',
        );
        setState(() {
          selectedImageFile = null;
        });
        _refreshProfile();
      } else {
        setState(() {
          selectedImageFile = null;
        });
        showPiliDialog(
          context,
          icon: Icons.error,
          title: 'Gagal',
          message: response['message'] ?? 'Gagal mengupload foto',
        );
      }
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      setState(() {
        selectedImageFile = null;
      });
      if (!mounted) return;
      showPiliDialog(
        context,
        icon: Icons.error,
        title: 'Error',
        message: 'Error: $e',
      );
    }
  }

  Future<void> _chooseImageSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _AnimatedPhotoButton(
                      icon: Icons.camera_alt,
                      label: 'Ambil Foto',
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AnimatedPhotoButton(
                      icon: Icons.image,
                      label: 'Dari Galeri',
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEEEE),
                    foregroundColor: AppColors.danger,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final user = snapshot.data?['user'];
          final name = user is Map ? (user['name'] ?? 'Nama Lengkap') : (user?.name ?? 'Nama Lengkap');
          final email = user is Map ? (user['email'] ?? '') : (user?.email ?? '');
          final photoUrl = user is Map
              ? (user['photo_url'] ?? user['photoUrl'])
              : (user?.photoUrl);
          
          // Format member since date
          String memberSinceText = 'Anggota sejak sekarang';
          final createdAt = user is Map ? user['created_at'] : user?.createdAt;
          if (createdAt != null) {
            try {
              final date = createdAt is String ? DateTime.parse(createdAt) : createdAt;
              final monthYear = DateFormat('MMMM yyyy').format(date);
              memberSinceText = 'Anggota sejak $monthYear';
            } catch (e) {
              memberSinceText = 'Anggota sejak sekarang';
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFD8A15F),
                      backgroundImage: selectedImageFile != null 
                          ? FileImage(selectedImageFile!) as ImageProvider
                          : (photoUrl != null ? NetworkImage(photoUrl) : null),
                      child: (selectedImageFile == null && photoUrl == null) 
                          ? const Icon(Icons.person, size: 62, color: Colors.white) 
                          : null,
                    ),
                    GestureDetector(
                      onTap: _chooseImageSource,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primaryBlue,
                        child: const Icon(
                          Icons.edit,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  memberSinceText,
                  style: const TextStyle(fontSize: 9, color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                // Nama Lengkap Card
                _ProfileCard(
                  label: 'Nama Lengkap',
                  value: name?.toString() ?? '',
                  icon: Icons.person_outline,
                  onTap: () async {
                    final updated = await showEditNameDialog(
                      context,
                      currentName: name?.toString() ?? '',
                    );
                    if (updated == true) {
                      _refreshProfile();
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Alamat Email Card
                _ProfileCard(
                  label: 'Alamat Email',
                  value: email?.toString() ?? '',
                  icon: Icons.mail_outline,
                  onTap: () async {
                    final updated = await showEditEmailDialog(
                      context,
                      currentEmail: email?.toString() ?? '',
                    );
                    if (updated == true) {
                      _refreshProfile();
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Ganti Kata Sandi Card
                _ProfileCard(
                  label: 'Ganti Kata Sandi',
                  value: '',
                  icon: Icons.key_outlined,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEEEE),
                      foregroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    onPressed: () => showLogoutDialog(context),
                    icon: const Icon(Icons.logout, size: 17),
                    label: const Text('Keluar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedPhotoButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedPhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_AnimatedPhotoButton> createState() => _AnimatedPhotoButtonState();
}

class _AnimatedPhotoButtonState extends State<_AnimatedPhotoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, size: 32, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 8),
            Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _ProfileCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value.isEmpty ? label : value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}
