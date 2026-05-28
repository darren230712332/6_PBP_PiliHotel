import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/bottom_navbar.dart';
import '../core/widgets/custom_textfield.dart';
import '../core/widgets/logo.dart';
import '../core/widgets/primary_button.dart';
import 'splash_page.dart';
import 'register_success_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  String name = '';
  String phone = '';
  String email = '';
  String password = '';
  String passwordConfirmation = '';
  bool agreedToTerms = false;
  bool loading = false;

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
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7BA5), Color(0xFFFFD36D)],
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.add, color: Colors.white, size: 15),
                  ),
                ],
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
                obscure: true,
                suffix: Icon(Icons.visibility_outlined, size: 17),
                onChanged: (value) => password = value,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Konfirmasi Kata Sandi',
                hint: 'Ulangi kata sandi Anda',
                icon: Icons.lock_outline,
                obscure: true,
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
                    'Sudah punya akun?',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
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
        const SnackBar(content: Text('Setujui syarat dan kebijakan terlebih dahulu.')),
      );
      return;
    }

    if (name.isEmpty || email.isEmpty || password.isEmpty || passwordConfirmation.isEmpty) {
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
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Registrasi gagal')),
      );
    }
  }

}