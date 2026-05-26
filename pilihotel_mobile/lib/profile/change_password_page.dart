import 'package:flutter/material.dart';

import '../core/widgets/custom_appbar.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/custom_textfield.dart';
import '../core/widgets/loading_dialog.dart';
import '../core/widgets/primary_button.dart';
import '../core/services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _loading = false;
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      showPiliDialog(context, icon: Icons.error, title: 'Gagal', message: 'Semua field harus diisi.');
      return;
    }

    if (next.length < 6) {
      showPiliDialog(context, icon: Icons.error, title: 'Gagal', message: 'Password minimal 6 karakter.');
      return;
    }

    if (next != confirm) {
      showPiliDialog(context, icon: Icons.error, title: 'Gagal', message: 'Konfirmasi password tidak sama.');
      return;
    }

    setState(() => _loading = true);
    await showPiliLoadingDialog(context, message: 'Menyimpan kata sandi baru...');

    final res = await _authService.changePassword(
      currentPassword: current,
      newPassword: next,
      newPasswordConfirmation: confirm,
    );

    if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    setState(() => _loading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      showPiliDialog(
        context,
        icon: Icons.check_circle,
        title: 'Kata Sandi Berhasil Diubah',
        message: res['message'] ?? 'Gunakan kata sandi baru saat login berikutnya.',
      );
      // Optionally clear fields
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
    } else {
      showPiliDialog(
        context,
        icon: Icons.error,
        title: 'Gagal Mengubah Kata Sandi',
        message: res['message'] ?? 'Terjadi kesalahan',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Ganti Kata Sandi'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Atur Kata Sandi Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pastikan kata sandi baru Anda aman dan sulit ditebak oleh orang lain.',
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 22),
              CustomTextField(
                controller: _currentController,
                label: 'Kata Sandi Saat Ini',
                hint: 'Masukkan kata sandi lama',
                icon: Icons.lock_outline,
                obscure: _hideCurrent,
                suffix: IconButton(
                  icon: Icon(
                    _hideCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 17,
                  ),
                  onPressed: () => setState(() => _hideCurrent = !_hideCurrent),
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _newController,
                label: 'Kata Sandi Baru',
                hint: 'Minimal 6 karakter',
                icon: Icons.lock_outline,
                obscure: _hideNew,
                suffix: IconButton(
                  icon: Icon(
                    _hideNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 17,
                  ),
                  onPressed: () => setState(() => _hideNew = !_hideNew),
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _confirmController,
                label: 'Konfirmasi Kata Sandi Baru',
                hint: 'Ulangi kata sandi baru',
                icon: Icons.lock_outline,
                obscure: _hideConfirm,
                suffix: IconButton(
                  icon: Icon(
                    _hideConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 17,
                  ),
                  onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: _loading ? 'Menyimpan...' : 'Simpan',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
