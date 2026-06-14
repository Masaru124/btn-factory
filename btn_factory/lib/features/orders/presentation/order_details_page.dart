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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateTimeStr;
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
    final rawMaterials = order['raw_materials'] as List<dynamic>? ?? [];
    final casting = order['casting_process'] as Map<String, dynamic>?;
    final turning = order['turning_process'] as Map<String, dynamic>?;
    final polish = order['polishing_process'] as Map<String, dynamic>?;
    final packing = order['packing_process'] as Map<String, dynamic>?;

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
          const SizedBox(height: 16),
          SectionCard(
            title: 'Raw Materials',
            child: rawMaterials.isEmpty
                ? const Text('No raw materials recorded.', style: TextStyle(fontStyle: FontStyle.italic))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rawMaterials.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, idx) {
                      final m = rawMaterials[idx] as Map<String, dynamic>;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          child: const Icon(Icons.layers_outlined),
                        ),
                        title: Text(m['material_name'] as String? ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Recorded on ${_formatDate(m['created_at'] as String?)}'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${m['quantity'] ?? 'N/A'} ${m['unit'] ?? ''}', style: Theme.of(context).textTheme.titleMedium),
                            Text('₹${m['price'] ?? 'N/A'}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Casting Data',
            child: casting == null
                ? const Text('Casting details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic))
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: <Widget>[
                      _DetailChip(label: 'Sheet Type', value: casting['sheet_type'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Weight', value: '${casting['weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'Thickness', value: casting['thickness'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Gross Quantity', value: '${casting['gross_quantity'] ?? 'N/A'}'),
                      _DetailChip(label: 'Machine No', value: casting['machine_no'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Start Time', value: _formatDateTime(casting['start_time'] as String?)),
                      _DetailChip(label: 'End Time', value: _formatDateTime(casting['end_time'] as String?)),
                      _DetailChip(label: 'Remarks', value: casting['remarks'] as String? ?? 'None'),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Turning Data',
            child: turning == null
                ? const Text('Turning details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic))
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: <Widget>[
                      _DetailChip(label: 'Receiving Date', value: _formatDateTime(turning['receiving_date'] as String?)),
                      _DetailChip(label: 'Date of Turning', value: _formatDateTime(turning['date_of_turning'] as String?)),
                      _DetailChip(label: 'Art No.', value: turning['art_no'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Machine No', value: turning['machine_no'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Hole Size', value: turning['hole_size'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Weight', value: '${turning['weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'Turned in Kgs', value: '${turning['turned_in_kgs'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'Gross Quantity', value: '${turning['gross_quantity'] ?? 'N/A'}'),
                      _DetailChip(label: 'Semi Finish Thickness', value: turning['semi_finish_thickness'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Finish Thickness', value: turning['finish_thickness'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Operator', value: turning['operator'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Remarks', value: turning['remarks'] as String? ?? 'None'),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Polish Data',
            child: polish == null
                ? const Text('Polishing details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic))
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: <Widget>[
                      _DetailChip(label: 'Art No.', value: polish['art_no'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Receiving Date', value: _formatDateTime(polish['receiving_date'] as String?)),
                      _DetailChip(label: 'Weight', value: '${polish['weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'In Gross', value: '${polish['gross_quantity'] ?? 'N/A'}'),
                      _DetailChip(label: 'Polish Type', value: polish['polish_type'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Feeding Time', value: _formatDateTime(polish['feeding_time'] as String?)),
                      _DetailChip(label: 'Out Time', value: _formatDateTime(polish['out_time'] as String?)),
                      _DetailChip(label: 'Operator', value: polish['operator'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Remarks', value: polish['remarks'] as String? ?? 'None'),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Packing Data',
            child: packing == null
                ? const Text('Packing details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic))
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: <Widget>[
                      _DetailChip(label: 'Receiving Date', value: _formatDateTime(packing['receiving_date'] as String?)),
                      _DetailChip(label: 'Art No.', value: packing['art_no'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Weight', value: '${packing['weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'In Gross', value: '${packing['in_gross'] ?? 'N/A'}'),
                      _DetailChip(label: 'Finishing', value: packing['finishing'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Packed Qty (Gross)', value: '${packing['packed_qty'] ?? 'N/A'}'),
                      _DetailChip(label: 'Rejected Qty', value: '${packing['rejected_qty'] ?? 'N/A'}'),
                      _DetailChip(label: 'Short Qty', value: '${packing['short_qty'] ?? 'N/A'}'),
                      _DetailChip(label: 'Excess Qty', value: '${packing['excess_qty'] ?? 'N/A'}'),
                      _DetailChip(label: 'Operator', value: packing['operator'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Remarks (Rejection Reason)', value: packing['remarks'] as String? ?? 'None'),
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
