import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/gen/app_localizations.dart';

/// The shared "floating card" top bar used by every screen instead of a
/// flat [AppBar] — a rounded, softly-shadowed card containing the title,
/// an optional subtitle, a back button when the route can pop, trailing
/// actions, and an optional [bottom] slot for a screen's own navigation
/// controls (a tab bar, a date/month selector) so that content reads as
/// part of the same header panel rather than a separate row below it.
///
/// [DashboardHeaderCard] is the Home tab's own richer variant of this same
/// visual language (a branded icon avatar, gradient fill); every other
/// screen uses this plain version so the app still reads as one system.
class PageHeaderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? bottom;
  final bool showBackButton;

  const PageHeaderCard({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canPop = showBackButton && Navigator.of(context).canPop();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (canPop) ...[
                _HeaderIconButton(
                  icon: Icons.arrow_back,
                  tooltip: AppLocalizations.of(context).back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppSpacing.xs),
              ] else
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              for (final action in actions)
                Padding(padding: const EdgeInsets.only(left: 4), child: action),
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: AppSpacing.xs),
            bottom!,
          ],
        ],
      ),
    );
  }
}

/// A rounded, tonal icon button used inside header cards — consistent
/// look for back buttons and trailing actions alike.
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  /// A small count on the icon's corner for something worth a look behind
  /// this action; hidden when null or 0.
  final int? badgeCount;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return _HeaderIconButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
      color: color,
      badgeCount: badgeCount,
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
  final int? badgeCount;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      icon: Badge.count(
        count: badgeCount ?? 0,
        isLabelVisible: (badgeCount ?? 0) > 0,
        child: Icon(icon, size: 20),
      ),
      onPressed: onPressed,
      color: color ?? colorScheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
        shape: const CircleBorder(),
      ),
    );
  }
}
