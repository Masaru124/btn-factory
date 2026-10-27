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
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _holesController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _laserController = TextEditingController();
  final TextEditingController _polishTypeController = TextEditingController();
  final TextEditingController _packingOptionController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();
  final TextEditingController _boxTypeController = TextEditingController();
  final TextEditingController _sampleController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _poDateController = TextEditingController();
  final TextEditingController _dispatchDateController = TextEditingController();
  String _orderType = 'Production';
  String? _castingType;
  String? _linings;
  String? _poImageName;
  Uint8List? _poImageBytes;
  String? _buttonImageName;
  Uint8List? _buttonImageBytes;
  String? _status;
  bool _isDispatched = false;

  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _isLoadingOrder = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (widget.mode == OrderFormMode.edit && widget.orderToken != null) {
      _tokenController.text = widget.orderToken!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrderDetails());
    } else {
      // Sensible standard factory defaults
      _castingType = 'Sheet';
      _orderType = 'Production';
      _holesController.text = '4';
      _boxTypeController.text = 'DD';
      _thicknessController.text = '1.2 mm';
      _linings = '14';
      _poDateController.text = DateTime.now().toIso8601String().split('T').first;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNextToken());
    }
  }

  Future<void> _fetchNextToken() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/orders/next-token');
      if (res.data is Map && res.data['next_token'] != null) {
        if (mounted && _tokenController.text.isEmpty) {
          setState(() {
            _tokenController.text = res.data['next_token'].toString();
          });
        }
      }
    } catch (_) {}
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
        if (order['token'] != null) {
          _tokenController.text = order['token'].toString();
        }
        _orderType = (order['order_type'] as String?) ?? 'Production';
        _companyController.text = order['company_name'] as String? ?? '';
        _holesController.text = order['holes'] as String? ?? '';
        _rateController.text = order['rate']?.toString() ?? '';
        _quantityController.text = order['quantity']?.toString() ?? '';
        final rawCasting = order['casting_type'] as String?;
        _castingType = (rawCasting != null && rawCasting.toLowerCase() == 'rod') ? 'Rod' : 'Sheet';
        _sampleController.text = order['sample'] as String? ?? '';
        _thicknessController.text = order['thickness'] as String? ?? '';
        _boxTypeController.text = order['box_type'] as String? ?? '';
        _weightController.text = order['weight']?.toString() ?? '';
        _linings = order['linings'] as String?;
        _laserController.text = order['laser'] as String? ?? '';
        _polishTypeController.text = order['polish_type'] as String? ?? '';
        _packingOptionController.text = order['packing_option'] as String? ?? '';
        _status = order['status'] as String?;
        _isDispatched = _status == 'Dispatched';

        if (order['po_date'] != null) {
          final s = order['po_date'].toString();
          _poDateController.text = s.contains('T') ? s.split('T').first : s;
        }
        if (order['dispatch_date'] != null) {
          final s = order['dispatch_date'].toString();
          _dispatchDateController.text = s.contains('T') ? s.split('T').first : s;
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
    _tokenController.dispose();
    _companyController.dispose();
    _holesController.dispose();
    _rateController.dispose();
    _quantityController.dispose();
    _laserController.dispose();
    _polishTypeController.dispose();
    _packingOptionController.dispose();
    _thicknessController.dispose();
    _boxTypeController.dispose();
    _sampleController.dispose();
    _weightController.dispose();
    _poDateController.dispose();
    _dispatchDateController.dispose();
    super.dispose();
  }

  String _formatDateForPayload(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return DateTime.now().toIso8601String().split('T').first;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) return trimmed;
    final dt = DateTime.tryParse(trimmed);
    if (dt != null) return dt.toIso8601String().split('T').first;
    final dmy = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})').firstMatch(trimmed);
    if (dmy != null) {
      final d = dmy.group(1)!.padLeft(2, '0');
      final m = dmy.group(2)!.padLeft(2, '0');
      final y = dmy.group(3)!;
      return '$y-$m-$d';
    }
    return trimmed;
  }

  Future<void> _pickDate(bool isPoDate) async {
    final controller = isPoDate ? _poDateController : _dispatchDateController;
    DateTime initialDate = DateTime.now();
    if (controller.text.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(_formatDateForPayload(controller.text));
      if (parsed != null) initialDate = parsed;
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    final dateStr = pickedDate.toIso8601String().split('T').first;
    setState(() {
      if (isPoDate) {
        _poDateController.text = dateStr;
      } else {
        _dispatchDateController.text = dateStr;
      }
    });
  }

  Future<void> _pickImage(bool isPoImage, {ImageSource? source}) async {
    final ImageSource? selectedSource = source ?? await showImageSourceDialog(context);
    if (selectedSource == null) {
      return;
    }

    Uint8List? bytes;
    String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: selectedSource,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        bytes = await pickedFile.readAsBytes();
        fileName = pickedFile.name;
      }
    } catch (_) {
      // Fallback for desktop or unexpected camera/gallery exceptions
      if (selectedSource == ImageSource.gallery) {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );
        if (result != null && result.files.isNotEmpty) {
          final platformFile = result.files.single;
          bytes = platformFile.bytes;
          fileName = platformFile.name;
          if (bytes == null && platformFile.path != null && !kIsWeb) {
            try {
              final file = File(platformFile.path!);
              if (await file.exists()) {
                bytes = await file.readAsBytes();
              }
            } catch (_) {}
          }
        }
      }
    }

    if (bytes == null || bytes.isEmpty) {
      return;
    }

    // Encode image bytes as self-contained Base64 Data URI
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final mime = (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : (ext == 'webp' ? 'image/webp' : 'image/png');
    final base64Val = 'data:$mime;base64,${base64Encode(bytes)}';

    // Set immediate memory bytes and base64 string for 100% reliable local/remote display
    setState(() {
      if (isPoImage) {
        _poImageBytes = bytes;
        _poImageName = base64Val;
      } else {
        _buttonImageBytes = bytes;
        _buttonImageName = base64Val;
      }
    });

    // Also upload to media server in background for physical archival if available
    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });
      await dio.post('/media/upload', data: formData);
    } catch (_) {
      // Background media upload failure is non-fatal because base64 is already safely stored
    }
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

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onPick) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Color(0xFFF8FAFC)),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF14B8A6), size: 20),
          tooltip: 'Pick date',
          onPressed: onPick,
        ),
      ),
      validator: (value) {
        if (label.contains('PO Date') && (value == null || value.trim().isEmpty)) {
          return 'PO Date is required';
        }
        return null;
      },
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
        'token': _tokenController.text.trim().isNotEmpty ? _tokenController.text.trim() : null,
        'order_type': _orderType,
        'sample': _sampleController.text.trim().isNotEmpty ? _sampleController.text.trim() : null,
        'company_name': _companyController.text.trim(),
        'po_date': _formatDateForPayload(_poDateController.text),
        'casting_type': _castingType,
        'thickness': _thicknessController.text.trim(),
        'holes': _holesController.text.trim(),
        'box_type': _boxTypeController.text.trim(),
        'rate': double.tryParse(_rateController.text) ?? 0.0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'weight': double.tryParse(_weightController.text.trim()),
        'linings': _linings,
        'laser': _laserController.text.trim(),
        'polish_type': _polishTypeController.text.trim(),
        'packing_option': _packingOptionController.text.trim(),
        'dispatch_date': _isDispatched
            ? (_dispatchDateController.text.trim().isNotEmpty
                ? _formatDateForPayload(_dispatchDateController.text)
                : DateTime.now().toIso8601String().split('T').first)
            : (_dispatchDateController.text.trim().isNotEmpty
                ? _formatDateForPayload(_dispatchDateController.text)
                : null),
        'po_image': _poImageName,
        'button_image': _buttonImageName,
        if (_isDispatched)
          'status': 'Dispatched'
        else if (widget.mode == OrderFormMode.edit && _status != null)
          'status': (_status == 'Dispatched' ? 'Ready To Dispatch' : _status),
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
                // Order Identification & Classification header
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
                      'Order Identification & Classification',
                      style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    return Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: isWide ? 3 : 0,
                          child: TextFormField(
                            controller: _tokenController,
                            style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(
                              labelText: 'Order Number (Job Card No.) *',
                              helperText: 'Editable number. If deleted, it is freed & new orders can reuse it.',
                              prefixIcon: Icon(Icons.tag, color: Color(0xFF14B8A6)),
                            ),
                            validator: (value) => value == null || value.trim().isEmpty ? 'Order Number is required' : null,
                          ),
                        ),
                        if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                        Flexible(
                          flex: isWide ? 2 : 0,
                          child: DropdownButtonFormField<String>(
                            initialValue: _orderType,
                            dropdownColor: const Color(0xFF111827),
                            style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(
                              labelText: 'Order Type *',
                              prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF14B8A6)),
                              helperText: 'Production, Sampling, or Stock',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Production', child: Text('Production')),
                              DropdownMenuItem(value: 'Sampling', child: Text('Sampling')),
                              DropdownMenuItem(value: 'Stock', child: Text('Stock')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _orderType = val);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

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
                _buildDateField('PO Date (Manual Entry or Pick)', _poDateController, () => _pickDate(true)),
                const SizedBox(height: 16),
                AppImageUploadCard(
                  label: 'PO Image Upload',
                  imageSource: _poImageName,
                  imageBytes: _poImageBytes,
                  onPickImage: () => _pickImage(true, source: ImageSource.gallery),
                  onPickCamera: () => _pickImage(true, source: ImageSource.camera),
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
                    const castingOptions = <String>['Sheet', 'Rod'];
                    if (_castingType == null || !castingOptions.contains(_castingType)) {
                      _castingType = 'Sheet';
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
                        TextFormField(
                          controller: _sampleController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Sample'),
                        ),
                        TextFormField(
                          controller: _thicknessController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Thickness'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Thickness is required' : null,
                        ),
                        TextFormField(
                          controller: _holesController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(
                            labelText: 'Holes *',
                            helperText: 'Standard default: 4 (or 2, 0)',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Holes are required' : null,
                        ),
                        TextFormField(
                          controller: _boxTypeController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Box Type'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Box Type is required' : null,
                        ),
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
                        TextFormField(
                          controller: _weightController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Order Weight (kg)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        _buildDropdown('Linings', _linings, liningOptions, (value) => setState(() => _linings = value)),
                        TextFormField(
                          controller: _laserController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Laser Logo/Text'),
                        ),
                        TextFormField(
                          controller: _polishTypeController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Polish Type'),
                        ),
                        TextFormField(
                          controller: _packingOptionController,
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: const InputDecoration(labelText: 'Packing Type'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isDispatched ? const Color(0xFF10B981) : const Color(0xFF334155),
                      width: _isDispatched ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: _isDispatched,
                    activeColor: const Color(0xFF10B981),
                    checkColor: Colors.black,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      children: [
                        const Text(
                          'Order Dispatched',
                          style: TextStyle(
                            color: Color(0xFFF8FAFC),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _isDispatched
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : const Color(0xFF64748B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isDispatched ? 'DISPATCHED' : 'NOT DISPATCHED',
                            style: TextStyle(
                              color: _isDispatched ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _isDispatched
                          ? 'Tick enabled: Order marked as dispatched.'
                          : 'Unticked: Order has not been dispatched yet.',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    onChanged: (bool? val) {
                      setState(() {
                        _isDispatched = val ?? false;
                        if (_isDispatched) {
                          _status = 'Dispatched';
                          if (_dispatchDateController.text.trim().isEmpty) {
                            _dispatchDateController.text = DateTime.now().toIso8601String().split('T').first;
                          }
                        } else {
                          if (_status == 'Dispatched') {
                            _status = 'Ready To Dispatch';
                          }
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildDateField('Dispatch Date (Manual Entry or Pick)', _dispatchDateController, () => _pickDate(false)),
                const SizedBox(height: 16),
                AppImageUploadCard(
                  label: 'Button Sample Image',
                  imageSource: _buttonImageName,
                  imageBytes: _buttonImageBytes,
                  onPickImage: () => _pickImage(false, source: ImageSource.gallery),
                  onPickCamera: () => _pickImage(false, source: ImageSource.camera),
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


