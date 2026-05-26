import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/custom_textfield.dart';

Future<bool> showEditEmailDialog(BuildContext context, {required String currentEmail}) async {
  final authService = AuthService();
  final controller = TextEditingController(text: currentEmail);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      bool loading = false;

      return StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: controller,
                  label: 'ALAMAT EMAIL',
                  hint: 'contoh@email.com',
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: loading ? null : () => Navigator.pop(context, false),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 120,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: loading
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
                                final result = await authService.updateProfile(email: newEmail);
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
                                    message: result['message']?.toString() ?? 'Gagal mengubah email.',
                                  );
                                }
                              },
                        child: Text(
                          loading ? 'Menyimpan...' : 'Simpan',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
