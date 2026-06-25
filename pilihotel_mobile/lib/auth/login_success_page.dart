import 'package:flutter/material.dart';

import '../core/widgets/bottom_navbar.dart';
import 'success_scaffold.dart';

/// Page displayed after successful login
class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({super.key, this.userName = 'Andi', this.photoUrl});

  final String userName;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) => SuccessScaffold(
    title: 'Login Berhasil!',
    message: 'Selamat datang $userName!\nSelamat menggunakan Aplikasi\nPiliHotel',
    button: 'Ke Beranda',
    photoUrl: photoUrl,
    onPressed: () => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    ),
  );
}
