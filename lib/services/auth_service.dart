import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan pengguna saat ini
  User? get currentUser => _auth.currentUser;

  // Fungsi Login
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Ambil data detail user dari Firestore
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } else {
          // Jika dokumen belum ada di Firestore, buat data default
          UserModel newUser = UserModel(
            uid: credential.user!.uid,
            namaLengkap: 'Pengguna',
            email: email,
            noHp: '-',
            role: 'customer',
          );
          await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set(newUser.toMap());
          return newUser;
        }
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi Register
  Future<UserModel?> register({
    required String email,
    required String password,
    required String namaLengkap,
    required String noHp,
    required String role,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        UserModel newUser = UserModel(
          uid: credential.user!.uid,
          namaLengkap: namaLengkap,
          email: email,
          noHp: noHp,
          role: role,
        );

        // Simpan data user ke Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser.toMap());

        await _auth.signOut();
        return newUser;
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> signOut() => logout();
}
