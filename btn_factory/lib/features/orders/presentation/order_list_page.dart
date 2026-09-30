import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/app_image_preview.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  List<_OrderRow> _orders = <_OrderRow>[];
  bool _isLoading = true;
  String? _error;
  String? _deletingToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrders());
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders/list');
      final List<dynamic> data = response.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _orders = data.map((item) {
          final map = item as Map<String, dynamic>;
          final status = map['status'] as String? ?? 'Created';
          return _OrderRow(
            token: map['token'] as String? ?? '',
            companyName: map['company_name'] as String? ?? '',
            poNumber: map['po_number'] as String? ?? '',
            status: status,
            statusColor: _statusColor(status),
            buttonImage: map['button_image'] as String?,
            poImage: map['po_image'] as String?,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load orders: $e';
      });
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'Created':
        return const Color(0xFF64748B); // Slate
      case 'Raw Material Updated':
        return const Color(0xFF0D9488); // Teal
      case 'Casting Completed':
        return const Color(0xFFF97316); // Casting Orange
      case 'Turning Completed':
        return const Color(0xFF3B82F6); // Blue
      case 'Polishing Completed':
        return const Color(0xFFA855F7); // Purple
      case 'Packing Completed':
        return const Color(0xFF10B981); // Emerald
      case 'Ready To Dispatch':
      case 'Dispatched':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  /// Shows a confirmation popup, then deletes the order via the backend API
  /// and refreshes the list. Never opens the order details page.
  Future<void> _confirmAndDelete(_OrderRow order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1F2937)),
        ),
        title: const Text(
          'Delete order?',
          style: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Order ${order.token} for ${order.companyName} will be permanently deleted. Its token will not be reused for future orders.',
          style: const TextStyle(color: Color(0xFF94A3B8), height: 1.4),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingToken = order.token);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/orders/delete/${order.token}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.token} deleted'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      await _fetchOrders();
    } catch (e) {
      if (!mounted) return;
      String message = 'Failed to delete order ${order.token}';
      if (e is DioException) {
        final detail = e.response?.data;
        if (detail is Map && detail['detail'] is String) {
          message = detail['detail'] as String;
        } else if (e.response?.statusCode == 403) {
          message = 'You do not have permission to delete orders';
        } else if (e.response?.statusCode == 404) {
          message = 'Order ${order.token} was not found';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: const Color(0xFFEF4444)),
      );
    } finally {
      if (mounted) setState(() => _deletingToken = null);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider).value;
    final isAdmin = authState?.userRole == 'super_admin';

    final search = _searchController.text.trim().toLowerCase();
    final filteredOrders = _orders.where((order) {
      final matchesSearch = search.isEmpty ||
          order.token.toLowerCase().contains(search) ||
          order.poNumber.toLowerCase().contains(search) ||
          order.companyName.toLowerCase().contains(search);

      final matchesFilter = _selectedFilter == 'All' || order.status.contains(_selectedFilter);
      return matchesSearch && matchesFilter;
    }).toList(growable: false);

    return AppScaffold(
      selectedIndex: 1,
      title: 'Orders Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Search & Create Row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    decoration: InputDecoration(
                      labelText: 'Search PO number, token, or company',
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF1F2937)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF1F2937)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 1.5),
                      ),
                    ),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await context.push('/orders/create');
                      if (result == true) {
                        _fetchOrders();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Order', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips Carousel Area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: <String>['All', 'Created', 'Raw Material', 'Casting', 'Turning', 'Polishing', 'Packing', 'Dispatch']
                  .map(
                    (filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedFilter = filter),
                          backgroundColor: const Color(0xFF111827),
                          selectedColor: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                          checkmarkColor: const Color(0xFF14B8A6),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF94A3B8),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF1F2937),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6)))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_error!, style: const TextStyle(color: Color(0xFFFCA5A5))),
                            const SizedBox(height: 12),
                            OutlinedButton(onPressed: _fetchOrders, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : filteredOrders.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                'No orders found for the selected search and filter.',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchOrders,
                            color: const Color(0xFF14B8A6),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111827),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: order.statusColor.withValues(alpha: 0.15),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      await context.push('/orders/${order.token}');
                                      _fetchOrders();
                                    },
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: (order.buttonImage != null || order.poImage != null)
                                        ? SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: AppImagePreview(
                                                imageSource: order.buttonImage ?? order.poImage,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: order.statusColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.receipt_long, color: order.statusColor),
                                          ),
                                    title: Text(
                                      '${order.companyName} • ${order.token}',
                                      style: const TextStyle(
                                        color: Color(0xFFF8FAFC),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'PO ${order.poNumber}',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: order.statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            order.status,
                                            style: TextStyle(
                                              color: order.statusColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 8),
                                          _deletingToken == order.token
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Color(0xFFEF4444),
                                                  ),
                                                )
                                              : IconButton(
                                                  onPressed: () => _confirmAndDelete(order),
                                                  icon: const Icon(Icons.delete_outline),
                                                  tooltip: 'Delete order',
                                                  color: const Color(0xFFEF4444),
                                                  visualDensity: VisualDensity.compact,
                                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                                  padding: EdgeInsets.zero,
                                                ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow {
  const _OrderRow({
    required this.token,
    required this.companyName,
    required this.poNumber,
    required this.status,
    required this.statusColor,
    this.buttonImage,
    this.poImage,
  });

  final String token;
  final String companyName;
  final String poNumber;
  final String status;
  final Color statusColor;
  final String? buttonImage;
  final String? poImage;
}

