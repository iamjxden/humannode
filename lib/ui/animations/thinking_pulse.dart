import 'package:flutter/material.dart';

class ThinkingPulse extends StatefulWidget {
  final double size;
  final Color? color;
  const ThinkingPulse({super.key, this.size = 8, this.color});
  @override State<ThinkingPulse> createState() => _ThinkingPulseState();
}

class _ThinkingPulseState extends State<ThinkingPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  }

  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final color = widget.color ?? Theme.of(context).colorScheme.onSurface;
        return Row(mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: widget.size, height: widget.size,
                decoration: BoxDecoration(
                  color: color.withAlpha(60 + ((_ctrl.value * 3 + i * 0.5) % 1 * 120).round()),
                  shape: BoxShape.circle,
                ),
              ),
            )));
      },
    );
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({super.key, required super.listenable, required this.builder});
  @override Widget build(BuildContext context) => builder(context, null);
}
