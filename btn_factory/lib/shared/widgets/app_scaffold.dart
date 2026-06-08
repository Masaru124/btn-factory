import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        return;
      case 1:
        context.go('/orders');
        return;
      case 2:
        context.go('/raw-material');
        return;
      case 3:
        context.go('/casting');
        return;
      case 4:
        context.go('/turning');
        return;
      case 5:
        context.go('/polish');
        return;
      case 6:
        context.go('/packing');
        return;
      case 7:
        context.go('/reports');
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) => _navigate(context, index),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.grain_outlined), label: 'Raw'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), label: 'Casting'),
          NavigationDestination(icon: Icon(Icons.precision_manufacturing_outlined), label: 'Turning'),
          NavigationDestination(icon: Icon(Icons.auto_fix_high_outlined), label: 'Polish'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Packing'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined), label: 'Reports'),
        ],
      ),
    );
  }
}
