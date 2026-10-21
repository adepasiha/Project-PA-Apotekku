# 🏥 ApotekKu - Aplikasi Manajemen & Penjualan Obat

**ApotekKu** adalah aplikasi berbasis mobile (Flutter) yang terintegrasi dengan Firebase untuk membantu pengelolaan inventaris apotek bagi pihak admin serta mempermudah pelanggan dalam mencari, memesan, dan membeli produk kesehatan secara digital.

---

## 📱 Fitur Utama

### 🛠️ Fitur Admin (Apotek)
* **Dashboard Admin**: Ringkasan statistik performa apotek, total penjualan, dan status inventaris.
* **Manajemen Inventaris**: Tambah, ubah, hapus, dan pantau stok obat secara *real-time*.
* **Manajemen Pesanan**: Memantau dan mengelola pesanan masuk dari pelanggan.
* **Laporan & Notifikasi**: Peringatan otomatis untuk stok obat yang hampir habis (*low stock*) serta pengingat produk kedaluwarsa (*expired date*).

### 🛍️ Fitur Pelanggan (Customer)
* **Katalog Produk**: Menjelajahi berbagai macam produk obat, vitamin, dan suplemen berdasarkan kategori.
* **Pencarian & Filter**: Mencari produk dengan cepat berdasarkan nama atau kategori.
* **Keranjang Belanja**: Menambah, mengurangi, atau menghapus item belanjaan sebelum checkout.
* **Checkout & Pembayaran**: Memilih alamat pengiriman dan berbagai metode pembayaran (Tunai, QRIS, Transfer Bank, E-Wallet).
* **Riwayat Pesanan & Profil**: Melihat status pesanan aktif, riwayat transaksi sebelumnya, serta pengaturan profil pengguna.

---

## 🛠️ Teknologi yang Digunakan

* **Framework**: [Flutter](https://flutter.dev/) (Dart)
* **Backend & Database**: [Firebase Authentication](https://firebase.google.com/docs/auth) & [Cloud Firestore](https://firebase.google.com/docs/firestore)
* **Manajemen Paket**:
  * `firebase_core`, `firebase_auth`, `cloud_firestore` (Integrasi Firebase)
  * `cached_network_image` (Optimasi pemuatan gambar)
  * `cupertino_icons` (Gaya ikon iOS/Material)

---

## 📂 Struktur Direktori Proyek

```text
lib/
│
├── main.dart                 # Titik masuk utama aplikasi
├── app.dart                  # Konfigurasi aplikasi & routing utama
│
├── models/                   # Model Data (DTO)
│   ├── user_model.dart
│   ├── obat_model.dart
│   └── transaksi_model.dart
│
├── screens/                  # Tampilan / Antarmuka Pengguna
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── admin/
│   │   ├── dashboard_admin.dart
│   │   ├── inventaris_screen.dart
│   │   ├── pesanan_screen.dart
│   │   └── laporan_screen.dart
│   └── customer/
│       ├── home_screen.dart
│       ├── katalog_screen.dart
│       ├── keranjang_screen.dart
│       ├── checkout_screen.dart
│       └── profil_screen.dart
│
├── services/                 # Layanan Backend & Database
│   ├── auth_service.dart
│   └── database_service.dart
│
├── widgets/                  # Komponen UI yang Dapat Digunakan Kembali
│   └── obat_card.dart
│
└── utils/                    # Utilitas & Tema Global
    └── app_theme.dart