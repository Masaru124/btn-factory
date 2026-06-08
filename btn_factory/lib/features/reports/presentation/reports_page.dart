import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 7,
      title: 'Reports',
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
            child: const _ReportSummary(
              rows: <_ReportRow>[
                _ReportRow(label: 'Orders completed', value: '118'),
                _ReportRow(label: 'Casting output', value: '12,400'),
                _ReportRow(label: 'Turning output', value: '12,180'),
                _ReportRow(label: 'Packing output', value: '11,600'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Material Consumption',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const <Widget>[
                _SummaryTile(label: 'Brass Used', value: '540 kg'),
                _SummaryTile(label: 'Copper Used', value: '240 kg'),
                _SummaryTile(label: 'Plastic Used', value: '84 kg'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Rejection Report',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const <Widget>[
                _SummaryTile(label: 'Department Wise', value: '4.2% average'),
                _SummaryTile(label: 'Date Wise', value: 'Last 30 days'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Revenue Report',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const <Widget>[
                _SummaryTile(label: 'Order Value', value: '₹18.4M'),
                _SummaryTile(label: 'Completed Orders', value: '118'),
                _SummaryTile(label: 'Pending Value', value: '₹3.8M'),
              ],
            ),
          ),
        ],
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
