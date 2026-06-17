import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/custom_textfield.dart';
import '../core/widgets/primary_button.dart';
import 'register_success_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  File? selectedImageFile;

  String name = '';
  String phone = '';
  String email = '';
  String password = '';
  String passwordConfirmation = '';
  bool hidePassword = true;
  bool hidePasswordConfirmation = true;
  bool agreedToTerms = false;
  bool loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final result = await _imagePicker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 60,
    );
    if (result != null) {
      setState(() {
        selectedImageFile = File(result.path);
      });
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Text('Buat Akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _chooseImageSource,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2E8F0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: selectedImageFile != null
                            ? Image.file(
                                selectedImageFile!,
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF7BA5),
                                      Color(0xFFFFD36D)
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(
                        selectedImageFile != null ? Icons.edit : Icons.add,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Atur profil Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Tambahkan foto untuk mempersonalisasi akun Anda',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap Anda',
                icon: Icons.person_outline,
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Nomor Telepon',
                hint: '08123456789',
                icon: Icons.phone_outlined,
                onChanged: (value) => phone = value,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Email',
                hint: 'contoh@gmail.com',
                icon: Icons.mail_outline,
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Kata Sandi',
                hint: 'Min. 6 karakter',
                icon: Icons.lock_outline,
                obscure: hidePassword,
                suffix: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 17,
                  ),
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                ),
                onChanged: (value) => password = value,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Konfirmasi Kata Sandi',
                hint: 'Ulangi kata sandi Anda',
                icon: Icons.lock_outline,
                obscure: hidePasswordConfirmation,
                suffix: IconButton(
                  icon: Icon(
                    hidePasswordConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 17,
                  ),
                  onPressed: () => setState(
                    () => hidePasswordConfirmation = !hidePasswordConfirmation,
                  ),
                ),
                onChanged: (value) => passwordConfirmation = value,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreedToTerms,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) =>
                        setState(() => agreedToTerms = value ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => agreedToTerms = !agreedToTerms),
                        child: const Text(
                          'Dengan mendaftar, Anda menyetujui Syarat Layanan dan Kebijakan Privasi kami.',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              PrimaryButton(
                text: 'Daftar',
                onPressed: loading ? null : _register,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setujui syarat dan kebijakan terlebih dahulu.'),
        ),
      );
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data registrasi.')),
      );
      return;
    }

    if (password != passwordConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak sesuai.')),
      );
      return;
    }

    setState(() => loading = true);
    final result = await _authService.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      photo: selectedImageFile,
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RegisterSuccessPage()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Registrasi gagal'),
        ),
      );
    }
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
