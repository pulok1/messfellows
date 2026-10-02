import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/app_update_info.dart';

/// Checks GitHub's releases API for a newer build than the one currently
/// installed, for the Home screen's "update available" banner.
///
/// The app isn't distributed through the Play Store or any other
/// auto-update channel (see docs/deployment.md): CI republishes the APK as
/// the GitHub release on every push, but an already-installed copy has no
/// way to learn that on its own. This is the only place in the app that
/// calls the network — it's a convenience, not something the rest of the
/// app depends on, so any failure (offline, rate-limited, malformed
/// response) is swallowed and just reports "no update found".
///
/// Only meaningful on Android: there's no APK to install on the web build
/// (it updates itself on the next page load) or on iOS (no APK target at
/// all — see the landing page's own iOS handling).
class UpdateCheckerService {
  static const _releaseApiUrl =
      'https://api.github.com/repos/pulok1/messfellows/releases/latest';
  static const _downloadUrl =
      'https://github.com/pulok1/messfellows/releases/latest/download/messfellows.apk';

  // CI tags releases as "v<pubspec version>-build.<commit count>" — see
  // .github/workflows/deploy.yml. The build number is what actually maps to
  // Android's versionCode, so it's what decides "is this newer", not the
  // semver part (which can stay unchanged across many builds).
  static final _tagPattern = RegExp(r'^v(.+)-build\.(\d+)$');

  final http.Client _client;

  UpdateCheckerService({http.Client? client}) : _client = client ?? http.Client();

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;

    try {
      final response = await _client
          .get(
            Uri.parse(_releaseApiUrl),
            headers: const {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final tag = (jsonDecode(response.body) as Map<String, dynamic>)['tag_name'] as String?;
      final match = tag == null ? null : _tagPattern.firstMatch(tag);
      if (match == null) return null;

      final latestBuild = int.parse(match.group(2)!);
      final currentInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(currentInfo.buildNumber) ?? 0;
      if (latestBuild <= currentBuild) return null;

      return AppUpdateInfo(
        version: match.group(1)!,
        buildNumber: latestBuild,
        downloadUrl: _downloadUrl,
      );
    } catch (_) {
      return null;
    }
  }
}
