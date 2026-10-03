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
    final foreground = AppTheme.onTopBarColor(Theme.of(context).colorScheme);
    final textTheme = Theme.of(context).textTheme;
    final canPop = showBackButton && Navigator.of(context).canPop();

    return HeaderBar(
      bottom: bottom,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
          children: [
            if (canPop)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.8),
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
    );
  }
}

/// The surface every top bar sits on: a full-width [AppTheme.topBarColor]
/// bar drawn under the status bar, with an optional [bottom] strip (a month
/// or date selector) on the plain chrome colour just beneath it.
///
/// It reacts to the screen's scrolling: the shadow deepens once content is
/// under the bar, and the title row slides away while scrolling down a long
/// list and returns on the first scroll back up (the Gmail/Chrome pattern),
/// handing the space to content. It listens to the enclosing [Scaffold]'s
/// [ScrollNotificationObserver], so screens don't need to wire anything up.
class HeaderBar extends StatefulWidget {
  final Widget child;
  final Widget? bottom;

  const HeaderBar({super.key, required this.child, this.bottom});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  ScrollNotificationObserverState? _observer;
  bool _scrolledUnder = false;

  /// Whether the title row is slid away. The [HeaderBar.bottom] strip and
  /// the status bar fill stay put, so a screen's month/date selector is
  /// always reachable.
  bool _collapsed = false;

  /// How far a single scroll update has to move before the title row hides
  /// or returns, so slow drifts and tiny flings don't make it flicker.
  static const double _collapseThreshold = 4;

  /// Lists shorter than this never collapse the bar: hiding it grows the
  /// viewport by the bar's height, and on a barely-scrollable list that can
  /// remove the scroll range that triggered the hide in the first place.
  static const double _minScrollExtentToCollapse = 160;

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
    if (metrics.axis != Axis.vertical) return;

    final scrolledUnder = metrics.axisDirection == AxisDirection.down
        ? metrics.extentBefore > 0
        : metrics.extentAfter > 0;

    var collapsed = _collapsed;
    final delta = notification.scrollDelta ?? 0;
    if (metrics.extentBefore <= 0 ||
        metrics.maxScrollExtent < _minScrollExtentToCollapse) {
      collapsed = false;
    } else if (delta > _collapseThreshold) {
      collapsed = true;
    } else if (delta < -_collapseThreshold) {
      collapsed = false;
    }

    if (scrolledUnder != _scrolledUnder || collapsed != _collapsed) {
      setState(() {
        _scrolledUnder = scrolledUnder;
        _collapsed = collapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottom = widget.bottom;
    final duration = AppMotion.of(context, AppMotion.medium);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: headerOverlayStyle(context),
      child: AnimatedContainer(
        duration: duration,
        curve: AppMotion.emphasized,
        decoration: BoxDecoration(
          color: AppTheme.chromeColor(colorScheme),
          // Always slightly lifted off the body; deeper once content is
          // actually scrolling underneath.
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: _scrolledUnder ? 0.16 : 0.06,
              ),
              blurRadius: _scrolledUnder ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: AppTheme.topBarColor(colorScheme),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top,
                ),
                child: ClipRect(
                  child: AnimatedAlign(
                    duration: duration,
                    curve: AppMotion.emphasized,
                    alignment: Alignment.bottomCenter,
                    heightFactor: _collapsed ? 0 : 1,
                    child: AnimatedOpacity(
                      duration: duration,
                      opacity: _collapsed ? 0 : 1,
                      child: IconButtonTheme(
                        data: IconButtonThemeData(
                          style: IconButton.styleFrom(
                            foregroundColor: AppTheme.onTopBarColor(
                              colorScheme,
                            ),
                          ),
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (bottom != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: bottom,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Status bar styling for screens whose header draws under the status bar:
/// a transparent bar so the header colour shows through, with light icons —
/// [AppTheme.topBarColor] is dark enough for them in both themes.
SystemUiOverlayStyle headerOverlayStyle(BuildContext context) =>
    SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

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
      // Null falls through to the bar's IconButtonTheme foreground.
      color: color,
    );
  }
}
