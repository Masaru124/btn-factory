import 'package:btn_factory/core/utils/pdf_export_service.dart';
import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/app_image_preview.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:btn_factory/features/auth/application/auth_controller.dart';
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
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6))),
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
              Text(_error!, style: const TextStyle(color: Color(0xFFFCA5A5))),
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
    final blanking = order['blanking_process'] as Map<String, dynamic>? ??
        (casting != null && (casting['gross_quantity'] != null || casting['rejection_weight'] != null || casting['operator'] != null)
            ? casting
            : null);
    final turning = (order['turning_process'] ?? order['turning']) as Map<String, dynamic>?;
    final polish = (order['polishing_process'] ?? order['polish_process'] ?? order['polish']) as Map<String, dynamic>?;
    final packing = (order['packing_process'] ?? order['packing']) as Map<String, dynamic>?;

    final authState = ref.watch(authControllerProvider).value;
    final userRole = authState?.userRole ?? '';
    final isAdmin = userRole == 'super_admin';

    return AppScaffold(
      selectedIndex: 1,
      title: 'Order Details',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: <Widget>[
          // Header Company Details Card
          SectionCard(
            title: 'Company Details',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status'] as String? ?? 'Created',
                    style: const TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 15),
                  label: const Text('RM & Image PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => PdfExportService.exportRawMaterialsAndImagePdf(order),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: const BorderSide(color: Color(0xFF374151)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.description_outlined, size: 15),
                  label: const Text('Full Job Card', style: TextStyle(fontSize: 11)),
                  onPressed: () => PdfExportService.exportOrderPdf(order),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF14B8A6)),
                    tooltip: 'Edit Order',
                    onPressed: () async {
                      final result = await context.push('/orders/${widget.orderToken}/edit');
                      if (result == true) {
                        _fetchOrder();
                      }
                    },
                  ),
                ],
              ],
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _DetailChip(label: 'Company Name', value: order['company_name'] as String? ?? 'N/A'),
                _DetailChip(label: 'PO Date', value: _formatDate(order['po_date'] as String?)),
                _DetailChip(label: 'Token', value: order['token'] as String? ?? 'N/A'),
                _DetailChip(label: 'Order Type', value: order['order_type'] as String? ?? 'Production'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Product Details Card
          SectionCard(
            title: 'Product Details',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                if (order['sample'] != null && (order['sample'] as String).isNotEmpty)
                  _DetailChip(label: 'Sample', value: order['sample'] as String),
                _DetailChip(label: 'Casting Type', value: order['casting_type'] as String? ?? 'N/A'),
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
          const SizedBox(height: 18),
          // Dispatch details Card
          SectionCard(
            title: 'Dispatch Information',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _DetailChip(label: 'Dispatch Date', value: _formatDate(order['dispatch_date'] as String?)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Uploaded Files / Images
          SectionCard(
            title: 'Attachments',
            trailing: order['button_image'] == null
                ? null
                : TextButton.icon(
                    onPressed: () => PdfExportService.exportRawMaterialsAndImagePdf(order),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text('Export RM & Image PDF'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF14B8A6)),
                  ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                if (isAdmin) AppImagePreviewCard(title: 'PO Image', imageSource: order['po_image'] as String?),
                AppImagePreviewCard(title: 'Button Sample Image', imageSource: order['button_image'] as String?),
              ],
            ),
          ),
          // Department Statuses & Submissions
          const SizedBox(height: 18),
          SectionCard(
            title: 'Raw Materials Logs',
            trailing: TextButton.icon(
              onPressed: () => PdfExportService.exportRawMaterialsAndImagePdf(order),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('Export RM & Image PDF'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF14B8A6)),
            ),
            child: rawMaterials.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No raw materials recorded.', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rawMaterials.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFF1F2937), height: 24),
                    itemBuilder: (context, idx) {
                      final m = rawMaterials[idx] as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.layers_outlined, color: Color(0xFF0D9488)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['material_name'] as String? ?? 'N/A',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Recorded on ${_formatDate(m['created_at'] as String?)}',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Order: ${m['quantity'] ?? 'N/A'} ${m['unit'] ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC), fontSize: 14),
                                ),
                                if (m['total_available_quantity'] != null)
                                  Text(
                                    'Avail: ${m['total_available_quantity']} ${m['unit'] ?? ''}',
                                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${m['price'] ?? 'N/A'}',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Casting Process Logs',
            child: casting == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Casting details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                  )
                : Builder(
                    builder: (context) {
                      final isRod = (casting['casting_type'] as String?)?.toLowerCase() == 'rod';
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          _DetailChip(label: 'Casting Type', value: casting['casting_type'] as String? ?? 'N/A'),
                          _DetailChip(label: 'Date of Casting', value: _formatDateTime(casting['date_of_casting'] as String?)),
                          if (isRod) ...[
                            if (casting['sheet'] != null)
                              _DetailChip(label: 'Sheet', value: casting['sheet'] as String),
                            if (casting['line'] != null)
                              _DetailChip(label: 'Line', value: casting['line'] as String),
                            if (casting['total_resin'] != null)
                              _DetailChip(label: 'Total (Resin)', value: '${casting['total_resin']} kg'),
                            _DetailChip(label: 'Blank Thickness', value: (casting['blank_thickness'] ?? casting['thickness']) as String? ?? 'N/A'),
                            _DetailChip(label: 'No. of ROD', value: '${casting['no_of_rods'] ?? 'N/A'}'),
                            if (casting['gross_quantity'] != null)
                              _DetailChip(label: 'Gross (Approx)', value: '${casting['gross_quantity']}'),
                            if (casting['operator'] != null)
                              _DetailChip(label: 'Operator', value: casting['operator'] as String),
                          ] else ...[
                            _DetailChip(label: 'Total Raw Material', value: '${casting['total_weight'] ?? casting['weight'] ?? 'N/A'} kg'),
                            _DetailChip(label: 'Number of Sheets', value: '${casting['no_of_sheets'] ?? 'N/A'}'),
                            _DetailChip(label: 'Blank Thickness', value: (casting['blank_thickness'] ?? casting['thickness']) as String? ?? 'N/A'),
                          ],
                          _DetailChip(label: 'Remarks', value: casting['remarks'] as String? ?? 'None'),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Blanking Process Logs',
            child: blanking == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Blanking details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      _DetailChip(label: 'Weight in kgs', value: '${blanking['weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'In Gross', value: '${blanking['gross_quantity'] ?? 'N/A'}'),
                      _DetailChip(label: 'Rejection in kgs', value: '${blanking['rejection_weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'Operator', value: blanking['operator'] as String? ?? 'N/A'),
                      if (blanking['blank_thickness'] != null)
                        _DetailChip(label: 'Blank Thickness', value: blanking['blank_thickness'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Remarks', value: blanking['remarks'] as String? ?? 'None'),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Turning Process Logs',
            child: turning == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Turning details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      _DetailChip(label: 'Receiving Date', value: _formatDateTime(turning['receiving_date'] as String?)),
                      _DetailChip(label: 'Date of Turning', value: _formatDateTime(turning['date_of_turning'] as String?)),
                      _DetailChip(label: 'Tool Number', value: (turning['tool_no'] ?? turning['art_no']) as String? ?? 'N/A'),
                      _DetailChip(label: 'Machine No', value: turning['machine_no'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Hole Size', value: turning['hole_size'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Inwards Weight', value: '${turning['inward_weight'] ?? turning['weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'Outward Weight', value: '${turning['outward_weight'] ?? turning['turned_in_kgs'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'Gross Quantity', value: '${turning['gross_quantity'] ?? 'N/A'}'),
                      _DetailChip(label: 'Blank Thickness', value: (turning['blank_thickness'] ?? turning['semi_finish_thickness']) as String? ?? 'N/A'),
                      _DetailChip(label: 'Finish Thickness', value: turning['finish_thickness'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Operator', value: turning['operator'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Remarks', value: turning['remarks'] as String? ?? 'None'),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Polishing Process Logs',
            child: polish == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Polishing details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      _DetailChip(label: 'Receiving Date', value: _formatDateTime(polish['receiving_date'] as String?)),
                      _DetailChip(label: 'Inward Weight', value: '${polish['inward_weight'] ?? polish['weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'Outward Weight', value: '${polish['outward_weight'] ?? 'N/A'} kg'),
                      _DetailChip(label: 'In Gross', value: '${polish['gross_quantity'] ?? 'N/A'}'),
                      _DetailChip(label: 'Polish Type', value: polish['polish_type'] as String? ?? 'N/A'),
                      _DetailChip(label: 'In Time', value: _formatDateTime(polish['feeding_time'] as String?)),
                      _DetailChip(label: 'Out Time', value: _formatDateTime(polish['out_time'] as String?)),
                      _DetailChip(label: 'Operator', value: polish['operator'] as String? ?? 'N/A'),
                      _DetailChip(label: 'Remarks', value: polish['remarks'] as String? ?? 'None'),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Packing Process Logs',
              child: packing == null
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Packing details not submitted yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        _DetailChip(label: 'Receiving Date', value: _formatDateTime(packing['receiving_date'] as String?)),
                        _DetailChip(label: 'Inward Weight', value: '${packing['inward_weight'] ?? packing['weight'] ?? 'N/A'} ${packing['inward_weight_unit'] ?? 'kg'}'),
                        _DetailChip(label: 'Outward Weight', value: '${packing['outward_weight'] ?? 'N/A'} ${packing['outward_weight_unit'] ?? 'kg'}'),
                        _DetailChip(label: 'Packing Gross Weight', value: '${packing['one_gross_weight'] ?? 'N/A'} ${packing['one_gross_weight_unit'] ?? 'g'}'),
                        _DetailChip(label: 'In Gross', value: '${packing['in_gross'] ?? 'N/A'}'),
                        _DetailChip(label: 'Finishing', value: packing['finishing'] as String? ?? 'N/A'),
                        _DetailChip(label: 'Packed Qty (Gross)', value: '${packing['packed_qty'] ?? 'N/A'}'),
                        if (packing['rejection_weight'] != null)
                          _DetailChip(label: 'Rejection Weight', value: '${packing['rejection_weight']} ${packing['rejection_unit'] ?? 'g'}'),
                        _DetailChip(label: 'Rejected Qty', value: '${packing['rejected_qty'] ?? 'N/A'}'),
                        _DetailChip(label: 'Short Qty', value: '${packing['short_qty'] ?? '0'}'),
                        _DetailChip(label: 'Excess Qty', value: '${packing['excess_qty'] ?? '0'}'),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF374151), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

