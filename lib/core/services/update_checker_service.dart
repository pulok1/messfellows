import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/app_update_info.dart';
import '../utils/build_abi.dart';

/// Finds out whether a newer build than the running one has shipped.
///
/// The app isn't distributed through the Play Store or any other
/// auto-update channel (see docs/deployment.md): CI publishes every push to
/// `main` as a GitHub release and redeploys the web app, but a running copy
/// has no way to learn that on its own.
///
/// - **Android** compares its versionCode with the latest GitHub release.
/// - **Web** compares the build it was compiled as (`APP_BUILD_NUMBER`,
///   passed by CI) with the `version.json` currently deployed next to it,
///   so it only says "reload" once the new files are really there.
///
/// It's a convenience nothing else depends on: any failure (offline,
/// rate-limited, malformed response) just reports "no update".
class UpdateCheckerService {
  static const _releaseApiUrl =
      'https://api.github.com/repos/pulok1/messfellows/releases/latest';

  // CI tags releases as "v<pubspec version>-build.<commit count>" — see
  // .github/workflows/deploy.yml. The build number is what maps to
  // Android's versionCode, so it's what decides "is this newer", not the
  // semver part (which can stay unchanged across many builds).
  static final _tagPattern = RegExp(r'^v(.+)-build\.(\d+)$');

  /// Set by CI for web builds; 0 for local runs, which never prompt.
  static const _webBuildNumber = int.fromEnvironment('APP_BUILD_NUMBER');

  final http.Client _client;

  UpdateCheckerService({http.Client? client})
    : _client = client ?? http.Client();

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      if (kIsWeb) return await _checkWeb();
      if (defaultTargetPlatform != TargetPlatform.android) return null;
      final current = int.tryParse(
        (await PackageInfo.fromPlatform()).buildNumber,
      );
      final release = await _latestRelease();
      if (release == null || current == null) return null;
      final info = parseRelease(release, arm32: isArm32Android);
      return info != null && info.buildNumber > current ? info : null;
    } catch (_) {
      return null;
    }
  }

  Future<AppUpdateInfo?> _checkWeb() async {
    if (_webBuildNumber == 0) return null;
    // Cache-busted: the whole point is to see a deploy that happened after
    // this page loaded.
    final response = await _client
        .get(
          Uri.base.resolve(
            'version.json?t=${DateTime.now().millisecondsSinceEpoch}',
          ),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final deployed = jsonDecode(response.body) as Map<String, dynamic>;
    final build = int.tryParse('${deployed['build_number']}') ?? 0;
    if (build <= _webBuildNumber) return null;

    // Borrow the release notes when the release is the one deployed.
    final release = await _latestRelease();
    final notes = release == null ? null : parseRelease(release, arm32: false);
    return AppUpdateInfo(
      version: '${deployed['version'] ?? ''}',
      buildNumber: build,
      notes: notes?.buildNumber == build ? notes!.notes : const [],
    );
  }

  Future<Map<String, dynamic>?> _latestRelease() async {
    final response = await _client
        .get(
          Uri.parse(_releaseApiUrl),
          headers: const {'Accept': 'application/vnd.github+json'},
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Reads a GitHub release: its build number, the APK matching [arm32],
  /// and its "What's new" lines.
  @visibleForTesting
  static AppUpdateInfo? parseRelease(
    Map<String, dynamic> release, {
    required bool arm32,
  }) {
    final tag = release['tag_name'] as String?;
    final match = tag == null ? null : _tagPattern.firstMatch(tag);
    if (match == null) return null;

    final apkName = arm32 ? 'messfellows-32bit.apk' : 'messfellows.apk';
    final assets = (release['assets'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final apk = assets.where((a) => a['name'] == apkName).firstOrNull;

    return AppUpdateInfo(
      version: match.group(1)!,
      buildNumber: int.parse(match.group(2)!),
      downloadUrl:
          apk?['browser_download_url'] as String? ??
          'https://github.com/pulok1/messfellows/releases/latest/download/$apkName',
      sizeBytes: apk?['size'] as int?,
      notes: parseNotes(release['body'] as String? ?? ''),
    );
  }

  /// The "- " bullet lines CI writes above the `---` separator (below it is
  /// download info for people browsing GitHub, not for the app).
  @visibleForTesting
  static List<String> parseNotes(String body) {
    final notes = <String>[];
    for (final raw in const LineSplitter().convert(body)) {
      final line = raw.trim();
      if (line == '---') break;
      if (line.startsWith('- ')) notes.add(line.substring(2).trim());
    }
    return notes;
  }
}
