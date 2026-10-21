class UserModel {
  final String uid;
  final String namaLengkap;
  final String email;
  final String noHp;
  final String role; // contoh: 'admin' atau 'customer'

  UserModel({
    required this.uid,
    required this.namaLengkap,
    required this.email,
    required this.noHp,
    required this.role,
  });

  // Menerima data dari Firestore (Map) dan mengubahnya menjadi objek UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      namaLengkap: map['namaLengkap'] ?? '',
      email: map['email'] ?? '',
      noHp: map['noHp'] ?? '',
      role: map['role'] ?? 'customer',
    );
  }

  // Mengubah objek UserModel menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'namaLengkap': namaLengkap,
      'email': email,
      'noHp': noHp,
      'role': role,
    };
  }
}
