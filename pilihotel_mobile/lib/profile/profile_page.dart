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
    showPiliLoadingDialog(context, message: 'Mengupload foto profil...');

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
    showPiliLoadingDialog(context, message: 'Mengupload foto profil...');

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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.text,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.text,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F3F6), height: 1),
        ),
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
          final name = user is Map
              ? (user['name'] ?? 'Nama Lengkap')
              : (user?.name ?? 'Nama Lengkap');
          final email = user is Map
              ? (user['email'] ?? '')
              : (user?.email ?? '');
          final photoUrl = user is Map
              ? (user['photo_url'] ?? user['photoUrl'])
              : (user?.photoUrl);
          final authProvider = user is Map
              ? (user['auth_provider'] ?? 'local')
              : (user?.authProvider ?? 'local');

          // Format member since date
          String memberSinceText = 'Anggota sejak sekarang';
          final createdAt = user is Map ? user['created_at'] : user?.createdAt;
          if (createdAt != null) {
            try {
              final date = createdAt is String
                  ? DateTime.parse(createdAt)
                  : createdAt;
              final monthYear = DateFormat('MMMM yyyy').format(date);
              memberSinceText = 'Anggota sejak $monthYear';
            } catch (e) {
              memberSinceText = 'Anggota sejak sekarang';
            }
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 26,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    color: const Color(0xFFE2E8F0),
                                    child: selectedImageFile != null
                                        ? Image.file(
                                            selectedImageFile!,
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                          )
                                        : (photoUrl != null &&
                                              photoUrl.isNotEmpty)
                                        ? Image.network(
                                            photoUrl,
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 96,
                                                    height: 96,
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 48,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            width: 96,
                                            height: 96,
                                            color: const Color(0xFFE2E8F0),
                                            child: const Icon(
                                              Icons.person,
                                              size: 48,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _chooseImageSource,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            memberSinceText,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Nama Lengkap Card
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Nama Lengkap',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _ProfileCard(
                            value: name?.toString() ?? '',
                            // // BORDER RADIUS UNTUK NAMA LENGKAP
                            // borderRadius: BorderRadius.circular(150),

                            // // WARNA BACKGROUND KARTU NAMA LENGKAP
                            // backgroundColor: const Color(0xFFF8FAFD),

                            // // WARNA GARIS TEPI / BORDER KARTU NAMA LENGKAP
                            // borderColor: const Color(0xFFE7EEF7),

                            // // WARNA TEKS KARTU NAMA LENGKAP
                            // textColor: AppColors.text,

                            // // WARNA CHEVRON (PANAH) KARTU NAMA LENGKAP
                            // chevronColor: AppColors.muted,
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
                          const SizedBox(height: 16),

                          // Alamat Email Card
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Alamat Email',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _ProfileCard(
                            // // BORDER RADIUS UNTUK EMAIL
                            // borderRadius: BorderRadius.circular(150),

                            // // WARNA BACKGROUND KARTU EMAIL
                            // backgroundColor: const Color(0xFFF8FAFD),

                            // // WARNA GARIS TEPI / BORDER KARTU EMAIL
                            // borderColor: const Color(0xFFE7EEF7),

                            // // WARNA TEKS KARTU EMAIL
                            // textColor: AppColors.text,

                            // // WARNA CHEVRON (PANAH) KARTU EMAIL
                            // chevronColor: AppColors.muted,
                            value: email?.toString() ?? '',
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

                          if (authProvider != 'google') ...[
                            const SizedBox(height: 16),
                            _ProfileCard(
                              value: 'Ganti Kata Sandi',
                              icon: Icons.key_outlined,

                              // // BORDER RADIUS UNTUK GANTI KATA SANDI
                              // borderRadius: BorderRadius.circular(12),

                              // // WARNA BACKGROUND KARTU GANTI KATA SANDI
                              // backgroundColor: const Color(0xFFF8FAFD),

                              // // WARNA GARIS TEPI / BORDER KARTU GANTI KATA SANDI
                              // borderColor: const Color(0xFFE7EEF7),

                              // // WARNA TEKS KARTU GANTI KATA SANDI
                              // textColor: AppColors.text,

                              // // WARNA IKON KUNCI KARTU GANTI KATA SANDI
                              // iconColor: AppColors.primaryBlue,

                              // // WARNA CHEVRON (PANAH) KARTU GANTI KATA SANDI
                              // chevronColor: AppColors.muted,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordPage(),
                                ),
                              ),
                            ),
                          ],

                          const Spacer(),
                          const SizedBox(height: 30),

                          // tombol logout
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFFEEEE),
                                foregroundColor: AppColors.danger,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), //border radius logout
                                ),
                              ),
                              onPressed: () => showLogoutDialog(context),
                              icon: const Icon(Icons.logout, size: 17),
                              label: const Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
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

class _AnimatedPhotoButtonState extends State<_AnimatedPhotoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
            Text(
              widget.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? chevronColor;

  const _ProfileCard({
    required this.value,
    this.icon,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.chevronColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          // WARNA BACKGROUND KARTU (DEFAULT)
          color: backgroundColor ?? AppColors.field,

          // BORDER RADIUS KARTU (DEFAULT)
          borderRadius: borderRadius ?? BorderRadius.circular(12),

          border: Border.all(
            // WARNA GARIS TEPI / BORDER KARTU (DEFAULT)
            color: borderColor ?? AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              // WARNA IKON KUNCI / LAINNYA (DEFAULT)
              Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  // WARNA TEKS KARTU (DEFAULT)
                  color: textColor ?? AppColors.text,
                ),
              ),
            ),
            // WARNA CHEVRON / PANAH KANAN (DEFAULT)
            Icon(
              Icons.chevron_right,
              color: chevronColor ?? AppColors.muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
