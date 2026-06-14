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
      setState(() {
        _isLoading = false;
        _error = errorMessage;
      });
    }
  }

  Future<void> _deleteStaff(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Staff Account?'),
        content: const Text('This will disable the user account. They will no longer be able to log in to the system.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/auth/users/$userId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff account deactivated successfully')),
        );
        _fetchStaff();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to deactivate staff: $e')),
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
        selectedIndex: 0,
        title: 'Manage Staff',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AppScaffold(
        selectedIndex: 0,
        title: 'Manage Staff',
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
      selectedIndex: 0,
      title: 'Manage Staff',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Staff Members', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    const Text('Manage login accounts and system permissions for factory personnel.'),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => _showStaffDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Staff'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchStaff,
                child: _staffList.isEmpty
                    ? const Center(child: Text('No staff members registered yet.'))
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
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 2)),
                                      ),
                                      children: const [
                                        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                        Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Department', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    ..._staffList.map((user) {
                                      final isActive = user['is_active'] as bool? ?? true;
                                      return TableRow(
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            child: Text(user['name'] as String? ?? ''),
                                          ),
                                          Text(user['email'] as String? ?? ''),
                                          Text(_formatRole(user['role'] as String? ?? '')),
                                          Text(user['department'] as String? ?? 'N/A'),
                                          WidgetBorderStatus(isActive: isActive),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined),
                                                tooltip: 'Edit Staff',
                                                onPressed: () => _showStaffDialog(user as Map<String, dynamic>),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                color: Theme.of(context).colorScheme.error,
                                                tooltip: 'Deactivate Staff',
                                                onPressed: isActive ? () => _deleteStaff(user['id'] as int) : null,
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
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(user['name'] as String? ?? ''),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(user['email'] as String? ?? ''),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(_formatRole(user['role'] as String? ?? '')),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            const SizedBox(width: 8),
                                            if (user['department'] != null)
                                              Chip(
                                                label: Text(user['department'] as String),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        WidgetBorderStatus(isActive: isActive),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () => _showStaffDialog(user as Map<String, dynamic>),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          color: Theme.of(context).colorScheme.error,
                                          onPressed: isActive ? () => _deleteStaff(user['id'] as int) : null,
                                        ),
                                      ],
                                    ),
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
    return Chip(
      label: Text(isActive ? 'Active' : 'Disabled'),
      backgroundColor: isActive ? Colors.green.shade50 : Colors.red.shade50,
      side: BorderSide(color: isActive ? Colors.green.shade300 : Colors.red.shade300),
      labelStyle: TextStyle(
        color: isActive ? Colors.green.shade800 : Colors.red.shade800,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      visualDensity: VisualDensity.compact,
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

      widget.onSave();
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.staff != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Staff Account' : 'Register New Staff'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: isEdit ? 'New Password (leave blank to keep current)' : 'Password',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!isEdit && (value == null || value.isEmpty)) return 'Password is required';
                    if (value != null && value.isNotEmpty && value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase().replaceAll('_', ' '))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _role = val;
                        // Auto-assign corresponding department
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
                  value: _department,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
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
                    title: const Text('Account Active'),
                    subtitle: const Text('Toggle to disable logins for this account.'),
                    value: _isActive,
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Details'),
        ),
      ],
    );
  }
}
