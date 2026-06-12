import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/widgets/logo.dart';
import 'otp_page.dart';
import 'login_page.dart';
import 'login_success_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    Future.delayed(const Duration(milliseconds: 2850), () {
      if (mounted) {
        Navigator.pushReplacement(context, _route(const LoginPage()));
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.blueGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final t = controller.value;
              final ellipseOpacity = (t / .28).clamp(0.0, 1.0);
              final logoOpacity = ((t - .24) / .24).clamp(0.0, 1.0);
              final compact = ((t - .52) / .28).clamp(0.0, 1.0);
              final textOpacity = ((t - .68) / .20).clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset(0, -4 * compact),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: ellipseOpacity * (1 - compact),
                      child: Container(
                        width: 132,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: logoOpacity,
                      child: Transform.scale(
                        scale: 1 - (.44 * compact),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PiliLogo(size: 58),
                            Opacity(
                              opacity: textOpacity,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Text(
                                  'PiliHotel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

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



void showGoogleSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pilih akun',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          for (final name in [
            'Andi Setiawan',
            'Jane Smith',
            'Gunakan akun lain',
          ])
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.gradientTop.withValues(alpha: .22),
                child: Icon(
                  name.startsWith('Gunakan') ? Icons.add : Icons.person,
                  color: AppColors.primaryBlue,
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                name.startsWith('Gunakan')
                    ? 'Masuk dengan akun baru'
                    : '${name.split(' ').first.toLowerCase()}@gmail.com',
                style: const TextStyle(fontSize: 10),
              ),
              onTap: () => Navigator.pushReplacement(
                context,
                _route(const LoginSuccessPage()),
              ),
            ),
        ],
      ),
    ),
  );
}

void showOtpSheet(BuildContext context) {
  showDialog(context: context, builder: (context) => const OtpPage());
}
