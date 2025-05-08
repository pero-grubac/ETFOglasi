import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/features/announcements/presentation/widget/announcement_card.dart';
import 'package:etf_oglasi/features/announcements/presentation/widget/api_error_widget.dart';
import 'package:etf_oglasi/features/announcements/presentation/widget/no_data_widget.dart';
import 'package:etf_oglasi/features/home/data/model/category.dart';
import 'package:flutter/material.dart';

import 'package:etf_oglasi/features/announcements/data/service/announcement_service.dart';

class AnnouncementScreen extends StatefulWidget {
  static const id = 'announcement_screen';

  const AnnouncementScreen({super.key, required this.category});
  final Category category;

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late Future<List<Announcement>> _data;
  final announcementService = AnnouncementService();

  @override
  void initState() {
    super.initState();
    _data = _loadItems();
  }

  Future<List<Announcement>> _loadItems() async {
    return await announcementService.fetchAnnouncements(widget.category.url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                _data = _loadItems();
              });
            },
            tooltip: 'Osvježi',
          ),
        ],
      ),
      body: FutureBuilder(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              );
            }
            if (snapshot.hasError) {
              return ApiErrorWidget(
                onRetry: () {
                  setState(() {
                    _data = _loadItems();
                  });
                },
              );
            }
            if (snapshot.data!.isEmpty) {
              return const NoDataWidget();
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return AnnouncementCard(announcement: snapshot.data![index]);
              },
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
            );
          }),
    );
  }
}
