import 'package:btn_factory/core/network/api_client.dart';
import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isLoading = true;
  String? _error;

  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _processingOrders = 0;
  int _completedOrders = 0;
  double _revenue = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDashboard());
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/analytics/dashboard');
      final data = response.data as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _totalOrders = (data['total_orders'] as num?)?.toInt() ?? 0;
        _pendingOrders = (data['pending_orders'] as num?)?.toInt() ?? 0;
        _processingOrders = (data['processing_orders'] as num?)?.toInt() ?? 0;
        _completedOrders = (data['completed_orders'] as num?)?.toInt() ?? 0;
        _revenue = (data['revenue'] as num?)?.toDouble() ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load dashboard: $e';
      });
    }
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider).value;

    return AppScaffold(
      selectedIndex: 0,
      title: 'Dashboard Overview',
      child: RefreshIndicator(
        onRefresh: _fetchDashboard,
        color: const Color(0xFF14B8A6),
        backgroundColor: const Color(0xFF111827),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: <Widget>[
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authState?.userName ?? "User"}',
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Track every production order and manage department operations from this dashboard.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Loading and Error States
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6))),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _fetchDashboard,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Metrics Section
              LayoutBuilder(
                builder: (context, constraints) {
                  final isAdmin = authState?.userRole == 'super_admin';
                  final crossAxisCount = isAdmin
                      ? (constraints.maxWidth >= 1100
                          ? 5
                          : (constraints.maxWidth >= 700 ? 3 : 2))
                      : (constraints.maxWidth >= 900
                          ? 4
                          : (constraints.maxWidth >= 600 ? 2 : 1));

                  final double cellWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
                  final double childAspectRatio = cellWidth / 92.0;

                  return GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: childAspectRatio,
                    children: <Widget>[
                      MetricCard(
                        title: 'Total Orders',
                        value: '$_totalOrders',
                        icon: Icons.shopping_bag_outlined,
                        tint: const Color(0xFF14B8A6), // Teal
                      ),
                      MetricCard(
                        title: 'Pending Orders',
                        value: '$_pendingOrders',
                        icon: Icons.pending_actions_outlined,
                        tint: const Color(0xFFF59E0B), // Amber
                      ),
                      MetricCard(
                        title: 'In Progress',
                        value: '$_processingOrders',
                        icon: Icons.cached_outlined,
                        tint: const Color(0xFF3B82F6), // Blue
                      ),
                      MetricCard(
                        title: 'Completed',
                        value: '$_completedOrders',
                        icon: Icons.check_circle_outline,
                        tint: const Color(0xFF10B981), // Emerald
                      ),
                      if (isAdmin)
                        MetricCard(
                          title: 'Total Revenue',
                          value: _formatCurrency(_revenue),
                          icon: Icons.currency_rupee_outlined,
                          tint: const Color(0xFF8B5CF6), // Purple
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
              // Section Heading for Action Cards
              const Row(
                children: [
                  Icon(Icons.bolt, color: Color(0xFF14B8A6), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Quick Console',
                    style: TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Actions Section
              LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = constraints.maxWidth;
                  final int cols = cardWidth >= 900 ? 3 : (cardWidth >= 600 ? 2 : 1);

                  return GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: cols,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: cardWidth >= 600 ? 2.5 : 3.2,
                    children: _buildActionCards(context, authState?.userRole),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionCards(BuildContext context, String? role) {
    if (role == 'super_admin') {
      return [
        _ActionCard(
          title: 'New Order',
          description: 'Launch a button production order request',
          icon: Icons.add_shopping_cart,
          color: const Color(0xFF14B8A6),
          onTap: () => context.go('/orders/create'),
          isHighlight: true,
        ),
        _ActionCard(
          title: 'Active Orders',
          description: 'Track, view, and search ongoing production lines',
          icon: Icons.format_list_bulleted_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () => context.go('/orders'),
        ),
        _ActionCard(
          title: 'Manage Staff',
          description: 'Register operators and update department credentials',
          icon: Icons.people_outline,
          color: const Color(0xFF8B5CF6),
          onTap: () => context.go('/staff'),
        ),
        _ActionCard(
          title: 'Analytics Insights',
          description: 'Analyze rejection graphs and delivery lead times',
          icon: Icons.bar_chart_outlined,
          color: const Color(0xFFEC4899),
          onTap: () => context.go('/analytics'),
        ),
        _ActionCard(
          title: 'MES Reports',
          description: 'Download PDF summaries and daily production reports',
          icon: Icons.document_scanner_outlined,
          color: const Color(0xFF10B981),
          onTap: () => context.go('/reports'),
        ),
      ];
    } else {
      // Department-specific operator actions
      final List<Widget> list = [
        _ActionCard(
          title: 'Active Orders',
          description: 'Inspect assigned order status and tasks',
          icon: Icons.format_list_bulleted_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () => context.go('/orders'),
        ),
      ];

      if (role == 'raw_material') {
        list.add(_ActionCard(
          title: 'Update Raw Material',
          description: 'Register raw material details and submit data',
          icon: Icons.grain_outlined,
          color: const Color(0xFF0D9488),
          onTap: () => context.go('/raw-material'),
          isHighlight: true,
        ));
      } else if (role == 'casting') {
        list.add(_ActionCard(
          title: 'Update Casting',
          description: 'Submit weights, thicknesses, and start timings',
          icon: Icons.local_fire_department_outlined,
          color: const Color(0xFFF97316),
          onTap: () => context.go('/casting'),
          isHighlight: true,
        ));
      } else if (role == 'turning') {
        list.add(_ActionCard(
          title: 'Update Turning',
          description: 'Enter turned logs, hole sizes, and operator status',
          icon: Icons.precision_manufacturing_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () => context.go('/turning'),
          isHighlight: true,
        ));
      } else if (role == 'polish') {
        list.add(_ActionCard(
          title: 'Update Polishing',
          description: 'Capture feed times and polish chemical logs',
          icon: Icons.auto_fix_high_outlined,
          color: const Color(0xFFA855F7),
          onTap: () => context.go('/polish'),
          isHighlight: true,
        ));
      } else if (role == 'packing') {
        list.add(_ActionCard(
          title: 'Update Packing',
          description: 'Specify final packed counts and register rejections',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF10B981),
          onTap: () => context.go('/packing'),
          isHighlight: true,
        ));
      }
      return list;
    }
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isHighlight = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlight;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color borderClr = widget.isHighlight
        ? widget.color.withValues(alpha: 0.3)
        : const Color(0xFF1F2937);
    final Color bgClr = widget.isHighlight
        ? widget.color.withValues(alpha: 0.08)
        : const Color(0xFF111827);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.identity(),
        child: Card(
          color: bgClr,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _isHovered ? widget.color.withValues(alpha: 0.5) : borderClr, width: 1.5),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFFF8FAFC),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF334155),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

