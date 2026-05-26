import 'package:flutter/material.dart';

class AppColors {
  static const primaryBlue = Color(0xFF2F80ED);
  static const gradientTop = Color(0xFF6EC6FF);
  static const gradientBottom = Color(0xFF4A7DFF);
  static const text = Color(0xFF1C2430);
  static const muted = Color(0xFF8A96A8);
  static const border = Color(0xFFE7EEF7);
  static const field = Color(0xFFF8FAFD);
  static const danger = Color(0xFFE63838);
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFFFB84D);

  static const blueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientBottom],
  );
}
