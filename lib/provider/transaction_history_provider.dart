import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

import '../models/transaksi_model.dart';

class TransactionHistoryProvider extends ChangeNotifier {
  final List<TransaksiModel> _transactions = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  Object? _loadError;
  bool _isLoading = false;

  List<TransaksiModel> get transactions => List.unmodifiable(_transactions);
  Object? get loadError => _loadError;
  bool get isLoading => _isLoading;

  void loadForCurrentUser() {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _loadError = StateError('Login diperlukan untuk melihat riwayat.');
      notifyListeners();
      return;
    }

    _listenToQuery(
      FirebaseFirestore.instance
          .collection('transaksi')
          .where('userId', isEqualTo: user.uid),
    );
  }

  void loadAllForAdmin() {
    if (Firebase.apps.isEmpty) {
      _loadError = StateError('Firebase belum tersedia untuk memuat pesanan.');
      notifyListeners();
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      _loadError = StateError('Login admin diperlukan untuk melihat pesanan.');
      notifyListeners();
      return;
    }
    _listenToQuery(FirebaseFirestore.instance.collection('transaksi'));
  }

  void _listenToQuery(Query<Map<String, dynamic>> query) {
    unawaited(_subscription?.cancel());
    _transactions.clear();
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    _subscription = query.snapshots().listen(
      (snapshot) {
        final transactions = <TransaksiModel>[];
        final failures = <String>[];
        for (final doc in snapshot.docs) {
          try {
            transactions.add(TransaksiModel.fromMap(doc.data(), doc.id));
          } catch (error, stackTrace) {
            failures.add(doc.id);
            debugPrint(
                'Gagal membaca transaksi ${doc.id}: $error\n$stackTrace');
          }
        }
        transactions.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        _transactions
          ..clear()
          ..addAll(transactions);
        _isLoading = false;
        _loadError = failures.isEmpty
            ? null
            : 'Sebagian data transaksi tidak dapat dibaca '
                '(${failures.length} transaksi).';
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _loadError = error;
        notifyListeners();
      },
    );
  }

  Future<void> addTransaction(TransaksiModel transaction) async {
    if (Firebase.apps.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('Silakan login kembali sebelum membuat pesanan.');
      }
      await FirebaseFirestore.instance
          .collection('transaksi')
          .doc(transaction.id)
          .set(transaction.toMap());
    }
    final existingIndex = _transactions.indexWhere(
      (item) => item.id == transaction.id,
    );
    if (existingIndex == -1) {
      _transactions.insert(0, transaction);
    } else {
      _transactions[existingIndex] = transaction;
    }
    notifyListeners();
  }

  Future<void> updateTransactionStatus(
    String transactionId,
    String newStatus,
  ) async {
    final index = _transactions.indexWhere(
      (transaction) => transaction.id == transactionId,
    );
    if (index < 0) {
      throw StateError('Pesanan tidak ditemukan. Muat ulang daftar pesanan.');
    }
    final current = _transactions[index];
    if (!StatusTransaksi.nextStatuses(current.status).contains(newStatus)) {
      throw StateError(
        'Perubahan status ${current.status} ke $newStatus tidak diizinkan.',
      );
    }

    if (Firebase.apps.isNotEmpty) {
      if (FirebaseAuth.instance.currentUser == null) {
        throw StateError('Login admin diperlukan untuk memperbarui pesanan.');
      }
      await FirebaseFirestore.instance
          .collection('transaksi')
          .doc(transactionId)
          .update({'status': newStatus});
    }

    _transactions[index] = current.copyWith(status: newStatus);
    notifyListeners();
  }

  void clearForSignOut() {
    _subscription?.cancel();
    _subscription = null;
    _transactions.clear();
    _isLoading = false;
    _loadError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
