import 'package:flutter/material.dart';

import '../../../core/theme/app_logo.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/localized_date.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/mess.dart';
import '../../shared/widgets/page_header_card.dart';

/// The Dashboard's top bar, on the same [HeaderBar] as every other screen:
/// a small logo tile, the mess name with the current month beneath it, and
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
    final colorScheme = Theme.of(context).colorScheme;
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
                color: colorScheme.primary,
              ),
              child: Center(
                child: AppLogoMark(size: 22, color: colorScheme.onPrimary),
              ),
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
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    formatMonthYear(context, month.year, month.month),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
}
