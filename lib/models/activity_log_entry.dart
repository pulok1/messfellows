import '../core/utils/money.dart';
import 'activity_type.dart';

/// One row in the Activity Log: a record of something that changed, kept
/// forever (unlike the Recycle Bin, this is meant to be a permanent audit
/// trail, not something that auto-purges).
class ActivityLogEntry {
  final String id;
  final String messId;
  final ActivityType type;

  /// The member the event is *about* — who paid/received a bazar entry or
  /// payment, or who was added/archived/reactivated. Null for events with
  /// no natural member association (rules, month close/reopen) — the app
  /// has no login, so there's no "current user" to attribute those to.
  final String? memberId;

  final Money? amount;

  /// Free-text detail that never needs translation: a bazar list, a
  /// payment note, or a rule title.
  final String? detail;

  /// Set only for [ActivityType.monthClosed]/[ActivityType.monthReopened],
  /// so the month name can be formatted in whatever language is active at
  /// read time rather than frozen into English when the event happened.
  final int? year;
  final int? month;

  final int? count;

  final DateTime createdAt;

  const ActivityLogEntry({
    required this.id,
    required this.messId,
    required this.type,
    this.memberId,
    this.amount,
    this.detail,
    this.year,
    this.month,
    this.count,
    required this.createdAt,
  });
}
