import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class OrderDetailsPage extends ConsumerStatefulWidget {
  const OrderDetailsPage({super.key, required this.orderToken});

  final String orderToken;

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrder());
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders/${widget.orderToken}');
      setState(() {
        _order = response.data as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load order: $e';
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffold(
        selectedIndex: 1,
        title: 'Order ${widget.orderToken}',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AppScaffold(
        selectedIndex: 1,
        title: 'Order ${widget.orderToken}',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _fetchOrder, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return AppScaffold(
      selectedIndex: 1,
      title: 'Order ${widget.orderToken}',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          SectionCard(
            title: 'Company Details',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(label: Text(order['status'] as String? ?? 'Created')),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Order',
                  onPressed: () async {
                    final result = await context.push('/orders/${widget.orderToken}/edit');
                    if (result == true) {
                      _fetchOrder();
                    }
                  },
                ),
              ],
            ),
            child: Wrap(

              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                _DetailChip(label: 'Company Name', value: order['company_name'] as String? ?? 'N/A'),
                _DetailChip(label: 'PO Number', value: order['po_number'] as String? ?? 'N/A'),
                _DetailChip(label: 'PO Date', value: _formatDate(order['po_date'] as String?)),
                _DetailChip(label: 'Token', value: order['token'] as String? ?? 'N/A'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Product Details',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                _DetailChip(label: 'Casting', value: order['casting_type'] as String? ?? 'N/A'),
                _DetailChip(label: 'Thickness', value: order['thickness'] as String? ?? 'N/A'),
                _DetailChip(label: 'Holes', value: order['holes'] as String? ?? 'N/A'),
                _DetailChip(label: 'Box Type', value: order['box_type'] as String? ?? 'N/A'),
                _DetailChip(label: 'Quantity', value: '${order['quantity'] ?? 'N/A'}'),
                _DetailChip(label: 'Rate', value: '₹${order['rate'] ?? 'N/A'}'),
                _DetailChip(label: 'Linings', value: order['linings'] as String? ?? 'N/A'),
                _DetailChip(label: 'Laser', value: order['laser'] as String? ?? 'N/A'),
                _DetailChip(label: 'Polish Type', value: order['polish_type'] as String? ?? 'N/A'),
                _DetailChip(label: 'Packing Option', value: order['packing_option'] as String? ?? 'N/A'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Dispatch',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                _DetailChip(label: 'Dispatch Date', value: _formatDate(order['dispatch_date'] as String?)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Images',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                _PreviewCard(title: 'PO Image', fileName: order['po_image'] as String?),
                _PreviewCard(title: 'Button Image', fileName: order['button_image'] as String?),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.title, this.fileName});

  final String title;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title),
            if (fileName != null) ...[
              const SizedBox(height: 4),
              Text(fileName!, style: Theme.of(context).textTheme.bodySmall),
            ] else
              Text('No file', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
