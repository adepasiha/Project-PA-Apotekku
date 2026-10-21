# 🏥 ApotekKu — Aplikasi Manajemen & Penjualan Obat

**ApotekKu** adalah aplikasi mobile berbasis Flutter yang terintegrasi dengan Firebase. Aplikasi ini membantu admin mengelola inventaris dan pesanan obat serta memudahkan pelanggan mencari, memesan, dan membeli produk kesehatan.

## 📱 Fitur Utama

### 🛠️ Admin
- **Dashboard:** Menampilkan ringkasan informasi apotek.
- **Manajemen Inventaris:** Menambah, melihat, mengubah, dan menghapus data obat (CRUD).
- **Manajemen Pesanan:** Memantau dan mengelola pesanan pelanggan.
- **Laporan:** Membantu memantau penjualan dan stok obat.
- **Notifikasi Stok:** Mendukung pemantauan stok obat yang hampir habis sesuai implementasi aplikasi.

### 🛍️ Pelanggan
- **Katalog Produk:** Melihat daftar obat, vitamin, dan produk kesehatan.
- **Pencarian:** Mencari produk berdasarkan nama atau kategori.
- **Keranjang Belanja:** Menambah dan menghapus produk dari keranjang.
- **Checkout:** Mengisi informasi pesanan dan memilih metode pembayaran yang tersedia.
- **Profil dan Riwayat:** Mengelola profil serta melihat riwayat pesanan.

## 🛠️ Teknologi yang Digunakan

- **Flutter:** Framework untuk membangun aplikasi mobile.
- **Dart:** Bahasa pemrograman.
- **Firebase Authentication:** Mengelola autentikasi pengguna.
- **Cloud Firestore:** Menyimpan data obat, pengguna, dan transaksi sesuai implementasi.
- **Firebase Storage:** Menyimpan gambar produk apabila fitur penyimpanan gambar Firebase digunakan.
- **Provider:** Membantu pengelolaan state aplikasi.

## 📂 Struktur Direktori

```text
lib/
├── main.dart
├── app.dart
├── models/
│   ├── user_model.dart
│   ├── obat_model.dart
│   └── transaksi_model.dart
├── provider/
├── screens/
│   ├── auth/
│   ├── admin/
│   └── customer/
├── services/
├── utils/
└── widgets/

assets/
└── images/
```

## ⚙️ Cara Menjalankan Aplikasi

Pastikan Flutter SDK, Android Studio, dan Git sudah terpasang.

1. Clone repositori:

   ```bash
   git clone https://github.com/adepasiha/Project-PA-Apotekku.git
   ```

2. Masuk ke folder proyek:

   ```bash
   cd Project-PA-Apotekku
   ```

3. Instal dependensi:

   ```bash
   flutter pub get
   ```

4. Konfigurasikan Firebase sesuai proyek Firebase yang digunakan.

5. Jalankan aplikasi:

   ```bash
   flutter run
   ```

## 🔥 Cara Menghubungkan Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Buat proyek Firebase atau buka proyek Firebase yang sudah digunakan.
3. Tambahkan aplikasi Android menggunakan **application ID** yang sesuai dengan proyek Flutter.
4. Hubungkan Flutter dengan Firebase menggunakan FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. Pastikan file `firebase_options.dart` dibuat dan konfigurasi proyek sesuai.
6. Tambahkan paket Firebase yang diperlukan melalui `pubspec.yaml`, misalnya:

   ```bash
   flutter pub add firebase_core firebase_auth cloud_firestore
   ```

   Jika aplikasi menggunakan unggah gambar ke Firebase Storage, tambahkan:

   ```bash
   flutter pub add firebase_storage image_picker
   ```

7. Inisialisasikan Firebase sebelum menjalankan aplikasi, sesuai konfigurasi pada `main.dart`.

### Alur Kerja Firebase

- **Authentication:** Memverifikasi akun pengguna jika fitur login dan registrasi menggunakannya.
- **Cloud Firestore:** Menyimpan dan mengambil data yang digunakan aplikasi.
- **Firebase Storage:** Menyimpan file gambar produk apabila fitur tersebut diaktifkan.

Pastikan aturan keamanan Firebase dikonfigurasi dengan benar agar hanya pengguna yang berwenang dapat melakukan perubahan data.

## 📦 Build APK

Untuk membuat APK yang dapat dipasang pada perangkat Android, jalankan:

```bash
flutter build apk --release
```

File APK akan dihasilkan di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 👨‍💻 Pengembang

**Proyek:** ApotekKu — Aplikasi Manajemen & Penjualan Obat

**Repository GitHub:**  
https://github.com/adepasiha/Project-PA-Apotekku
