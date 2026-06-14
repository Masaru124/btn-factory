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
        child: Center(child: CircularProgressIndicator()),
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
                Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
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
      title: 'Reports',
      child: RefreshIndicator(
        onRefresh: _fetchReport,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text('Admin-only reporting center', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Generate production, material, rejection, and revenue reports from the backend.'),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Production Report',
              trailing: TextButton(onPressed: () {}, child: const Text('Export PDF')),
              child: _ReportSummary(
                rows: <_ReportRow>[
                  _ReportRow(label: 'Orders completed', value: _formatCount(production['completed_orders'] ?? 0)),
                  _ReportRow(label: 'Casting output', value: '${_formatCount(production['casting_output'] ?? 0)} gross qty'),
                  _ReportRow(label: 'Turning output', value: '${_formatCount(production['turning_output'] ?? 0)} gross qty'),
                  _ReportRow(label: 'Packing output', value: '${_formatCount(production['packing_output'] ?? 0)} packed qty'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Material Consumption',
              child: materials.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No material consumption recorded yet.', style: TextStyle(fontStyle: FontStyle.italic)),
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
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Rejection Report',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _SummaryTile(
                    label: 'Rejection Rate',
                    value: '${rejection['rejection_rate'] ?? 0.0}% average',
                  ),
                  _SummaryTile(
                    label: 'Total Produced',
                    value: _formatCount((rejection['total_packed'] ?? 0) + (rejection['total_rejected'] ?? 0)),
                  ),
                  _SummaryTile(
                    label: 'Total Rejected',
                    value: _formatCount(rejection['total_rejected'] ?? 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Revenue Report',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _SummaryTile(
                    label: 'Total Order Value',
                    value: _formatCurrency(revenue['total_revenue'] ?? 0.0),
                  ),
                  _SummaryTile(
                    label: 'Completed Orders',
                    value: _formatCount(revenue['completed_count'] ?? 0),
                  ),
                  _SummaryTile(
                    label: 'Pending Value',
                    value: _formatCurrency(revenue['pending_revenue'] ?? 0.0),
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
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(row.label)),
                  Text(row.value, style: Theme.of(context).textTheme.titleMedium),
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
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

