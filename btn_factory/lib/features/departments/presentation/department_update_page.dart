import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/app_image_preview.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';


class FieldDefinition {
  final String label;
  final String jsonKey;
  final String type; // 'string', 'double', 'int', 'datetime'

  const FieldDefinition(this.label, this.jsonKey, this.type);
}

class RawMaterialInputRow {
  final nameController = TextEditingController();
  final totalAvailableController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController(text: 'kg');
  final priceController = TextEditingController();
}

class DepartmentUpdatePage extends ConsumerStatefulWidget {
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
  ConsumerState<DepartmentUpdatePage> createState() => _DepartmentUpdatePageState();
}

class _DepartmentUpdatePageState extends ConsumerState<DepartmentUpdatePage> {
  final TextEditingController _tokenController = TextEditingController(text: 'BTN-2025-0001');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _order;
  bool _isFetching = false;
  bool _isSubmitting = false;
  String? _fetchError;
  String? _submitError;

  final Map<String, TextEditingController> _fieldControllers = {};
  final List<RawMaterialInputRow> _rawMaterialRows = [];
  List<Map<String, dynamic>> _universalMaterials = [];
  bool _isLoadingUniversal = false;

  List<FieldDefinition> _getFields() {
    switch (widget.title) {
      case 'Raw Material':
        return const [
          FieldDefinition('Material Name', 'material_name', 'string'),
          FieldDefinition('Total Available Raw Material', 'total_available_quantity', 'double'),
          FieldDefinition('Quantity for Order', 'quantity', 'double'),
          FieldDefinition('Unit', 'unit', 'string'),
          FieldDefinition('Price', 'price', 'double'),
        ];
      case 'Casting':
        return const [
          FieldDefinition('Casting Type', 'casting_type', 'string'),
          FieldDefinition('Date of Casting', 'date_of_casting', 'datetime'),
          FieldDefinition('Total Weight (kg)', 'total_weight', 'double'),
          FieldDefinition('Blank Thickness', 'blank_thickness', 'string'),
          FieldDefinition('No. of Sheets', 'no_of_sheets', 'int'),
          FieldDefinition('Gross Quantity', 'gross_quantity', 'int'),
          FieldDefinition('Machine No', 'machine_no', 'string'),
          FieldDefinition('Start Time', 'start_time', 'datetime'),
          FieldDefinition('End Time', 'end_time', 'datetime'),
          FieldDefinition('Remarks', 'remarks', 'string'),
        ];
      case 'Turning':
        return const [
          FieldDefinition('Receiving Date (for Turning)', 'receiving_date', 'datetime'),
          FieldDefinition('Date of Turning', 'date_of_turning', 'datetime'),
          FieldDefinition('Inwards Weight (kg)', 'inward_weight', 'double'),
          FieldDefinition('Tool Number', 'tool_no', 'string'),
          FieldDefinition('Hole', 'hole_size', 'string'),
          FieldDefinition('M/C No.', 'machine_no', 'string'),
          FieldDefinition('Outward Weight (kg)', 'outward_weight', 'double'),
          FieldDefinition('Gross (Approx)', 'gross_quantity', 'int'),
          FieldDefinition('Semi Finish Thickness', 'semi_finish_thickness', 'string'),
          FieldDefinition('Finish Thickness', 'finish_thickness', 'string'),
          FieldDefinition('Operator', 'operator', 'string'),
          FieldDefinition('Remarks', 'remarks', 'string'),
        ];
      case 'Polish':
        return const [
          FieldDefinition('Tool Number', 'tool_no', 'string'),
          FieldDefinition('Receiving Date (from Laser/Turning)', 'receiving_date', 'datetime'),
          FieldDefinition('Inward Weight (kg)', 'inward_weight', 'double'),
          FieldDefinition('Outward Weight (kg)', 'outward_weight', 'double'),
          FieldDefinition('In Gross', 'gross_quantity', 'int'),
          FieldDefinition('Finishing : Polish / Semi Finish / F/R', 'polish_type', 'string'),
          FieldDefinition('Time of Feeding', 'feeding_time', 'datetime'),
          FieldDefinition('Out Time', 'out_time', 'datetime'),
          FieldDefinition('Operator', 'operator', 'string'),
          FieldDefinition('Remarks', 'remarks', 'string'),
        ];
      case 'Packing':
        return const [
          FieldDefinition('Receiving Date (from Polishing)', 'receiving_date', 'datetime'),
          FieldDefinition('Tool Number', 'tool_no', 'string'),
          FieldDefinition('Inward Weight (kg)', 'inward_weight', 'double'),
          FieldDefinition('In Gross', 'in_gross', 'int'),
          FieldDefinition('Finishing : Polish / Semi Finish / F/R', 'finishing', 'string'),
          FieldDefinition('Packed in Gross', 'packed_qty', 'int'),
          FieldDefinition('Excess Qty.', 'excess_qty', 'int'),
          FieldDefinition('Short Qty.', 'short_qty', 'int'),
          FieldDefinition('Rejection Qty.', 'rejected_qty', 'int'),
          FieldDefinition('Reason for Rejection', 'remarks', 'string'),
          FieldDefinition('Operator', 'operator', 'string'),
        ];
      default:
        return const [];
    }
  }

