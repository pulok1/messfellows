import 'package:flutter/material.dart';

/// A section heading used to introduce a group of related content within a
/// screen (e.g. "Settlement", "Bazar history", "Local data") — one shared
/// look instead of each screen choosing its own text style/padding.
class SectionHeader extends StatelessWidget {
  final String title;

  /// Horizontal inset before the title. Screens that already pad their
  /// scroll view (most of them) should leave this at zero; screens that
  /// place the header directly in an unpadded list (like Settings) pass
  /// their own inset.
  final EdgeInsetsGeometry padding;

  const SectionHeader(this.title, {super.key, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
