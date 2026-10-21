import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CustomerProfileProvider extends ChangeNotifier {
  String _name = 'Pengguna ApotekKu';
  String _email = 'customer@apotekku.com';
  String _phone = '081234567890';
  String _addressLabel = 'Rumah';
  String _recipientName = 'Pengguna ApotekKu';
  String _recipientPhone = '081234567890';
  String _address = 'Jl. Melati No. 12, Bandung';
  String? _profilePhotoUrl;
  Uint8List? _profilePhotoBytes;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get addressLabel => _addressLabel;
  String get recipientName => _recipientName;
  String get recipientPhone => _recipientPhone;
  String get address => _address;
  String? get profilePhotoUrl => _profilePhotoUrl;
  Uint8List? get profilePhotoBytes => _profilePhotoBytes;

  Future<void> loadCurrentUser() async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _email = user.email ?? _email;
    _profilePhotoUrl = user.photoURL;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data();
    if (data != null) {
      _name = data['namaLengkap'] as String? ?? _name;
      _phone = data['noHp'] as String? ?? _phone;
      final profilePhotoUrl = data['profileImageUrl'];
      if (profilePhotoUrl is String && profilePhotoUrl.isNotEmpty) {
        _profilePhotoUrl = profilePhotoUrl;
      }
      final addressData = data['alamatPengiriman'];
      if (addressData is Map<String, dynamic>) {
        _addressLabel = addressData['label'] as String? ?? _addressLabel;
        _recipientName =
            addressData['namaPenerima'] as String? ?? _recipientName;
        _recipientPhone =
            addressData['noHpPenerima'] as String? ?? _recipientPhone;
        _address = addressData['alamat'] as String? ?? _address;
      }
    }
    notifyListeners();
  }

  Future<void> updateProfilePhoto({
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (bytes.isEmpty || bytes.lengthInBytes > 5 * 1024 * 1024) {
      throw ArgumentError('Foto profil harus berukuran maksimal 5 MB.');
    }

    final user = _signedInUser;
    if (user == null) {
      _profilePhotoBytes = Uint8List.fromList(bytes);
      _profilePhotoUrl = null;
      notifyListeners();
      return;
    }

    final photoRef =
        FirebaseStorage.instance.ref('profile_images/${user.uid}/profile');
    await photoRef.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    final photoUrl = await photoRef.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'profileImageUrl': photoUrl,
    }, SetOptions(merge: true));

    _profilePhotoBytes = null;
    _profilePhotoUrl = photoUrl;
    notifyListeners();
  }

  Future<void> updateAccount({
    required String name,
    required String phone,
  }) async {
    final receiverUsesAccount = _recipientName == _name;
    final user = _signedInUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'namaLengkap': name.trim(),
        'noHp': phone.trim(),
      }, SetOptions(merge: true));
    }
    _name = name.trim();
    _phone = phone.trim();
    if (receiverUsesAccount) {
      _recipientName = _name;
      _recipientPhone = _phone;
    }
    notifyListeners();
  }

  Future<void> updateAddress({
    required String label,
    required String recipientName,
    required String recipientPhone,
    required String address,
  }) {
    final user = _signedInUser;
    if (user != null) {
      return _saveAddress(
        user.uid,
        label: label,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        address: address,
      );
    }
    _applyAddress(
      label: label,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      address: address,
    );
    return Future<void>.value();
  }

  User? get _signedInUser {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> _saveAddress(
    String userId, {
    required String label,
    required String recipientName,
    required String recipientPhone,
    required String address,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'alamatPengiriman': {
        'label': label.trim(),
        'namaPenerima': recipientName.trim(),
        'noHpPenerima': recipientPhone.trim(),
        'alamat': address.trim(),
      },
    }, SetOptions(merge: true));
    _applyAddress(
      label: label,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      address: address,
    );
  }

  void _applyAddress({
    required String label,
    required String recipientName,
    required String recipientPhone,
    required String address,
  }) {
    _addressLabel = label.trim();
    _recipientName = recipientName.trim();
    _recipientPhone = recipientPhone.trim();
    _address = address.trim();
    notifyListeners();
  }

  String get customerId => _signedInUser?.uid ?? 'demo-customer';

  void reset() {
    _name = 'Pengguna ApotekKu';
    _email = 'customer@apotekku.com';
    _phone = '081234567890';
    _addressLabel = 'Rumah';
    _recipientName = 'Pengguna ApotekKu';
    _recipientPhone = '081234567890';
    _address = 'Jl. Melati No. 12, Bandung';
    _profilePhotoUrl = null;
    _profilePhotoBytes = null;
    notifyListeners();
  }
}
