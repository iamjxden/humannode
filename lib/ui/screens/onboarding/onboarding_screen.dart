import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humannode/core/di/service_locator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.travel_explore_rounded,
      title: 'Run AI Locally',
      body:
          'HumanNode runs language models directly on your device. No cloud, no subscriptions, no data leaving your phone.',
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Agentic Mode',
      body:
          'Give HumanNode a task and let it work. It can search the web, run code, manage files, and take notes on your behalf.',
    ),
    _OnboardingPage(
      icon: Icons.lock_rounded,
      title: 'Private by Design',
      body:
          'Your conversations, notes, and models stay on your device. Nothing is ever sent to a server.',
    ),
  ];

  Future<void> _finish() async {
    await ServiceLocator.settingsDao.set('onboarding_complete', 'true');
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _pages[i].build(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? cs.primary
                          : cs.primary.withAlpha(60),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLast
                      ? _finish
                      : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (!isLast)
                TextButton(
                  onPressed: _finish,
                  child: Text('Skip',
                      style: TextStyle(color: cs.onSurface.withAlpha(120))),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage(
      {required this.icon, required this.title, required this.body});

  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: cs.primary.withAlpha(60),
                    blurRadius: 40,
                    offset: const Offset(0, 12))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 48),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Text(body,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: cs.onSurface.withAlpha(160))),
        ],
      ),
    );
  }
}
