import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeIn));
    _scale = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.8, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/home');
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Column(mainAxisSize: MainAxisSize.min, children: [
            FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cs.primary, cs.tertiary],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: cs.primary.withAlpha(80), blurRadius: 32, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 56),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fadeIn,
              child: Text('HumanNode', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -1)),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _fadeIn,
              child: Text('Your AI. Your device. Anywhere.',
                  style: TextStyle(fontSize: 15, color: cs.onSurface.withAlpha(140), fontWeight: FontWeight.w400)),
            ),
            const SizedBox(height: 52),
            FadeTransition(
              opacity: _ctrl,
              child: SizedBox(width: 26, height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.primary)),
            ),
          ]),
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({super.key, required super.listenable, required this.builder});
  @override Widget build(BuildContext context) => builder(context, null);
}
