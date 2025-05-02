import 'package:etf_oglasi/features/announcements/data/model/announcement.dart';
import 'package:etf_oglasi/features/announcements/data/model/dummy_data.dart';
import 'package:etf_oglasi/features/announcements/presentation/widget/announcement_card.dart';
import 'package:etf_oglasi/features/home/data/model/category.dart';
import 'package:flutter/material.dart';

class AnnouncementScreen extends StatelessWidget {
  static const id = 'announcement_screen';

  const AnnouncementScreen({super.key, required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    final List<Announcement> data = dummyAnnouncements;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return AnnouncementCard(announcement: data[index]);
        },
        padding: const EdgeInsets.all(8.0),
        itemCount: data.length,
      ),
    );
  }
}
