import 'package:apotekku/models/transaksi_model.dart';
import 'package:apotekku/provider/transaction_history_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes legacy order statuses and restricts status transitions', () {
    expect(
      StatusTransaksi.normalize('Menunggu konfirmasi apotek'),
      StatusTransaksi.menungguProses,
    );
    expect(
      StatusTransaksi.normalize('Sedang diproses'),
      StatusTransaksi.diproses,
    );
    expect(
      StatusTransaksi.nextStatuses(StatusTransaksi.menungguProses),
      [StatusTransaksi.diproses, StatusTransaksi.dibatalkan],
    );
    expect(StatusTransaksi.nextStatuses(StatusTransaksi.selesai), isEmpty);
  });

  test('updates a purchase through the allowed status lifecycle', () async {
    final history = TransactionHistoryProvider();
    addTearDown(history.dispose);
    final transaction = TransaksiModel(
      id: 'TRX-1',
      userId: 'user-1',
      items: [],
      totalHarga: 10000,
      metodePembayaran: 'Tunai',
      status: 'Menunggu konfirmasi apotek',
      tanggal: '2026-10-20T10:00:00',
    );
    expect(
      transaction.toMap()['status'],
      'Menunggu konfirmasi apotek',
    );
    await history.addTransaction(transaction);

    await history.updateTransactionStatus(
      'TRX-1',
      StatusTransaksi.diproses,
    );
    expect(history.transactions.single.status, StatusTransaksi.diproses);

    await expectLater(
      history.updateTransactionStatus('TRX-1', StatusTransaksi.selesai),
      throwsStateError,
    );
  });

  test('adding the same transaction twice does not duplicate history',
      () async {
    final history = TransactionHistoryProvider();
    addTearDown(history.dispose);
    final transaction = TransaksiModel(
      id: 'TRX-duplicate',
      userId: 'user-1',
      items: [
        ItemTransaksi(
          obatId: 'jahe-merah',
          namaProduk: 'Jahe Merah',
          harga: 14000,
          jumlah: 1,
        ),
      ],
      totalHarga: 19000,
      metodePembayaran: 'Tunai',
      status: StatusTransaksi.menungguProses,
      tanggal: '2026-10-20T10:00:00',
    );

    await history.addTransaction(transaction);
    await history.addTransaction(transaction);

    expect(history.transactions, hasLength(1));
    expect(history.transactions.single.items.single.namaProduk, 'Jahe Merah');
  });

  test('parses incomplete and legacy transaction values without throwing', () {
    final transaction = TransaksiModel.fromMap(
      {
        'userId': 123,
        'items': [
          {
            'obatId': 42,
            'namaProduk': 'Vitamin C',
            'harga': '25000',
            'jumlah': '2',
          },
          'invalid item',
        ],
        'totalHarga': '50000',
        'status': null,
      },
      'transaction-1',
    );

    expect(transaction.id, 'transaction-1');
    expect(transaction.userId, '123');
    expect(transaction.totalHarga, 50000);
    expect(transaction.status, StatusTransaksi.menungguProses);
    expect(transaction.items, hasLength(1));
    expect(transaction.items.first.harga, 25000);
    expect(transaction.items.first.jumlah, 2);
  });
}
