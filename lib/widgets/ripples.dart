import 'package:flutter/material.dart';

import '../theme.dart';

/// Expanding rings around [child]. Used as radar while scanning and as the
/// "ringing" pulse around the Find button.
class Ripples extends StatefulWidget {
  const Ripples({
    super.key,
    required this.active,
    required this.size,
    required this.child,
    this.color = Zy.cyan,
  });

  final bool active;
  final double size;
  final Widget child;
  final Color color;

  @override
  State<Ripples> createState() => _RipplesState();
}

class _RipplesState extends State<Ripples> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(Ripples old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.active)
            CustomPaint(
              size: Size.square(widget.size),
              painter: _RipplePainter(_c, widget.color),
            ),
          widget.child,
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.anim, this.color) : super(repaint: anim);
  final Animation<double> anim;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2;
    for (var i = 0; i < 3; i++) {
      final t = (anim.value + i / 3) % 1.0;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color.withAlpha(((1 - t) * 150).round());
      canvas.drawCircle(center, maxR * (0.4 + 0.6 * t), paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.color != color;
}
