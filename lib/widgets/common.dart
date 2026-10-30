import 'package:flutter/material.dart';

import '../theme.dart';

/// App mark in a rounded tile, taken from the Zyvro logo.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 46});
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.3),
        child: Image.asset('assets/icon/mark.png', width: size, height: size),
      );
}

/// Dark backdrop with a soft cobalt glow at the top.
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.15),
            radius: 1.1,
            colors: [Color(0xFF0B2250), Zy.bg],
          ),
        ),
        child: child,
      );
}

class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.color = Zy.danger,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(90)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 13.5, height: 1.3))),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      );
}

/// Four-bar signal indicator from RSSI.
class SignalBars extends StatelessWidget {
  const SignalBars({super.key, required this.rssi});
  final int? rssi;

  static int levelOf(int? rssi) {
    if (rssi == null) return 0;
    if (rssi >= -60) return 4;
    if (rssi >= -72) return 3;
    if (rssi >= -85) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final level = levelOf(rssi);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 1; i <= 4; i++)
          Container(
            width: 5,
            height: 5.0 + i * 4,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: i <= level ? Zy.cyan : Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

String proximityLabel(int? rssi) {
  switch (SignalBars.levelOf(rssi)) {
    case 4:
      return 'Very close';
    case 3:
      return 'Nearby';
    case 2:
      return 'In range';
    case 1:
      return 'Far away';
    default:
      return 'Measuring signal';
  }
}
