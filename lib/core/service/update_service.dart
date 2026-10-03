import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRelease {
  final String version;

  /// The GitHub release page, where the APKs can be downloaded.
  final String url;

  const AppRelease({required this.version, required this.url});
}

/// Looks for a newer release on GitHub. This is the only request the app
/// sends anywhere other than the ETF API.
class UpdateService {
  static const releasesPageUrl =
      'https://github.com/pero-grubac/ETFOglasi/releases';
  static const _latestReleaseUrl =
      'https://api.github.com/repos/pero-grubac/ETFOglasi/releases/latest';
  static const lastCheckKey = 'lastUpdateCheck';

  /// Releases come out about once a month, so weekly is enough.
  static const checkInterval = Duration(days: 7);

  final ApiService _service;

  UpdateService({required ApiService service}) : _service = service;

  Future<AppRelease> fetchLatestRelease() {
    return _service.fetchData(
      url: _latestReleaseUrl,
      headers: const {'Accept': 'application/vnd.github+json'},
      fromJson: (json) => AppRelease(
        version: normalizeVersion(json['tag_name'] as String),
        url: json['html_url'] as String? ?? releasesPageUrl,
      ),
    );
  }

  /// The newer release, or `null` when [currentVersion] is up to date.
  Future<AppRelease?> findUpdate(String currentVersion) async {
    final latest = await fetchLatestRelease();
    return isNewerVersion(latest.version, currentVersion) ? latest : null;
  }

  /// Whether [checkInterval] has passed since the last successful check.
  static Future<bool> isAutomaticCheckDue({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(lastCheckKey);
    if (last == null) return true;
    return (now ?? DateTime.now()).difference(
          DateTime.fromMillisecondsSinceEpoch(last),
        ) >=
        checkInterval;
  }

  /// Records a successful check. Failed checks (e.g. offline) aren't
  /// recorded, so the next start tries again.
  static Future<void> markChecked({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      lastCheckKey,
      (now ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }
}

/// `v1.2.0` → `1.2.0`; also drops a build suffix (`1.2.0+3`).
String normalizeVersion(String version) {
  var result = version.trim();
  if (result.startsWith('v') || result.startsWith('V')) {
    result = result.substring(1);
  }
  return result.split('+').first;
}

/// Compares dotted version numbers (`1.10.0` > `1.9.2`). Missing parts count
/// as 0; anything after a `-` (pre-release) is ignored.
bool isNewerVersion(String candidate, String current) {
  List<int> parts(String version) => normalizeVersion(
    version,
  ).split('-').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();

  final a = parts(candidate);
  final b = parts(current);
  for (var i = 0; i < a.length || i < b.length; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}
