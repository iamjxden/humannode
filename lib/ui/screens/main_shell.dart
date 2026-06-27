import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  bool _drawerOpen = false;
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  static const _navItems = [
    _NavItem(Icons.chat_bubble_rounded, 'Chat', '/home'),
    _NavItem(Icons.smart_toy_rounded, 'Models', '/home/models'),
    _NavItem(Icons.notes_rounded, 'Notes', '/home/notes'),
    _NavItem(Icons.settings_rounded, 'Settings', '/home/settings'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  void _openDrawer() {
    setState(() => _drawerOpen = true);
    _ctrl.forward();
  }

  void _closeDrawer() {
    _ctrl.reverse().then((_) => setState(() => _drawerOpen = false));
  }

  void _navigate(String route) {
    _closeDrawer();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) context.go(route);
    });
  }

  String _currentRoute(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).uri.toString();
    if (loc.startsWith('/home/models')) return '/home/models';
    if (loc.startsWith('/home/notes')) return '/home/notes';
    if (loc.startsWith('/home/settings')) return '/home/settings';
    return '/home';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _currentRoute(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(children: [
        widget.child,
        if (_drawerOpen) ...[
          FadeTransition(
            opacity: _fade,
            child: GestureDetector(
              onTap: _closeDrawer,
              child: Container(color: Colors.black54),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(_slide),
            child: _Drawer(
              currentRoute: currentRoute,
              navItems: _navItems,
              onNavigate: _navigate,
              onClose: _closeDrawer,
            ),
          ),
        ],
      ]),
      floatingActionButton: FloatingActionButton(
        mini: true,
        heroTag: 'drawer_btn',
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.primary,
        elevation: 2,
        onPressed: _drawerOpen ? _closeDrawer : _openDrawer,
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _ctrl,
          size: 22,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

class _Drawer extends StatelessWidget {
  final String currentRoute;
  final List<_NavItem> navItems;
  final void Function(String) onNavigate;
  final VoidCallback onClose;

  const _Drawer({
    required this.currentRoute,
    required this.navItems,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(4, 0),
          )
        ],
      ),
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.travel_explore_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('HumanNode',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: cs.onSurface,
                        letterSpacing: -0.5)),
                Text('Local AI Workspace',
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withAlpha(120))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Divider(color: cs.outlineVariant, height: 1),
          const SizedBox(height: 8),
          ...navItems.map((item) {
            final active = currentRoute == item.route;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Material(
                color: active ? cs.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onNavigate(item.route),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    child: Row(children: [
                      Icon(item.icon,
                          size: 22,
                          color: active ? cs.primary : cs.onSurface.withAlpha(160)),
                      const SizedBox(width: 14),
                      Text(item.label,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? cs.primary
                                  : cs.onSurface.withAlpha(180))),
                    ]),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Divider(color: cs.outlineVariant, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.circle, size: 8, color: Colors.green.shade400),
              const SizedBox(width: 8),
              Text('On-device inference',
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withAlpha(120))),
            ]),
          ),
        ]),
      ),
    );
  }
}
