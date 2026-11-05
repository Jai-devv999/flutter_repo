import 'package:flutter/material.dart';

import 'screens/task_list_screen.dart';
import 'services/task_storage.dart';

class Modul05App extends StatelessWidget {
  const Modul05App({super.key});

  /// `--dart-define=LAMBAT=true` → penyimpanan sengaja lambat 2 detik,
  /// supaya keadaan memuat dapat diperlihatkan.
  static const bool lambatSimulasi = bool.fromEnvironment('LAMBAT');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 05 — Local Storage Dasar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      home: TaskListScreen(
        storage: lambatSimulasi
            ? const TaskStorage(tunda: Duration(seconds: 2))
            : const TaskStorage(),
      ),
    );
  }
}
