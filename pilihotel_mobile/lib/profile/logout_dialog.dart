import 'package:flutter/material.dart';

import '../auth/splash_page.dart';
import '../core/colors.dart';
import '../core/widgets/primary_button.dart';

Future<void> showLogoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFFFE6E6),
              child: Icon(Icons.logout, color: AppColors.danger),
            ),
            const SizedBox(height: 14),
            const Text(
              'Keluar dari Akun?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            const Text(
              'Apakah Anda yakin ingin keluar dari akun PiliHotel Anda?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Ya, Keluar',
              color: AppColors.danger,
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    ),
  );
}
