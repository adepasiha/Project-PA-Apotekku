class ItemTransaksi {
  final String obatId;
  final String namaProduk;
  final double harga;
  final int jumlah;
  final bool perluResep;

  ItemTransaksi({
    required this.obatId,
    required this.namaProduk,
    required this.harga,
    required this.jumlah,
    this.perluResep = false,
  });

  factory ItemTransaksi.fromMap(Map<String, dynamic> map) {
    return ItemTransaksi(
      obatId: _readString(map['obatId']),
      namaProduk: _readString(map['namaProduk']),
      harga: _readDouble(map['harga']),
      jumlah: _readInt(map['jumlah']),
      perluResep: map['perluResep'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'obatId': obatId,
      'namaProduk': namaProduk,
      'harga': harga,
      'jumlah': jumlah,
      'perluResep': perluResep,
    };
  }
}

String _readString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value is String ? value : value.toString();
}

double _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _readInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class StatusTransaksi {
  static const menungguProses = 'Menunggu proses';
  static const menungguVerifikasiResep = 'Menunggu verifikasi resep';
  static const diproses = 'Diproses';
  static const dikirim = 'Dikirim';
  static const selesai = 'Selesai';
  static const dibatalkan = 'Dibatalkan';

  static const values = [
    menungguProses,
    menungguVerifikasiResep,
    diproses,
    dikirim,
    selesai,
    dibatalkan,
  ];

  static const filters = ['Semua', ...values];

  static String normalize(Object? value) {
    final status = _readString(value).trim();
    return switch (status.toLowerCase()) {
      'menunggu konfirmasi apotek' ||
      'menunggu proses' ||
      'pending' =>
        menungguProses,
      'menunggu verifikasi resep' ||
      'menunggu resep' ||
      'prescription verification' =>
        menungguVerifikasiResep,
      'diproses' || 'sedang diproses' || 'processing' => diproses,
      'dikirim' || 'dalam pengiriman' || 'shipped' => dikirim,
      'selesai' || 'completed' => selesai,
      'dibatalkan' || 'cancelled' || 'canceled' => dibatalkan,
      '' => menungguProses,
      _ => status,
    };
  }

  static List<String> nextStatuses(String status) {
    return switch (normalize(status)) {
      menungguProses => [diproses, dibatalkan],
      menungguVerifikasiResep => [menungguProses, dibatalkan],
      diproses => [dikirim, dibatalkan],
      dikirim => [selesai, dibatalkan],
      _ => const [],
    };
  }
}

class TransaksiModel {
  final String id;
  final String userId;
  final List<ItemTransaksi> items;
  final double totalHarga;
  final String metodePembayaran;
  final String status; // contoh: 'Selesai', 'Diproses', 'Dibatalkan'
  final String tanggal;
  final String alamatPengiriman;
  final String statusPembayaran;
  final String? buktiResepPath;
  final String? nomorEwallet;

  TransaksiModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.status,
    required this.tanggal,
    this.alamatPengiriman = '',
    this.statusPembayaran = 'Menunggu pembayaran',
    this.buktiResepPath,
    this.nomorEwallet,
  });

  TransaksiModel copyWith({String? status}) {
    return TransaksiModel(
      id: id,
      userId: userId,
      items: items,
      totalHarga: totalHarga,
      metodePembayaran: metodePembayaran,
      status: status ?? this.status,
      tanggal: tanggal,
      alamatPengiriman: alamatPengiriman,
      statusPembayaran: statusPembayaran,
      buktiResepPath: buktiResepPath,
      nomorEwallet: nomorEwallet,
    );
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map, String documentId) {
    final rawItems = map['items'];
    final parsedItems = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => ItemTransaksi.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <ItemTransaksi>[];

    return TransaksiModel(
      id: documentId,
      userId: _readString(map['userId']),
      items: parsedItems,
      totalHarga: _readDouble(map['totalHarga']),
      metodePembayaran: _readString(map['metodePembayaran']),
      status: StatusTransaksi.normalize(map['status']),
      tanggal: _readString(map['tanggal']),
      alamatPengiriman: _readString(map['alamatPengiriman']),
      statusPembayaran: _readString(
        map['statusPembayaran'],
        fallback: 'Menunggu pembayaran',
      ),
      buktiResepPath: map['buktiResepPath'] is String
          ? map['buktiResepPath'] as String
          : null,
      nomorEwallet:
          map['nomorEwallet'] is String ? map['nomorEwallet'] as String : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalHarga': totalHarga,
      'metodePembayaran': metodePembayaran,
      'status': status,
      'tanggal': tanggal,
      'alamatPengiriman': alamatPengiriman,
      'statusPembayaran': statusPembayaran,
      if (buktiResepPath != null) 'buktiResepPath': buktiResepPath,
      if (nomorEwallet != null) 'nomorEwallet': nomorEwallet,
    };
  }
}