  String _getApiEndpoint() {
    switch (widget.title) {
      case 'Raw Material':
        return '/department/raw-material/add';
      case 'Casting':
        return '/department/casting/update';
      case 'Turning':
        return '/department/turning/update';
      case 'Polish':
        return '/department/polish/update';
      case 'Packing':
        return '/department/packing/update';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    for (final field in _getFields()) {
      _fieldControllers[field.jsonKey] = TextEditingController();
    }
    if (widget.title == 'Raw Material') {
      _rawMaterialRows.add(RawMaterialInputRow());
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchUniversalMaterials());
    }
  }

  Future<void> _fetchUniversalMaterials() async {
    setState(() => _isLoadingUniversal = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/department/raw-material/universal');
      if (res.data is List) {
        setState(() {
          _universalMaterials = (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoadingUniversal = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingUniversal = false);
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    for (final row in _rawMaterialRows) {
      row.nameController.dispose();
      row.totalAvailableController.dispose();
      row.quantityController.dispose();
      row.unitController.dispose();
      row.priceController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchOrder() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() {
      _isFetching = true;
      _fetchError = null;
      _order = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders/$token');
      setState(() {
        _order = response.data as Map<String, dynamic>;
        _isFetching = false;
        if (widget.title == 'Casting' && _order != null && _order!['casting_type'] != null) {
          final castingType = _order!['casting_type'].toString();
          if (castingType.isNotEmpty && (_fieldControllers['casting_type']?.text.isEmpty ?? true)) {
            _fieldControllers['casting_type']?.text = castingType;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isFetching = false;
        _fetchError = e is DioException && e.response?.statusCode == 404
            ? 'Order not found'
            : 'Failed to fetch order: $e';
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final DateTime dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    controller.text = dateTime.toUtc().toIso8601String();
  }

  Future<void> _submitUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final payload = <String, dynamic>{
      'order_token': token,
    };

    if (widget.title == 'Raw Material') {
      final materialsList = <Map<String, dynamic>>[];
      for (final row in _rawMaterialRows) {
        final totalAvail = double.tryParse(row.totalAvailableController.text.trim());
        final map = <String, dynamic>{
          'material_name': row.nameController.text.trim(),
          'quantity': double.tryParse(row.quantityController.text.trim()) ?? 0.0,
          'unit': row.unitController.text.trim().isEmpty ? 'kg' : row.unitController.text.trim(),
          'price': double.tryParse(row.priceController.text.trim()) ?? 0.0,
        };
        if (totalAvail != null) {
          map['total_available_quantity'] = totalAvail;
        }
        materialsList.add(map);
      }
      payload['materials'] = materialsList;
    } else {
      for (final field in _getFields()) {
        final text = _fieldControllers[field.jsonKey]?.text.trim() ?? '';
        if (text.isEmpty) {
          continue;
        }
        if (field.type == 'double') {
          payload[field.jsonKey] = double.tryParse(text) ?? 0.0;
        } else if (field.type == 'int') {
          payload[field.jsonKey] = int.tryParse(text) ?? 0;
        } else {
          payload[field.jsonKey] = text;
        }
      }
    }

    try {
      final dio = ref.read(dioProvider);
      final endpoint = _getApiEndpoint();
      await dio.post(endpoint, data: payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.title} details submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form fields
      if (widget.title == 'Raw Material') {
        for (final row in _rawMaterialRows) {
          row.nameController.dispose();
          row.totalAvailableController.dispose();
          row.quantityController.dispose();
          row.unitController.dispose();
          row.priceController.dispose();
        }
        _rawMaterialRows.clear();
        _rawMaterialRows.add(RawMaterialInputRow());
        _fetchUniversalMaterials();
      } else {
        for (final controller in _fieldControllers.values) {
          controller.clear();
        }
      }

      setState(() {
        _isSubmitting = false;
      });

      // Re-fetch the order to show the updated status in the snapshot
      await _fetchOrder();
    } catch (e) {
      String details = e.toString();
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          details = data['detail'].toString();
        }
      }
      setState(() {
        _isSubmitting = false;
        _submitError = 'Submission failed: $details';
      });
    }
  }

  Widget _buildUniversalMaterialSummary() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: Color(0xFF14B8A6), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Universal Available Raw Materials (Stock)',
                      style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF14B8A6)),
                  tooltip: 'Refresh Available Stock',
                  onPressed: _fetchUniversalMaterials,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoadingUniversal)
              const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: Color(0xFF14B8A6))))
            else if (_universalMaterials.isEmpty)
              const Text('No universal stock registered yet. Entering materials below will establish available stock.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontStyle: FontStyle.italic))
            else
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _universalMaterials.map((m) {
                  final name = m['material_name'] as String? ?? '';
                  final avail = m['total_available_quantity'] ?? 0;
                  final unit = m['unit'] as String? ?? 'kg';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      '$name: $avail $unit',
                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawMaterialRow(int index, RawMaterialInputRow row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Material #${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (_rawMaterialRows.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      setState(() {
                        _rawMaterialRows.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 85,
                  ),
                  children: [
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: row.nameController.text),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        final names = _universalMaterials.map((m) => m['material_name'] as String? ?? '').where((n) => n.isNotEmpty);
                        if (textEditingValue.text.isEmpty) {
                          return names;
                        }
                        return names.where((n) => n.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        row.nameController.text = selection;
                        final match = _universalMaterials.firstWhere(
                          (m) => (m['material_name'] as String?)?.toLowerCase() == selection.toLowerCase(),
                          orElse: () => <String, dynamic>{},
                        );
                        if (match.isNotEmpty) {
                          if (match['total_available_quantity'] != null) {
                            row.totalAvailableController.text = match['total_available_quantity'].toString();
                          }
                          if (match['unit'] != null) {
                            row.unitController.text = match['unit'].toString();
                          }
                          if (match['price'] != null) {
                            row.priceController.text = match['price'].toString();
                          }
                          setState(() {});
                        }
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        if (row.nameController.text.isNotEmpty && textEditingController.text.isEmpty) {
                          textEditingController.text = row.nameController.text;
                        }
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Material Name',
                            hintText: 'e.g. Polyester Resin',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => row.nameController.text = val,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Material name is required' : null,
                        );
                      },
                    ),
                    TextFormField(
                      controller: row.totalAvailableController,
                      decoration: const InputDecoration(
                        labelText: 'Total Available Raw Material',
                        hintText: 'Universal available stock',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextFormField(
                      controller: row.quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity for Order',
                        hintText: 'Used for this order',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value == null || double.tryParse(value) == null ? 'Enter a valid quantity' : null,
                    ),
                    TextFormField(
                      controller: row.unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (e.g. kg, gross)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Unit is required' : null,
                    ),
                    TextFormField(
                      controller: row.priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value == null || double.tryParse(value) == null ? 'Enter a valid price' : null,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool get _isDepartmentAlreadySubmitted {
    if (_order == null) return false;
    switch (widget.title) {
      case 'Raw Material':
        final rawMaterials = _order!['raw_materials'] as List<dynamic>? ?? [];
        final status = _order!['status'] as String? ?? 'Created';
        return rawMaterials.isNotEmpty || status != 'Created';
      case 'Casting':
        return _order!['casting_process'] != null;
      case 'Turning':
        return _order!['turning_process'] != null;
      case 'Polish':
        return _order!['polishing_process'] != null;
      case 'Packing':
        return _order!['packing_process'] != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = _getFields();
    final hasStatusMismatch = _order != null &&
        _order!['status'] != widget.currentStatusLabel;

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
                    decoration: const InputDecoration(
                      labelText: 'Token',
                      hintText: 'Enter order token (e.g. BTN-2025-0001)',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _fetchOrder(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isFetching ? null : _fetchOrder,
                    icon: _isFetching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Fetch Order'),
                  ),
                ),
              ],
            ),
          ),
          if (_fetchError != null) ...[
            const SizedBox(height: 12),
            Text(
              _fetchError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            title: 'Step 2: Order Snapshot',
            child: _order == null
                ? const Text('Search for a valid order to see the snapshot.', style: TextStyle(fontStyle: FontStyle.italic))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: <Widget>[
                          _SnapshotChip(label: 'Company', value: _order!['company_name'] as String? ?? 'N/A'),
                          if (widget.title == 'Raw Material')
                            _SnapshotChip(label: 'Order Qty', value: '${_order!['quantity'] ?? 'N/A'}'),
                          if (widget.title == 'Casting') ...[
                            _SnapshotChip(label: 'Total Quantity', value: '${_order!['quantity'] ?? 'N/A'}'),
                            _SnapshotChip(label: 'Casting Type', value: _order!['casting_type'] as String? ?? 'N/A'),
                          ],
                          _SnapshotChip(
                            label: 'Current Status',
                            value: _order!['status'] as String? ?? 'N/A',
                            color: hasStatusMismatch ? Colors.amber.shade900 : null,
                          ),
                          _SnapshotChip(label: 'Expected Status', value: widget.currentStatusLabel),
                        ],
                      ),
                      if (_order!['button_image'] != null) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            AppImagePreviewCard(
                              title: 'Button Sample Image',
                              imageSource: _order!['button_image'] as String?,
                              width: 190,
                              height: 150,
                            ),
                          ],
                        ),
                      ],
                      if (widget.title == 'Casting') ...[
                        const SizedBox(height: 16),
                        Text(
                          'Raw Materials:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final rawMaterials = _order!['raw_materials'] as List<dynamic>? ?? [];
                            if (rawMaterials.isEmpty) {
                              return const Text(
                                'No raw materials recorded.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              );
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: rawMaterials.map<Widget>((m) {
                                final name = m['material_name'] as String? ?? 'N/A';
                                final qty = m['quantity'] ?? 0;
                                final unit = m['unit'] as String? ?? '';
                                return Chip(
                                  avatar: const Icon(Icons.layers_outlined, size: 16),
                                  label: Text('$name: $qty $unit'),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                      if (hasStatusMismatch) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Status Warning: This order is currently in "${_order!['status']}". This department expects "${widget.currentStatusLabel}". Submitting details will force progress the status.',
                                  style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (widget.title == 'Raw Material') ...[
            const SizedBox(height: 16),
            _buildUniversalMaterialSummary(),
          ],
          const SizedBox(height: 16),
          SectionCard(
            title: 'Step 3: Department Form',
            child: _isDepartmentAlreadySubmitted
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.title} Form Already Submitted',
                                style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Details for ${widget.title} have already been submitted for order ${_order!['token']}. Form is locked and no longer taking inputs.',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: _order == null
                        ? const Text('Fetch an order first to enable the department form.', style: TextStyle(fontStyle: FontStyle.italic))
                        : widget.title == 'Raw Material'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ...List.generate(
                                    _rawMaterialRows.length,
                                    (index) => _buildRawMaterialRow(index, _rawMaterialRows[index]),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _rawMaterialRows.add(RawMaterialInputRow());
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Another Material'),
                                    ),
                                  ),
                                ],
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final columns = constraints.maxWidth >= 900 ? 2 : 1;

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent: 85,
                                    ),
                                    itemCount: fields.length,
                                    itemBuilder: (context, index) {
                                      final field = fields[index];
                                      final controller = _fieldControllers[field.jsonKey];
                                      if (controller == null) {
                                        // Re-initialize controller if not present (e.g. state changed dynamically)
                                        return const SizedBox();
                                      }

                                      if (field.type == 'datetime') {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: controller,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: field.label,
                                                  suffixIcon: IconButton(
                                                    icon: const Icon(Icons.calendar_today),
                                                    onPressed: () => _selectDateTime(context, controller),
                                                  ),
                                                  border: const OutlineInputBorder(),
                                                ),
                                                validator: (value) => value == null || value.trim().isEmpty ? '${field.label} is required' : null,
                                                onTap: () => _selectDateTime(context, controller),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () {
                                                controller.text = DateTime.now().toUtc().toIso8601String();
                                              },
                                              child: const Text('NOW'),
                                            ),
                                          ],
                                        );
                                      }

                                      return TextFormField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          labelText: field.label,
                                          border: const OutlineInputBorder(),
                                        ),
                                        keyboardType: field.type == 'double' || field.type == 'int'
                                            ? const TextInputType.numberWithOptions(decimal: true)
                                            : TextInputType.text,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return '${field.label} is required';
                                          }
                                          if (field.type == 'double' && double.tryParse(value) == null) {
                                            return 'Enter a valid decimal number';
                                          }
                                          if (field.type == 'int' && int.tryParse(value) == null) {
                                            return 'Enter a valid integer';
                                          }
                                          return null;
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                  ),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 12),
            Text(
              _submitError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_order == null || _isSubmitting || _isDepartmentAlreadySubmitted) ? null : _submitUpdate,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _isDepartmentAlreadySubmitted
                        ? 'Submitted for ${widget.title} (Locked)'
                        : 'Submit Update for ${widget.title}',
                  ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotChip extends StatelessWidget {
  const _SnapshotChip({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color?.withValues(alpha: 0.15),
      side: color != null ? BorderSide(color: color!) : null,
      labelStyle: color != null ? TextStyle(color: color, fontWeight: FontWeight.bold) : null,
    );
  }
}

