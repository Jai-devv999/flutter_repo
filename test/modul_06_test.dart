import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Sesuaikan 'tugas1_flutter' dengan baris `name:` di pubspec.yaml.
import 'package:tugas1_flutter/modul_06/models/sesi_pengguna.dart';
import 'package:tugas1_flutter/modul_06/modul_06_app.dart';
import 'package:tugas1_flutter/modul_06/screens/login_screen.dart';
import 'package:tugas1_flutter/modul_06/services/auth_api.dart';
import 'package:tugas1_flutter/modul_06/services/sesi_memori.dart';
import 'package:tugas1_flutter/modul_06/widgets/kartu_sesi.dart';

/// API palsu yang menghitung berapa kali masuk() dipanggil.
class _ApiHitung extends AuthApi {
  const _ApiHitung({super.tunda});
  static int panggilan = 0;

  @override
  Future<SesiPengguna> masuk({
    required String email,
    required String sandi,
    Duration masaBerlaku = const Duration(hours: 2),
  }) {
    panggilan++;
    return super.masuk(email: email, sandi: sandi, masaBerlaku: masaBerlaku);
  }
}

Future<void> _pasang(
  WidgetTester tester, {
  AuthApi? api,
  SesiMemori? memori,
  DateTime Function()? jam,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: LoginScreen(
        api: api ?? const AuthApi(tunda: Duration.zero),
        sesiMemori: memori ?? SesiMemori(),
        jam: jam ?? DateTime.now,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _isi(WidgetTester tester, String email, String sandi) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), sandi);
}

Future<void> _isiDanMasuk(
  WidgetTester tester,
  String email,
  String sandi,
) async {
  await _isi(tester, email, sandi);
  await tester.tap(find.text('Masuk'));
  await tester.pumpAndSettle();
}

