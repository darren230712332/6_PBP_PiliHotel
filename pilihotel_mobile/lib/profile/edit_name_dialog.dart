import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/custom_textfield.dart';

Future<bool> showEditNameDialog(BuildContext context, {required String currentName}) async {
  final authService = AuthService();
  final controller = TextEditingController(text: currentName);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      bool loading = false;

      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ubah Nama',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: controller,
                    label: 'NAMA LENGKAP',
                    hint: 'Masukkan nama lengkap',
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
                                  final newName = controller.text.trim();
                                  if (newName.isEmpty) {
                                    showPiliDialog(
                                      context,
                                      icon: Icons.error,
                                      title: 'Gagal',
                                      message: 'Nama tidak boleh kosong.',
                                    );
                                    return;
                                  }

                                  setStateDialog(() => loading = true);
                                  final updateResult = await authService.updateProfile(name: newName);
                                  if (!context.mounted) return;
                                  setStateDialog(() => loading = false);

                                  if (updateResult['success'] == true) {
                                    Navigator.pop(context, true);
                                    showPiliDialog(
                                      context,
                                      icon: Icons.check_circle,
                                      title: 'Simpan Berhasil',
                                      message: 'Perubahan nama profil Anda telah berhasil disimpan.',
                                    );
                                  } else {
                                    showPiliDialog(
                                      context,
                                      icon: Icons.error,
                                      title: 'Gagal',
                                      message: updateResult['message']?.toString() ?? 'Gagal mengubah nama.',
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
          );
        },
      );
    },
  );

  return result ?? false;
}
