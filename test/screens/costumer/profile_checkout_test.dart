import 'dart:typed_data';

import 'package:apotekku/provider/cart_provider.dart';
import 'package:apotekku/provider/customer_profile_provider.dart';
import 'package:apotekku/provider/transaction_history_provider.dart';
import 'package:apotekku/models/transaksi_model.dart';
import 'package:apotekku/screens/costumer/home_screen.dart';
import 'package:apotekku/screens/costumer/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _profileTestApp({
  required CartProvider cart,
  required CustomerProfileProvider profile,
  required Widget home,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CartProvider>.value(value: cart),
      ChangeNotifierProvider<CustomerProfileProvider>.value(value: profile),
      ChangeNotifierProvider<TransactionHistoryProvider>(
        create: (_) => TransactionHistoryProvider(),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

void main() {
  test('profile photo is available for the active demo session', () async {
    final profile = CustomerProfileProvider();
    final photoBytes = Uint8List.fromList([1, 2, 3]);

    await profile.updateProfilePhoto(
      bytes: photoBytes,
      contentType: 'image/jpeg',
    );

    expect(profile.profilePhotoBytes, photoBytes);
    expect(profile.profilePhotoUrl, isNull);
  });

  testWidgets('profile settings and address can be edited', (tester) async {
    final cart = CartProvider();
    final profile = CustomerProfileProvider();
    await tester.pumpWidget(
      _profileTestApp(
        cart: cart,
        profile: profile,
        home: const Scaffold(body: ProfileContent()),
      ),
    );

    await tester.tap(find.text('Pengaturan Akun'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Siti Aminah');
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();
    expect(profile.name, 'Siti Aminah');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alamat Pengiriman'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Jl. Kenanga No. 8, Bandung',
    );
    await tester.tap(find.text('Simpan Alamat'));
    await tester.pumpAndSettle();
    expect(profile.address, 'Jl. Kenanga No. 8, Bandung');
  });

  testWidgets('checkout uses cart total and the saved shipping address', (
    tester,
  ) async {
    final cart = CartProvider()..addItem('paracetamol', 'Paracetamol', 5000);
    final profile = CustomerProfileProvider();
    await tester.pumpWidget(
      _profileTestApp(
        cart: cart,
        profile: profile,
        home: const CartScreenContent(),
      ),
    );

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Tunai (Bayar di Tempat)'), findsOneWidget);
    expect(find.text('E-Wallet'), findsOneWidget);
    expect(find.text('GoPay'), findsNothing);
    expect(find.text('DANA'), findsNothing);
    expect(find.text('QRIS'), findsNothing);
    expect(find.text('Transfer Bank'), findsNothing);
    expect(find.text('Rp 5.000'), findsWidgets);
    expect(find.text('Rp 10.000'), findsWidgets);

    await tester.tap(find.textContaining('Rumah • Pengguna ApotekKu'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Jl. Kenanga No. 8, Bandung',
    );
    await tester.tap(find.text('Simpan Alamat'));
    await tester.pumpAndSettle();

    expect(profile.address, 'Jl. Kenanga No. 8, Bandung');
    expect(
      find.textContaining('Jl. Kenanga No. 8, Bandung'),
      findsOneWidget,
    );
  });

  testWidgets('prescription items can be ordered without uploading a recipe', (
    tester,
  ) async {
    final cart = CartProvider()
      ..addItem(
        'amoxicillin',
        'Amoxicillin',
        26000,
        perluResep: true,
      );
    final profile = CustomerProfileProvider();
    final history = TransactionHistoryProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider<CustomerProfileProvider>.value(
            value: profile,
          ),
          ChangeNotifierProvider<TransactionHistoryProvider>.value(
            value: history,
          ),
        ],
        child: const MaterialApp(home: CheckoutScreen()),
      ),
    );

    expect(find.text('Resep Dokter'), findsNothing);
    final placeOrderButton = find.widgetWithText(
      ElevatedButton,
      'Buat Pesanan',
    );
    expect(
        tester.widget<ElevatedButton>(placeOrderButton).onPressed, isNotNull);

    await tester.ensureVisible(placeOrderButton);
    await tester.tap(placeOrderButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pesanan berhasil dibuat'), findsOneWidget);
    expect(cart.items, isEmpty);
    expect(history.transactions, hasLength(1));
    expect(
      history.transactions.first.status,
      StatusTransaksi.menungguVerifikasiResep,
    );
  });

  testWidgets('completed checkout appears in transaction history', (
    tester,
  ) async {
    final cart = CartProvider()..addItem('vitamin-c', 'Vitamin C', 25000);
    final profile = CustomerProfileProvider();
    final history = TransactionHistoryProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider<CustomerProfileProvider>.value(
            value: profile,
          ),
          ChangeNotifierProvider<TransactionHistoryProvider>.value(
            value: history,
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('E-Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Nomor HP E-Wallet'), findsOneWidget);

    final placeOrderButton = find.text('Buat Pesanan');
    await tester.ensureVisible(placeOrderButton);
    await tester.pumpAndSettle();
    await tester.tap(placeOrderButton);
    await tester.pumpAndSettle();
    expect(find.text('Nomor HP E-Wallet wajib diisi'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nomor HP E-Wallet'),
      '081234567890',
    );
    await tester.ensureVisible(placeOrderButton);
    await tester.tap(placeOrderButton);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Lihat riwayat'));
    await tester.pumpAndSettle();

    expect(cart.items, isEmpty);
    expect(history.transactions, hasLength(1));
    expect(history.transactions.first.totalHarga, 30000);
    expect(history.transactions.first.metodePembayaran, 'E-Wallet');
    expect(history.transactions.first.nomorEwallet, '081234567890');

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Vitamin C'), findsOneWidget);
    expect(find.text(StatusTransaksi.menungguProses), findsWidgets);
  });
}
