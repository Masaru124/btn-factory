import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<_OrderRow> _orders = <_OrderRow>[
    const _OrderRow(token: 'BTN-2025-0001', companyName: 'Alpha Metal Works', poNumber: 'PO-1044', status: 'Processing', statusColor: Colors.blue),
    const _OrderRow(token: 'BTN-2025-0002', companyName: 'Nexa Furnishings', poNumber: 'PO-1051', status: 'Pending', statusColor: Colors.orange),
    const _OrderRow(token: 'BTN-2025-0003', companyName: 'Metro Decor', poNumber: 'PO-1058', status: 'Completed', statusColor: Colors.green),
    const _OrderRow(token: 'BTN-2025-0004', companyName: 'Classic Homes', poNumber: 'PO-1062', status: 'Dispatched', statusColor: Colors.teal),
  ];

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

      final matchesFilter = _selectedFilter == 'All' || order.status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList(growable: false);

    return AppScaffold(
      selectedIndex: 1,
      title: 'Orders',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Row(
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
                onPressed: () => context.go('/orders/create'),
                icon: const Icon(Icons.add),
                label: const Text('Create Order'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <String>['All', 'Pending', 'Processing', 'Completed', 'Dispatched']
                .map(
                  (filter) => FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          if (filteredOrders.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No orders found for the selected search and filter.')))
          else
            ...filteredOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    onTap: () => context.go('/orders/${order.token}'),
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
