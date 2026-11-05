# Modul 05 — Local Storage Dasar (Fase A)

Aplikasi **Tugas Praktikum**: daftar tugas yang tetap ada setelah aplikasi ditutup,
memakai `SharedPreferences` dan satu String JSON (tanpa SQLite).

## Cara menjalankan

```bash
flutter pub get
flutter run -d chrome
# melihat keadaan memuat (penyimpanan sengaja lambat 2 detik):
flutter run -d chrome --dart-define=LAMBAT=true
```

Untuk membuka modul langsung, di `lib/main.dart` arahkan tombol/`home` ke `Modul05App()`.

## Struktur

```
lib/modul_05/
├── models/task.dart               model + toJson/fromJson + copyWith
├── services/task_storage.dart     seluruh akses SharedPreferences
├── widgets/task_tile.dart         satu baris tugas
├── screens/task_list_screen.dart  daftar + empat keadaan + aksi
└── modul_05_app.dart              titik masuk
```

## Bukti empat keadaan

| Keadaan | Tangkapan layar |
|---|---|
| Memuat | ![memuat](screenshots/01_memuat.png) |
| Gagal | ![gagal](screenshots/02_gagal.png) |
| Kosong | ![kosong](screenshots/03_kosong.png) |
| Berhasil | ![berhasil](screenshots/04_berhasil.png) |

## Bukti data bertahan

1. Tambah dua tugas, tutup aplikasi sepenuhnya, jalankan ulang → kedua tugas masih ada.
2. Hapus satu tugas, tutup dan jalankan ulang → penghapusan ikut tersimpan.

(Catatan: Chrome — tutup tab lalu jalankan ulang; tombol kembali tidak membuktikan apa pun.)

## Verifikasi

```bash
dart format .
flutter analyze
flutter test test/modul_05_test.dart
```

## Keamanan

Tidak ada token, password, atau kunci API yang disimpan di SharedPreferences.
