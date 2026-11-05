import '../models/sesi_pengguna.dart';

/// Sesi disimpan di memori proses: hilang saat proses aplikasi berakhir.
/// Semua metode tetap `Future` supaya pemanggil tidak terbiasa dengan
/// penyimpanan yang serba instan.
class SesiMemori {
  SesiPengguna? _sesi;

  /// Dipakai pengujian.
  int jumlahPenulisan = 0;

  SesiPengguna? baca() => _sesi;
  bool get adaSesi => _sesi != null;

  Future<void> simpan(SesiPengguna sesi) async {
    _sesi = sesi;
    jumlahPenulisan++;
  }

  Future<void> hapus() async {
    _sesi = null;
  }
}
