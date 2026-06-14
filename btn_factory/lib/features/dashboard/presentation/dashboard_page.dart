import 'package:btn_factory/core/network/api_client.dart';
import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isLoading = true;
  String? _error;

  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _processingOrders = 0;
  int _completedOrders = 0;
  double _revenue = 0.0;
  double _materialCost = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDashboard());
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/analytics/dashboard');
      final data = response.data as Map<String, dynamic>;
      setState(() {
        _totalOrders = (data['total_orders'] as num?)?.toInt() ?? 0;
        _pendingOrders = (data['pending_orders'] as num?)?.toInt() ?? 0;
        _processingOrders = (data['processing_orders'] as num?)?.toInt() ?? 0;
        _completedOrders = (data['completed_orders'] as num?)?.toInt() ?? 0;
        _revenue = (data['revenue'] as num?)?.toDouble() ?? 0.0;
        _materialCost = (data['material_cost'] as num?)?.toDouble() ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load dashboard: $e';
      });
    }
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider).value;

    return AppScaffold(
      selectedIndex: 0,
      title: 'Dashboard',
      child: RefreshIndicator(
        onRefresh: _fetchDashboard,
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
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _fetchDashboard, child: const Text('Retry')),
                    ],
                  ),
                ),
              )
            else
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
                    children: <Widget>[
                      MetricCard(
                        title: 'Total Orders',
                        value: '$_totalOrders',
                        icon: Icons.shopping_bag_outlined,
                        tint: Colors.teal,
                      ),
                      MetricCard(
                        title: 'Pending',
                        value: '$_pendingOrders',
                        icon: Icons.pending_actions_outlined,
                        tint: Colors.orange,
                      ),
                      MetricCard(
                        title: 'Processing',
                        value: '$_processingOrders',
                        icon: Icons.settings_outlined,
                        tint: Colors.blue,
                      ),
                      MetricCard(
                        title: 'Completed',
                        value: '$_completedOrders',
                        icon: Icons.verified_outlined,
                        tint: Colors.green,
                      ),
                      MetricCard(
                        title: 'Revenue',
                        value: _formatCurrency(_revenue),
                        icon: Icons.currency_rupee_outlined,
                        tint: Colors.purple,
                      ),
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
      ),
    );
  }
}
