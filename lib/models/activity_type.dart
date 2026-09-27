/// Every kind of event the Activity Log records. Persisted by name in
/// SQLite (via Drift's `textEnum`) — never reorder or rename existing
/// values, only append new ones, or old rows will fail to decode.
///
/// Deliberately excludes routine meal-slot taps on today or tomorrow: those
/// are the single highest-frequency action in the app and logging every tap
/// would drown out everything else worth reviewing. A meal changed *after
/// its day has passed* is logged ([mealChangedLater]), since that's exactly
/// the kind of change other members may want to check.
enum ActivityType {
  bazarAdded,
  bazarEdited,
  bazarDeleted,
  bazarRestored,
  bazarPurged,
  paymentAdded,
  paymentEdited,
  paymentDeleted,
  paymentRestored,
  paymentPurged,
  memberAdded,
  memberArchived,
  memberReactivated,
  ruleAdded,
  rulesBulkAdded,
  ruleUpdated,
  ruleDeleted,
  monthClosed,
  monthReopened,

  /// One meal slot on a past day changed, with the reason given — see
  /// ActivityLogs.mealDate/mealSlot/previousCount.
  mealChangedLater,
}
