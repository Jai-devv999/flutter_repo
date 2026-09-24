import 'package:flutter/material.dart';
import 'modul_01/profile_screen.dart';
import 'modul_02/modul_02_app.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas Anomali'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Daftar Modul Praktikum',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // MODUL 01
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PoliwangiProfileApp(),
                    ),
                  );
                },
                child: const Text('Modul 01 - Profil Mahasiswa'),
              ),
            ),

            const SizedBox(height: 12),

            // MODUL 02
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Modul02App(),
                    ),
                  );
                },
                child: const Text('Modul 02 - Dashboard Akademik'),
              ),
            ),

            const SizedBox(height: 12),

            // MODUL 03
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Modul 03'),
              ),
            ),

            const SizedBox(height: 12),

            // MODUL 04
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Modul 04'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}