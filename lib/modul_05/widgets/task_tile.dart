import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onToggle});

  final Task task;

  /// Dipanggil saat kotak centang ditekan.
  final ValueChanged<Task> onToggle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;
    final DateTime? tanggal = Task.bacaTanggal(task);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: CheckboxListTile(
        value: task.done,
        onChanged: (_) => onToggle(task),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            // Tugas yang selesai dicoret — hanya perubahan tampilan;
            // datanya tetap utuh di penyimpanan.
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done ? warna.onSurfaceVariant : warna.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: <Widget>[
              _BadgePrioritas(prioritas: task.prioritas),
              const SizedBox(width: 8),
              Icon(Icons.menu_book_outlined, size: 14, color: warna.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.course,
                  style: TextStyle(fontSize: 12, color: warna.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tanggal != null) ...<Widget>[
                const SizedBox(width: 8),
                Icon(
                  Icons.event_outlined,
                  size: 14,
                  color: warna.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTanggal(tanggal),
                  style: TextStyle(fontSize: 12, color: warna.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Mengubah `2026-09-15` menjadi `15 Sep 2026` — tanpa paket `intl`,
  /// supaya Fase A tetap tanpa library tambahan.
  static String _formatTanggal(DateTime tanggal) {
    const List<String> bulan = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }
}

/// Penanda prioritas kecil. Warnanya diambil dari ColorScheme, bukan
/// ditulis tetap, sehingga tetap terbaca saat tema berganti.
class _BadgePrioritas extends StatelessWidget {
  const _BadgePrioritas({required this.prioritas});

  final int prioritas;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    final Color latar;
    final Color teks;
    switch (prioritas) {
      case 1:
        latar = warna.errorContainer;
        teks = warna.onErrorContainer;
      case 3:
        latar = warna.surfaceContainerHighest;
        teks = warna.onSurfaceVariant;
      default:
        latar = warna.primaryContainer;
        teks = warna.onPrimaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        Task.labelPrioritas(prioritas),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: teks,
        ),
      ),
    );
  }
}
