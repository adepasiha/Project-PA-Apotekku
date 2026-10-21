import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../provider/cart_provider.dart';
import '../../provider/customer_profile_provider.dart';
import '../../models/transaksi_model.dart';
import '../../provider/transaction_history_provider.dart';
import 'shipping_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Tunai';
  final _ewalletFormKey = GlobalKey<FormState>();
  final _ewalletPhoneController = TextEditingController();
  bool _isPlacingOrder = false;

  static const int _ongkir = 5000;

  @override
  void dispose() {
    _ewalletPhoneController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final profile = context.watch<CustomerProfileProvider>();
    final subtotal = cart.totalAmount;
    final total = subtotal + _ongkir;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alamat Pengiriman Section
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ShippingAddressScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.addressLabel} • ${profile.recipientName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.recipientPhone}\n${profile.address}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metode Pembayaran Section
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
              child: Column(
                children: [
                  _buildPaymentOption(
                    title: 'Tunai (Bayar di Tempat)',
                    icon: Icons.payments_outlined,
                    value: 'Tunai',
                  ),
                  _buildPaymentOption(
                    title: 'E-Wallet',
                    icon: Icons.account_balance_wallet_outlined,
                    value: 'E-Wallet',
                  ),
                ],
              ),
            ),
            if (_selectedPaymentMethod == 'E-Wallet') ...[
              const SizedBox(height: 8),
              Form(
                key: _ewalletFormKey,
                child: TextFormField(
                  controller: _ewalletPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP E-Wallet',
                    hintText: 'Contoh: 081234567890',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final phone = (value ?? '').trim();
                    final digits = phone.replaceAll(RegExp(r'\D'), '');
                    if (digits.isEmpty) {
                      return 'Nomor HP E-Wallet wajib diisi';
                    }
                    if (digits.length < 9 || digits.length > 15) {
                      return 'Masukkan nomor HP yang valid';
                    }
                    return null;
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Stok akhir akan dikonfirmasi oleh apoteker sebelum pesanan diproses.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),

            // Ringkasan Pesanan Section
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...cart.items.values.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.namaObat} x ${item.jumlah}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text('Rp ${_formatCurrency(item.harga * item.jumlah)}'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        'Rp ${_formatCurrency(subtotal)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ongkos Kirim',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        'Rp ${_formatCurrency(_ongkir)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Rp ${_formatCurrency(total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Bayar Sekarang
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cart.items.isEmpty || _isPlacingOrder
                    ? null
                    : () {
                        if (_selectedPaymentMethod == 'E-Wallet' &&
                            !(_ewalletFormKey.currentState?.validate() ??
                                false)) {
                          return;
                        }
                        _placeOrder(cart, profile, total);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Buat Pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = _selectedPaymentMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: RadioListTile<String>(
          title: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          secondary: Icon(
            icon,
            color: isSelected ? Colors.green : Colors.grey,
          ),
          value: value,
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    CartProvider cart,
    CustomerProfileProvider profile,
    int total,
  ) async {
    if (_isPlacingOrder) return;

    final outOfStockItems = cart.items.values
        .where((item) => item.jumlah > item.stokTersedia)
        .toList();
    if (outOfStockItems.isNotEmpty) {
      final outOfStockItem = outOfStockItems.first;
      _showMessage(
        'Stok ${outOfStockItem.namaObat} tidak mencukupi. Kurangi jumlahnya.',
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    final transactionItems = cart.items.values
        .map(
          (item) => ItemTransaksi(
            obatId: item.id,
            namaProduk: item.namaObat,
            harga: item.harga.toDouble(),
            jumlah: item.jumlah,
            perluResep: item.perluResep,
          ),
        )
        .toList();
    final transaction = TransaksiModel(
      id: 'TRX-${DateTime.now().microsecondsSinceEpoch}',
      userId: profile.customerId,
      items: transactionItems,
      totalHarga: total.toDouble(),
      metodePembayaran: _selectedPaymentMethod,
      nomorEwallet: _selectedPaymentMethod == 'E-Wallet'
          ? _ewalletPhoneController.text.trim()
          : null,
      status: cart.items.values.any((item) => item.perluResep)
          ? StatusTransaksi.menungguVerifikasiResep
          : 'Menunggu konfirmasi apotek',
      tanggal: DateTime.now().toIso8601String(),
      alamatPengiriman: '${profile.addressLabel} - ${profile.recipientName}, '
          '${profile.recipientPhone}, ${profile.address}',
      statusPembayaran: _selectedPaymentMethod == 'Tunai'
          ? 'Bayar di tempat (simulasi)'
          : 'Simulasi, belum dibayar',
    );

    try {
      await context.read<TransactionHistoryProvider>().addTransaction(
            transaction,
          );
      if (!mounted) return;
      cart.clearCart();
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 44),
          title: const Text('Pesanan berhasil dibuat'),
          content: Text(
            'Nomor pesanan ${transaction.id}\n'
            'Status: ${transaction.status}\n'
            'Pembayaran masih simulasi untuk demo.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Lihat riwayat'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseException catch (error) {
      _showMessage('Pesanan belum tersimpan: ${error.message ?? error.code}');
    } catch (error) {
      _showMessage('Pesanan belum tersimpan: $error');
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
