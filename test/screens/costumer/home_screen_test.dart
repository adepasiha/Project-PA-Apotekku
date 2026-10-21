import 'package:apotekku/provider/cart_provider.dart';
import 'package:apotekku/screens/costumer/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(
          home: Scaffold(body: HomeCustomerContent()),
        ),
      ),
    );
  }

  testWidgets('each category displays its products when tapped', (
    tester,
  ) async {
    await pumpHome(tester);

    const categoryProducts = {
      'Obat Bebas': 'Paracetamol 500mg',
      'Vitamin': 'Vitamin C 1000mg',
      'Resep Dokter': 'Amoxicillin 500mg',
      'Herbal': 'Jahe Merah',
    };

    for (final entry in categoryProducts.entries) {
      await tester.ensureVisible(find.text(entry.key).first);
      await tester.tap(find.text(entry.key).first);
      await tester.pumpAndSettle();

      expect(find.text('Produk ${entry.key}'), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('popular products include images and show more than four items', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Produk Populer'), findsOneWidget);
    expect(find.text('Paracetamol 500mg'), findsOneWidget);
    expect(find.text('Jahe Merah'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(18));
  });

  testWidgets('search filters products by name and product type', (
    tester,
  ) async {
    await pumpHome(tester);
    final searchField = find.byKey(const ValueKey('product-search'));

    await tester.enterText(searchField, 'Paracetamol');
    await tester.pumpAndSettle();
    expect(find.text('Paracetamol 500mg'), findsOneWidget);
    expect(find.text('Vitamin C 1000mg'), findsNothing);

    await tester.enterText(searchField, 'suplemen');
    await tester.pumpAndSettle();
    expect(find.text('Hasil pencarian'), findsOneWidget);
    expect(find.text('Zinc 20mg'), findsOneWidget);
    expect(find.text('Multivitamin Harian'), findsOneWidget);
    expect(find.text('Paracetamol 500mg'), findsNothing);
  });
}
