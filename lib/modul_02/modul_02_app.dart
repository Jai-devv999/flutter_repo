import 'package:flutter/material.dart';
import 'academic_dashboard_screen.dart';

/// Pemilik state tema aplikasi Modul 02.
///
/// State `ThemeMode` sengaja diletakkan DI SINI — di atas `MaterialApp` —
/// bukan di dalam layar. Itulah pola terpusat pada §2.6: `MaterialApp`
/// menerima `theme`, `darkTheme`, dan `themeMode` sekaligus.
class Modul02App extends StatefulWidget {
  const Modul02App({super.key});

  @override
  State<Modul02App> createState() => _Modul02AppState();
}

class _Modul02AppState extends State<Modul02App> {
  // Satu-satunya state di lapisan aplikasi: mode tema yang sedang aktif.
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 02 — Declarative UI & Responsive Layout',
      // Tema terang (default)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      // Tema gelap
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: Brightness.dark,
        ),
      ),
      // Ditentukan oleh tombol di AppBar, bukan oleh pengaturan OS.
      themeMode: _themeMode,
      home: AcademicDashboardScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}