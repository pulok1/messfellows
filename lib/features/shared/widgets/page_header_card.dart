import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';

/// The shared top bar used by every screen instead of an [AppBar], laid out
/// like a Material 3 small top app bar: a back button when the route can
/// pop, the title (and an optional subtitle), plain trailing icon actions,
/// and an optional [bottom] slot for a screen's own navigation controls (a
/// tab bar, a date/month selector) so they read as part of the same bar.
///
/// [DashboardHeaderCard] is the Home tab's own variant (a logo tile and the
/// mess name); both sit on [HeaderBar] so they look and behave the same.
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

    return HeaderBar(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Row(
              children: [
                if (canPop)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: HeaderIconButton(
                      icon: Icons.arrow_back,
                      tooltip: AppLocalizations.of(context).back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                else
                  const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                ...actions,
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
          ),
          if (bottom != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: bottom!,
            ),
        ],
      ),
    );
  }
}

/// The surface every top bar sits on: full-width, drawn under the status
/// bar (with the status bar icons matched to the theme), and flat while the
/// screen is scrolled to the top. Once content scrolls underneath it a
/// divider and soft shadow fade in to separate the two, the same cue a
/// Material 3 [AppBar] gives — it listens to the enclosing [Scaffold]'s
/// [ScrollNotificationObserver], so screens don't need to wire anything up.
class HeaderBar extends StatefulWidget {
  final Widget child;

  const HeaderBar({super.key, required this.child});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  ScrollNotificationObserverState? _observer;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer?.removeListener(_handleScroll);
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _observer?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification ||
        !defaultScrollNotificationPredicate(notification)) {
      return;
    }
    final metrics = notification.metrics;
    // Horizontal scrollers (chip rows, month strips) say nothing about
    // whether content sits under the bar.
    final scrolledUnder = switch (metrics.axisDirection) {
      AxisDirection.down => metrics.extentBefore > 0,
      AxisDirection.up => metrics.extentAfter > 0,
      AxisDirection.left || AxisDirection.right => _scrolledUnder,
    };
    if (scrolledUnder != _scrolledUnder) {
      setState(() => _scrolledUnder = scrolledUnder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: headerOverlayStyle(context),
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.short),
        curve: AppMotion.emphasized,
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        decoration: BoxDecoration(
          color: AppTheme.chromeColor(colorScheme),
          border: Border(
            bottom: BorderSide(
              color: _scrolledUnder
                  ? colorScheme.outlineVariant
                  : colorScheme.outlineVariant.withValues(alpha: 0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: _scrolledUnder ? 0.08 : 0,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Status bar styling for screens whose header draws under the status bar:
/// a transparent bar so the header colour shows through, with icons that
/// stay readable against it in both light and dark themes.
SystemUiOverlayStyle headerOverlayStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
      .copyWith(statusBarColor: Colors.transparent);
}

/// A standard top-bar icon button — a plain 24dp icon with the usual
/// circular press ripple — used for back buttons and trailing actions alike.
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
    return IconButton(
      tooltip: tooltip,
      icon: Badge.count(
        count: badgeCount ?? 0,
        isLabelVisible: (badgeCount ?? 0) > 0,
        child: Icon(icon),
      ),
      onPressed: onPressed,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
