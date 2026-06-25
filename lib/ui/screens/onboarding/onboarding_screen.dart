import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    _Page('Welcome to HumanNode', 'Your local AI workspace that goes wherever you go.\nPrivate, offline-first, and powerful.',
        Icons.travel_explore_rounded, 'Your AI on your device'),
    _Page('Run Local Models', 'Download and run LLMs directly on your phone.\nNo cloud, no subscriptions, no tracking.',
        Icons.smart_toy_rounded, 'On-device inference'),
    _Page('Agentic Mode', 'Let HumanNode use tools to search, calculate, manage files,\nand help you accomplish real tasks.',
        Icons.auto_awesome_rounded, 'Powered by tools'),
    _Page('Ready to Go', 'Start chatting, create notes, and explore.\nEverything runs locally on your device.',
        Icons.rocket_launch_rounded, 'Get started'),
  ];
  int _current = 0;
  final _controller = PageController();

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.all(40),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [cs.primary.withAlpha(60), cs.tertiary.withAlpha(40)]),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(_pages[i].icon, size: 56, color: cs.primary),
                  ),
                  const SizedBox(height: 40),
                  Text(_pages[i].label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Text(_pages[i].title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(_pages[i].body, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.5, color: cs.onSurface.withAlpha(140))),
                ]),
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(4),
              width: i == _current ? 24 : 8, height: 8,
              decoration: BoxDecoration(
                color: i == _current ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          })),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (_current < _pages.length - 1) {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    context.go('/home');
                  }
                },
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(_current < _pages.length - 1 ? 'Next' : 'Get Started', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          if (_current < _pages.length - 1)
            TextButton(onPressed: () => context.go('/home'), child: Text('Skip', style: TextStyle(color: cs.onSurface.withAlpha(100)))),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override void dispose() { _controller.dispose(); super.dispose(); }
}

class _Page {
  final String title;
  final String body;
  final IconData icon;
  final String label;
  const _Page(this.title, this.body, this.icon, this.label);
}
