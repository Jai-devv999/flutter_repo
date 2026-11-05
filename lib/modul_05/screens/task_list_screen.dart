import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.storage});

  /// Dapat disuntikkan dari luar (widget test atau praktikum keadaan memuat).
  final TaskStorage? storage;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

/// Pilihan penyaringan; `enum` agar salah ketik tertangkap analyzer.
enum _SaringTugas { semua, belumSelesai, selesai }

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskStorage _storage = widget.storage ?? const TaskStorage();

  List<Task>? _tugas;
  Object? _error;
  bool _sedangMenyimpan = false;
  _SaringTugas _saring = _SaringTugas.semua;

  @override
  void initState() {
    super.initState();
    unawaited(_muat());
  }

  Future<void> _muat() async {
    setState(() {
      _tugas = null;
      _error = null;
    });

    try {
      final List<Task> hasil = await _storage.muat();
      if (!mounted) return;
      setState(() => _tugas = hasil);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<bool> _simpanDaftar(
    List<Task> daftarBaru, {
    String? pesan,
    List<Task>? daftarSebelumnya,
  }) async {
    final List<Task>? cadangan = daftarSebelumnya ?? _tugas;

    setState(() {
      _tugas = daftarBaru;
      _sedangMenyimpan = true;
    });

    try {
      await _storage.simpan(daftarBaru);
      if (!mounted) return true;
      setState(() => _sedangMenyimpan = false);
      if (pesan != null) _pesan(pesan);
      return true;
    } catch (e) {
      if (!mounted) return false;
      // Gulung balik: layar dikembalikan ke kondisi terakhir yang
      // benar-benar tersimpan.
      setState(() {
        _tugas = cadangan;
        _sedangMenyimpan = false;
      });
      _pesan('Gagal menyimpan: ${_rapikanPesan(e)}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Task>? tugas = _tugas;
    final Object? error = _error;
    final bool siap = tugas != null && error == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Praktikum'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang dari penyimpanan',
            onPressed: () => unawaited(_muat()),
          ),
          PopupMenuButton<String>(
            tooltip: 'Aksi lain',
            onSelected: (String pilihan) {
              switch (pilihan) {
                case 'hapus-selesai':
                  unawaited(_hapusYangSelesai());
                case 'rusak':
                  unawaited(_rusakkanData());
                case 'bersihkan':
                  unawaited(_bersihkanData());
              }
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'hapus-selesai',
                    child: Text('Hapus yang selesai'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'rusak',
                    child: Text('Rusakkan data (demo keadaan gagal)'),
                  ),
                  PopupMenuItem<String>(
                    value: 'bersihkan',
                    child: Text('Hapus semua data'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Penanda halus bahwa penulisan ke disk sedang berjalan.
          if (_sedangMenyimpan) const LinearProgressIndicator(minHeight: 2),
          if (siap) _buildBarisSaring(tugas),
          if (siap) const Divider(height: 1),
          Expanded(child: _buildIsi(tugas, error)),
        ],
      ),
      floatingActionButton: siap
          ? FloatingActionButton.extended(
              onPressed: () => unawaited(_tambah()),
              icon: const Icon(Icons.add),
              label: const Text('Tugas'),
            )
          : null,
    );
  }

  Widget _buildIsi(List<Task>? tugas, Object? error) {
    // null = penyimpanan belum menjawab → memuat.
    if (tugas == null && error == null) return _buildMemuat();
    // Penyimpanan menjawab dengan kegagalan → gagal.
    if (error != null) return _buildGagal(error);

    final List<Task> tampil = _daftarTampil(tugas!);
    // Jawaban sah "tidak ada tugas" diperiksa paling akhir.
    if (tampil.isEmpty) return _buildKosong(tugas);
    return _buildDaftar(tampil);
  }

  Widget _buildMemuat() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Membaca tugas dari penyimpanan perangkat...',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGagal(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sd_card_alert_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Data Tersimpan Tidak Terbaca',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _rapikanPesan(error),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ini biasanya terjadi setelah bentuk model diubah tanpa '
              'menaikkan versi skema.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => unawaited(_muat()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
                OutlinedButton.icon(
                  onPressed: () => unawaited(_bersihkanData()),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus Data Rusak'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong(List<Task> semuaTugas) {
    // Dua sebab berbeda, dan pengguna berhak tahu yang mana:
    // kosong karena saringan, atau benar-benar belum ada tugas.
    final bool karenaSaringan = semuaTugas.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              karenaSaringan ? Icons.filter_alt_off_outlined : Icons.task_alt,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              karenaSaringan
                  ? 'Tidak ada tugas pada saringan "${_labelSaring(_saring)}".'
                  : 'Belum ada tugas sama sekali.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              karenaSaringan
                  ? 'Coba pilih saringan "Semua".'
                  : 'Tekan tombol Tugas di kanan bawah untuk menambah.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _daftarTampil(List<Task> sumber) {
    switch (_saring) {
      case _SaringTugas.semua:
        return sumber;
      case _SaringTugas.belumSelesai:
        return sumber.where((Task t) => !t.done).toList(growable: false);
      case _SaringTugas.selesai:
        return sumber.where((Task t) => t.done).toList(growable: false);
    }
  }

  static String _labelSaring(_SaringTugas pilihan) {
    switch (pilihan) {
      case _SaringTugas.semua:
        return 'Semua';
      case _SaringTugas.belumSelesai:
        return 'Belum Selesai';
      case _SaringTugas.selesai:
        return 'Selesai';
    }
  }

  /// Menghapus seluruh tugas yang sudah ditandai selesai — dengan
  /// tombol Urungkan, sama seperti penghapusan satu tugas.
  Future<void> _hapusYangSelesai() async {
    final List<Task>? sekarang = _tugas;
    if (sekarang == null) return;

    final int jumlah = sekarang.where((Task t) => t.done).length;
    if (jumlah == 0) {
      _pesan('Belum ada tugas yang ditandai selesai.');
      return;
    }

    final List<Task> baru = sekarang
        .where((Task t) => !t.done)
        .toList(growable: true);

    final bool berhasil = await _simpanDaftar(baru, daftarSebelumnya: sekarang);
    if (!berhasil || !mounted) return;

    _pesan(
      '$jumlah tugas selesai dihapus.',
      labelAksi: 'Urungkan',
      saatAksi: () => unawaited(_simpanDaftar(List<Task>.of(sekarang))),
    );
  }

  /// Dua aksi praktikum untuk membuktikan keadaan gagal dan kosong.
  Future<void> _rusakkanData() async {
    await _storage.rusakkanUntukDemo();
    if (!mounted) return;
    await _muat();
  }

  Future<void> _bersihkanData() async {
    await _storage.hapusSemua();
    if (!mounted) return;
    await _muat();
  }

  Widget _buildBarisSaring(List<Task> tugas) {
    final int selesai = tugas.where((Task t) => t.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              for (final _SaringTugas pilihan in _SaringTugas.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_labelSaring(pilihan)),
                    selected: _saring == pilihan,
                    labelStyle: const TextStyle(fontSize: 13),
                    onSelected: (bool dipilih) {
                      if (dipilih) setState(() => _saring = pilihan);
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            '$selesai dari ${tugas.length} tugas selesai',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDaftar(List<Task> items) {
    return ListView.builder(
      // Ruang bawah disisakan supaya baris terakhir tidak tertutup
      // tombol mengambang.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final Task item = items[index];

        return Dismissible(
          key: ValueKey<String>(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20, bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (DismissDirection _) => unawaited(_hapus(item)),
          child: TaskTile(
            task: item,
            onToggle: (Task t) => unawaited(_ubahStatus(t)),
          ),
        );
      },
    );
  }

  Future<void> _ubahStatus(Task tugas) async {
    final List<Task>? sekarang = _tugas;
    if (sekarang == null) return;

    // `map` + `copyWith`, bukan mengubah objek di tempat.
    final List<Task> baru = sekarang
        .map((Task t) => t.id == tugas.id ? t.copyWith(done: !t.done) : t)
        .toList(growable: true);

    await _simpanDaftar(baru, daftarSebelumnya: sekarang);
  }

  Future<void> _tambah() async {
    final _IsianTugas? isian = await showDialog<_IsianTugas>(
      context: context,
      builder: (BuildContext context) => const _DialogTugasBaru(),
    );
    if (isian == null || !mounted) return;

    final List<Task> sekarang = _tugas ?? <Task>[];

    // Id dibuat sendiri oleh aplikasi: penyimpanan kunci-nilai tidak punya
    // kolom penomori otomatis seperti tabel SQLite.
    final Task tugasBaru = Task(
      id: 'tugas-${DateTime.now().microsecondsSinceEpoch}',
      title: isian.judul,
      course: isian.mataKuliah,
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
      prioritas: isian.prioritas,
    );

    await _simpanDaftar(<Task>[
      tugasBaru,
      ...sekarang,
    ], pesan: 'Tugas baru disimpan ke penyimpanan perangkat.');
  }

  Future<void> _hapus(Task tugas) async {
    final List<Task>? sekarang = _tugas;
    if (sekarang == null) return;

    final List<Task> baru = List<Task>.of(sekarang)
      ..removeWhere((Task t) => t.id == tugas.id);

    final bool berhasil = await _simpanDaftar(baru, daftarSebelumnya: sekarang);
    if (!berhasil || !mounted) return;

    _pesan(
      '"${tugas.title}" dihapus.',
      labelAksi: 'Urungkan',
      saatAksi: () {
        // Daftar lama dikembalikan utuh, sehingga urutannya pun pulih.
        unawaited(_simpanDaftar(List<Task>.of(sekarang)));
      },
    );
  }

  void _pesan(String teks, {String? labelAksi, VoidCallback? saatAksi}) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(teks),
        action: labelAksi == null
            ? null
            : SnackBarAction(label: labelAksi, onPressed: saatAksi ?? () {}),
      ),
    );
  }

  static String _rapikanPesan(Object error) => error
      .toString()
      .replaceAll('Exception: ', '')
      .replaceAll('FormatException: ', '');
}

class _IsianTugas {
  const _IsianTugas({
    required this.judul,
    required this.mataKuliah,
    required this.prioritas,
  });

  final String judul;
  final String mataKuliah;
  final int prioritas;
}

class _DialogTugasBaru extends StatefulWidget {
  const _DialogTugasBaru();

  @override
  State<_DialogTugasBaru> createState() => _DialogTugasBaruState();
}

class _DialogTugasBaruState extends State<_DialogTugasBaru> {
  final TextEditingController _judul = TextEditingController();
  final TextEditingController _mataKuliah = TextEditingController(
    text: 'Pemrograman Perangkat Bergerak',
  );

  String? _pesanGalat;
  int _prioritas = 2;

  @override
  void dispose() {
    _judul.dispose();
    _mataKuliah.dispose();
    super.dispose();
  }

  void _kirim() {
    final String judul = _judul.text.trim();

    // Validasi sisi klien: penyimpanan tidak akan menolak teks kosong,
    // jadi satu-satunya tempat mencegahnya adalah di sini.
    if (judul.isEmpty) {
      setState(() => _pesanGalat = 'Judul tugas tidak boleh kosong.');
      return;
    }

    Navigator.pop(
      context,
      _IsianTugas(
        judul: judul,
        mataKuliah: _mataKuliah.text.trim().isEmpty
            ? 'Umum'
            : _mataKuliah.text.trim(),
        prioritas: _prioritas,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tugas Baru'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _judul,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Judul tugas',
              border: const OutlineInputBorder(),
              errorText: _pesanGalat,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mataKuliah,
            decoration: const InputDecoration(
              labelText: 'Mata kuliah',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Prioritas', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 1, label: Text('Tinggi')),
              ButtonSegment<int>(value: 2, label: Text('Sedang')),
              ButtonSegment<int>(value: 3, label: Text('Rendah')),
            ],
            selected: <int>{_prioritas},
            showSelectedIcon: false,
            onSelectionChanged: (Set<int> pilihan) {
              setState(() => _prioritas = pilihan.first);
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _kirim, child: const Text('Simpan')),
      ],
    );
  }
}
