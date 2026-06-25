import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/widgets/logo.dart';
import '../core/widgets/primary_button.dart';

/// Reusable success page scaffold for registration and login flows
class SuccessScaffold extends StatelessWidget {
  const SuccessScaffold({
    super.key,
    required this.title,
    required this.message,
    required this.button,
    required this.onPressed,
    this.photoUrl,
  });

  final String title;
  final String message;
  final String button;
  final VoidCallback onPressed;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 64, 32, 30),
          child: Column(
            children: [
              const SizedBox(height: 28),
              if (photoUrl != null && photoUrl!.isNotEmpty)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const PiliLogoCard(size: 80),
                    ),
                  ),
                )
              else
                const PiliLogoCard(size: 80),
              const SizedBox(height: 14),
              const Text(
                'PiliHotel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 34),
              PrimaryButton(
                text: button,
                icon: Icons.arrow_forward,
                iconOnRight: true,
                onPressed: onPressed,
              ),
              const Spacer(flex: 2),
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
