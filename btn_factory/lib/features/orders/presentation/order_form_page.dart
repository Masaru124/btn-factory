import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum OrderFormMode { create, edit }

class OrderFormPage extends ConsumerStatefulWidget {
  const OrderFormPage({super.key, required this.mode});

  final OrderFormMode mode;

  @override
  ConsumerState<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends ConsumerState<OrderFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController(text: 'Alpha Metal Works');
  final TextEditingController _poNumberController = TextEditingController(text: 'PO-1044');
  final TextEditingController _holesController = TextEditingController(text: '4');
  final TextEditingController _rateController = TextEditingController(text: '42.50');
  final TextEditingController _quantityController = TextEditingController(text: '12000');
  String? _castingType = 'Pressed';
  String? _thickness = '1.2 mm';
  String? _boxType = 'Export';
  String? _linings = 'No';
  String? _laser = 'Yes';
  String? _polishType = 'Mirror';
  String? _packingOption = 'Carton';
  DateTime? _poDate = DateTime.now();
  DateTime? _dispatchDate = DateTime.now().add(const Duration(days: 14));
  String? _poImageName;
  String? _buttonImageName;

  @override
  void dispose() {
    _companyController.dispose();
    _poNumberController.dispose();
    _holesController.dispose();
    _rateController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isPoDate) async {
    final DateTime initialDate = isPoDate ? _poDate ?? DateTime.now() : _dispatchDate ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      if (isPoDate) {
        _poDate = pickedDate;
      } else {
        _dispatchDate = pickedDate;
      }
    });
  }

  Future<void> _pickImage(bool isPoImage) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      if (isPoImage) {
        _poImageName = result.files.single.name;
      } else {
        _buttonImageName = result.files.single.name;
      }
    });
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: options.map((option) => DropdownMenuItem<String>(value: option, child: Text(option))).toList(growable: false),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select $label' : null,
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, VoidCallback onTap) {
    final String value = _selectedDateLabel(selectedDate, label);

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: <Widget>[
            const Icon(Icons.date_range_outlined),
            const SizedBox(width: 10),
            Text(value),
          ],
        ),
      ),
    );
  }

  String _selectedDateLabel(DateTime? selectedDate, String label) {
    if (selectedDate == null) {
      return 'Pick $label';
    }
    return MaterialLocalizations.of(context).formatMediumDate(selectedDate);
  }

  Widget _buildUploadTile({required String label, required String? fileName, required VoidCallback onPressed}) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(fileName ?? 'No file selected'),
        trailing: OutlinedButton(onPressed: onPressed, child: const Text('Choose')),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_poImageName == null || _buttonImageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload both PO image and button image before submitting.')));
      return;
    }

    try {
      final Dio dio = ref.read(dioProvider);
      final Map<String, dynamic> payload = {
        'company_name': _companyController.text.trim(),
        'po_number': _poNumberController.text.trim(),
        'po_date': _poDate?.toIso8601String().split('T').first,
        'casting_type': _castingType,
        'thickness': _thickness,
        'holes': _holesController.text.trim(),
        'box_type': _boxType,
        'rate': double.tryParse(_rateController.text) ?? 0.0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'linings': _linings,
        'laser': _laser,
        'polish_type': _polishType,
        'packing_option': _packingOption,
        'dispatch_date': _dispatchDate?.toIso8601String().split('T').first,
        'po_image': _poImageName,
        'button_image': _buttonImageName,
      };

      final Response response = await dio.post('/orders/create', data: payload);
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(token != null ? 'Order created. Token: $token' : 'Order created')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 1,
      title: widget.mode == OrderFormMode.create ? 'Create Order' : 'Edit Order',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            widget.mode == OrderFormMode.create ? 'Create a new job card' : 'Reuse the same widgets to edit an existing order',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Company Information', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Company name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _poNumberController,
                  decoration: const InputDecoration(labelText: 'PO Number'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'PO number is required' : null,
                ),
                const SizedBox(height: 16),
                _buildDateField('PO Date', _poDate, () => _pickDate(true)),
                const SizedBox(height: 16),
                _buildUploadTile(label: 'PO Image', fileName: _poImageName, onPressed: () => _pickImage(true)),
                const SizedBox(height: 24),
                Text('Product Information', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                LayoutBuilder(
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
                      children: <Widget>[
                        _buildDropdown('Casting Type', _castingType, const <String>['Pressed', 'Moulded', 'Die Cast'], (value) => setState(() => _castingType = value)),
                        _buildDropdown('Thickness', _thickness, const <String>['0.8 mm', '1.0 mm', '1.2 mm', '1.5 mm'], (value) => setState(() => _thickness = value)),
                        TextFormField(
                          controller: _holesController,
                          decoration: const InputDecoration(labelText: 'Holes'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Holes are required' : null,
                        ),
                        _buildDropdown('Box Type', _boxType, const <String>['Export', 'Retail', 'Bulk'], (value) => setState(() => _boxType = value)),
                        TextFormField(
                          controller: _rateController,
                          decoration: const InputDecoration(labelText: 'Rate'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Rate is required' : null,
                        ),
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Quantity is required' : null,
                        ),
                        _buildDropdown('Linings', _linings, const <String>['Yes', 'No'], (value) => setState(() => _linings = value)),
                        _buildDropdown('Laser', _laser, const <String>['Yes', 'No'], (value) => setState(() => _laser = value)),
                        _buildDropdown('Polish Type', _polishType, const <String>['Mirror', 'Matt', 'Antique'], (value) => setState(() => _polishType = value)),
                        _buildDropdown('Packing Option', _packingOption, const <String>['Carton', 'Bag', 'Pallet'], (value) => setState(() => _packingOption = value)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField('Dispatch Date', _dispatchDate, () => _pickDate(false)),
                const SizedBox(height: 16),
                _buildUploadTile(label: 'Button Image', fileName: _buttonImageName, onPressed: () => _pickImage(false)),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: Text(widget.mode == OrderFormMode.create ? 'Create Order' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
