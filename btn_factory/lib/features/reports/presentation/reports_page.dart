import 'package:btn_factory/core/utils/pdf_export_service.dart';
import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _reportData;
  final TextEditingController _orderSearchController = TextEditingController();
  String _selectedStatusFilter = 'All';
  final Set<String> _expandedOrderTokens = {};

  @override
  void dispose() {
    _orderSearchController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchReport());
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/reports/summary');
      if (!mounted) return;
      setState(() {
        _reportData = response.data as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      String errorMessage = 'Failed to load reports: $e';
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          errorMessage = 'Access Denied: Admin privileges required to view reports.';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Unauthorized: Please log in again.';
        }
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = errorMessage;
      });
    }
  }

  String _formatCurrency(num value) {
    try {
      return NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(value);
    } catch (_) {
      return '₹$value';
    }
  }

  String _formatCount(num value) {
    try {
      return NumberFormat.decimalPattern().format(value);
    } catch (_) {
      return '$value';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        selectedIndex: 8,
        title: 'Reports',
        child: Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6))),
      );
    }

    if (_error != null) {
      return AppScaffold(
        selectedIndex: 8,
        title: 'Reports',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 56, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _fetchReport,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = _reportData!;
    final production = data['production'] as Map<String, dynamic>? ?? {};
    final materials = data['materials'] as List<dynamic>? ?? [];
    final universalMaterials = data['universal_materials'] as List<dynamic>? ?? [];
    final rejection = data['rejection'] as Map<String, dynamic>? ?? {};
    final revenue = data['revenue'] as Map<String, dynamic>? ?? {};
    final orderReports = data['order_reports'] as List<dynamic>? ?? [];

    final filteredOrderReports = orderReports.where((item) {
      final orderMap = item as Map<String, dynamic>;
      final query = _orderSearchController.text.trim().toLowerCase();
      final status = orderMap['status']?.toString().toLowerCase() ?? '';

      if (_selectedStatusFilter != 'All') {
        if (_selectedStatusFilter == 'Completed / Dispatched') {
          if (status != 'ready to dispatch' && status != 'dispatched') return false;
        } else if (_selectedStatusFilter == 'In Progress') {
          if (status == 'ready to dispatch' || status == 'dispatched') return false;
        }
      }

      if (query.isNotEmpty) {
        final token = orderMap['token']?.toString().toLowerCase() ?? '';
        final party = (orderMap['company_name'] ?? orderMap['party_name'] ?? '').toString().toLowerCase();
        final prod = (orderMap['product_name'] ?? '').toString().toLowerCase();
        final po = (orderMap['po_number'] ?? '').toString().toLowerCase();
        if (!token.contains(query) && !party.contains(query) && !prod.contains(query) && !po.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();


    return AppScaffold(
      selectedIndex: 8,
      title: 'Reports & Analytics',
      child: RefreshIndicator(
        onRefresh: _fetchReport,
        color: const Color(0xFF14B8A6),
        backgroundColor: const Color(0xFF111827),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: <Widget>[
            const Text(
              'Reporting Console',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Generate details on production output, raw materials consumed, rejections, and revenue.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Production Report',
              trailing: TextButton.icon(
                onPressed: _reportData == null ? null : () => PdfExportService.exportReportPdf(_reportData!),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Export PDF'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF14B8A6),
                ),
              ),
              child: _ReportSummary(
                rows: <_ReportRow>[
                  _ReportRow(label: 'Orders completed', value: _formatCount(production['completed_orders'] ?? 0)),
                  _ReportRow(label: 'Casting output', value: '${_formatCount(production['casting_output'] ?? 0)} gross qty'),
                  _ReportRow(label: 'Turning output', value: '${_formatCount(production['turning_output'] ?? 0)} gross qty'),
                  _ReportRow(label: 'Packing output', value: '${_formatCount(production['packing_output'] ?? 0)} packed qty'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Universal Raw Material Stock & Balance',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${universalMaterials.length} Materials Tracked',
                  style: const TextStyle(color: Color(0xFF14B8A6), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              child: universalMaterials.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No universal raw materials registered yet.',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                      ),
                    )
                  : Column(
                      children: universalMaterials.map((item) {
                        final name = item['name'] as String? ?? 'N/A';
                        final remaining = (item['remaining_quantity'] as num?)?.toDouble() ?? 0.0;
                        final consumed = (item['consumed_quantity'] as num?)?.toDouble() ?? 0.0;
                        final initial = (item['initial_quantity'] as num?)?.toDouble() ?? (remaining + consumed);
                        final unit = item['unit'] as String? ?? '';
                        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                        final totalVal = (item['total_value'] as num?)?.toDouble() ?? (remaining * price);

                        final ratio = initial > 0 ? (remaining / initial).clamp(0.0, 1.0) : 0.0;
                        final badgeColor = remaining <= 0
                            ? const Color(0xFFEF4444)
                            : (ratio < 0.2 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
                        final badgeText = remaining <= 0
                            ? 'DEPLETED'
                            : (ratio < 0.2 ? 'LOW STOCK' : 'IN STOCK');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF374151), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Color(0xFFF8FAFC),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFF111827),
                                  valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _InfoBadge(
                                    label: 'Remaining',
                                    value: '$remaining $unit',
                                    color: const Color(0xFF14B8A6),
                                  ),
                                  _InfoBadge(
                                    label: 'Consumed',
                                    value: '$consumed $unit',
                                    color: const Color(0xFFF59E0B),
                                  ),
                                  _InfoBadge(
                                    label: 'Rate',
                                    value: '₹$price / $unit',
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  _InfoBadge(
                                    label: 'Valuation',
                                    value: _formatCurrency(totalVal),
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Order Material Consumption',
              child: materials.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No material consumption recorded yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: materials.map((item) {
                        final name = item['name'] as String? ?? 'N/A';
                        final qty = item['quantity'] ?? 0;
                        final unit = item['unit'] as String? ?? '';
                        return _SummaryTile(
                          label: name,
                          value: '$qty $unit',
                          tint: const Color(0xFF0D9488),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Rejection Report',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _SummaryTile(
                    label: 'Rejection Rate',
                    value: '${rejection['rejection_rate'] ?? 0.0}% avg',
                    tint: const Color(0xFFEF4444),
                  ),
                  _SummaryTile(
                    label: 'Total Produced',
                    value: _formatCount((rejection['total_packed'] ?? 0) + (rejection['total_rejected'] ?? 0)),
                    tint: const Color(0xFF14B8A6),
                  ),
                  _SummaryTile(
                    label: 'Total Rejected',
                    value: _formatCount(rejection['total_rejected'] ?? 0),
                    tint: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Revenue Report',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _SummaryTile(
                    label: 'Total Order Value',
                    value: _formatCurrency(revenue['total_revenue'] ?? 0.0),
                    tint: const Color(0xFF8B5CF6),
                  ),
                  _SummaryTile(
                    label: 'Completed Orders',
                    value: _formatCount(revenue['completed_count'] ?? 0),
                    tint: const Color(0xFF10B981),
                  ),
                  _SummaryTile(
                    label: 'Pending Value',
                    value: _formatCurrency(revenue['pending_revenue'] ?? 0.0),
                    tint: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Individual Order Reports',

              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${filteredOrderReports.length} Orders',
                  style: const TextStyle(color: Color(0xFF14B8A6), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _orderSearchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search order by token, party, product, PO...',
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                            suffixIcon: _orderSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _orderSearchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            filled: true,
                            fillColor: const Color(0xFF1F2937),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF374151)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF374151)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'In Progress', 'Completed / Dispatched'].map((filter) {
                        final isSelected = _selectedStatusFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedStatusFilter = filter);
                            },
                            selectedColor: const Color(0xFF14B8A6),
                            backgroundColor: const Color(0xFF1F2937),
                            labelStyle: TextStyle(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredOrderReports.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        _orderSearchController.text.isNotEmpty
                            ? 'No orders found matching "${_orderSearchController.text}"'
                            : 'No order reports available.',
                        style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                      ),
                    )
                  else
                    ...filteredOrderReports.map((orderItem) {
                      final order = orderItem as Map<String, dynamic>;
                      final token = order['token'] as String? ?? 'BTN-ORDER';
                      final isExpanded = _expandedOrderTokens.contains(token);

                      return _IndividualOrderCard(
                        order: order,
                        isExpanded: isExpanded,
                        onToggleExpand: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedOrderTokens.remove(token);
                            } else {
                              _expandedOrderTokens.add(token);
                            }
                          });
                        },
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.rows});

  final List<_ReportRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map(
            (row) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF374151), width: 1),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.label,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ReportRow {
  const _ReportRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value, required this.tint});

  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tint.withValues(alpha: 0.15), width: 1.5),
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
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _IndividualOrderCard extends StatelessWidget {
  const _IndividualOrderCard({
    required this.order,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  final Map<String, dynamic> order;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dispatched':
      case 'ready to dispatch':
        return const Color(0xFF10B981);
      case 'packing completed':
      case 'packing in progress':
      case 'packing':
        return const Color(0xFF06B6D4);
      case 'polishing completed':
      case 'polishing in progress':
      case 'polish':
        return const Color(0xFF3B82F6);
      case 'turning completed':
      case 'turning in progress':
      case 'turning':
        return const Color(0xFFF59E0B);
      case 'casting completed':
      case 'casting in progress':
      case 'casting':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = order['token'] as String? ?? 'N/A';
    final companyName = (order['company_name'] ?? order['party_name'] ?? 'N/A') as String;
    final poNumber = order['po_number'] as String? ?? 'N/A';
    final status = order['status'] as String? ?? 'Created';
    final qty = order['quantity'] ?? 0;
    final unit = order['unit'] as String? ?? 'Gross';
    final rate = order['rate'];
    final casting = order['casting_process'] as Map<String, dynamic>?;
    final turning = order['turning_process'] as Map<String, dynamic>?;
    final polish = order['polishing_process'] as Map<String, dynamic>?;
    final packing = order['packing_process'] as Map<String, dynamic>?;
    final rawMaterials = order['raw_materials'] as List<dynamic>? ?? [];

    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF374151), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827).withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: const Border(bottom: BorderSide(color: Color(0xFF374151))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            token,
                            style: const TextStyle(
                              color: Color(0xFF14B8A6),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$companyName  •  PO: $poNumber',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Export RM & Image PDF',
                      icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF14B8A6), size: 18),
                      onPressed: () => PdfExportService.exportRawMaterialsAndImagePdf(order),
                    ),
                    IconButton(
                      tooltip: 'Export Full Job Card PDF',
                      icon: const Icon(Icons.description_outlined, color: Color(0xFF94A3B8), size: 18),
                      onPressed: () => PdfExportService.exportOrderPdf(order),
                    ),
                    IconButton(
                      tooltip: 'View Full Order Details',
                      icon: const Icon(Icons.open_in_new, color: Color(0xFF94A3B8), size: 18),
                      onPressed: () => context.push('/orders/$token'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricChip(label: 'Ordered', value: '$qty $unit', color: const Color(0xFF94A3B8)),
                    if (rate != null)
                      _MetricChip(label: 'Rate', value: '₹$rate', color: const Color(0xFF8B5CF6)),
                    _MetricChip(
                      label: 'Casting',
                      value: casting != null ? '${casting['gross_quantity'] ?? 0} gross' : 'Pending',
                      color: casting != null ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                    ),
                    _MetricChip(
                      label: 'Turning',
                      value: turning != null ? '${turning['gross_quantity'] ?? 0} gross' : 'Pending',
                      color: turning != null ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                    ),
                    _MetricChip(
                      label: 'Polishing',
                      value: polish != null ? '${polish['gross_quantity'] ?? 0} gross' : 'Pending',
                      color: polish != null ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                    ),
                    _MetricChip(
                      label: 'Packed',
                      value: packing != null ? '${packing['packed_qty'] ?? 0} packed' : 'Pending',
                      color: packing != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    ),
                    if (packing != null) ...[
                      _MetricChip(
                        label: 'Rejection',
                        value: packing['rejection_weight'] != null
                            ? '${packing['rejection_weight']} ${packing['rejection_unit'] ?? 'g'}'
                            : '${packing['rejected_qty'] ?? 0} pcs',
                        color: (packing['rejection_weight'] != null && (packing['rejection_weight'] as num) > 0) ||
                                (packing['rejected_qty'] != null && (packing['rejected_qty'] as num) > 0)
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                      ),
                      if (packing['excess_qty'] != null && (packing['excess_qty'] as num) > 0)
                        _MetricChip(label: 'Excess', value: '+${packing['excess_qty']}', color: const Color(0xFF10B981))
                      else if (packing['short_qty'] != null && (packing['short_qty'] as num) > 0)
                        _MetricChip(label: 'Short', value: '-${packing['short_qty']}', color: const Color(0xFFF59E0B)),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onToggleExpand,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18,
                          color: const Color(0xFF14B8A6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpanded ? 'Hide Department Logs' : 'View Department Process Logs & Raw Materials',
                          style: const TextStyle(
                            color: Color(0xFF14B8A6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const Divider(color: Color(0xFF374151), height: 20),
                  if (rawMaterials.isNotEmpty) ...[
                    const Text('Raw Materials Used:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: rawMaterials.map((rm) {
                        final rmMap = rm as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF374151)),
                          ),
                          child: Text(
                            '${rmMap['name'] ?? rmMap['material_name']}: ${rmMap['quantity']} ${rmMap['unit']}',
                            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (casting != null)
                    _LogDetailRow(
                      department: 'Casting',
                      details: 'Type: ${casting['casting_type'] ?? 'Sheet'} • RM Total: ${casting['total_weight'] ?? 'N/A'} kg • Sheets: ${casting['no_of_sheets'] ?? casting['no_of_rods'] ?? 'N/A'} • Thickness: ${casting['blank_thickness'] ?? 'N/A'} • Op: ${casting['operator'] ?? 'N/A'}',
                    ),
                  if (turning != null)
                    _LogDetailRow(
                      department: 'Turning',
                      details: 'Tool: ${turning['tool_no'] ?? 'N/A'} • In: ${turning['inward_weight'] ?? 'N/A'} kg • Out: ${turning['outward_weight'] ?? 'N/A'} kg • Laser: ${turning['laser'] ?? 'None'} • Op: ${turning['operator'] ?? 'N/A'}',
                    ),
                  if (polish != null)
                    _LogDetailRow(
                      department: 'Polishing',
                      details: 'Finish: ${polish['polish_type'] ?? 'N/A'} • In: ${polish['inward_weight'] ?? 'N/A'} kg • Out: ${polish['outward_weight'] ?? 'N/A'} kg • Op: ${polish['operator'] ?? 'N/A'}',
                    ),
                  if (packing != null)
                    _LogDetailRow(
                      department: 'Packing',
                      details: 'In: ${packing['inward_weight'] ?? 'N/A'} ${packing['inward_weight_unit'] ?? 'kg'} • Out: ${packing['outward_weight'] ?? 'N/A'} ${packing['outward_weight_unit'] ?? 'kg'} • 1-Gross: ${packing['one_gross_weight'] ?? 'N/A'} ${packing['one_gross_weight_unit'] ?? 'g'} • Packed: ${packing['packed_qty'] ?? 'N/A'} • Rej: ${packing['rejection_weight'] != null ? '${packing['rejection_weight']} ${packing['rejection_unit'] ?? 'g'}' : (packing['rejected_qty'] ?? 0)} • Op: ${packing['operator'] ?? 'N/A'}',
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LogDetailRow extends StatelessWidget {
  const _LogDetailRow({required this.department, required this.details});

  final String department;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              department,
              style: const TextStyle(color: Color(0xFF14B8A6), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              details,
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}