void main() {
  group('Fase A — SesiPengguna', () {
    test('toJson/fromJson bolak-balik tanpa kehilangan data', () {
      final SesiPengguna asli = SesiPengguna.contoh(peran: 'dosen');
      final SesiPengguna hasil = SesiPengguna.fromJson(asli.toJson());
      expect(hasil.token, asli.token);
      expect(hasil.email, asli.email);
      expect(hasil.nama, asli.nama);
      expect(hasil.peran, 'dosen');
      expect(hasil.masukPada, asli.masukPada);
      expect(hasil.kedaluwarsaPada, asli.kedaluwarsaPada);
    });

    test('fromJson memakai nilai cadangan untuk kunci yang hilang', () {
      final SesiPengguna s = SesiPengguna.fromJson(<String, dynamic>{});
      expect(s.token, '');
      expect(s.email, 'tanpa-email');
      expect(s.nama, 'Pengguna');
      expect(s.peran, 'mahasiswa');
    });

    test('sudahKedaluwarsa: sebelum, tepat pada, dan sesudah batas', () {
      final SesiPengguna s = SesiPengguna.contoh(); // 08:00 + 2 jam
      expect(s.sudahKedaluwarsa(DateTime(2026, 9, 21, 9, 59)), isFalse);
      expect(s.sudahKedaluwarsa(DateTime(2026, 9, 21, 10, 0)), isTrue);
      expect(s.sudahKedaluwarsa(DateTime(2026, 9, 21, 11, 0)), isTrue);
    });

    test('tanggal rusak dianggap kedaluwarsa', () {
      final SesiPengguna s = SesiPengguna.contoh().copyWith(
        kedaluwarsaPada: 'bukan-tanggal',
      );
      expect(s.sudahKedaluwarsa(DateTime(2026, 9, 21)), isTrue);
      expect(s.sisaWaktu(DateTime(2026, 9, 21)), Duration.zero);
    });

    test('sisaWaktu tidak pernah negatif', () {
      final SesiPengguna s = SesiPengguna.contoh();
      expect(
        s.sisaWaktu(DateTime(2026, 9, 21, 9, 0)),
        const Duration(hours: 1),
      );
      expect(s.sisaWaktu(DateTime(2026, 9, 21, 12, 0)), Duration.zero);
    });

    test('toString tidak membocorkan token', () {
      final SesiPengguna s = SesiPengguna.contoh(token: 'rahasia-banget');
      expect(s.toString(), isNot(contains('rahasia-banget')));
    });

    test('labelPeran', () {
      expect(SesiPengguna.labelPeran('dosen'), 'Dosen');
      expect(SesiPengguna.labelPeran('mahasiswa'), 'Mahasiswa');
      expect(SesiPengguna.labelPeran('lain'), 'Pengguna');
    });
  });

  group('Fase A — AuthApi', () {
    const AuthApi api = AuthApi(tunda: Duration.zero);

    test('kredensial demo menghasilkan sesi dengan token dummy', () async {
      final SesiPengguna s = await api.masuk(
        email: AuthApi.emailDemo,
        sandi: AuthApi.sandiDemo,
      );
      expect(s.token, startsWith('dummy.'));
      expect(s.email, AuthApi.emailDemo);
      expect(s.sudahKedaluwarsa(DateTime.now()), isFalse);
    });

    test('email tidak peka huruf besar dan spasi di tepi', () async {
      final SesiPengguna s = await api.masuk(
        email: '  STUDENT@trpl.test ',
        sandi: AuthApi.sandiDemo,
      );
      expect(s.email, AuthApi.emailDemo);
    });

    test('kata sandi salah → 401 dan pesan tidak membocorkan field', () async {
      try {
        await api.masuk(email: AuthApi.emailDemo, sandi: 'salah-sandi');
        fail('seharusnya melempar AuthException');
      } on AuthException catch (e) {
        expect(e.kode, 401);
        expect(e.pesan, 'Email atau kata sandi salah.');
        expect(e.pesan.toLowerCase(), isNot(contains('terdaftar')));
      }
    });

    test(
      'email tidak dikenal memberi pesan yang sama dengan sandi salah',
      () async {
        try {
          await api.masuk(email: 'orang@lain.test', sandi: 'belajar123');
          fail('seharusnya melempar AuthException');
        } on AuthException catch (e) {
          expect(e.kode, 401);
          expect(e.pesan, 'Email atau kata sandi salah.');
        }
      },
    );

    test('akun terkunci → 423', () async {
      expect(
        api.masuk(email: AuthApi.emailTerkunci, sandi: 'apa-saja-123'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 423)),
      );
    });

    test('server gangguan → 503', () async {
      expect(
        api.masuk(email: AuthApi.emailServerGangguan, sandi: 'apa-saja-123'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 503)),
      );
    });

    test('isian kosong → 400', () async {
      expect(
        api.masuk(email: '', sandi: ''),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 400)),
      );
    });

    test('perbaruiSesi memperpanjang masa berlaku', () async {
      final SesiPengguna lama = SesiPengguna.contoh();
      final SesiPengguna baru = await api.perbaruiSesi(lama);
      expect(baru.token, lama.token);
      expect(baru.sudahKedaluwarsa(DateTime.now()), isFalse);
    });
  });

  group('Fase A — SesiMemori', () {
    test('simpan, baca, hapus', () async {
      final SesiMemori memori = SesiMemori();
      expect(memori.baca(), isNull);
      expect(memori.adaSesi, isFalse);

      await memori.simpan(SesiPengguna.contoh());
      expect(memori.adaSesi, isTrue);
      expect(memori.baca()?.email, 'student@trpl.test');
      expect(memori.jumlahPenulisan, 1);

      await memori.hapus();
      expect(memori.baca(), isNull);
    });

    test('instans baru = proses baru: sesi tidak terbawa', () async {
      final SesiMemori lama = SesiMemori();
      await lama.simpan(SesiPengguna.contoh());
      final SesiMemori prosesBaru = SesiMemori();
      expect(prosesBaru.baca(), isNull);
    });
  });

  group('Fase A — KartuSesi (fungsi bantu)', () {
    test('samarkanToken menyisakan 6 karakter awal', () {
      expect(KartuSesi.samarkanToken('abcdefghij'), 'abcdef${'\u2022' * 12}');
      expect(KartuSesi.samarkanToken('abc'), '\u2022' * 3);
      expect(KartuSesi.samarkanToken(''), '(kosong)');
    });

    test('formatSisa', () {
      expect(KartuSesi.formatSisa(Duration.zero), 'sudah berakhir');
      expect(KartuSesi.formatSisa(const Duration(seconds: 45)), '45 detik');
      expect(KartuSesi.formatSisa(const Duration(minutes: 5)), '5 menit');
      expect(KartuSesi.formatSisa(const Duration(hours: 1)), '1 jam');
      expect(
        KartuSesi.formatSisa(const Duration(hours: 1, minutes: 5)),
        '1 jam 5 menit',
      );
    });

    test('formatWaktu', () {
      expect(
        KartuSesi.formatWaktu('2026-09-21T10:15:00.000'),
        '21 Sep 2026, 10:15',
      );
      expect(KartuSesi.formatWaktu('rusak'), 'tidak diketahui');
    });
  });

  group('Fase A — LoginScreen', () {
    testWidgets('aplikasi baru dibuka → form login tanpa pesan kesalahan', (
      WidgetTester tester,
    ) async {
      await _pasang(tester);
      expect(find.text('Masuk ke Portal Akademik'), findsOneWidget);
      expect(find.text('Email atau kata sandi salah.'), findsNothing);
      expect(find.text('Beranda'), findsNothing);
    });

    testWidgets('isian kosong → pesan validator, API tidak dipanggil', (
      WidgetTester tester,
    ) async {
      _ApiHitung.panggilan = 0;
      await _pasang(tester, api: const _ApiHitung(tunda: Duration.zero));
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi.'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
      expect(_ApiHitung.panggilan, 0);
    });

    testWidgets('sandi kurang dari 8 karakter ditolak validator', (
      WidgetTester tester,
    ) async {
      await _pasang(tester);
      await _isiDanMasuk(tester, 'student@trpl.test', 'abc');
      expect(find.text('Kata sandi minimal 8 karakter.'), findsOneWidget);
    });

    testWidgets('format email salah ditolak validator', (
      WidgetTester tester,
    ) async {
      await _pasang(tester);
      await _isiDanMasuk(tester, 'bukanemail', 'belajar123');
      expect(find.text('Format email belum benar.'), findsOneWidget);
    });

    testWidgets('kredensial salah → keadaan gagal dengan pesan', (
      WidgetTester tester,
    ) async {
      await _pasang(tester);
      await _isiDanMasuk(tester, 'student@trpl.test', 'sandi-salah-1');
      expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
      expect(find.text('Masuk ke Portal Akademik'), findsOneWidget);
    });

    testWidgets('akun terkunci menampilkan pesan khusus', (
      WidgetTester tester,
    ) async {
      await _pasang(tester);
      await _isiDanMasuk(tester, 'terkunci@trpl.test', 'belajar123');
      expect(find.textContaining('Akun terkunci'), findsOneWidget);
    });

    testWidgets('server gangguan menampilkan pesan khusus', (
      WidgetTester tester,
    ) async {
      await _pasang(tester);
      await _isiDanMasuk(tester, 'gangguan@trpl.test', 'belajar123');
      expect(find.textContaining('Server sedang tidak dapat'), findsOneWidget);
    });

    testWidgets('login berhasil → beranda, sesi tersimpan, token tersamar', (
      WidgetTester tester,
    ) async {
      final SesiMemori memori = SesiMemori();
      await _pasang(tester, memori: memori);
      await _isiDanMasuk(tester, 'student@trpl.test', 'belajar123');

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Mahasiswa TRPL'), findsOneWidget);
      expect(memori.adaSesi, isTrue);

      final String token = memori.baca()!.token;
      expect(find.textContaining(token), findsNothing);
    });

    testWidgets('tombol mati saat memproses dan tidak terkirim dua kali', (
      WidgetTester tester,
    ) async {
      _ApiHitung.panggilan = 0;
      await _pasang(
        tester,
        api: const _ApiHitung(tunda: Duration(milliseconds: 500)),
      );
      await _isi(tester, 'student@trpl.test', 'belajar123');

      await tester.tap(find.text('Masuk'));
      await tester.pump(); // masuk ke keadaan memproses

      expect(find.text('Memproses…'), findsOneWidget);
      final Finder tombol = find.ancestor(
        of: find.text('Memproses…'),
        matching: find.byWidgetPredicate((Widget w) => w is FilledButton),
      );
      expect(tester.widget<FilledButton>(tombol).onPressed, isNull);

      // Ketukan kedua saat tombol mati tidak boleh menembus.
      await tester.tap(find.text('Memproses…'), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(_ApiHitung.panggilan, 1);
      expect(find.text('Beranda'), findsOneWidget);
    });

    testWidgets('logout kembali ke keluar, bukan gagal', (
      WidgetTester tester,
    ) async {
      final SesiMemori memori = SesiMemori();
      await _pasang(tester, memori: memori);
      await _isiDanMasuk(tester, 'student@trpl.test', 'belajar123');

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Portal Akademik'), findsOneWidget);
      expect(find.text('Email atau kata sandi salah.'), findsNothing);
      expect(memori.adaSesi, isFalse);
    });

    testWidgets('sesi aktif di memori → langsung ke beranda', (
      WidgetTester tester,
    ) async {
      final SesiMemori memori = SesiMemori();
      await memori.simpan(SesiPengguna.contoh()); // berlaku sampai 10:00
      await _pasang(
        tester,
        memori: memori,
        jam: () => DateTime(2026, 9, 21, 9, 0),
      );
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('1 jam'), findsOneWidget);
    });

    testWidgets('sesi kedaluwarsa dibuang dan pengguna diberi tahu', (
      WidgetTester tester,
    ) async {
      final SesiMemori memori = SesiMemori();
      await memori.simpan(SesiPengguna.contoh());
      await _pasang(
        tester,
        memori: memori,
        jam: () => DateTime(2026, 9, 21, 12, 0),
      );
      expect(
        find.text('Sesi sebelumnya sudah berakhir. Silakan masuk lagi.'),
        findsOneWidget,
      );
      expect(memori.adaSesi, isFalse);
    });

    testWidgets('Modul06App membuat penyimpanan sekali, bukan tiap build', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const Modul06App(api: AuthApi(tunda: Duration.zero)),
      );
      await tester.pumpAndSettle();
      await _isiDanMasuk(tester, 'student@trpl.test', 'belajar123');
      expect(find.text('Beranda'), findsOneWidget);

      // Bangun ulang pohon widget: sesi harus tetap ada.
      await tester.pumpWidget(
        const Modul06App(api: AuthApi(tunda: Duration.zero)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Beranda'), findsOneWidget);
    });
  });
}
