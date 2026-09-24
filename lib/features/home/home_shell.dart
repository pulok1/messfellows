import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../models/mess.dart';
import '../bazar/bazar_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../meals/meals_screen.dart';
import '../reports/report_screen.dart';
import '../shared/quick_add/quick_add_sheet.dart';

/// The main app shell (section 12): Home / Meals / Bazar / Report on the
/// bottom nav, with the Quick Add FAB always available. Each tab keeps its
/// own AppBar (title/actions differ per tab); this shell only owns the
/// bottom nav and FAB, wrapped by IndexedStack so switching tabs doesn't
/// lose scroll position or in-progress state. Switching tabs fades the new
/// one in with a slight upward drift.
class HomeShell extends StatefulWidget {
  final Mess mess;

  const HomeShell({super.key, required this.mess});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _tabFade = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
    value: 1,
  );
  late final Animation<double> _tabCurve = CurvedAnimation(
    parent: _tabFade,
    curve: AppMotion.emphasized,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabFade.duration = AppMotion.of(context, AppMotion.medium);
  }

  @override
  void dispose() {
    _tabFade.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _tabFade.forward(from: 0);
  }

  void _goToMealsTab() => _selectTab(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      DashboardScreen(mess: widget.mess, onOpenMeals: _goToMealsTab),
      MealsScreen(mess: widget.mess),
      BazarScreen(messId: widget.mess.id),
      ReportScreen(mess: widget.mess),
    ];

    return Scaffold(
      body: FadeTransition(
        opacity: _tabCurve,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.015),
            end: Offset.zero,
          ).animate(_tabCurve),
          child: IndexedStack(index: _currentIndex, children: tabs),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuickAddSheet(
          context,
          messId: widget.mess.id,
          onSelectMeal: _goToMealsTab,
        ),
        tooltip: l10n.quickAddTooltip,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: l10n.navHome,
              isSelected: _currentIndex == 0,
              onTap: () => _selectTab(0),
            ),
            _NavItem(
              icon: Icons.restaurant_outlined,
              selectedIcon: Icons.restaurant,
              label: l10n.navMeals,
              isSelected: _currentIndex == 1,
              onTap: () => _selectTab(1),
            ),
            const SizedBox(width: 48),
            _NavItem(
              icon: Icons.shopping_basket_outlined,
              selectedIcon: Icons.shopping_basket,
              label: l10n.navBazar,
              isSelected: _currentIndex == 2,
              onTap: () => _selectTab(2),
            ),
            _NavItem(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long,
              label: l10n.navReport,
              isSelected: _currentIndex == 3,
              onTap: () => _selectTab(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    final duration = AppMotion.of(context, AppMotion.medium);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Material 3 style indicator pill that grows in behind the
            // selected icon.
            AnimatedContainer(
              duration: duration,
              curve: AppMotion.emphasized,
              width: isSelected ? 52 : 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.secondaryContainer
                    : colorScheme.secondaryContainer.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: duration,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : color,
                fontSize: 12,
                height: 1,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
