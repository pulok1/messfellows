/// A newer build of the app found on GitHub — see
/// `UpdateCheckerService.checkForUpdate`.
class AppUpdateInfo {
  final String version;
  final int buildNumber;
  final String downloadUrl;

  const AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
  });
}
