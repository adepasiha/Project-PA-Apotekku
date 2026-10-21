import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../provider/customer_profile_provider.dart';
import '../../widgets/profile_avatar.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<CustomerProfileProvider>();
    _nameController = TextEditingController(text: profile.name);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<CustomerProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ProfileAvatar(
                radius: 42,
                onTap: _isUploadingPhoto ? null : _pickProfilePhoto,
                showEditBadge: true,
                isLoading: _isUploadingPhoto,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ketuk foto untuk mengganti gambar profil',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama lengkap',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama lengkap wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: profile.email,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                helperText: 'Email akun tidak dapat diubah di halaman ini',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor telepon',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nomor telepon wajib diisi'
                  : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final profile = context.read<CustomerProfileProvider>();
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) _showMessage('Ukuran foto profil maksimal 5 MB.');
        return;
      }

      setState(() => _isUploadingPhoto = true);
      await profile.updateProfilePhoto(
        bytes: bytes,
        contentType: image.mimeType ?? 'image/jpeg',
      );
      if (!mounted) return;
      _showMessage(
        Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null
            ? 'Foto profil diperbarui untuk sesi ini.'
            : 'Foto profil berhasil disimpan.',
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      _showMessage(
        'Gagal menyimpan foto profil: ${error.message ?? error.code}',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal memilih atau menyimpan foto profil: $error');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await context.read<CustomerProfileProvider>().updateAccount(
            name: _nameController.text,
            phone: _phoneController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informasi akun berhasil disimpan')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan informasi akun: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
