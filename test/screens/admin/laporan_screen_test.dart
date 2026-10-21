import 'package:apotekku/screens/admin/laporan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('report page uses real report filters and clear empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LaporanScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Penjualan'), findsNWidgets(2));
    expect(find.text('Stok menipis'), findsNWidgets(2));
    expect(find.text('Kedaluwarsa'), findsNWidgets(2));
    expect(find.text('Proton'), findsNothing);
    expect(find.text('1 Apr 2025'), findsNothing);

    await tester.tap(find.text('Stok menipis').last);
    await tester.pumpAndSettle();
    expect(find.text('Laporan belum tersedia'), findsOneWidget);
  });
}
