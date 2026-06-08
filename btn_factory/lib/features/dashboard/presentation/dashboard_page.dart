import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider).value;

    return AppScaffold(
      selectedIndex: 0,
      title: 'Dashboard',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Welcome${authState?.userName == null ? '' : ', ${authState!.userName}'}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Track every order through raw material, casting, turning, polishing, packing, and dispatch.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1100
                  ? 5
                  : constraints.maxWidth >= 700
                      ? 3
                      : 2;

              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.8,
                children: const <Widget>[
                  MetricCard(title: 'Total Orders', value: '248', icon: Icons.shopping_bag_outlined, tint: Colors.teal),
                  MetricCard(title: 'Pending Orders', value: '34', icon: Icons.pending_actions_outlined, tint: Colors.orange),
                  MetricCard(title: 'Processing Orders', value: '96', icon: Icons.settings_outlined, tint: Colors.blue),
                  MetricCard(title: 'Completed Orders', value: '118', icon: Icons.verified_outlined, tint: Colors.green),
                  MetricCard(title: 'Revenue', value: '₹18.4M', icon: Icons.currency_rupee_outlined, tint: Colors.purple),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton.icon(onPressed: () => context.go('/orders/create'), icon: const Icon(Icons.add), label: const Text('Create Order')),
              FilledButton.tonalIcon(onPressed: () => context.go('/orders'), icon: const Icon(Icons.list_alt_outlined), label: const Text('View Orders')),
              FilledButton.tonalIcon(onPressed: () => context.go('/staff'), icon: const Icon(Icons.group_outlined), label: const Text('Manage Staff')),
              FilledButton.tonalIcon(onPressed: () => context.go('/reports'), icon: const Icon(Icons.description_outlined), label: const Text('Reports')),
              FilledButton.tonalIcon(onPressed: () => context.go('/analytics'), icon: const Icon(Icons.insights_outlined), label: const Text('Analytics')),
            ],
          ),
        ],
      ),
    );
  }
}
