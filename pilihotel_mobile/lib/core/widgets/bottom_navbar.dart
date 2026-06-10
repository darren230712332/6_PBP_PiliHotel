import 'package:flutter/material.dart';

import '../../explore/explore_page.dart';
import '../../order/order_page.dart';
import '../../profile/profile_page.dart';
import '../colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int index = widget.initialIndex;

  final pages = const [ExplorePage(), OrderPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .07),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
             _Item(
              icon: Icons.search_rounded,
              label: 'EKSPLOR',
              active: index == 0,
              onTap: () => setState(() => index = 0),
            ),
            _Item(
              icon: Icons.luggage_outlined,
              label: 'PESANAN',
              active: index == 1,
              onTap: () => setState(() => index = 1),
            ),
            _Item(
              icon: Icons.person_outline,
              label: 'PROFIL',
              active: index == 2,
              onTap: () => setState(() => index = 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: active ? AppColors.primaryBlue : AppColors.muted,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.primaryBlue : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
