import 'package:flutter/material.dart';

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
/// lose scroll position or in-progress state.
class HomeShell extends StatefulWidget {
  final Mess mess;

  const HomeShell({super.key, required this.mess});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _goToMealsTab() => setState(() => _currentIndex = 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      DashboardScreen(mess: widget.mess),
      MealsScreen(messId: widget.mess.id),
      BazarScreen(messId: widget.mess.id),
      ReportScreen(mess: widget.mess),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
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
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _NavItem(
              icon: Icons.restaurant_outlined,
              selectedIcon: Icons.restaurant,
              label: l10n.navMeals,
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 48),
            _NavItem(
              icon: Icons.shopping_basket_outlined,
              selectedIcon: Icons.shopping_basket,
              label: l10n.navBazar,
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _NavItem(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long,
              label: l10n.navReport,
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
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
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}
