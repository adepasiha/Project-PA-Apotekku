import 'package:flutter/material.dart';

import 'inventaris_screen.dart';
import 'pesanan_screen.dart';
import 'laporan_screen.dart';
import '../costumer/home_screen.dart';
import '../auth/login_screen.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _currentIndex = 0;
  bool _focusInventorySearch = false;

  void _showInventory({bool focusSearch = false}) {
    setState(() {
      _currentIndex = 1;
      _focusInventorySearch = focusSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (_currentIndex) {
      0 => AdminHomeContent(
          onSearchMedicine: () => _showInventory(focusSearch: true),
          onOpenCategories: () => _showInventory(),
          onOpenCart: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const CartScreenContent(),
              ),
            );
          },
          onOpenHistory: () => setState(() => _currentIndex = 2),
        ),
      1 => InventarisScreen(
          key: ValueKey(_focusInventorySearch),
          focusSearch: _focusInventorySearch,
        ),
      2 => const PesananScreen(),
      _ => const LaporanScreen(),
    };

    return Scaffold(
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventaris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}

// Widget Konten Beranda Admin
class AdminHomeContent extends StatelessWidget {
  final VoidCallback onSearchMedicine;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenHistory;

  const AdminHomeContent({
    super.key,
    required this.onSearchMedicine,
    required this.onOpenCategories,
    required this.onOpenCart,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Admin',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Selamat Datang di ApotekKu',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Total Transaksi Hari Ini
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Transaksi Hari Ini',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rp 245.000',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Pintasan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShortcutItem(
                  context,
                  Icons.search,
                  'Cari Obat',
                  onSearchMedicine,
                ),
                _buildShortcutItem(
                  context,
                  Icons.category,
                  'Kategori',
                  onOpenCategories,
                ),
                _buildShortcutItem(
                  context,
                  Icons.shopping_cart,
                  'Keranjang',
                  onOpenCart,
                ),
                _buildShortcutItem(
                  context,
                  Icons.history,
                  'Riwayat',
                  onOpenHistory,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Informasi Stok
            const Text(
              'Informasi Stok',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStockCard('Total Produk', '248', Colors.blue),
                const SizedBox(width: 12),
                _buildStockCard('Stok Menipis', '12', Colors.orange),
                const SizedBox(width: 12),
                _buildStockCard('Stok Habis', '3', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
