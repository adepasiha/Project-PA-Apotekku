class ObatModel {
  final String id;
  final String namaProduk;
  final String kategori;
  final double harga;
  final int stok;
  final String tanggalExpired;
  final String deskripsi;
  final String gambarUrl;
  final bool perluResep;

  ObatModel({
    required this.id,
    required this.namaProduk,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.tanggalExpired,
    required this.deskripsi,
    required this.gambarUrl,
    this.perluResep = false,
  });

  // Menerima data dari Firestore (Map) dan mengubahnya menjadi objek ObatModel
  factory ObatModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ObatModel(
      id: documentId,
      namaProduk: map['namaProduk'] ?? '',
      kategori: map['kategori'] ?? '',
      harga: (map['harga'] ?? 0).toDouble(),
      stok: map['stok'] ?? 0,
      tanggalExpired: map['tanggalExpired'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      gambarUrl: map['gambarUrl'] ?? '',
      perluResep:
          map['perluResep'] == true || map['requiresPrescription'] == true,
    );
  }

  // Mengubah objek ObatModel menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'namaProduk': namaProduk,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'tanggalExpired': tanggalExpired,
      'deskripsi': deskripsi,
      'gambarUrl': gambarUrl,
      'perluResep': perluResep,
    };
  }
}
