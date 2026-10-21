import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaksi_model.dart';
import '../../provider/transaction_history_provider.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  String _filter = 'Semua';
  String? _updatingTransactionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TransactionHistoryProvider>().loadAllForAdmin();
    });
  }

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
    final waitingCount = transactions
        .where((transaction) => StatusTransaksi.nextStatuses(
              transaction.status,
            ).isNotEmpty)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text(
          'Manajemen Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Muat ulang pesanan',
            onPressed: history.isLoading ? null : history.loadAllForAdmin,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: history.isLoading && transactions.isEmpty
          ? _buildMessage(
              icon: Icons.hourglass_top_rounded,
              message: 'Memuat daftar pesanan...',
              showProgress: true,
            )
          : history.loadError != null && transactions.isEmpty
              ? _buildLoadError(history.loadError!)
              : transactions.isEmpty
                  ? _buildMessage(
                      icon: Icons.receipt_long_outlined,
                      message: 'Belum ada pesanan masuk.',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummary(transactions.length, waitingCount),
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
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                                selectedColor: Colors.green,
                                labelStyle: TextStyle(
                                  color: _filter == filter
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide.none,
                              );
                            },
                          ),
                        ),
                        if (history.loadError != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              'Sebagian pesanan tidak dapat dibaca. '
                              '${history.loadError}',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Expanded(
                          child: filteredTransactions.isEmpty
                              ? Center(
                                  child: Text(
                                    'Belum ada pesanan dengan status "$_filter".',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                  itemCount: filteredTransactions.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) =>
                                      _buildOrderCard(filteredTransactions
                                          .elementAt(index)),
                                ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSummary(int orderCount, int waitingCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryValue(label: 'Total pesanan', value: '$orderCount'),
          ),
          Expanded(
            child: _SummaryValue(
              label: 'Perlu ditindaklanjuti',
              value: '$waitingCount',
            ),
          ),
          const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(TransaksiModel transaction) {
    final color = _statusColor(transaction.status);
    final nextStatuses = StatusTransaksi.nextStatuses(transaction.status);
    final isUpdating = _updatingTransactionId == transaction.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.shopping_bag_outlined, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.items.isEmpty
                          ? 'Pesanan ${transaction.id}'
                          : transaction.items
                              .map((item) => item.namaProduk)
                              .join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(transaction.tanggal)} • ${transaction.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusBadge(
                label: StatusTransaksi.normalize(transaction.status),
                color: color,
              ),
              Text(
                'Rp ${_formatCurrency(transaction.totalHarga.round())}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (nextStatuses.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Perbarui status pesanan',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in nextStatuses)
                  OutlinedButton(
                    onPressed: isUpdating
                        ? null
                        : () => _updateStatus(
                              transaction,
                              status,
                            ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _statusColor(status),
                      side: BorderSide(color: _statusColor(status)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: isUpdating && status == _updatingTargetStatus
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(status),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _updatingTargetStatus;

  Future<void> _updateStatus(
    TransaksiModel transaction,
    String status,
  ) async {
    setState(() {
      _updatingTransactionId = transaction.id;
      _updatingTargetStatus = status;
    });
    try {
      await context.read<TransactionHistoryProvider>().updateTransactionStatus(
            transaction.id,
            status,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status pesanan diperbarui menjadi "$status".')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status pesanan: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingTransactionId = null;
          _updatingTargetStatus = null;
        });
      }
    }
  }

  Widget _buildLoadError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Colors.red, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Pesanan belum dapat dimuat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  context.read<TransactionHistoryProvider>().loadAllForAdmin,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    bool showProgress = false,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showProgress)
            const CircularProgressIndicator(color: Colors.green)
          else
            Icon(icon, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
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

String _formatCurrency(int amount) {
  return amount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final day = date.day.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour}:$minute';
}
