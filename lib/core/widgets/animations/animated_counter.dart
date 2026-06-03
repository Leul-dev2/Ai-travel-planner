// ─── Animated Counter ────────────────────────────────────────────────
// Animates from 0 to a target number. Great for stats dashboards.

import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';

class AnimatedCounter extends StatefulWidget {
  final double value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;
  final int decimals;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.decimals = 0,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.value)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = _anim.value;
      _anim = Tween<double>(begin: _oldValue, end: widget.value)
          .chain(CurveTween(curve: Curves.easeOutCubic))
          .animate(_ctrl);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final displayValue = widget.decimals > 0
            ? _anim.value.toStringAsFixed(widget.decimals)
            : _anim.value.toInt().toString();
        return Text(
          '${widget.prefix ?? ''}$displayValue${widget.suffix ?? ''}',
          style: widget.style ?? AppTypography.headlineLarge,
        );
      },
    );
  }
}
