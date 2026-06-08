import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class DepartmentUpdatePage extends StatefulWidget {
  const DepartmentUpdatePage({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.description,
    required this.fieldLabels,
    required this.currentStatusLabel,
  });

  final String title;
  final int selectedIndex;
  final String description;
  final List<String> fieldLabels;
  final String currentStatusLabel;

  @override
  State<DepartmentUpdatePage> createState() => _DepartmentUpdatePageState();
}

class _DepartmentUpdatePageState extends State<DepartmentUpdatePage> {
  final TextEditingController _tokenController = TextEditingController(text: 'BTN-2025-0001');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: widget.selectedIndex,
      title: widget.title,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(widget.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          SectionCard(
            title: 'Step 1: Search Token',
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _tokenController,
                    decoration: const InputDecoration(labelText: 'Token'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: () {}, child: const Text('Fetch Order')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Step 2: Order Snapshot',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                _SnapshotChip(label: 'Company', value: 'Alpha Metal Works'),
                _SnapshotChip(label: 'PO', value: 'PO-1044'),
                _SnapshotChip(label: 'Current Status', value: widget.currentStatusLabel),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Step 3: Department Form',
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900 ? 2 : 1;

                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 4.8,
                    ),
                    children: widget.fieldLabels
                        .map(
                          (label) => TextFormField(
                            decoration: InputDecoration(labelText: label),
                            validator: (value) => value == null || value.trim().isEmpty ? '$label is required' : null,
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Department update submitted and status will be advanced by the backend.')));
              }
            },
            child: const Text('Submit Update'),
          ),
        ],
      ),
    );
  }
}

class _SnapshotChip extends StatelessWidget {
  const _SnapshotChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
