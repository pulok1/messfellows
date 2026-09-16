import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// A single large, tappable meal toggle (Breakfast/Lunch/Dinner). No
/// confirmation dialog — tapping immediately flips the state, per section
/// 15's "avoid unnecessary confirmation dialogs" and "make meal-off easy".
class MealToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final VoidCallback onTap;

  const MealToggleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isOn ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final foreground = isOn ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: '$label, ${isOn ? "eaten" : "off"}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56, minWidth: 72),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
