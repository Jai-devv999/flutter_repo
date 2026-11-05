class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.date,
    required this.readCount,
  });

  final int id;
  final String title;
  final String content;
  final String author;
  final String category;
  final String date;
  final int readCount;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Tanpa Judul',
      content: json['content'] as String? ?? '',
      author: json['author'] as String? ?? 'Bagian Akademik Poliwangi',
      category: json['category'] as String? ?? 'Akademik',
      date: json['date'] as String? ?? '-',
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
    );
  }

  static const List<Announcement> _sampleAnnouncements = <Announcement>[
    Announcement(
      id: 1,
      title: 'Jadwal Pengisian KRS Semester Ganjil',
      content: 'Mahasiswa dimohon memperhatikan jadwal pengisian KRS yang telah ditetapkan oleh bagian akademik.',
      author: 'Bagian Akademik Poliwangi',
      category: 'Akademik',
      date: '2026-09-01',
      readCount: 120,
    ),
    Announcement(
      id: 2,
      title: 'Informasi Beasiswa Mahasiswa',
      content: 'Informasi mengenai pendaftaran dan persyaratan beasiswa dapat dilihat melalui pengumuman ini.',
      author: 'Bagian Akademik Poliwangi',
      category: 'Beasiswa',
      date: '2026-09-02',
      readCount: 95,
    ),
    Announcement(
      id: 3,
      title: 'Kegiatan Kampus Bulan September',
      content: 'Berikut informasi kegiatan kampus yang akan dilaksanakan pada bulan September.',
      author: 'Bagian Akademik Poliwangi',
      category: 'Kegiatan',
      date: '2026-09-03',
      readCount: 82,
    ),
    Announcement(
      id: 4,
      title: 'Pengumuman Prestasi Mahasiswa',
      content: 'Selamat kepada mahasiswa yang berhasil memperoleh prestasi pada kompetisi tingkat regional.',
      author: 'Bagian Akademik Poliwangi',
      category: 'Prestasi',
      date: '2026-09-04',
      readCount: 76,
    ),
  ];

  static List<Announcement> getSampleAnnouncements() {
    return _sampleAnnouncements;
  }
}
