import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage> {
  List<dynamic> _staffList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStaff());
  }

  Future<void> _fetchStaff() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/auth/users');
      if (!mounted) return;
      setState(() {
        _staffList = response.data as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      String errorMessage = 'Failed to load staff: $e';
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          errorMessage = 'Access Denied: Admin privileges required to manage staff.';
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

  Future<void> _toggleStaffStatus(int userId, bool isCurrentlyActive) async {
    final action = isCurrentlyActive ? 'Deactivate' : 'Activate';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Staff Account?'),
        content: Text('This will ${isCurrentlyActive ? 'disable' : 'enable'} the user account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: isCurrentlyActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dio = ref.read(dioProvider);
      if (isCurrentlyActive) {
        await dio.delete('/auth/users/$userId');
      } else {
        await dio.put('/auth/users/$userId', data: {'is_active': true});
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Staff account ${action.toLowerCase()}d successfully')),
        );
        _fetchStaff();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${action.toLowerCase()} staff: $e')),
        );
      }
    }
  }

  void _showStaffDialog([Map<String, dynamic>? staff]) {
    showDialog(
      context: context,
      builder: (context) => _StaffFormDialog(
        staff: staff,
        onSave: () {
          Navigator.pop(context);
          _fetchStaff();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        selectedIndex: 8,
        title: 'Manage Staff',
        child: Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6))),
      );
    }

    if (_error != null) {
      return AppScaffold(
        selectedIndex: 8,
        title: 'Manage Staff',
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
                  onPressed: _fetchStaff,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      selectedIndex: 8,
      title: 'Manage Staff',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Staff Directory',
                        style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage active roles and security credentials.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showStaffDialog(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchStaff,
                color: const Color(0xFF14B8A6),
                backgroundColor: const Color(0xFF111827),
                child: _staffList.isEmpty
                    ? const Center(child: Text('No staff members registered yet.', style: TextStyle(color: Color(0xFF64748B))))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SectionCard(
                                title: 'Active Accounts',
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(2),
                                    4: FlexColumnWidth(1.5),
                                    5: IntrinsicColumnWidth(),
                                  },
                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Color(0xFF1F2937), width: 2)),
                                      ),
                                      children: const [
                                        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                                        Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                        Text('Role', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                        Text('Department', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                        Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                        Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                    ..._staffList.map((user) {
                                      final isActive = user['is_active'] as bool? ?? true;
                                      return TableRow(
                                        decoration: const BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            child: Text(user['name'] as String? ?? '', style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w600)),
                                          ),
                                          Text(user['email'] as String? ?? '', style: const TextStyle(color: Color(0xFFE2E8F0))),
                                          Text(_formatRole(user['role'] as String? ?? ''), style: const TextStyle(color: Color(0xFFF8FAFC))),
                                          Text(user['department'] as String? ?? 'N/A', style: const TextStyle(color: Color(0xFF94A3B8))),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: WidgetBorderStatus(isActive: isActive),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF14B8A6)),
                                                tooltip: 'Edit Staff',
                                                onPressed: () => _showStaffDialog(user as Map<String, dynamic>),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  isActive ? Icons.delete_outline : Icons.check_circle_outline,
                                                  color: isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                                ),
                                                tooltip: isActive ? 'Deactivate Staff' : 'Activate Staff',
                                                onPressed: () => _toggleStaffStatus(user['id'] as int, isActive),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _staffList.length,
                              itemBuilder: (context, index) {
                                final user = _staffList[index];
                                final isActive = user['is_active'] as bool? ?? true;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111827),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user['name'] as String? ?? '',
                                              style: const TextStyle(
                                                color: Color(0xFFF8FAFC),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          WidgetBorderStatus(isActive: isActive),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        user['email'] as String? ?? '',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E293B),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _formatRole(user['role'] as String? ?? ''),
                                              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          if (user['department'] != null) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E293B),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                (user['department'] as String).toUpperCase(),
                                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF14B8A6), size: 20),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            onPressed: () => _showStaffDialog(user as Map<String, dynamic>),
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: Icon(
                                              isActive ? Icons.delete_outline : Icons.check_circle_outline,
                                              color: isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                              size: 20,
                                            ),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            onPressed: () => _toggleStaffStatus(user['id'] as int, isActive),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'raw_material':
        return 'Raw Material Staff';
      case 'casting':
        return 'Casting Operator';
      case 'turning':
        return 'Turning Operator';
      case 'polish':
        return 'Polishing Operator';
      case 'packing':
        return 'Packing Staff';
      default:
        return role;
    }
  }
}

class WidgetBorderStatus extends StatelessWidget {
  const WidgetBorderStatus({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFEF4444).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFEF4444).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Disabled',
        style: TextStyle(
          color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _StaffFormDialog extends ConsumerStatefulWidget {
  const _StaffFormDialog({this.staff, required this.onSave});

  final Map<String, dynamic>? staff;
  final VoidCallback onSave;

  @override
  ConsumerState<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends ConsumerState<_StaffFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late String _role;
  late String? _department;
  late bool _isActive;
  bool _isSaving = false;

  final List<String> _roles = [
    'super_admin',
    'raw_material',
    'casting',
    'turning',
    'polish',
    'packing',
  ];

  final List<String> _departments = [
    'admin',
    'raw_material',
    'casting',
    'turning',
    'polish',
    'packing',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    _nameController = TextEditingController(text: s?['name'] as String? ?? '');
    _emailController = TextEditingController(text: s?['email'] as String? ?? '');
    _passwordController = TextEditingController();
    _role = s?['role'] as String? ?? 'super_admin';
    _department = s?['department'] as String? ?? 'admin';
    _isActive = s?['is_active'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    final isEdit = widget.staff != null;
    final dio = ref.read(dioProvider);

    try {
      if (isEdit) {
        final payload = <String, dynamic>{
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _role,
          'department': _department,
          'is_active': _isActive,
        };

        if (_passwordController.text.isNotEmpty) {
          payload['password'] = _passwordController.text;
        }

        await dio.put('/auth/users/${widget.staff!['id']}', data: payload);
      } else {
        final payload = <String, dynamic>{
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'role': _role,
          'department': _department,
        };

        await dio.post('/auth/register', data: payload);
      }

      if (mounted) {
        widget.onSave();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        String details = e.toString();
        if (e is DioException && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('detail')) {
            details = data['detail'].toString();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save staff details: $details')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.staff != null;

    return AlertDialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(isEdit ? 'Edit Staff Account' : 'Register New Staff', style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: InputDecoration(
                    labelText: isEdit ? 'New Password (leave blank to keep current)' : 'Password',
                  ),
                  validator: (value) {
                    if (!isEdit && (value == null || value.isEmpty)) return 'Password is required';
                    if (value != null && value.isNotEmpty && value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('role_$_role'),
                  initialValue: _role,
                  dropdownColor: const Color(0xFF111827),
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                  ),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase().replaceAll('_', ' '))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _role = val;
                        if (val == 'super_admin') {
                          _department = 'admin';
                        } else {
                          _department = val;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('dept_$_department'),
                  initialValue: _department,
                  dropdownColor: const Color(0xFF111827),
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: const InputDecoration(
                    labelText: 'Department',
                  ),
                  items: _departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d.toUpperCase().replaceAll('_', ' '))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _department = val);
                    }
                  },
                ),
                if (isEdit) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Account Active', style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold)),
                    subtitle: const Text('Toggle to disable logins for this account.', style: TextStyle(color: Color(0xFF64748B))),
                    value: _isActive,
                    activeThumbColor: const Color(0xFF14B8A6),
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text('Save Details'),
        ),
      ],
    );
  }
}

