import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _reportData;

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
        selectedIndex: 7,
        title: 'Reports',
        child: Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6))),
      );
    }

    if (_error != null) {
      return AppScaffold(
        selectedIndex: 7,
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
    final rejection = data['rejection'] as Map<String, dynamic>? ?? {};
    final revenue = data['revenue'] as Map<String, dynamic>? ?? {};

    return AppScaffold(
      selectedIndex: 7,
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
                onPressed: () {},
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
              title: 'Material Consumption',
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


