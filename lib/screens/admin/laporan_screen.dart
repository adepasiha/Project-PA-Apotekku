import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../models/transaksi_model.dart';
import '../../utils/product_image.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  static const _filters = [
    'Semua',
    'Penjualan',
    'Stok menipis',
    'Kedaluwarsa',
  ];
  static const _lowStockLimit = 10;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _salesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _inventorySubscription;
  List<TransaksiModel> _transactions = [];
  List<_InventoryItem> _inventory = [];
  final List<String> _errors = [];
  String _selectedFilter = 'Semua';
  DateTime? _selectedDate;
  bool _salesLoaded = false;
  bool _inventoryLoaded = false;

  bool get _isLoading => !_salesLoaded || !_inventoryLoaded;
  bool get _hasFirebase => Firebase.apps.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_hasFirebase) {
      _subscribeToReports();
    } else {
      _salesLoaded = true;
      _inventoryLoaded = true;
      _errors.add('Firebase belum dikonfigurasi; laporan membutuhkan koneksi.');
    }
  }

  @override
  void dispose() {
    _salesSubscription?.cancel();
    _inventorySubscription?.cancel();
    super.dispose();
  }

  void _subscribeToReports() {
    if (FirebaseAuth.instance.currentUser == null) {
      setState(() {
        _salesLoaded = true;
        _inventoryLoaded = true;
        _errors.add('Login diperlukan untuk memuat laporan.');
      });
      return;
    }

    _salesSubscription =
        FirebaseFirestore.instance.collection('transaksi').snapshots().listen(
      (snapshot) {
        final parsed = <TransaksiModel>[];
        final errors = <String>[];
        for (final doc in snapshot.docs) {
          try {
            parsed.add(TransaksiModel.fromMap(doc.data(), doc.id));
          } catch (error, stackTrace) {
            errors.add('Transaksi ${doc.id} tidak dapat dibaca.');
            debugPrint(
              'Gagal membaca transaksi laporan ${doc.id}: $error\n$stackTrace',
            );
          }
        }
        parsed.sort((a, b) {
          final aDate = _parseDate(a.tanggal);
          final bDate = _parseDate(b.tanggal);
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        if (!mounted) return;
        setState(() {
          _transactions = parsed;
          _salesLoaded = true;
          _replaceErrorsWithPrefix('Transaksi', errors);
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Gagal memuat laporan penjualan: $error\n$stackTrace');
        if (!mounted) return;
        setState(() {
          _salesLoaded = true;
          _replaceErrorsWithPrefix(
            'Transaksi',
            ['Gagal memuat penjualan: $error'],
          );
        });
      },
    );

    _inventorySubscription =
        FirebaseFirestore.instance.collection('obat').snapshots().listen(
      (snapshot) {
        final products = <_InventoryItem>[];
        final errors = <String>[];
        for (final doc in snapshot.docs) {
          try {
            products.add(_InventoryItem.fromMap(doc.data(), doc.id));
          } catch (error, stackTrace) {
            errors.add('Produk ${doc.id} tidak dapat dibaca.');
            debugPrint(
              'Gagal membaca produk laporan ${doc.id}: $error\n$stackTrace',
            );
          }
        }
        if (!mounted) return;
        setState(() {
          _inventory = products;
          _inventoryLoaded = true;
          _replaceErrorsWithPrefix('Inventaris', errors);
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Gagal memuat laporan inventaris: $error\n$stackTrace');
        if (!mounted) return;
        setState(() {
          _inventoryLoaded = true;
          _replaceErrorsWithPrefix(
            'Inventaris',
            ['Gagal memuat inventaris: $error'],
          );
        });
      },
    );
  }

  void _replaceErrorsWithPrefix(String prefix, List<String> replacements) {
    _errors.removeWhere((error) => error.startsWith(prefix));
    _errors.addAll(replacements.map((message) => '$prefix: $message'));
  }

  List<TransaksiModel> get _dateFilteredTransactions {
    return _transactions.where((transaction) {
      if (_selectedDate == null) return true;
      final date = _parseDate(transaction.tanggal);
      return date != null && _isSameDay(date, _selectedDate!);
    }).toList();
  }

  List<_ReportEntry> get _visibleEntries {
    final entries = <_ReportEntry>[];
    for (final transaction in _dateFilteredTransactions) {
      entries.add(
        _ReportEntry(
          type: 'Penjualan',
          title: 'Transaksi ${transaction.status}',
          subtitle: transaction.items.isEmpty
              ? 'Pesanan ${transaction.id}'
              : transaction.items.map((item) => item.namaProduk).join(', '),
          imageAsset: transaction.items.isEmpty
              ? null
              : productImageAssetForName(transaction.items.first.namaProduk),
          date: _parseDate(transaction.tanggal),
          amount: transaction.totalHarga,
          icon: Icons.receipt_long_outlined,
          color: Colors.blue,
        ),
      );
    }

    final now = DateTime.now();
    for (final item in _inventory) {
      if (item.stock <= _lowStockLimit) {
        entries.add(
          _ReportEntry(
            type: 'Stok menipis',
            title: item.stock <= 0 ? 'Stok obat habis' : 'Stok obat menipis',
            subtitle: '${item.name} tersisa ${item.stock} stok.',
            imageAsset: productImageAssetForName(item.name),
            date: null,
            icon: Icons.warning_amber_rounded,
            color: item.stock <= 0 ? Colors.red : Colors.orange,
          ),
        );
      }
      final daysUntilExpiry = item.expiryDate?.difference(now).inDays;
      if (daysUntilExpiry != null && daysUntilExpiry <= 30) {
        entries.add(
          _ReportEntry(
            type: 'Kedaluwarsa',
            title: daysUntilExpiry < 0
                ? 'Produk sudah kedaluwarsa'
                : 'Produk mendekati kedaluwarsa',
            subtitle:
                '${item.name} ${daysUntilExpiry < 0 ? 'kedaluwarsa' : 'kedaluwarsa dalam'}'
                '${daysUntilExpiry < 0 ? '' : ' $daysUntilExpiry hari'}'
                ' (${_formatDate(item.expiryDate!)}).',
            imageAsset: productImageAssetForName(item.name),
            date: item.expiryDate,
            icon: Icons.event_busy_outlined,
            color: Colors.red,
          ),
        );
      }
    }

    final filtered = _selectedFilter == 'Semua'
        ? entries
        : entries.where((entry) => entry.type == _selectedFilter).toList();
    filtered.sort((a, b) {
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return filtered;
  }

  int get _lowStockCount =>
      _inventory.where((item) => item.stock <= _lowStockLimit).length;

  int get _expiringCount => _inventory.where((item) {
        final days = item.expiryDate?.difference(DateTime.now()).inDays;
        return days != null && days <= 30;
      }).length;

  double get _totalSales => _dateFilteredTransactions
      .where((transaction) => transaction.status != 'Dibatalkan')
      .fold<double>(0, (total, transaction) => total + transaction.totalHarga);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih tanggal laporan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _visibleEntries;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text(
          'Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Pilih tanggal',
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = filter == _selectedFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: Colors.green,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(
                  _selectedDate == null
                      ? 'Semua tanggal'
                      : _formatDate(_selectedDate!),
                ),
              ),
            ),
          ),
          if (_errors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errors.join('\n'),
                  style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 12),
                        Text('Memuat laporan...'),
                      ],
                    ),
                  )
                : entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _ReportCard(entry: entries[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDate == null
                ? 'Ringkasan seluruh data'
                : 'Ringkasan ${_formatDate(_selectedDate!)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Penjualan',
                  value: 'Rp ${_formatCurrency(_totalSales.round())}',
                  icon: Icons.trending_up_rounded,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Stok menipis',
                  value: '$_lowStockCount produk',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Kedaluwarsa',
                  value: '$_expiringCount produk',
                  icon: Icons.event_busy_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _hasFirebase
                  ? Icons.analytics_outlined
                  : Icons.cloud_off_outlined,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _hasFirebase ? 'Belum ada laporan' : 'Laporan belum tersedia',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              _hasFirebase
                  ? 'Data penjualan dan inventaris akan tampil di sini.'
                  : 'Hubungkan Firebase untuk melihat laporan penjualan dan stok.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryItem {
  final String name;
  final int stock;
  final DateTime? expiryDate;

  const _InventoryItem({
    required this.name,
    required this.stock,
    required this.expiryDate,
  });

  factory _InventoryItem.fromMap(Map<String, dynamic> map, String id) {
    final nameValue = map['namaProduk'] ?? map['nama'];
    final stockValue = map['stok'];
    return _InventoryItem(
      name: nameValue is String && nameValue.trim().isNotEmpty
          ? nameValue
          : 'Produk $id',
      stock: stockValue is num
          ? stockValue.toInt()
          : int.tryParse('$stockValue') ?? 0,
      expiryDate: _parseDate(map['tanggalExpired']),
    );
  }
}

class _ReportEntry {
  final String type;
  final String title;
  final String subtitle;
  final DateTime? date;
  final double? amount;
  final IconData icon;
  final Color color;
  final String? imageAsset;

  const _ReportEntry({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
    this.imageAsset,
    this.amount,
  });
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final _ReportEntry entry;

  const _ReportCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: entry.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: entry.imageAsset == null
                ? Icon(entry.icon, color: entry.color, size: 21)
                : ClipOval(
                    child: Image.asset(
                      entry.imageAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(entry.icon, color: entry.color, size: 21),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.subtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.date == null ? entry.type : _formatDate(entry.date!),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          if (entry.amount != null)
            Text(
              'Rp ${_formatCurrency(entry.amount!.round())}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatCurrency(int amount) {
  return amount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
}
