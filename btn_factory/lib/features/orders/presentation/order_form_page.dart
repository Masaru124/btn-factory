import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/app_image_preview.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:btn_factory/features/auth/application/auth_controller.dart';
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
  final TextEditingController _holesController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _laserController = TextEditingController();
  final TextEditingController _polishTypeController = TextEditingController();
  final TextEditingController _packingOptionController = TextEditingController();
  String? _castingType;
  String? _thickness;
  String? _boxType;
  String? _linings;
  DateTime? _poDate;
  DateTime? _dispatchDate;
  String? _poImageName;
  Uint8List? _poImageBytes;
  String? _buttonImageName;
  Uint8List? _buttonImageBytes;
  String? _status;

  bool _isSubmitting = false;
  bool _isSubmitted = false;
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
      _holesController.text = '4';
      _rateController.text = '42.50';
      _quantityController.text = '12000';
      _castingType = 'Sheet';
      _thickness = '1.2 mm';
      _boxType = 'DD';
      _linings = '14';
      _laserController.text = 'Logo';
      _polishTypeController.text = 'Mirror';
      _packingOptionController.text = 'Carton';
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
        _holesController.text = order['holes'] as String? ?? '';
        _rateController.text = order['rate']?.toString() ?? '';
        _quantityController.text = order['quantity']?.toString() ?? '';
        _castingType = order['casting_type'] as String?;
        _thickness = order['thickness'] as String?;
        _boxType = order['box_type'] as String?;
        _linings = order['linings'] as String?;
        _laserController.text = order['laser'] as String? ?? '';
        _polishTypeController.text = order['polish_type'] as String? ?? '';
        _packingOptionController.text = order['packing_option'] as String? ?? '';
        _status = order['status'] as String?;

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
    _holesController.dispose();
    _rateController.dispose();
    _quantityController.dispose();
    _laserController.dispose();
    _polishTypeController.dispose();
    _packingOptionController.dispose();
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
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }

    final platformFile = result.files.single;
    Uint8List? bytes = platformFile.bytes;

    if (bytes == null && platformFile.path != null && !kIsWeb) {
      try {
        final file = File(platformFile.path!);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      } catch (_) {}
    }

    String imageValue;
    if (bytes != null && bytes.isNotEmpty) {
      final ext = platformFile.name.contains('.') ? platformFile.name.split('.').last.toLowerCase() : 'png';
      final mime = (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : (ext == 'webp' ? 'image/webp' : 'image/png');
      imageValue = 'data:$mime;base64,${base64Encode(bytes)}';
    } else {
      imageValue = platformFile.path ?? platformFile.name;
    }

    setState(() {
      if (isPoImage) {
        _poImageName = imageValue;
        _poImageBytes = bytes;
      } else {
        _buttonImageName = imageValue;
        _buttonImageBytes = bytes;
      }
    });
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: const Color(0xFF111827),
      style: const TextStyle(color: Color(0xFFF8FAFC)),
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
            const Icon(Icons.date_range_outlined, color: Color(0xFF64748B)),
            const SizedBox(width: 10),
            Text(displayValue, style: const TextStyle(color: Color(0xFFF8FAFC))),
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final Dio dio = ref.read(dioProvider);
      final Map<String, dynamic> payload = {
        'company_name': _companyController.text.trim(),
        'po_date': _poDate?.toIso8601String().split('T').first,
        'casting_type': _castingType,
        'thickness': _thickness,
        'holes': _holesController.text.trim(),
        'box_type': _boxType,
        'rate': double.tryParse(_rateController.text) ?? 0.0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'linings': _linings,
        'laser': _laserController.text.trim(),
        'polish_type': _polishTypeController.text.trim(),
        'packing_option': _packingOptionController.text.trim(),
        'dispatch_date': _dispatchDate?.toIso8601String().split('T').first,
        'po_image': _poImageName,
        'button_image': _buttonImageName,
        if (widget.mode == OrderFormMode.edit && _status != null) 'status': _status,
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
      
      setState(() {
        _isSubmitted = true;
      });

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
    final authState = ref.watch(authControllerProvider).value;
    final isAdmin = authState?.userRole == 'super_admin';

    if (widget.mode == OrderFormMode.edit && !isAdmin) {
      return AppScaffold(
        selectedIndex: 1,
        title: 'Access Denied',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_outline, size: 64, color: Color(0xFFEF4444)),
                SizedBox(height: 16),
                Text(
                  'Access Denied: Only Admin can edit submitted forms.',
                  style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Form submission restriction is active. Non-admin users are denied access to modify submitted order forms.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_isLoadingOrder) {
      return AppScaffold(
        selectedIndex: 1,
        title: widget.mode == OrderFormMode.create ? 'Create Order' : 'Edit Order',
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6))),
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
              Text(_loadError!, style: const TextStyle(color: Color(0xFFFCA5A5))),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: <Widget>[
          Text(
            widget.mode == OrderFormMode.create ? 'Create a new production job card' : 'Edit the specifications of manufacturing order.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Company section header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Company Information',
                      style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyController,
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Company name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildDateField('PO Date', _poDate, () => _pickDate(true)),
                const SizedBox(height: 16),
                AppImageUploadCard(
                  label: 'PO Image Upload',
                  imageSource: _poImageName,
                  imageBytes: _poImageBytes,
                  onPickImage: () => _pickImage(true),
                  onClearImage: () => setState(() {
                    _poImageName = null;
                    _poImageBytes = null;
                  }),
                ),
                
                const SizedBox(height: 32),
                
                // Product section header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Product Information',
                      style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900 ? 2 : 1;
                    final castingOptions = <String>['Sheet', 'Rod', 'Blank', 'Block', 'Custom'];
                    if (_castingType != null && !castingOptions.contains(_castingType)) {
                      castingOptions.add(_castingType!);
                    }
                    final liningOptions = List<String>.generate(15, (i) => (14 + i * 2).toString());
                    if (_linings != null && !liningOptions.contains(_linings)) {
                      liningOptions.add(_linings!);
                    }
                    return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: constraints.maxWidth >= 900 ? 4.8 : 3.8,
                      ),
                      children: <Widget>[
                        _buildDropdown('Casting Type', _castingType, castingOptions, (value) => setState(() => _castingType = value)),
                        _buildDropdown('Thickness', _thickness, const <String>['0.8 mm', '1.0 mm', '1.2 mm', '1.5 mm'], (value) => setState(() => _thickness = value)),
                        TextFormField(
                          controller: _holesController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Holes'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Holes are required' : null,
                        ),
                        _buildDropdown('Box Type', _boxType, const <String>['DD', 'SD'], (value) => setState(() => _boxType = value)),
                        TextFormField(
                          controller: _rateController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Rate (₹)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Rate is required' : null,
                        ),
                        TextFormField(
                          controller: _quantityController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Quantity is required' : null,
                        ),
                        _buildDropdown('Linings', _linings, liningOptions, (value) => setState(() => _linings = value)),
                        TextFormField(
                          controller: _laserController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Laser Logo/Text'),
                        ),
                        TextFormField(
                          controller: _polishTypeController,
                          enabled: !_isSubmitted,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Polish Type'),
                        ),
                        TextFormField(
                          controller: _packingOptionController,
                          enabled: !_isSubmitted,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Packing Type'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField('Dispatch Date', _dispatchDate, () => _pickDate(false)),
                const SizedBox(height: 16),
                AppImageUploadCard(
                  label: 'Button Sample Image',
                  imageSource: _buttonImageName,
                  imageBytes: _buttonImageBytes,
                  onPickImage: () => _pickImage(false),
                  onClearImage: () => setState(() {
                    _buttonImageName = null;
                    _buttonImageBytes = null;
                  }),
                ),
                
                if (widget.mode == OrderFormMode.edit && _status != null) ...[
                  const SizedBox(height: 32),
                  // Status section header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Order Lifecycle Status',
                        style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Current Status',
                    _status,
                    const <String>[
                      'Created',
                      'Raw Material Updated',
                      'Casting Completed',
                      'Turning Completed',
                      'Polishing Completed',
                      'Packing Completed',
                      'Ready To Dispatch',
                      'Dispatched',
                    ],
                    (value) => setState(() => _status = value),
                  ),
                ],
                const SizedBox(height: 36),
                FilledButton(
                  onPressed: (_isSubmitting || _isSubmitted) ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text(
                          widget.mode == OrderFormMode.create ? 'Create Order Job Card' : 'Save Specs Changes',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


