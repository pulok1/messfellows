import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/app_update_info.dart';

enum UpdatePhase {
  downloading,

  /// The APK is downloaded and Android's installer is on screen. It
  /// installs over the current app (same id and signing key), keeping data.
  installing,

  /// The user hasn't allowed this app to install apps yet. Android shows
  /// that switch itself the first time; trying again after allowing works.
  permissionDenied,
  failed,
}

class UpdateProgress {
  final UpdatePhase phase;

  /// 0–1 while downloading.
  final double? fraction;
  final Object? error;

  const UpdateProgress(this.phase, {this.fraction, this.error});
}

/// Carries out an update [UpdateCheckerService] found.
class AppUpdater {
  const AppUpdater();

  /// Android: downloads the APK inside the app, then opens the system
  /// installer.
  Stream<UpdateProgress> installApk(AppUpdateInfo info) async* {
    yield const UpdateProgress(UpdatePhase.downloading, fraction: 0);
    try {
      await for (final event in OtaUpdate().execute(
        info.downloadUrl!,
        destinationFilename: 'messfellows-update.apk',
      )) {
        switch (event.status) {
          case OtaStatus.DOWNLOADING:
            final percent = double.tryParse(event.value ?? '') ?? 0;
            yield UpdateProgress(
              UpdatePhase.downloading,
              fraction: (percent / 100).clamp(0, 1),
            );
          case OtaStatus.INSTALLING:
          case OtaStatus.INSTALLATION_DONE:
            yield const UpdateProgress(UpdatePhase.installing);
            return;
          case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
            yield const UpdateProgress(UpdatePhase.permissionDenied);
            return;
          default:
            yield UpdateProgress(UpdatePhase.failed, error: event.value);
            return;
        }
      }
    } catch (e) {
      yield UpdateProgress(UpdatePhase.failed, error: e);
    }
  }

  /// Fallback when the in-app download fails: the browser downloads the APK.
  Future<void> openInBrowser(AppUpdateInfo info) => launchUrl(
    Uri.parse(info.downloadUrl!),
    mode: LaunchMode.externalApplication,
  );

  /// Web: loading the page again picks up the new deploy.
  Future<void> reloadWeb() => launchUrl(Uri.base, webOnlyWindowName: '_self');
}
