import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  List<_OrderRow> _orders = <_OrderRow>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Delay to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrders());
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders/list');
      final List<dynamic> data = response.data as List<dynamic>;
      setState(() {
        _orders = data.map((item) {
          final map = item as Map<String, dynamic>;
          final status = map['status'] as String? ?? 'Created';
          return _OrderRow(
            token: map['token'] as String? ?? '',
            companyName: map['company_name'] as String? ?? '',
            poNumber: map['po_number'] as String? ?? '',
            status: status,
            statusColor: _statusColor(status),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load orders: $e';
      });
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'Created':
        return Colors.grey;
      case 'Raw Material Updated':
        return Colors.orange;
      case 'Casting Completed':
        return Colors.blue;
      case 'Turning Completed':
        return Colors.indigo;
      case 'Polishing Completed':
        return Colors.purple;
      case 'Packing Completed':
        return Colors.teal;
      case 'Ready To Dispatch':
        return Colors.green;
      case 'Dispatched':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = _searchController.text.trim().toLowerCase();
    final filteredOrders = _orders.where((order) {
      final matchesSearch = search.isEmpty ||
          order.token.toLowerCase().contains(search) ||
          order.poNumber.toLowerCase().contains(search) ||
          order.companyName.toLowerCase().contains(search);

      final matchesFilter = _selectedFilter == 'All' || order.status.contains(_selectedFilter);
      return matchesSearch && matchesFilter;
    }).toList(growable: false);

    return AppScaffold(
      selectedIndex: 1,
      title: 'Orders',
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Search PO number, token, or company',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () async {
                    final result = await context.push('/orders/create');
                    if (result == true) {
                      _fetchOrders();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Order'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <String>['All', 'Created', 'Raw Material', 'Casting', 'Turning', 'Polishing', 'Packing', 'Dispatch']
                  .map(
                    (filter) => FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            const SizedBox(height: 12),
                            OutlinedButton(onPressed: _fetchOrders, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : filteredOrders.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No orders found for the selected search and filter.')))
                        : RefreshIndicator(
                            onRefresh: _fetchOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    child: ListTile(
                                      onTap: () async {
                                        await context.push('/orders/${order.token}');
                                        _fetchOrders();
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: order.statusColor.withValues(alpha: 0.14),
                                        foregroundColor: order.statusColor,
                                        child: const Icon(Icons.receipt_long),
                                      ),
                                      title: Text('${order.companyName} • ${order.token}'),
                                      subtitle: Text('PO ${order.poNumber}'),
                                      trailing: Chip(label: Text(order.status)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow {
  const _OrderRow({
    required this.token,
    required this.companyName,
    required this.poNumber,
    required this.status,
    required this.statusColor,
  });

  final String token;
  final String companyName;
  final String poNumber;
  final String status;
  final Color statusColor;
}
