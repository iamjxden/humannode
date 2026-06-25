import 'package:flutter/material.dart';
class ShimmerPlaceholder extends StatefulWidget {
  final double width; final double height; final double radius;
  const ShimmerPlaceholder({super.key, this.width = double.infinity, this.height = 16, this.radius = 8});
  @override State<ShimmerPlaceholder> createState() => _ShimmerState();
}
class _ShimmerState extends State<ShimmerPlaceholder> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); }
  @override Widget build(BuildContext context) => _Animated(animation: _ctrl, builder: (c, _) =>
    Container(width: widget.width, height: widget.height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
                stops: [_ctrl.value - 0.5, _ctrl.value, _ctrl.value + 0.5]))));
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
}
class _Animated extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const _Animated({required super.listenable, required this.builder});
  @override Widget build(BuildContext context) => builder(context, null);
}
