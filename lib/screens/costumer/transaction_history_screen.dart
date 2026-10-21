import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaksi_model.dart';
import '../../provider/transaction_history_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final history = context.watch<TransactionHistoryProvider>();
    final transactions = history.transactions;
    final filteredTransactions = _filter == 'Semua'
        ? transactions
        : transactions.where(
            (transaction) =>
                StatusTransaksi.normalize(transaction.status) == _filter,
          );
    final totalSpent = transactions
        .where(
          (transaction) =>
              StatusTransaksi.normalize(transaction.status) !=
              StatusTransaksi.dibatalkan,
        )
        .fold<double>(
            0, (total, transaction) => total + transaction.totalHarga);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF6F8F7),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: transactions.isEmpty
          ? history.isLoading
              ? _buildLoadingState()
              : history.loadError == null
                  ? _buildEmptyState()
                  : _buildLoadError()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummary(transactions.length, totalSpent),
                if (history.loadError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Sebagian riwayat tidak dapat dimuat. Coba periksa kembali koneksi atau data transaksi.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: StatusTransaksi.filters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = StatusTransaksi.filters[index];
                      return ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color:
                              _filter == filter ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada transaksi "$_filter".',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final transaction =
                                filteredTransactions.elementAt(index);
                            return _TransactionCard(
                              transaction: transaction,
                              onTap: () => _showDetails(transaction),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummary(int count, double totalSpent) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total transaksi',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  '$count pesanan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Total belanja',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  'Rp ${_formatCurrency(totalSpent.round())}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.green,
                size: 52,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada transaksi',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan yang berhasil dibuat akan tampil di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.green),
          SizedBox(height: 14),
          Text('Memuat riwayat pembelian...'),
        ],
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Riwayat belum dapat dimuat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              'Periksa koneksi internet lalu buka kembali halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(TransaksiModel transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetails(transaction: transaction),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransaksiModel transaction;
  final VoidCallback onTap;

  const _TransactionCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(transaction.status);
    final statusLabel = StatusTransaksi.normalize(transaction.status);
    final itemCount = transaction.items.fold<int>(
      0,
      (total, item) => total + item.jumlah,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.items.isEmpty
                              ? 'Pesanan ApotekKu'
                              : transaction.items.first.namaProduk,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(transaction.tanggal)} • ${transaction.id}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: _StatusBadge(
                  label: statusLabel,
                  color: statusColor,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$itemCount barang',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'Rp ${_formatCurrency(transaction.totalHarga.round())}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  final TransaksiModel transaction;

  const _TransactionDetails({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Detail Pesanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '${_formatDate(transaction.tanggal)} • ${transaction.id}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 18),
              ...transaction.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${item.namaProduk} x ${item.jumlah}'),
                      ),
                      Text(
                        'Rp ${_formatCurrency((item.harga * item.jumlah).round())}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              _DetailRow(
                label: 'Metode pembayaran',
                value: transaction.metodePembayaran,
              ),
              const SizedBox(height: 10),
              if (transaction.nomorEwallet != null &&
                  transaction.nomorEwallet!.isNotEmpty) ...[
                _DetailRow(
                  label: 'Nomor HP E-Wallet',
                  value: transaction.nomorEwallet!,
                ),
                const SizedBox(height: 10),
              ],
              _DetailRow(
                label: 'Status',
                value: StatusTransaksi.normalize(transaction.status),
              ),
              const SizedBox(height: 10),
              _DetailRow(
                label: 'Pembayaran',
                value: transaction.statusPembayaran,
              ),
              const SizedBox(height: 10),
              if (transaction.alamatPengiriman.isNotEmpty) ...[
                _DetailRow(
                  label: 'Alamat',
                  value: transaction.alamatPengiriman,
                ),
                const SizedBox(height: 10),
              ],
              if (transaction.buktiResepPath != null) ...[
                const _DetailRow(
                  label: 'Resep dokter',
                  value: 'Terlampir untuk verifikasi',
                ),
                const SizedBox(height: 10),
              ],
              _DetailRow(
                label: 'Total pembayaran',
                value: 'Rp ${_formatCurrency(transaction.totalHarga.round())}',
                isEmphasized: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasized;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isEmphasized ? Colors.green : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

Color _statusColor(String status) {
  return switch (StatusTransaksi.normalize(status)) {
    StatusTransaksi.selesai => Colors.green.shade700,
    StatusTransaksi.dibatalkan => Colors.red.shade700,
    StatusTransaksi.dikirim => Colors.blue.shade700,
    StatusTransaksi.diproses => Colors.teal.shade700,
    _ => Colors.orange.shade800,
  };
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(label), size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(String status) {
  return switch (StatusTransaksi.normalize(status)) {
    StatusTransaksi.menungguProses ||
    StatusTransaksi.menungguVerifikasiResep =>
      Icons.schedule_rounded,
    StatusTransaksi.diproses => Icons.inventory_2_outlined,
    StatusTransaksi.dikirim => Icons.local_shipping_outlined,
    StatusTransaksi.selesai => Icons.check_circle_outline_rounded,
    StatusTransaksi.dibatalkan => Icons.cancel_outlined,
    _ => Icons.info_outline_rounded,
  };
}

String _formatCurrency(int amount) {
  return amount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
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
  final day = date.day.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}, '
      '${date.hour}:$minute';
}
