// ─── Staggered List Animation ────────────────────────────────────────
// Wraps a list of children in staggered fade+slide entrance animations.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final Offset slideOffset;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 400),
    this.slideOffset = const Offset(0, 24),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return child
            .animate(delay: itemDelay * index)
            .fadeIn(duration: itemDuration, curve: Curves.easeOut)
            .slideY(
              begin: slideOffset.dy / 100,
              end: 0,
              duration: itemDuration,
              curve: Curves.easeOutCubic,
            );
      }).toList(),
    );
  }
}

/// Wraps a single widget with a staggered animation by index.
class StaggeredItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;

  const StaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: baseDelay * index)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .slideY(
          begin: 0.15,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Wraps any sliver list items with staggered animation support.
extension StaggerExtension on Widget {
  Widget staggered(int index, {Duration delay = const Duration(milliseconds: 60)}) {
    return animate(delay: delay * index)
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
