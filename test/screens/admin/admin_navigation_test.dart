import 'package:apotekku/provider/cart_provider.dart';
import 'package:apotekku/provider/customer_profile_provider.dart';
import 'package:apotekku/provider/transaction_history_provider.dart';
import 'package:apotekku/screens/admin/dashboard_admin.dart';
import 'package:apotekku/screens/admin/inventaris_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('inventory category chips filter products', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InventarisScreen()),
    );

    expect(find.text('Paracetamol 500 mg'), findsOneWidget);
    await tester.tap(find.text('Tablet'));
    await tester.pumpAndSettle();
    expect(find.text('Paracetamol 500 mg'), findsOneWidget);
    expect(find.text('Amoxicillin 500 mg'), findsNothing);

    await tester.tap(find.text('Kapsul'));
    await tester.pumpAndSettle();
    expect(find.text('Amoxicillin 500 mg'), findsOneWidget);
    expect(find.text('Paracetamol 500 mg'), findsNothing);

    await tester.tap(find.text('Sirup'));
    await tester.pumpAndSettle();
    expect(find.text('Obat Batuk Sirup'), findsOneWidget);
    expect(find.text('Amoxicillin 500 mg'), findsNothing);

    await tester.tap(find.text('Salep'));
    await tester.pumpAndSettle();
    expect(find.text('Salep Kulit 10 g'), findsOneWidget);
    expect(find.text('Obat Batuk Sirup'), findsNothing);
  });

  testWidgets('inventory shows product photos matched to product names', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: InventarisScreen()),
    );

    expect(find.text('Vitamin D3 1000 IU'), findsOneWidget);
    expect(find.text('Vitamin B Kompleks'), findsOneWidget);
    expect(find.text('Vitamin E 100 IU'), findsOneWidget);
    expect(find.text('Amlodipine 5 mg'), findsOneWidget);
    expect(find.text('Jahe Merah'), findsOneWidget);
    expect(find.text('Madu Herbal'), findsOneWidget);
    expect(find.text('Kunyit Asam'), findsOneWidget);
    expect(find.text('Minyak Kayu Putih'), findsOneWidget);
    expect(find.text('Antasida Doen'), findsOneWidget);
    expect(find.text('Loratadine 10 mg'), findsOneWidget);
    expect(find.text('Metformin 500 mg'), findsOneWidget);
    expect(find.text('Zinc 20 mg'), findsOneWidget);
    expect(find.text('Multivitamin Harian'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(18));
  });

  testWidgets('admin can add, edit, and delete an inventory product', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: InventarisScreen()),
    );

    await tester.tap(find.text('Tambah Produk'));
    await tester.pumpAndSettle();
    final stockField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(2),
    );
    expect(stockField.controller!.text, isEmpty);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(3))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.text('Rp '), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Produk Uji');
    await tester.enterText(find.byType(TextFormField).at(1), 'Produsen Uji');
    await tester.enterText(find.byType(TextFormField).at(2), '12');
    await tester.enterText(find.byType(TextFormField).at(3), '5000');
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Produk Uji'), findsOneWidget);

    final productActions = find.byKey(
      const ValueKey('product-actions-Produk Uji'),
    );
    await tester.ensureVisible(productActions);
    await tester.tap(productActions);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Produk Uji Edit');
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Produk Uji Edit'), findsOneWidget);
    expect(find.text('Produk Uji'), findsNothing);

    final editedProductActions = find.byKey(
      const ValueKey('product-actions-Produk Uji Edit'),
    );
    await tester.ensureVisible(editedProductActions);
    await tester.tap(editedProductActions);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();

    expect(find.text('Produk Uji Edit'), findsNothing);
  });

  testWidgets('admin home shortcuts open the matching screens', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => CustomerProfileProvider()),
          ChangeNotifierProvider(create: (_) => TransactionHistoryProvider()),
        ],
        child: const MaterialApp(home: DashboardAdmin()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cari Obat'));
    await tester.pumpAndSettle();
    expect(find.text('Inventaris Obat'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kategori'));
    await tester.pumpAndSettle();
    expect(find.text('Tablet'), findsOneWidget);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    expect(find.text('Keranjang Belanja'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Manajemen Pesanan'), findsOneWidget);
  });
}
