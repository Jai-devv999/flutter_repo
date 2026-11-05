class Task {
  final String id;
  final String title;
  final String course;
  final bool done;
  final String createdAt;
  final int prioritas; // 1 = Tinggi, 2 = Sedang, 3 = Rendah

  const Task({
    required this.id,
    required this.title,
    required this.course,
    required this.createdAt,
    this.done = false,
    this.prioritas = 2,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? 'tanpa-id',
      title: json['title'] as String? ?? 'Tanpa Judul',
      course: json['course'] as String? ?? 'Umum',
      done: json['done'] is bool ? json['done'] as bool : false,
      createdAt: json['createdAt'] as String? ?? '1970-01-01',
      // Data yang ditulis sebelum field ini ada tidak punya kunci
      // 'prioritas'. Nilai cadangan 2 membuatnya tetap terbaca.
      prioritas: json['prioritas'] is int ? json['prioritas'] as int : 2,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'course': course,
      'done': done,
      'createdAt': createdAt,
      'prioritas': prioritas,
    };
  }

  Task copyWith({String? title, String? course, bool? done, int? prioritas}) {
    return Task(
      id: id,
      title: title ?? this.title,
      course: course ?? this.course,
      done: done ?? this.done,
      createdAt: createdAt,
      prioritas: prioritas ?? this.prioritas,
    );
  }

  /// Label prioritas yang ditampilkan ke pengguna.
  static String labelPrioritas(int prioritas) {
    switch (prioritas) {
      case 1:
        return 'Tinggi';
      case 3:
        return 'Rendah';
      default:
        return 'Sedang';
    }
  }

  /// Tanggal dikembalikan menjadi DateTime hanya saat ditampilkan.
  /// Dipakai oleh TaskTile untuk merapikan tampilan tanggal.
  static DateTime? bacaTanggal(Task tugas) =>
      DateTime.tryParse(tugas.createdAt);

  static List<Task> getSampleTasks() {
    return const <Task>[
      Task(
        id: 'contoh-1',
        title: 'Menyelesaikan laporan praktikum Modul 04',
        course: 'Pemrograman Perangkat Bergerak',
        createdAt: '2026-09-15',
      ),
      Task(
        id: 'contoh-2',
        title: 'Mengerjakan latihan SharedPreferences',
        course: 'Pemrograman Perangkat Bergerak',
        createdAt: '2026-09-18',
        prioritas: 1,
      ),
      Task(
        id: 'contoh-3',
        title: 'Membaca dokumentasi sqflite',
        course: 'Basis Data',
        createdAt: '2026-09-20',
        prioritas: 3,
      ),
    ];
  }
}
