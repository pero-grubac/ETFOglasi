import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_notifier.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:flutter_test/flutter_test.dart';

Announcement _announcement(int id) => Announcement(
  id: id,
  naslov: 'Oglas $id',
  sadrzaj: '',
  vrijemeKreiranja: DateTime(2026),
  vrijemeIsteka: DateTime(2026, 2),
  oglasnaPloca: OglasnaPloca(id: 1),
  oglasPrilozi: const [],
);

class _FakeService extends AnnouncementService {
  _FakeService(this.announcements) : super(service: ApiService());
  final List<Announcement> announcements;

  @override
  Future<List<Announcement>> fetchAnnouncements(String url) async =>
      announcements;
}

class _FakeRepository implements AnnouncementRepository {
  final Map<String, List<Announcement>> stored = {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Announcement>?> findAnnouncementsById(String id) async =>
      stored[id];

  @override
  Future<void> saveAnnouncements(
    String id,
    List<Announcement> announcements,
  ) async {
    stored[id] = announcements;
  }
}

void main() {
  const url = 'board';

  test('first check stores the board without reporting anything', () async {
    final repository = _FakeRepository();

    final result = await fetchNewAnnouncements(
      url: url,
      service: _FakeService([_announcement(1), _announcement(2)]),
      repository: repository,
    );

    expect(result, isEmpty);
    expect(repository.stored[url]!.map((a) => a.id), [1, 2]);
  });

  test('reports only announcements that were not stored before', () async {
    final repository = _FakeRepository()
      ..stored[url] = [_announcement(1), _announcement(2)];

    final result = await fetchNewAnnouncements(
      url: url,
      service: _FakeService([
        _announcement(3),
        _announcement(1),
        _announcement(2),
      ]),
      repository: repository,
    );

    expect(result.map((a) => a.id), [3]);
    expect(repository.stored[url]!.map((a) => a.id), [3, 1, 2]);
  });

  test('a second check with no changes reports nothing', () async {
    final repository = _FakeRepository()..stored[url] = [_announcement(1)];

    final result = await fetchNewAnnouncements(
      url: url,
      service: _FakeService([_announcement(1)]),
      repository: repository,
    );

    expect(result, isEmpty);
  });
}
