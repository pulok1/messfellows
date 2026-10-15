import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/core/services/update_checker_service.dart';
import 'package:messfellows/providers/update_check_provider.dart';

void main() {
  const body = '''
- Sign in or sign up with Google
- Correct meal rate rounding

---
messfellows.apk for current 64-bit phones; messfellows-32bit.apk for older 32-bit phones.
''';

  final release = {
    'tag_name': 'v1.0.0-build.212',
    'body': body,
    'assets': [
      {
        'name': 'messfellows.apk',
        'size': 23068672,
        'browser_download_url': 'https://example.com/64.apk',
      },
      {
        'name': 'messfellows-32bit.apk',
        'size': 20971520,
        'browser_download_url': 'https://example.com/32.apk',
      },
    ],
  };

  test('reads build, notes and the 64-bit APK from a release', () {
    final info = UpdateCheckerService.parseRelease(release, arm32: false)!;
    expect(info.version, '1.0.0');
    expect(info.buildNumber, 212);
    expect(info.downloadUrl, 'https://example.com/64.apk');
    expect(info.sizeBytes, 23068672);
    expect(info.notes, [
      'Sign in or sign up with Google',
      'Correct meal rate rounding',
    ]);
  });

  test('a 32-bit build is offered the 32-bit APK', () {
    final info = UpdateCheckerService.parseRelease(release, arm32: true)!;
    expect(info.downloadUrl, 'https://example.com/32.apk');
  });

  test('releases not tagged by CI are ignored', () {
    expect(
      UpdateCheckerService.parseRelease({'tag_name': 'v1.0.0'}, arm32: false),
      isNull,
    );
  });

  test('"Later" hides a build for a day, and never hides a newer one', () {
    final at = DateTime(2026, 10, 15, 9);
    bool snoozed(int build, Duration later) => isSnoozed(
      build: build,
      snoozedBuild: 212,
      snoozedAt: at,
      now: at.add(later),
    );
    expect(snoozed(212, const Duration(hours: 23)), isTrue);
    expect(snoozed(212, const Duration(hours: 25)), isFalse);
    expect(snoozed(213, const Duration(minutes: 1)), isFalse);
  });
}
