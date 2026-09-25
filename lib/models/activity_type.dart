/// Every kind of event the Activity Log records. Persisted by name in
/// SQLite (via Drift's `textEnum`) — never reorder or rename existing
/// values, only append new ones, or old rows will fail to decode.
///
/// Deliberately excludes routine meal-slot taps: those are the single
/// highest-frequency action in the app and logging every tap would drown
/// out everything else worth reviewing. The Meals tab is already the
/// record of what was eaten; the Activity Log is for what changed.
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
}
