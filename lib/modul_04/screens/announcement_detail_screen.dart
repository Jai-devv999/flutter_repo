import 'package:flutter/material.dart';

import '../models/announcement.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Chip(label: Text(announcement.category)),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '${announcement.author} • ${announcement.date}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 32),
            Text(
              announcement.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                const Icon(Icons.visibility_outlined),
                const SizedBox(width: 8),
                Text('${announcement.readCount} kali dibaca'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
