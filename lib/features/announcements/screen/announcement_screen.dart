import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/announcements/widget/announcement_card.dart';
import 'package:etf_oglasi/features/announcements/widget/api_error_widget.dart';
import 'package:etf_oglasi/features/announcements/widget/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnnouncementScreen extends ConsumerStatefulWidget {
  static const id = 'announcement_screen';

  const AnnouncementScreen({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends ConsumerState<AnnouncementScreen> {
  late Future<List<Announcement>> _data;
  late AnnouncementService _announcementService;
  late AnnouncementRepository _announcementRepository;
  bool _isRefreshing = false;
  @override
  void initState() {
    super.initState();
    _announcementService = ref.read(announcementServiceProvider);
    _announcementRepository = ref.read(announcementRepositoryProvider);
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (_isRefreshing) {
      setState(() {
        _isRefreshing = true;
      });
    }

    _data = _announcementService.fetchAnnouncements(widget.category.url!);
    try {
      final announcements = await _data;
      await _announcementRepository.saveAnnouncements(
          widget.category.url!, announcements);
    } finally {
      if (_isRefreshing) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadItems();
              });
            },
            tooltip: 'Osvježi',
          ),
        ],
      ),
      body: FutureBuilder(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !_isRefreshing) {
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
                    _loadItems();
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
