import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem(this.icon, this.label, this.route);
}

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.child,
  });

  final int selectedIndex;
  final String title;
  final Widget child;

  List<NavItem> _getNavItems(String role) {
    final base = [
      const NavItem(Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
      const NavItem(Icons.list_alt_outlined, 'Orders', '/orders'),
    ];
    switch (role) {
      case 'super_admin':
        return [
          ...base,
          const NavItem(Icons.grain_outlined, 'Raw', '/raw-material'),
          const NavItem(Icons.local_fire_department_outlined, 'Casting', '/casting'),
          const NavItem(Icons.precision_manufacturing_outlined, 'Turning', '/turning'),
          const NavItem(Icons.auto_fix_high_outlined, 'Polish', '/polish'),
          const NavItem(Icons.inventory_2_outlined, 'Packing', '/packing'),
          const NavItem(Icons.assessment_outlined, 'Reports', '/reports'),
        ];
      case 'raw_material':
        return [...base, const NavItem(Icons.grain_outlined, 'Raw', '/raw-material')];
      case 'casting':
        return [...base, const NavItem(Icons.local_fire_department_outlined, 'Casting', '/casting')];
      case 'turning':
        return [...base, const NavItem(Icons.precision_manufacturing_outlined, 'Turning', '/turning')];
      case 'polish':
        return [...base, const NavItem(Icons.auto_fix_high_outlined, 'Polish', '/polish')];
      case 'packing':
        return [...base, const NavItem(Icons.inventory_2_outlined, 'Packing', '/packing')];
      default:
        return base;
    }
  }

  String _getRouteForStaticIndex(int index) {
    switch (index) {
      case 0:
        return '/dashboard';
      case 1:
        return '/orders';
      case 2:
        return '/raw-material';
      case 3:
        return '/casting';
      case 4:
        return '/turning';
      case 5:
        return '/polish';
      case 6:
        return '/packing';
      case 7:
        return '/reports';
      default:
        return '/dashboard';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider).value;
    final userRole = authState?.userRole ?? 'super_admin';
    final navItems = _getNavItems(userRole);

    final currentRoute = _getRouteForStaticIndex(selectedIndex);
    int activeNavIndex = navItems.indexWhere((item) => item.route == currentRoute);
    if (activeNavIndex == -1) {
      activeNavIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'User Profile',
              onPressed: () => context.go('/profile'),
            ),
          ),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeNavIndex,
        onDestinationSelected: (int index) {
          context.go(navItems[index].route);
        },
        destinations: navItems
            .map((item) => NavigationDestination(icon: Icon(item.icon), label: item.label))
            .toList(),
      ),
    );
  }
}
