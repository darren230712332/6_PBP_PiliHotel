import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/custom_textfield.dart';
import '../core/widgets/logo.dart';
import '../core/widgets/primary_button.dart';
import 'register_page.dart';
import 'otp_page.dart';
import 'login_success_page.dart';

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
              const PiliLogoCard(size: 80),
              const SizedBox(height: 14),
              const Text(
                'PiliHotel',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Text(
                'Tingkatkan pengalaman perjalanan Anda',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Silakan masukkan detail Anda untuk masuk',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                label: 'Alamat Email',
                hint: 'contoh@hotelmail.com',
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
                hint: '******',
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
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
              OutlinedButton(
                onPressed: loading ? null : _loginWithGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'G',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Masuk dengan Google',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
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
                    onPressed: () =>
                        Navigator.push(context, _route(const RegisterPage())),
                    child: const Text(
                      'Daftar',
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
      final String name = (result['user'] as dynamic)?.name ?? 'Andi';
      final String? photoUrl = (result['user'] as dynamic)?.photoUrl;
      Navigator.pushAndRemoveUntil(
        context,
        _route(LoginSuccessPage(userName: name, photoUrl: photoUrl)),
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

    if (result['success'] == true) {
      setState(() => loading = false);
      final String name = (result['user'] as dynamic)?.name ?? 'Andi';
      final String? photoUrl = (result['user'] as dynamic)?.photoUrl;
      Navigator.pushAndRemoveUntil(
        context,
        _route(LoginSuccessPage(userName: name, photoUrl: photoUrl)),
        (_) => false,
      );
    } else if (result['needs_mock'] == true) {
      setState(() => loading = false);
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.g_mobiledata_rounded, color: AppColors.primaryBlue, size: 44),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Simulasi Google Sign-In',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sertifikat SHA-1 belum terdaftar di Firebase untuk perangkat ini (ApiException 10).\n\nApakah Anda ingin masuk menggunakan akun Google simulasi untuk demo/pengujian local?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() => loading = true);
                            
                            final mockResult = await _authService.loginWithMockGoogle();
                            
                            if (!context.mounted) return;
                            setState(() => loading = false);
                            
                            if (mockResult['success'] == true) {
                              final String name = (mockResult['user'] as dynamic)?.name ?? 'Andi';
                              final String? photoUrl = (mockResult['user'] as dynamic)?.photoUrl;
                              Navigator.pushAndRemoveUntil(
                                context,
                                _route(LoginSuccessPage(userName: name, photoUrl: photoUrl)),
                                (_) => false,
                              );
                            } else {
                              setState(() {
                                loginErrorMessage = mockResult['message']?.toString() ?? 'Login Google gagal';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Ya, Masuk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      setState(() {
        loading = false;
        loginErrorMessage = result['message']?.toString() ?? 'Login Google gagal';
      });
    }
  }
}
