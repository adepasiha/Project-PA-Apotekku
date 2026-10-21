import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:apotekku/provider/cart_provider.dart';
import 'package:apotekku/provider/customer_profile_provider.dart';
import 'package:apotekku/provider/transaction_history_provider.dart';
import 'package:apotekku/models/obat_model.dart';
import 'package:apotekku/services/auth_service.dart';
import 'package:apotekku/screens/auth/login_screen.dart';
import 'package:apotekku/utils/product_image.dart';
import 'package:apotekku/widgets/profile_avatar.dart';

import 'account_settings_screen.dart';
import 'checkout_screen.dart';
import 'shipping_address_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeCustomerContent(),
    const CartScreenContent(),
    const TransactionHistoryScreen(),
    const ProfileContent(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    final profile = context.read<CustomerProfileProvider>();
    final history = context.read<TransactionHistoryProvider>();
    try {
      await profile.loadCurrentUser();
      history.loadForCurrentUser();
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat data pelanggan: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sebagian data akun gagal dimuat dari server.'),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ==========================================
// KONTEN UTAMA HALAMAN BERANDA (CUSTOMER)
// ==========================================
class HomeCustomerContent extends StatefulWidget {
  const HomeCustomerContent({super.key});

  @override
  State<HomeCustomerContent> createState() => _HomeCustomerContentState();
}

class _HomeCustomerContentState extends State<HomeCustomerContent> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catalogSubscription;
  List<_Produk>? _firestoreProducts;
  Object? _catalogError;
  String? _selectedCategory;
  String _searchQuery = '';

  static const List<_Produk> _demoProducts = [
    _Produk(
      id: 'paracetamol',
      namaObat: 'Paracetamol 500mg',
      kategori: 'Obat Bebas',
      harga: 5000,
      stok: 50,
      imageAsset: 'assets/images/paracetamol.png',
    ),
    _Produk(
      id: 'ibuprofen',
      namaObat: 'Ibuprofen 400mg',
      kategori: 'Obat Bebas',
      harga: 8000,
      stok: 30,
      imageAsset: 'assets/images/ibuprofen.png',
    ),
    _Produk(
      id: 'obat-batuk',
      namaObat: 'Obat Batuk Sirup',
      kategori: 'Obat Bebas',
      harga: 12000,
      stok: 25,
      imageAsset: 'assets/images/herbakof.png',
    ),
    _Produk(
      id: 'vitamin-c',
      namaObat: 'Vitamin C 1000mg',
      kategori: 'Vitamin',
      harga: 25000,
      stok: 40,
      imageAsset: 'assets/images/vitamin_c.png',
    ),
    _Produk(
      id: 'vitamin-d',
      namaObat: 'Vitamin D3 1000 IU',
      kategori: 'Vitamin',
      harga: 18000,
      stok: 25,
      imageAsset: 'assets/images/vitamin_d3.png',
    ),
    _Produk(
      id: 'vitamin-b',
      namaObat: 'Vitamin B Kompleks',
      kategori: 'Vitamin',
      harga: 15000,
      stok: 35,
      imageAsset: 'assets/images/vitamin_b_kompleks.png',
    ),
    _Produk(
      id: 'amoxicillin',
      namaObat: 'Amoxicillin 500mg',
      kategori: 'Resep Dokter',
      harga: 12000,
      stok: 20,
      imageAsset: 'assets/images/amoxicillin.png',
    ),
    _Produk(
      id: 'amlodipine',
      namaObat: 'Amlodipine 5mg',
      kategori: 'Resep Dokter',
      harga: 10000,
      stok: 20,
      imageAsset: 'assets/images/amlodipine.png',
    ),
    _Produk(
      id: 'metformin',
      namaObat: 'Metformin 500mg',
      kategori: 'Resep Dokter',
      harga: 9000,
      stok: 15,
      imageAsset: 'assets/images/metformin.jpg',
    ),
    _Produk(
      id: 'jahe-merah',
      namaObat: 'Jahe Merah',
      kategori: 'Herbal',
      harga: 14000,
      stok: 30,
      imageAsset: 'assets/images/jahe_merah.png',
    ),
    _Produk(
      id: 'madu-herbal',
      namaObat: 'Madu Herbal',
      kategori: 'Herbal',
      harga: 30000,
      stok: 20,
      imageAsset: 'assets/images/madu_herbal.png',
    ),
    _Produk(
      id: 'kunyit-asam',
      namaObat: 'Kunyit Asam',
      kategori: 'Herbal',
      harga: 16000,
      stok: 24,
      imageAsset: 'assets/images/kunyit_asam.png',
    ),
    _Produk(
      id: 'antasida',
      namaObat: 'Antasida Doen',
      kategori: 'Obat Bebas',
      harga: 6000,
      stok: 30,
      imageAsset: 'assets/images/antasida.jpg',
    ),
    _Produk(
      id: 'loratadine',
      namaObat: 'Loratadine 10mg',
      kategori: 'Obat Bebas',
      harga: 11000,
      stok: 18,
      imageAsset: 'assets/images/loratadine.jpg',
    ),
    _Produk(
      id: 'vitamin-e',
      namaObat: 'Vitamin E 100 IU',
      kategori: 'Vitamin',
      harga: 22000,
      stok: 25,
      imageAsset: 'assets/images/vitamin_e.png',
    ),
    _Produk(
      id: 'zinc',
      namaObat: 'Zinc 20mg',
      kategori: 'Suplemen',
      harga: 13000,
      stok: 25,
      imageAsset: 'assets/images/zinc.png',
    ),
    _Produk(
      id: 'multivitamin',
      namaObat: 'Multivitamin Harian',
      kategori: 'Suplemen',
      harga: 28000,
      stok: 15,
      imageAsset: 'assets/images/multivitamin.jpg',
    ),
    _Produk(
      id: 'minyak-kayu-putih',
      namaObat: 'Minyak Kayu Putih',
      kategori: 'Herbal',
      harga: 17000,
      stok: 22,
      imageAsset: 'assets/images/minyak_kayu_putih.png',
    ),
  ];

  List<_Produk> get _products => _firestoreProducts?.isNotEmpty == true
      ? _firestoreProducts!
      : _demoProducts;

  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isEmpty) return;
    _catalogSubscription =
        FirebaseFirestore.instance.collection('obat').snapshots().listen(
      (snapshot) {
        final products = snapshot.docs.map((doc) {
          final obat = ObatModel.fromMap(doc.data(), doc.id);
          final requiresPrescription = obat.perluResep ||
              _requiresPrescription(obat.namaProduk, obat.kategori);
          return _Produk(
            id: obat.id,
            namaObat: obat.namaProduk,
            kategori: _displayCategory(
              obat.kategori,
              obat.namaProduk,
              requiresPrescription,
            ),
            harga: obat.harga.round(),
            stok: obat.stok,
            imageAsset: productImageAssetForName(obat.namaProduk),
            imageUrl: obat.gambarUrl.isEmpty ? null : obat.gambarUrl,
            perluResep: requiresPrescription,
          );
        }).toList();
        if (!mounted) return;
        setState(() {
          _firestoreProducts = products;
          _catalogError = null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _catalogError = error);
      },
    );
  }

  List<_Produk> get _visibleProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == null || product.kategori == _selectedCategory;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      if (query == 'obat') return product.kategori != 'Herbal';
      if (query == 'vitamin' || query == 'suplemen') {
        return product.kategori == 'Vitamin' || product.kategori == 'Suplemen';
      }
      return product.namaObat.toLowerCase().contains(query) ||
          product.kategori.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _catalogSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 18),

            // Bilah Pencarian
            TextField(
              key: const ValueKey('product-search'),
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  if (value.trim().isNotEmpty) {
                    _selectedCategory = null;
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari obat, vitamin, atau suplemen...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF2E7D32),
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 17),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFF43A047),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_catalogError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off_outlined, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Katalog online tidak tersedia. Produk demo ditampilkan.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            // Banner Promo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promo Sehat Bulan Ini!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Diskon hingga 20% untuk semua pembelian Vitamin C & Suplemen.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.local_pharmacy_rounded,
                    size: 54,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kategori Obat
            const Text(
              'Kategori Pilihan',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _KategoriItem(
                    icon: Icons.medication_rounded,
                    label: 'Obat Bebas',
                    isSelected: _selectedCategory == 'Obat Bebas',
                    onTap: () => _selectCategory('Obat Bebas'),
                  ),
                  _KategoriItem(
                    icon: Icons.health_and_safety_rounded,
                    label: 'Vitamin',
                    isSelected: _selectedCategory == 'Vitamin',
                    onTap: () => _selectCategory('Vitamin'),
                  ),
                  _KategoriItem(
                    icon: Icons.medical_services_rounded,
                    label: 'Resep Dokter',
                    isSelected: _selectedCategory == 'Resep Dokter',
                    onTap: () => _selectCategory('Resep Dokter'),
                  ),
                  _KategoriItem(
                    icon: Icons.spa_rounded,
                    label: 'Herbal',
                    isSelected: _selectedCategory == 'Herbal',
                    onTap: () => _selectCategory('Herbal'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daftar Produk Populer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Hasil pencarian'
                          : _selectedCategory == null
                              ? 'Produk Populer'
                              : 'Produk $_selectedCategory',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_visibleProducts.length} produk untuk kebutuhanmu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (_searchQuery.isEmpty && _selectedCategory == null)
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFF9A825),
                    size: 22,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (_visibleProducts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Produk tidak ditemukan',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coba kata kunci obat, vitamin, atau suplemen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.68,
                children: [
                  for (final product in _visibleProducts)
                    _ProdukCard(product: product),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F0E9)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang,',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                SizedBox(height: 3),
                Text(
                  'Pelanggan Setia',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Material(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                key: const ValueKey('home-cart-button'),
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  context
                      .findAncestorStateOfType<_HomeScreenState>()
                      ?._onItemTapped(1);
                },
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF2E7D32),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Item Kategori UI
class _KategoriItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _KategoriItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? const Color(0xFF2E7D32) : const Color(0xFF657568);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 82,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF81C784) : const Color(0xFFE8ECE8),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF1F7F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Produk {
  final String id;
  final String namaObat;
  final String kategori;
  final int harga;
  final int stok;
  final String? imageAsset;
  final String? imageUrl;
  final bool perluResep;

  const _Produk({
    required this.id,
    required this.namaObat,
    required this.kategori,
    required this.harga,
    this.stok = 20,
    this.imageAsset,
    this.imageUrl,
    this.perluResep = false,
  });
}

String _displayCategory(
  String rawCategory,
  String productName,
  bool requiresPrescription,
) {
  final value = '$rawCategory $productName'.toLowerCase();
  if (requiresPrescription) return 'Resep Dokter';
  if (value.contains('vitamin') ||
      value.contains('suplemen') ||
      value.contains('zinc')) {
    return 'Vitamin';
  }
  if (value.contains('herbal') ||
      value.contains('jahe') ||
      value.contains('madu') ||
      value.contains('kunyit') ||
      value.contains('kayu putih')) {
    return 'Herbal';
  }
  return 'Obat Bebas';
}

bool _requiresPrescription(String productName, String rawCategory) {
  final value = '$rawCategory $productName'.toLowerCase();
  return value.contains('resep') ||
      value.contains('antibiotik') ||
      value.contains('amoxicillin') ||
      value.contains('metformin') ||
      value.contains('amlodipine');
}

IconData _categoryIcon(String category) {
  return switch (category) {
    'Vitamin' || 'Suplemen' => Icons.health_and_safety_outlined,
    'Herbal' => Icons.spa_outlined,
    'Resep Dokter' => Icons.medical_services_outlined,
    _ => Icons.medication_outlined,
  };
}

String _formatRupiah(int amount) {
  return amount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
}

// Widget Kartu Produk Terhubung Provider
class _ProdukCard extends StatelessWidget {
  final _Produk product;

  const _ProdukCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8ECE8)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF193D20).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0xFFF3F8F3),
                    child: Center(
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  _productFallbackIcon(),
                            )
                          : product.imageAsset == null
                              ? _productFallbackIcon()
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    product.imageAsset!,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _productFallbackIcon(),
                                  ),
                                ),
                    ),
                  ),
                ),
                Positioned(
                  left: 9,
                  top: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.perluResep ? 'Resep dokter' : product.kategori,
                      style: const TextStyle(
                        color: Color(0xFF347B3B),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.namaObat,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF243027),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rp ${_formatRupiah(product.harga)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.stok > 0
                                ? 'Stok ${product.stok}'
                                : 'Stok habis',
                            style: TextStyle(
                              fontSize: 10,
                              color: product.stok > 0
                                  ? Colors.grey.shade600
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: product.stok > 0
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(11),
                      child: InkWell(
                        key: ValueKey('add-${product.id}'),
                        onTap: product.stok == 0
                            ? null
                            : () {
                                final quantity =
                                    cart.items[product.id]?.jumlah ?? 0;
                                if (quantity >= product.stok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Jumlah keranjang sudah mencapai stok.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                cart.addItem(
                                  product.id,
                                  product.namaObat,
                                  product.harga,
                                  perluResep: product.perluResep,
                                  stokTersedia: product.stok,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.namaObat} ditambahkan ke keranjang',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                        borderRadius: BorderRadius.circular(11),
                        child: const SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productFallbackIcon() {
    return Icon(
      _categoryIcon(product.kategori),
      size: 54,
      color: const Color(0xFF66A96B),
    );
  }
}

// ==========================================
// KONTEN HALAMAN KERANJANG (CUSTOMER)
// ==========================================
class CartScreenContent extends StatelessWidget {
  const CartScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Keranjang Belanja'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: cart.items.isEmpty
            ? const Center(
                child: Text(
                  'Keranjang Anda masih kosong',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final cartItem = cart.items.values.toList()[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.medication, color: Colors.white),
                    ),
                    title: Text(cartItem.namaObat),
                    subtitle: Text('Rp ${cartItem.harga} x ${cartItem.jumlah}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        cart.removeItem(cartItem.id);
                      },
                    ),
                  );
                },
              ),
        bottomNavigationBar: cart.items.isEmpty
            ? null
            : Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: Rp ${cart.totalAmount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ==========================================
// KONTEN HALAMAN PROFIL (CUSTOMER)
// ==========================================
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<CustomerProfileProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileAvatar(
              radius: 50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountSettingsScreen(),
                  ),
                );
              },
              showEditBadge: true,
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              profile.email,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: const Text('Pengaturan Akun'),
              subtitle: const Text('Nama dan nomor telepon'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountSettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('Alamat Pengiriman'),
              subtitle: Text('${profile.addressLabel} • ${profile.address}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ShippingAddressScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar (Logout)'),
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  context.read<TransactionHistoryProvider>().clearForSignOut();
                  context.read<CustomerProfileProvider>().reset();
                }
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
