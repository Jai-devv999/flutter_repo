import 'package:flutter/material.dart';
import 'models/course.dart';
import 'widgets/course_card.dart';
import 'widgets/header_banner.dart';

/// Tampilan dashboard. Widget ini TIDAK mengatur tema sendiri: ia membaca
/// `themeMode` dari konstruktor dan melaporkan aksi tombol lewat
/// `onToggleTheme`. Tema tetap terpusat di `MaterialApp` (modul_02_app.dart).
class AcademicDashboardScreen extends StatelessWidget {
  const AcademicDashboardScreen({
    super.key,
    this.themeMode = ThemeMode.light,
    this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback? onToggleTheme;

  // Daftar mata kuliah bersifat tetap (tidak berubah selama aplikasi hidup),
  // sehingga cukup menjadi data statis — bukan state.
  static final List<Course> _courses = Course.getSampleCourses();

  bool get _isDarkMode => themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Akademik TRPL',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: _isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            // Aksi diteruskan ke atas; layar tidak mengubah tema sendiri.
            onPressed: onToggleTheme,
          ),
        ],
      ),
      // LayoutBuilder membaca ukuran layar untuk menentukan tata letak responsif
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoint 600dp: Tablet / Landscape menggunakan 2 kolom
          if (constraints.maxWidth >= 600) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom kiri: banner profil
                  const Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: HeaderBanner(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Kolom kanan: jumlah kolom mengikuti ruang yang tersedia.
                  Expanded(
                    flex: 3,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        // Lebar kartu tidak melebihi 340 dp. Pada ruang yang
                        // cukup GridView menambah kolom; pada ruang sempit
                        // jumlah kolom otomatis berkurang.
                        maxCrossAxisExtent: 340,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        // Tinggi eksplisit agar seluruh isi CourseCard muat.
                        // Jangan gabungkan dengan childAspectRatio.
                        mainAxisExtent: 240,
                      ),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(course: _courses[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          // Default (smartphone): tata letak 1 kolom vertikal
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HeaderBanner(),
              const SizedBox(height: 16),
              Text(
                'Mata Kuliah Semester 5 (${_courses.length} Terdaftar)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._courses.map((course) => CourseCard(course: course)),
            ],
          );
        },
      ),
    );
  }
}