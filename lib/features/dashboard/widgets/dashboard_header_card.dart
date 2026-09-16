import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../models/mess.dart';

/// The Dashboard's header, rendered as its own floating card rather than a
/// flat app bar — a rounded-square mess icon, the mess name, the current
/// month as a subtitle, and the Members/Settings actions grouped into one
/// tonal pill on the right.
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

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceContainerHigh,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
            ),
            child: Icon(
              Icons.ramen_dining,
              color: colorScheme.onPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mess.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _monthYear(month),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionPill(onMembers: onMembers, onSettings: onSettings),
        ],
      ),
    );
  }
}

/// Members + Settings grouped into one rounded, translucent pill instead of
/// two separate floating icon buttons.
class _ActionPill extends StatelessWidget {
  final VoidCallback onMembers;
  final VoidCallback onSettings;

  const _ActionPill({required this.onMembers, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(
            icon: Icons.group_outlined,
            tooltip: 'Members',
            onPressed: onMembers,
          ),
          _PillButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _PillButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      onPressed: onPressed,
    );
  }
}

String _monthYear(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
