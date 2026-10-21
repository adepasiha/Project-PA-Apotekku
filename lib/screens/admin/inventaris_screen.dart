import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../utils/product_image.dart';

class InventarisScreen extends StatefulWidget {
  final bool focusSearch;

  const InventarisScreen({super.key, this.focusSearch = false});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {
  static const _categories = [
    'Semua',
    'Tablet',
    'Kapsul',
    'Sirup',
    'Salep',
    'Herbal',
    'Vitamin',
  ];

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _inventorySubscription;

  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _daftarObat = [
    {
      'nama': 'Paracetamol 500 mg',
      'kategori': 'Tablet | PT. Kimia Farma',
      'stok': 120,
      'harga': 'Rp 1.500',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/paracetamol.png',
    },
    {
      'nama': 'Amoxicillin 500 mg',
      'kategori': 'Kapsul | PT. Bina San Prima',
      'stok': 85,
      'harga': 'Rp 2.500',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/amoxicillin.png',
    },
    {
      'nama': 'Vitamin C 1000 mg',
      'kategori': 'Tablet | PT. Sanbe Farma',
      'stok': 45,
      'harga': 'Rp 3.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/vitamin_c.png',
    },
    {
      'nama': 'Ibuprofen 400 mg',
      'kategori': 'Tablet | PT. Sanbe Farma',
      'stok': 30,
      'harga': 'Rp 2.000',
      'status': 'Hampir Habis',
      'warnaStatus': Colors.orange,
      'gambar': 'assets/images/ibuprofen.png',
    },
    {
      'nama': 'Obat Batuk Sirup',
      'kategori': 'Sirup | PT. Konimex',
      'stok': 60,
      'harga': 'Rp 12.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/herbakof.png',
    },
    {
      'nama': 'Salep Kulit 10 g',
      'kategori': 'Salep | PT. Kimia Farma',
      'stok': 24,
      'harga': 'Rp 8.500',
      'status': 'Stok',
      'warnaStatus': Colors.green,
    },
    {
      'nama': 'Antasida Doen',
      'kategori': 'Tablet | Generik',
      'stok': 30,
      'harga': 'Rp 6.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
    },
    {
      'nama': 'Loratadine 10 mg',
      'kategori': 'Tablet | Novapharin',
      'stok': 18,
      'harga': 'Rp 11.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
    },
    {
      'nama': 'Metformin 500 mg',
      'kategori': 'Tablet | Dexa Medica',
      'stok': 15,
      'harga': 'Rp 9.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
    },
    {
      'nama': 'Zinc 20 mg',
      'kategori': 'Kapsul | Generik',
      'stok': 25,
      'harga': 'Rp 13.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
    },
    {
      'nama': 'Multivitamin Harian',
      'kategori': 'Vitamin | Blackmores',
      'stok': 15,
      'harga': 'Rp 28.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
    },
    {
      'nama': 'Vitamin D3 1000 IU',
      'kategori': 'Tablet | PT. PIM Pharmaceuticals',
      'stok': 25,
      'harga': 'Rp 18.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/vitamin_d3.png',
    },
    {
      'nama': 'Vitamin B Kompleks',
      'kategori': 'Tablet | IPI',
      'stok': 35,
      'harga': 'Rp 15.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/vitamin_b_kompleks.png',
    },
    {
      'nama': 'Vitamin E 100 IU',
      'kategori': 'Vitamin | Sido Muncul',
      'stok': 25,
      'harga': 'Rp 22.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/vitamin_e.png',
    },
    {
      'nama': 'Amlodipine 5 mg',
      'kategori': 'Tablet | Hexpharm Jaya',
      'stok': 20,
      'harga': 'Rp 10.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/amlodipine.png',
    },
    {
      'nama': 'Jahe Merah',
      'kategori': 'Herbal | Bejo',
      'stok': 30,
      'harga': 'Rp 14.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/jahe_merah.png',
    },
    {
      'nama': 'Madu Herbal',
      'kategori': 'Sirup | Madu Murni',
      'stok': 20,
      'harga': 'Rp 30.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/madu_herbal.png',
    },
    {
      'nama': 'Kunyit Asam',
      'kategori': 'Sirup | Sido Muncul',
      'stok': 24,
      'harga': 'Rp 16.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/kunyit_asam.png',
    },
    {
      'nama': 'Minyak Kayu Putih',
      'kategori': 'Herbal | Cap Lang',
      'stok': 22,
      'harga': 'Rp 17.000',
      'status': 'Stok',
      'warnaStatus': Colors.green,
      'gambar': 'assets/images/minyak_kayu_putih.png',
    },
  ];

  @override
  void initState() {
    super.initState();

    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    if (Firebase.apps.isEmpty) return;

    _inventorySubscription =
        FirebaseFirestore.instance.collection('obat').snapshots().listen(
      (snapshot) {
        if (!mounted) return;
        if (snapshot.docs.isEmpty) return;

        setState(() {
          _daftarObat
            ..clear()
            ..addAll(
              snapshot.docs.map(_mapFirestoreProductToUiModel).toList(),
            );
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        debugPrint('Gagal memuat inventaris dari Firestore: $error');
      },
    );
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Map<String, dynamic> _mapFirestoreProductToUiModel(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return {
      ..._mapProductDataToUiModel(doc.data()),
      'docId': doc.id,
    };
  }

  Map<String, dynamic> _mapProductDataToUiModel(Map<String, dynamic> data) {
    final nama = (data['namaProduk'] ?? 'Produk Baru').toString();
    final kategori = (data['kategori'] ?? 'Tablet').toString();
    final produsen = (data['produsen'] ?? 'Produsen Lokal').toString();

    final stokValue = data['stok'];
    final hargaValue = data['harga'];

    final stok = stokValue is num ? stokValue.toInt() : 0;
    final harga = hargaValue is num ? hargaValue.toDouble() : 0.0;

    final status = stok <= 10 ? 'Hampir Habis' : 'Stok';
    final warnaStatus = stok <= 10 ? Colors.orange : Colors.green;

    return {
      'nama': nama,
      'kategori': '$kategori | $produsen',
      'stok': stok,
      'harga': _formatRupiah(harga),
      'status': status,
      'warnaStatus': warnaStatus,
      'gambarBase64': (data['gambarBase64'] ?? '').toString(),
      'gambar': productImageAssetForName(nama),
    };
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final nama = product['nama'] as String;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "$nama" dari inventaris?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final docId = product['docId'] as String?;
      if (docId != null && Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('obat').doc(docId).delete();
      }

      if (!mounted) return;
      setState(() => _daftarObat.remove(product));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "$nama" berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk "$nama": $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatRupiah(double value) {
    final formatted = value.round().toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );

    return 'Rp $formatted';
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    return _daftarObat.where((obat) {
      final category =
          (obat['kategori'] as String).split('|').first.trim().toLowerCase();

      final matchesCategory = _selectedCategory == 'Semua' ||
          category == _selectedCategory.toLowerCase();

      final matchesSearch = query.isEmpty ||
          (obat['nama'] as String).toLowerCase().contains(query) ||
          (obat['kategori'] as String).toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<XFile?> _pilihGambar() async {
    final picker = ImagePicker();

    return picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
      maxWidth: 600,
      maxHeight: 600,
    );
  }

  // Kompres gambar dan ubah menjadi Base64 agar dapat disimpan di Firestore.
  Future<String> _gambarKeBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('File gambar tidak dapat dibaca.');
    }

    final resized = decoded.width > 600 || decoded.height > 600
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? 600 : null,
            height: decoded.height > decoded.width ? 600 : null,
          )
        : decoded;

    final compressed = img.encodeJpg(resized, quality: 45);
    final result = base64Encode(compressed);

    // Batas dokumen Firestore sekitar 1 MiB; Base64 juga menambah ukuran.
    if (result.length > 700000) {
      throw Exception(
        'Gambar masih terlalu besar. Pilih gambar yang lebih kecil.',
      );
    }

    return result;
  }

  Future<void> _showProductDialog({Map<String, dynamic>? product}) async {
    final formKey = GlobalKey<FormState>();
    final productCategory =
        (product?['kategori'] as String? ?? 'Tablet').split('|').first.trim();
    final namaController = TextEditingController(
      text: product?['nama'] as String? ?? '',
    );
    final produsenController = TextEditingController(
      text: product == null
          ? ''
          : (product['kategori'] as String).split('|').skip(1).join('|').trim(),
    );
    final stokController = TextEditingController(
      text: product?['stok']?.toString() ?? '',
    );
    final hargaController = TextEditingController(
      text: product == null
          ? ''
          : (product['harga'] as String).replaceAll(RegExp(r'[^0-9]'), ''),
    );

    String selectedCategory =
        _categories.contains(productCategory) ? productCategory : 'Tablet';
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  product == null ? 'Tambah Produk Baru' : 'Edit Produk',
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image Picker dan preview gambar.
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: selectedImageBytes != null
                              ? Image.memory(
                                  selectedImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : product?['gambar'] != null
                                  ? Image.asset(
                                      product!['gambar'] as String,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.medication),
                                    )
                                  : const Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  try {
                                    final picked = await _pilihGambar();

                                    if (picked == null) return;

                                    final bytes = await picked.readAsBytes();

                                    setDialogState(() {
                                      selectedImage = picked;
                                      selectedImageBytes = bytes;
                                    });
                                  } catch (error) {
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Gagal memilih gambar: $error',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.image),
                          label: const Text('Pilih Gambar Obat'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama obat',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Nama obat wajib diisi';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          items: _categories
                              .where((category) => category != 'Semua')
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      selectedCategory = value;
                                    });
                                  }
                                },
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: produsenController,
                          decoration: const InputDecoration(
                            labelText: 'Produsen',
                            hintText: 'Contoh: PT. Kimia Farma',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: stokController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stok',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Stok wajib diisi';
                            }

                            final stok = int.tryParse((value ?? '').trim());

                            if (stok == null || stok < 0) {
                              return 'Stok harus berupa angka >= 0';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: hargaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga',
                            prefixText: 'Rp ',
                            hintText: '1500',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final harga = int.tryParse(
                              (value ?? '').replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              ),
                            );

                            if (harga == null || harga < 0) {
                              return 'Harga harus berupa angka valid';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isSaving ? null : () => Navigator.pop(dialogContext),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            final nama = namaController.text.trim();

                            final produsen =
                                produsenController.text.trim().isEmpty
                                    ? 'Produsen Lokal'
                                    : produsenController.text.trim();

                            final stok = int.parse(stokController.text.trim());

                            final hargaValue = int.tryParse(
                                  hargaController.text.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  ),
                                ) ??
                                0;

                            setDialogState(() => isSaving = true);

                            try {
                              var gambarBase64 =
                                  product?['gambarBase64'] as String? ?? '';

                              if (selectedImage != null) {
                                gambarBase64 =
                                    await _gambarKeBase64(selectedImage!);
                              }

                              final data = {
                                'namaProduk': nama,
                                'kategori': selectedCategory,
                                'produsen': produsen,
                                'stok': stok,
                                'harga': hargaValue,
                                'tanggalExpired': '',
                                'deskripsi':
                                    'Produk baru ditambahkan dari admin',
                                'gambarBase64': gambarBase64,
                                'perluResep': false,
                              };
                              final docId = product?['docId'] as String?;

                              if (Firebase.apps.isNotEmpty) {
                                final collection =
                                    FirebaseFirestore.instance.collection(
                                  'obat',
                                );
                                if (docId == null) {
                                  await collection.add({
                                    ...data,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                                } else {
                                  await collection.doc(docId).update(data);
                                }
                              }

                              if (!mounted) return;

                              setState(() {
                                final updatedProduct = {
                                  ...?product,
                                  ..._mapProductDataToUiModel(data),
                                  if (docId != null) 'docId': docId,
                                };
                                if (product == null) {
                                  _daftarObat.insert(0, updatedProduct);
                                } else {
                                  final productIndex =
                                      _daftarObat.indexOf(product);
                                  if (productIndex != -1) {
                                    _daftarObat[productIndex] = updatedProduct;
                                  }
                                }
                                _selectedCategory = 'Semua';
                                _searchQuery = '';
                                _searchController.clear();
                              });

                              Navigator.of(this.context).pop();

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    product == null
                                        ? 'Produk "$nama" berhasil ditambahkan.'
                                        : 'Produk "$nama" berhasil diperbarui.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (error) {
                              setDialogState(() => isSaving = false);

                              if (!mounted) return;

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menyimpan produk: $error',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        namaController.dispose();
        produsenController.dispose();
        stokController.dispose();
        hargaController.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventaris Obat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Bar pencarian.
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Cari nama obat, kategori...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filter kategori.
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final category in _categories)
                      _buildFilterChip(category),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Daftar obat.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount:
                  _filteredProducts.isEmpty ? 1 : _filteredProducts.length,
              itemBuilder: (context, index) {
                if (_filteredProducts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        'Obat tidak ditemukan.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                final obat = _filteredProducts[index];
                final imageAsset =
                    productImageAssetForName(obat['nama'] as String);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Gambar dari Firestore atau aset lokal.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 56,
                          height: 56,
                          color: Colors.green.shade50,
                          padding: const EdgeInsets.all(3),
                          child: (obat['gambarBase64'] as String? ?? '')
                                  .isNotEmpty
                              ? Image.memory(
                                  base64Decode(
                                    obat['gambarBase64'] as String,
                                  ),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.medication,
                                      color: Colors.green,
                                    );
                                  },
                                )
                              : imageAsset != null
                                  ? Image.asset(
                                      imageAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.medication,
                                          color: Colors.green,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.medication,
                                      color: Colors.green,
                                    ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Informasi obat.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              obat['nama'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              obat['kategori'] as String,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Stok: ${obat['stok']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    obat['harga'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  key: ValueKey(
                                      'product-actions-${obat['nama']}'),
                                  tooltip: 'Aksi ${obat['nama']}',
                                  padding: EdgeInsets.zero,
                                  onSelected: (action) {
                                    if (action == 'edit') {
                                      _showProductDialog(product: obat);
                                    } else {
                                      _deleteProduct(obat);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit_outlined),
                                        title: Text('Edit'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        title: Text('Hapus'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status stok.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (obat['warnaStatus'] as Color).withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          obat['status'] as String,
                          style: TextStyle(
                            color: obat['warnaStatus'] as Color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Tombol tambah produk.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showProductDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedCategory = label);
        },
        selectedColor: Colors.green.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.green.shade800 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
