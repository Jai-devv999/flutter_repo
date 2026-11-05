import 'package:flutter/material.dart';

import 'modul_01/profile_screen.dart';
import 'modul_02/modul_02_app.dart';
import 'modul_03/modul_03_app.dart';
import 'modul_04/modul_04_app.dart';
import 'modul_05/modul_05_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Praktikum Flutter',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _menuButton(
    BuildContext context,
    String label,
    Widget Function() page,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page()),
            );
          },
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelas Anomali'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Daftar Modul Praktikum',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _menuButton(
              context,
              'Modul 01 - Profil Mahasiswa',
              () => PoliwangiProfileApp(),
            ),
            _menuButton(
              context,
              'Modul 02 - Dashboard Akademik',
              () => Modul02App(),
            ),
            _menuButton(context, 'Modul 03', () => Modul03App()),
            _menuButton(context, 'Modul 04', () => Modul04App()),
            _menuButton(context, 'Modul 05', () => Modul05App()),
          ],
        ),
      ),
    );
  }
}
