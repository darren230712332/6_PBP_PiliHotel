import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/custom_dialog.dart';

Future<bool> showEditEmailDialog(
  BuildContext context, {
  required String currentEmail,
}) async {
  final authService = AuthService();
  final controller = TextEditingController(text: currentEmail);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      bool loading = false;

      return StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALAMAT EMAIL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'contoh@email.com',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F8FC),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: loading
                          ? null
                          : () => Navigator.pop(context, false),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: loading
                          ? null
                          : () async {
                              final newEmail = controller.text.trim();
                              if (!newEmail.contains('@')) {
                                showPiliDialog(
                                  context,
                                  icon: Icons.error,
                                  title: 'Gagal',
                                  message: 'Format email tidak valid.',
                                );
                                return;
                              }

                              setStateDialog(() => loading = true);
                              await Future.delayed(const Duration(seconds: 2));
                              final result = await authService.updateProfile(
                                email: newEmail,
                              );
                              if (!context.mounted) return;
                              setStateDialog(() => loading = false);

                              if (result['success'] == true) {
                                Navigator.pop(context, true);
                                showPiliDialog(
                                  context,
                                  icon: Icons.check_circle,
                                  title: 'Simpan Berhasil',
                                  message: 'Perubahan email berhasil disimpan.',
                                );
                              } else {
                                showPiliDialog(
                                  context,
                                  icon: Icons.error,
                                  title: 'Gagal',
                                  message:
                                      result['message']?.toString() ??
                                      'Gagal mengubah email.',
                                );
                              }
                            },
                      child: Container(
                        width: 120,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          loading ? 'Menyimpan...' : 'Selanjutnya',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
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
    },
  );

  return result ?? false;
}
