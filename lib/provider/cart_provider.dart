import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String namaObat;
  final int harga;
  final bool perluResep;
  final int stokTersedia;
  int jumlah;

  CartItem({
    required this.id,
    required this.namaObat,
    required this.harga,
    this.perluResep = false,
    this.stokTersedia = 999,
    this.jumlah = 1,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalAmount {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.harga * cartItem.jumlah;
    });
    return total;
  }

  void addItem(
    String productId,
    String namaObat,
    int harga, {
    bool perluResep = false,
    int stokTersedia = 999,
  }) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          namaObat: existingItem.namaObat,
          harga: existingItem.harga,
          perluResep: existingItem.perluResep,
          stokTersedia: stokTersedia,
          jumlah: existingItem.jumlah + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          namaObat: namaObat,
          harga: harga,
          perluResep: perluResep,
          stokTersedia: stokTersedia,
          jumlah: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
