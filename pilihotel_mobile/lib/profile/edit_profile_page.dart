import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/auth_service.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/custom_textfield.dart';
import '../core/widgets/loading_dialog.dart';
import '../core/widgets/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _pickedImage;
  String? _currentPhotoUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final res = await _authService.getProfile();
    if (res['success'] == true && mounted) {
      final user = res['user'];
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _currentPhotoUrl = user.photoUrl;
      setState(() {});
    }
  }

  Future<void> _pickImage([ImageSource source = ImageSource.camera]) async {
    final result = await _imagePicker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (result != null) {
      setState(() => _pickedImage = File(result.path));
    }
  }

  Future<void> _chooseImageSource() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
  }

  Future<void> _save() async {
    if (_loading) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() => _loading = true);
    showPiliLoadingDialog(context, message: 'Menyimpan perubahan profil...');

    try {
      // Run photo upload and profile update in parallel
      final futures = <Future<dynamic>>[
        _authService.updateProfile(
          name: name.isNotEmpty ? name : null,
          email: email.isNotEmpty ? email : null,
        ),
      ];

      if (_pickedImage != null) {
        futures.insert(0, _authService.uploadPhoto(photo: _pickedImage!));
      }

      final results = await Future.wait(futures);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      final photoRes = _pickedImage != null ? results[0] as Map<String, dynamic> : null;
      final updateRes = results[_pickedImage != null ? 1 : 0] as Map<String, dynamic>;

      if ((photoRes == null || photoRes['success'] == true) && updateRes['success'] == true) {
        await showPiliDialog(
          context,
          icon: Icons.check,
          title: 'Simpan Berhasil',
          message: 'Perubahan profil Anda telah berhasil disimpan.',
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        final message = (photoRes != null && photoRes['success'] == false)
            ? photoRes['message']
            : updateRes['message'];
        showPiliDialog(
          context,
          icon: Icons.error,
          title: 'Gagal',
          message: message ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!mounted) return;
      showPiliDialog(
        context,
        icon: Icons.error,
        title: 'Gagal',
        message: 'Error: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profil Saya'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          children: [
            GestureDetector(
              onTap: _chooseImageSource,
              child: ClipOval(
                child: Container(
                  width: 96,
                  height: 96,
                  color: const Color(0xFFD8A15F),
                  child: _pickedImage != null
                      ? Image.file(
                          _pickedImage!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        )
                      : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                          ? Image.network(
                              _currentPhotoUrl!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.camera_alt, size: 34, color: Colors.white),
                            )
                          : const Icon(Icons.camera_alt, size: 34, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ketuk foto untuk kamera atau galeri',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              hint: 'Darren',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _emailController,
              label: 'Alamat Email',
              hint: 'andi.setiawan@gmail.com',
              icon: Icons.mail_outline,
            ),
            const Spacer(),
            PrimaryButton(
              text: _loading ? 'Menyimpan...' : 'Simpan',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
