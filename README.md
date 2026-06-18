#  Penjelasan aplikasi PiliHotel

PiliHotel adalah aplikasi pemesanan (booking) hotel berbasis mobile yang dirancang untuk memudahkan pengguna dalam mencari hotel, memesan kamar secara real-time, mengelola profil, memberikan review, serta mendapatkan tiket booking berformat PDF.

Aplikasi ini menggunakan arsitektur Client-Server dengan memisahkan bagian Backend (Laravel API) dan Frontend Mobile (Flutter).

-------------------------------------------------------------------------------------------------------------

# Fitur Utama

1. Autentikasi Pengguna & Keamanan:
   - Registrasi dan login akun dengan validasi aman.
   - Login dengan Google Auth.
   - Fitur ganti kata sandi langsung dari aplikasi.
   - Keamanan API menggunakan token dengan Laravel Sanctum.

2. Eksplor Hotel & Lokasi:
   - Cari dan jelajahi berbagai daftar hotel beserta ketersediaan kamarnya.
   - Lihat ulasan (reviews) dan rating dari pelanggan lain.
   - Pencarian hotel terdekat (nearby hotels).

3. Sistem Pemesanan (Booking) Kamar:
   - Pilih kamar dan lakukan pemesanan secara instan.
   - Pembayaran pemesanan (booking payment).
   - Cetak / unduh e-tiket pemesanan dalam format PDF.

4. Ulasan & Review:
   - Kirim review serta rating untuk hotel/kamar yang telah dipesan.
   - Unggah foto saat memberikan ulasan.

5. Manajemen Profil:
   - Ubah informasi profil pengguna.
   - Unggah foto profil.
   - Integrasi Firebase Cloud Messaging (FCM) Token untuk mendukung notifikasi perangkat.

------------------------------------------------------------------------------------------------------------
# Arsitektur & Teknologi

# Backend (pilihotel_backend)
- Framework: Laravel 11 (PHP)
- Autentikasi: Laravel Sanctum (Token-based authentication)
- Database: MySQL / SQLite
- Fungsi Tambahan: PDF Generator (untuk tiket booking), File Upload (untuk foto profil & ulasan).

 Mobile App (pilihotel_mobile)
- Framework: Flutter (Dart)
- State Management / Widgets: Custom widgets terstruktur (buttons, textfields, appbars, dialogs)
- Fitur PDF: Rendering & viewing e-tiket PDF secara native di dalam aplikasi.
- Integrasi Pihak Ketiga: Firebase Core & FCM (Firebase Cloud Messaging).

-------------------------------------------------------------------------------------------------------------
# Entity Relationship Diagram (ERD)

![ERD PiliHotel](pilihotel_mobile/erd/erd.png)













-------------------------------------------------------------------------------------------------------------
# Link Figma

https://www.figma.com/design/6ffDYiLvh1E6GKlVT8BSFO/PBP-HOTEL-6--NEW-?node-id=1-1180&t=g0xuiy2K29Cr9zoY-1