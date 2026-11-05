import 'package:flutter/material.dart';

import 'models/course.dart';
import 'widgets/course_card.dart';
import 'widgets/header_banner.dart';

/// Tampilan dashboard akademik.
class AcademicDashboardScreen extends StatefulWidget {
  const AcademicDashboardScreen({
    super.key,
    this.themeMode = ThemeMode.light,
    this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback? onToggleTheme;

  @override
  State<AcademicDashboardScreen> createState() =>
      _AcademicDashboardScreenState();
}

class _AcademicDashboardScreenState extends State<AcademicDashboardScreen> {
  // Daftar mata kuliah
  static final List<Course> _courses = Course.getSampleCourses();

  // Kategori yang sedang dipilih
  String _selectedCategory = 'Semua';

  bool get _isDarkMode => widget.themeMode == ThemeMode.dark;

  // Daftar mata kuliah berdasarkan kategori yang dipilih
  List<Course> get _filteredCourses {
    if (_selectedCategory == 'Semua') {
      return _courses;
    }

    return _courses
        .where((course) => course.category == _selectedCategory)
        .toList();
  }

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
            icon: Icon(
              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: _isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          // Filter kategori
          final filterWidget = Wrap(
            spacing: 8.0,
            children: ['Semua', 'Teori', 'Praktikum'].map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
              );
            }).toList(),
          );

          // Tablet / Desktop
          if (constraints.maxWidth >= 600) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom kiri
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HeaderBanner(),
                          const SizedBox(height: 16),
                          filterWidget,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Kolom kanan
                  Expanded(
                    flex: 3,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 340,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 240,
                          ),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(course: _filteredCourses[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          // Smartphone
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HeaderBanner(),

              const SizedBox(height: 16),

              // Filter kategori
              filterWidget,

              const SizedBox(height: 16),

              Text(
                'Mata Kuliah Semester 5 (${_filteredCourses.length} Terdaftar)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ..._filteredCourses.map((course) => CourseCard(course: course)),
            ],
          );
        },
      ),
    );
  }
}
