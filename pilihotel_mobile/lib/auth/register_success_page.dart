import 'package:flutter/material.dart';

import 'login_page.dart';
import 'success_scaffold.dart';

/// Page displayed after successful registration
class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) => SuccessScaffold(
    title: 'Pendaftaran Berhasil!',
    message:
        'Akun Anda telah berhasil dibuat. Selamat bergabung dengan PiliHotel.',
    button: 'Kembali ke Login',
    onPressed: () => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    ),
  );
}
