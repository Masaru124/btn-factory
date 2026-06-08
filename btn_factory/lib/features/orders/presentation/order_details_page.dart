import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.orderToken});

  final String orderToken;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    return AppScaffold(
      selectedIndex: 1,
      title: 'Order $orderToken',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          SectionCard(
            title: 'Company Details',
            trailing: const Chip(label: Text('Processing')),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                _DetailChip(label: 'Company Name', value: 'Alpha Metal Works'),
                _DetailChip(label: 'PO Number', value: 'PO-1044'),
                _DetailChip(label: 'PO Date', value: formatter.format(DateTime(2025, 5, 10))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Product Details',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const <Widget>[
                _DetailChip(label: 'Casting', value: 'Pressed'),
                _DetailChip(label: 'Thickness', value: '1.2 mm'),
                _DetailChip(label: 'Quantity', value: '12,000'),
                _DetailChip(label: 'Rate', value: '₹42.50'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Raw Materials',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const <Widget>[
                _DetailChip(label: 'Material Name', value: 'Brass Coil'),
                _DetailChip(label: 'Quantity', value: '540 kg'),
                _DetailChip(label: 'Price', value: '₹96,000'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Casting Data',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const <Widget>[
                _DetailChip(label: 'Weight', value: '2.4 kg'),
                _DetailChip(label: 'Gross Quantity', value: '12,000'),
                _DetailChip(label: 'Machine', value: 'CAST-04'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Turning Data',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const <Widget>[
                _DetailChip(label: 'Machine', value: 'TURN-08'),
                _DetailChip(label: 'Thickness', value: '1.15 mm'),
                _DetailChip(label: 'Quantity', value: '11,850'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Polish Data',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const <Widget>[
                _DetailChip(label: 'Polish Type', value: 'Mirror'),
                _DetailChip(label: 'Quantity', value: '11,700'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Packing Data',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const <Widget>[
                _DetailChip(label: 'Packed Qty', value: '11,600'),
                _DetailChip(label: 'Rejected Qty', value: '100'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Images',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const <Widget>[
                _PreviewCard(title: 'PO Image'),
                _PreviewCard(title: 'Button Image'),
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
  const _PreviewCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(child: Text(title)),
    );
  }
}
