<div align="center">
  <h1>📱 e-Library Mobile App (Frontend)</h1>
  <p><strong>Flutter Application for Digital Library System - UKK Project</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/GetX-%23E51B24.svg?style=for-the-badge&logo=dart&logoColor=white" alt="GetX" />
  </p>
</div>

---

## 📱 Deskripsi
Ini adalah repository **Frontend (Mobile App)** untuk sistem Perpustakaan Digital, dibangun khusus untuk proyek Uji Kompetensi Keahlian (UKK). 

Aplikasi ini dirancang dengan antarmuka (UI) yang modern, bersih, dan sangat responsif, memberikan pengalaman pengguna (UX) terbaik baik bagi Admin perpustakaan maupun Siswa. Aplikasi ini mengonsumsi data dari REST API Backend Laravel.

## ✨ Fitur Utama
- **🎨 Modern UI/UX:** Desain antarmuka yang sangat indah, interaktif, dan mudah digunakan (User Friendly).
- **🎭 Multi-Role Dashboards:**
  - **Admin Panel:** Mengelola buku, anggota, menyetujui transaksi peminjaman/pengembalian, mengecek denda, dan melihat grafik statistik perpustakaan secara *real-time*.
  - **Student Panel:** Mencari katalog buku, menambah buku ke keranjang (cart), mengajukan peminjaman, melihat riwayat baca, dan notifikasi denda.
- **⚡ State Management (GetX):** Memastikan performa aplikasi sangat cepat, ringan, dan manajemen state yang rapi.
- **📄 Export & Reports:** Fitur untuk melakukan generate laporan transaksi ke dalam format PDF (khusus Admin).

## 🚀 Cara Menjalankan Aplikasi
1. Pastikan Flutter SDK sudah terpasang di komputer Anda.
2. Clone repository ini.
3. Jalankan `flutter pub get` di terminal untuk mengunduh semua dependency.
4. Buka file `lib/core/utils/url_utils.dart` (atau file konfigurasi API Anda) dan pastikan Base URL sudah mengarah ke IP Address lokal/server backend Laravel Anda.
5. Jalankan aplikasi di Emulator atau Device Fisik dengan perintah: `flutter run`.

---
<div align="center">
  <i>Dikembangkan dengan ❤️ oleh Naufal untuk Proyek UKK.</i>
</div>
