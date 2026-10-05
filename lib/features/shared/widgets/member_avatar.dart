import 'package:flutter/material.dart';

/// A member's initials on a colour of their own, so the same person is
/// recognisable at a glance on every screen (dashboard, bazar, members,
/// report) without reading the name.
///
/// The colour comes from the member's id, not their name, so renaming
/// someone keeps their colour, and it's computed with a fixed hash rather
/// than [String.hashCode], which isn't guaranteed stable between runs.
class MemberAvatar extends StatelessWidget {
  final String memberId;
  final String name;
  final double radius;

  /// Greys the avatar out — for archived members, or a payer who's no
  /// longer known.
  final bool muted;

  const MemberAvatar({
    super.key,
    required this.memberId,
    required this.name,
    this.radius = 18,
    this.muted = false,
  });

  /// (soft background, strong foreground) pairs for light mode. Dark mode
  /// flips them: the strong tone, dimmed, as background and the soft tone
  /// as text.
  static const _palette = [
    (Color(0xFFDFF1E8), Color(0xFF0F5A3E)), // emerald
    (Color(0xFFE0ECFB), Color(0xFF1D4E89)), // blue
    (Color(0xFFFDEFD6), Color(0xFF8A5300)), // amber
    (Color(0xFFFBE3E6), Color(0xFF9B2C3F)), // rose
    (Color(0xFFECE6FA), Color(0xFF5B3E96)), // violet
    (Color(0xFFDDF2F2), Color(0xFF0E6464)), // teal
    (Color(0xFFFDE7DA), Color(0xFF9A4317)), // orange
    (Color(0xFFE6EAEE), Color(0xFF3D4B5A)), // slate
  ];

  static int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  /// Up to two initials: "Rahim Uddin" → "RU", "Karim" → "K".
  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final Color background;
    final Color foreground;
    if (muted) {
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurfaceVariant;
    } else {
      final (soft, strong) = _palette[_stableHash(memberId) % _palette.length];
      background = isDark ? strong.withValues(alpha: 0.55) : soft;
      foreground = isDark ? soft : strong;
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      foregroundColor: foreground,
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
          height: 1,
        ),
      ),
    );
  }
}
