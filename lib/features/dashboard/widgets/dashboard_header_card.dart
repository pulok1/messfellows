import 'package:flutter/material.dart';

import '../../../core/theme/app_logo.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/localized_date.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/mess.dart';
import '../../shared/widgets/page_header_card.dart';

/// The Dashboard's top bar, on the same [HeaderBar] as every other screen:
/// a translucent logo tile, the mess name with a time-of-day greeting and
/// the current month beneath it, and
/// Members/Settings as standard trailing icon actions.
class DashboardHeaderCard extends StatelessWidget {
  final Mess mess;
  final DateTime month;
  final VoidCallback onMembers;
  final VoidCallback onSettings;

  const DashboardHeaderCard({
    super.key,
    required this.mess,
    required this.month,
    required this.onMembers,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = AppTheme.onTopBarColor(Theme.of(context).colorScheme);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return HeaderBar(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                color: foreground.withValues(alpha: 0.18),
              ),
              child: Center(child: AppLogoMark(size: 22, color: foreground)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mess.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  Text(
                    '${_greeting(l10n, DateTime.now())} · '
                    '${formatMonthYear(context, month.year, month.month)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: foreground.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            HeaderIconButton(
              icon: Icons.group_outlined,
              tooltip: l10n.membersLabel,
              onPressed: onMembers,
            ),
            HeaderIconButton(
              icon: Icons.settings_outlined,
              tooltip: l10n.settingsLabel,
              onPressed: onSettings,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  /// A time-of-day greeting for the subtitle. Evening runs on through the
  /// night — "Good evening" at 2am still reads naturally, a "Good night"
  /// on opening the app would sound like a goodbye.
  static String _greeting(AppLocalizations l10n, DateTime now) =>
      switch (now.hour) {
        >= 5 && < 12 => l10n.greetingMorning,
        >= 12 && < 17 => l10n.greetingAfternoon,
        _ => l10n.greetingEvening,
      };
}
