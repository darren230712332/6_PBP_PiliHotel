import 'package:flutter/material.dart';

import '../colors.dart';
import 'primary_button.dart';

Future<void> showPiliDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  String buttonText = 'Selesai',
  VoidCallback? onPressed,
  Color color = AppColors.success,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: color.withValues(alpha: .16),
              child: Icon(icon, color: color, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              text: buttonText,
              onPressed: onPressed ?? () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}
