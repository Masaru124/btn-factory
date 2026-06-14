import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum OrderFormMode { create, edit }

class OrderFormPage extends ConsumerStatefulWidget {
  const OrderFormPage({super.key, required this.mode, this.orderToken});

  final OrderFormMode mode;
  final String? orderToken;

  @override
  ConsumerState<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends ConsumerState<OrderFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _poNumberController = TextEditingController();
  final TextEditingController _holesController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _castingType;
  String? _thickness;
  String? _boxType;
  String? _linings;
  String? _laser;
  String? _polishType;
  String? _packingOption;
  DateTime? _poDate;
  DateTime? _dispatchDate;
  String? _poImageName;
  String? _buttonImageName;
  
  bool _isSubmitting = false;
  bool _isLoadingOrder = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (widget.mode == OrderFormMode.edit && widget.orderToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrderDetails());
    } else {
      // Set default values for Create Mode
      _companyController.text = 'Alpha Metal Works';
      _poNumberController.text = 'PO-1044';
      _holesController.text = '4';
      _rateController.text = '42.50';
      _quantityController.text = '12000';
      _castingType = 'Pressed';
      _thickness = '1.2 mm';
      _boxType = 'Export';
      _linings = 'No';
      _laser = 'Yes';
      _polishType = 'Mirror';
      _packingOption = 'Carton';
      _poDate = DateTime.now();
      _dispatchDate = DateTime.now().add(const Duration(days: 14));
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoadingOrder = true;
      _loadError = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders/${widget.orderToken}');
      final order = response.data as Map<String, dynamic>;

      setState(() {
        _companyController.text = order['company_name'] as String? ?? '';
        _poNumberController.text = order['po_number'] as String? ?? '';
        _holesController.text = order['holes'] as String? ?? '';
        _rateController.text = order['rate']?.toString() ?? '';
        _quantityController.text = order['quantity']?.toString() ?? '';
        _castingType = order['casting_type'] as String?;
        _thickness = order['thickness'] as String?;
        _boxType = order['box_type'] as String?;
        _linings = order['linings'] as String?;
        _laser = order['laser'] as String?;
        _polishType = order['polish_type'] as String?;
        _packingOption = order['packing_option'] as String?;

        if (order['po_date'] != null) {
          _poDate = DateTime.tryParse(order['po_date'] as String);
        }
        if (order['dispatch_date'] != null) {
          _dispatchDate = DateTime.tryParse(order['dispatch_date'] as String);
        }
        _poImageName = order['po_image'] as String?;
        _buttonImageName = order['button_image'] as String?;
        _isLoadingOrder = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOrder = false;
        _loadError = 'Failed to load order details: $e';
      });
    }
  }

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
      value: value,
      decoration: InputDecoration(labelText: label),
      items: options.map((option) => DropdownMenuItem<String>(value: option, child: Text(option))).toList(growable: false),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select $label' : null,
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, VoidCallback onTap) {
    final String displayValue = _selectedDateLabel(selectedDate, label);

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: <Widget>[
            const Icon(Icons.date_range_outlined),
            const SizedBox(width: 10),
            Text(displayValue),
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

    setState(() => _isSubmitting = true);

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

      final Response response;
      if (widget.mode == OrderFormMode.edit && widget.orderToken != null) {
        response = await dio.put('/orders/update/${widget.orderToken}', data: payload);
      } else {
        response = await dio.post('/orders/create', data: payload);
      }

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      
      if (!mounted) return;
      
      if (widget.mode == OrderFormMode.edit) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(token != null ? 'Order created. Token: $token' : 'Order created')));
      }
      
      Navigator.of(context).pop(true); // Return true to signal success/refresh
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map ? (e.response!.data as Map)['detail'] ?? e.message : e.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $detail')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save order: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOrder) {
      return AppScaffold(
        selectedIndex: 1,
        title: widget.mode == OrderFormMode.create ? 'Create Order' : 'Edit Order',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return AppScaffold(
        selectedIndex: 1,
        title: widget.mode == OrderFormMode.create ? 'Create Order' : 'Edit Order',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _fetchOrderDetails, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      selectedIndex: 1,
      title: widget.mode == OrderFormMode.create ? 'Create Order' : 'Edit Order',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            widget.mode == OrderFormMode.create ? 'Create a new job card' : 'Edit the details of this manufacturing order.',
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
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.mode == OrderFormMode.create ? 'Create Order' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

