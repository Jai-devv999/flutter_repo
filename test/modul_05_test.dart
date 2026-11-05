import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sesuaikan 'tugas1_flutter' dengan nama package di pubspec.yaml (baris `name:`).
import 'package:tugas1_flutter/modul_05/models/task.dart';
import 'package:tugas1_flutter/modul_05/modul_05_app.dart';
import 'package:tugas1_flutter/modul_05/services/task_storage.dart';

void main() {
  group('Modul 05 Fase A', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('Task toJson/fromJson bolak-balik tanpa kehilangan data', () {
      const Task asli = Task(
        id: 'a',
        title: 'Judul',
        course: 'MK',
        createdAt: '2026-09-21',
        done: true,
        prioritas: 1,
      );
      final Task hasil = Task.fromJson(asli.toJson());
      expect(hasil.id, 'a');
      expect(hasil.title, 'Judul');
      expect(hasil.course, 'MK');
      expect(hasil.done, true);
      expect(hasil.createdAt, '2026-09-21');
      expect(hasil.prioritas, 1);
    });

    test('fromJson memakai nilai cadangan untuk field yang belum ada', () {
      final Task t = Task.fromJson(<String, dynamic>{'id': 'x'});
      expect(t.prioritas, 2);
      expect(t.done, false);
      expect(t.course, 'Umum');
    });

    test('copyWith tidak mengubah objek lama', () {
      const Task a = Task(
        id: 'a',
        title: 't',
        course: 'c',
        createdAt: '2026-01-01',
      );
      final Task b = a.copyWith(done: true);
      expect(a.done, false);
      expect(b.done, true);
      expect(b.id, a.id);
    });

    test(
      'kunjungan pertama mengembalikan tiga tugas contoh yang bisa ditambah',
      () async {
        final List<Task> hasil = await const TaskStorage().muat();
        expect(hasil.length, 3);
        expect(() => hasil.add(hasil.first), returnsNormally);
      },
    );

    test('simpan lalu muat mengembalikan data yang sama', () async {
      const TaskStorage storage = TaskStorage();
      await storage.simpan(const <Task>[
        Task(id: '1', title: 'Satu', course: 'A', createdAt: '2026-09-01'),
        Task(
          id: '2',
          title: 'Dua',
          course: 'B',
          createdAt: '2026-09-02',
          done: true,
          prioritas: 3,
        ),
      ]);
      final List<Task> hasil = await storage.muat();
      expect(hasil.map((Task t) => t.id), <String>['1', '2']);
      expect(hasil[1].done, true);
      expect(hasil[1].prioritas, 3);
    });

    test('versi skema ikut tersimpan', () async {
      const TaskStorage storage = TaskStorage();
      expect(await storage.versiTersimpan(), isNull);
      await storage.simpan(const <Task>[]);
      expect(await storage.versiTersimpan(), TaskStorage.versiSkema);
    });

    test(
      'daftar kosong yang tersimpan tetap kosong, bukan contoh lagi',
      () async {
        const TaskStorage storage = TaskStorage();
        await storage.simpan(const <Task>[]);
        expect(await storage.muat(), isEmpty);
      },
    );

    test('data rusak melempar FormatException, bukan daftar kosong', () async {
      const TaskStorage storage = TaskStorage();
      await storage.rusakkanUntukDemo();
      expect(storage.muat(), throwsA(isA<FormatException>()));
    });

    test('JSON sah tetapi bukan daftar melempar FormatException', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        TaskStorage.kunciTugas: '{"a":1}',
      });
      expect(const TaskStorage().muat(), throwsA(isA<FormatException>()));
    });

    test(
      'hapusSemua mengembalikan keadaan seperti kunjungan pertama',
      () async {
        const TaskStorage storage = TaskStorage();
        await storage.simpan(const <Task>[]);
        await storage.hapusSemua();
        expect((await storage.muat()).length, 3);
        expect(await storage.versiTersimpan(), isNull);
      },
    );

    test('tidak ada kunci rahasia yang disimpan', () async {
      await const TaskStorage().simpan(Task.getSampleTasks());
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      for (final String kunci in prefs.getKeys()) {
        expect(kunci.toLowerCase(), isNot(contains('token')));
        expect(kunci.toLowerCase(), isNot(contains('password')));
        expect(kunci.toLowerCase(), isNot(contains('api')));
      }
    });

    testWidgets('menampilkan keadaan memuat lalu berhasil', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpWidget(const Modul05App());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(
        find.text('Menyelesaikan laporan praktikum Modul 04'),
        findsOneWidget,
      );
    });

    testWidgets(
      'data rusak menampilkan keadaan gagal dengan tombol pemulihan',
      (tester) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          TaskStorage.kunciTugas: '{rusak',
        });
        await tester.pumpWidget(const Modul05App());
        await tester.pumpAndSettle();
        expect(find.text('Data Tersimpan Tidak Terbaca'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);
        expect(find.text('Hapus Data Rusak'), findsOneWidget);
        expect(find.text('Belum ada tugas sama sekali.'), findsNothing);

        await tester.tap(find.text('Hapus Data Rusak'));
        await tester.pumpAndSettle();
        expect(find.text('Data Tersimpan Tidak Terbaca'), findsNothing);
      },
    );

    testWidgets('daftar kosong menampilkan keadaan kosong', (tester) async {
      await const TaskStorage().simpan(const <Task>[]);
      await tester.pumpWidget(const Modul05App());
      await tester.pumpAndSettle();
      expect(find.text('Belum ada tugas sama sekali.'), findsOneWidget);
    });
  });
}
