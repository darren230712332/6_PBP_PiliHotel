import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/bottom_navbar.dart';
import '../core/widgets/custom_textfield.dart';
import '../core/widgets/logo.dart';
import '../core/widgets/primary_button.dart';
import 'register_page.dart';
import 'otp_page.dart';

/// Custom route transition with fade and slide animation
Route _route(Widget page) => PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(.05, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  },
);

/// Login page for user authentication
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

void showOtpSheet(BuildContext context) {
  showDialog(context: context, builder: (context) => const OtpPage());
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  String email = '';
  String password = '';
  bool hidden = true;
  bool loading = false;
  String? loginErrorMessage;

  String? get emailError {
    if (email.isEmpty) return null;
    return email.contains('@') ? null : 'Email tidak valid';
  }

  String? get passwordError {
    if (password.isEmpty) return null;
    return password.length >= 6 ? null : 'Kata sandi minimal 6 karakter';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 20),
          child: Column(
            children: [
              const PiliLogo(size: 58),
              const SizedBox(height: 10),
              const Text(
                'PiliHotel',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Tingkatkan pengalaman perjalanan Anda',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Silakan masukkan detail Anda untuk masuk',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              CustomTextField(
                label: 'Alamat Email',
                hint: 'contoh@hotmail.com',
                icon: Icons.mail_outline,
                errorText: emailError,
                onChanged: (v) => setState(() {
                  email = v;
                  loginErrorMessage = null;
                }),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Kata Sandi',
                hint: 'Minimal 6 karakter',
                icon: Icons.lock_outline,
                obscure: hidden,
                errorText: passwordError,
                onChanged: (v) => setState(() {
                  password = v;
                  loginErrorMessage = null;
                }),
                suffix: IconButton(
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 17,
                  ),
                  onPressed: () => setState(() => hidden = !hidden),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showOtpSheet(context),
                  child: const Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (loginErrorMessage != null) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFB8B8)),
                  ),
                  child: Text(
                    loginErrorMessage!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
              PrimaryButton(
                text: 'Masuk',
                onPressed: loading ? null : _login,
              ),
              const SizedBox(height: 23),
              const Text(
                'ATAU LANJUT DENGAN',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: loading ? null : _loginWithGoogle,
                icon: const Text(
                  'G',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                label: const Text(
                  'Masuk dengan Google',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun?',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.push(context, _route(const RegisterPage())),
                    child: const Text(
                      'Daftar',
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

  Future<void> _login() async {
    if (emailError != null || passwordError != null || email.isEmpty || password.isEmpty) {
      setState(() {
        loginErrorMessage = 'Lengkapi email dan kata sandi dengan benar.';
      });
      return;
    }

    setState(() {
      loading = true;
      loginErrorMessage = null;
    });
    final result = await _authService.login(email: email, password: password);

    if (!mounted) return;

    setState(() => loading = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        _route(const MainShell()),
        (_) => false,
      );
    } else {
      setState(() {
        loginErrorMessage = result['message']?.toString() ?? 'Login gagal';
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      loading = true;
      loginErrorMessage = null;
    });

    final result = await _authService.loginWithGoogle();

    if (!mounted) return;

    setState(() => loading = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        _route(const MainShell()),
        (_) => false,
      );
    } else {
      setState(() {
        loginErrorMessage = result['message']?.toString() ?? 'Login Google gagal';
      });
    }
  }
}
