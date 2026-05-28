import 'package:flutter/material.dart';

import '../core/widgets/bottom_navbar.dart';
import 'success_scaffold.dart';

/// Page displayed after successful login
class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({super.key});

  @override
  Widget build(BuildContext context) => SuccessScaffold(
    title: 'Login Berhasil!',
    message: 'Selamat datang Andi. Selamat merencanakan perjalanan Anda.',
    button: 'Ke Beranda',
    onPressed: () => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    ),
  );
}
