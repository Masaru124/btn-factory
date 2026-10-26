import 'package:btn_factory/core/network/api_client.dart';
import 'package:btn_factory/shared/widgets/app_scaffold.dart';
import 'package:btn_factory/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _dashboardStats;
  List<Map<String, dynamic>> _ordersTrend = [];
  List<Map<String, dynamic>> _productionTrend = [];

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioProvider);

      final results = await Future.wait([
        dio.get('/analytics/dashboard'),
        dio.get('/analytics/orders-trend'),
        dio.get('/analytics/production-trend'),
      ]);

      if (mounted) {
        setState(() {
          _dashboardStats = results[0].data as Map<String, dynamic>?;

          final trendData = results[1].data;
          if (trendData is Map && trendData['points'] is List) {
            _ordersTrend = List<Map<String, dynamic>>.from(
              (trendData['points'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            );
          }

          final prodData = results[2].data;
          if (prodData is Map && prodData['points'] is List) {
            _productionTrend = List<Map<String, dynamic>>.from(
              (prodData['points'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            );
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load analytics: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 8,
      title: 'Analytics & Insights',
      child: RefreshIndicator(
        onRefresh: _fetchAnalytics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with reload button
              Row(
                children: [
                  const Icon(Icons.insights, color: Color(0xFF14B8A6), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Factory Production Analytics',
                          style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Real-time order volume, departmental workflow & financial metrics',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _fetchAnalytics,
                    icon: const Icon(Icons.refresh, color: Color(0xFF14B8A6)),
                    tooltip: 'Refresh analytics',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: _fetchAnalytics,
                        child: const Text('RETRY', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                )
              else ...[
                // KPI Stat Cards
                _buildKpiGrid(),
                const SizedBox(height: 24),

                // Production Workflow Distribution
                SectionCard(
                  title: 'Production Status Breakdown',
                  child: _buildProductionStatusChart(),
                ),
                const SizedBox(height: 24),

                // Orders Trend by Month
                SectionCard(
                  title: 'Monthly Orders Trend',
                  child: _buildOrdersTrendChart(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid() {
    final stats = _dashboardStats ?? {};
    final total = stats['total_orders'] ?? 0;
    final pending = stats['pending_orders'] ?? 0;
    final processing = stats['processing_orders'] ?? 0;
    final completed = stats['completed_orders'] ?? 0;
    final revenue = (stats['revenue'] ?? 0).toDouble();
    final materialCost = (stats['material_cost'] ?? 0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 600
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard('Total Orders', '$total', Icons.assignment, const Color(0xFF3B82F6)),
            _buildStatCard('Pending Orders', '$pending', Icons.pending_actions, const Color(0xFFF59E0B)),
            _buildStatCard('In Production', '$processing', Icons.precision_manufacturing, const Color(0xFF14B8A6)),
            _buildStatCard('Completed Orders', '$completed', Icons.check_circle_outline, const Color(0xFF10B981)),
            _buildStatCard('Total Revenue', '₹${revenue.toStringAsFixed(2)}', Icons.payments_outlined, const Color(0xFF6366F1)),
            _buildStatCard('Material Cost', '₹${materialCost.toStringAsFixed(2)}', Icons.inventory_2_outlined, const Color(0xFFEC4899)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionStatusChart() {
    if (_productionTrend.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No order status data available yet.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    final maxVal = _productionTrend.fold<int>(1, (prev, elem) {
      final v = (elem['value'] is num) ? (elem['value'] as num).toInt() : 1;
      return v > prev ? v : prev;
    });

    return Column(
      children: _productionTrend.map((item) {
        final label = item['label']?.toString() ?? 'Unknown';
        final val = (item['value'] is num) ? (item['value'] as num).toInt() : 0;
        final ratio = (val / maxVal).clamp(0.05, 1.0);

        final Color barColor = _getColorForStatus(label);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  label,
                  style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 40,
                child: Text(
                  '$val',
                  style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrdersTrendChart() {
    if (_ordersTrend.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No monthly orders recorded yet.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    final maxVal = _ordersTrend.fold<int>(1, (prev, elem) {
      final v = (elem['value'] is num) ? (elem['value'] as num).toInt() : 1;
      return v > prev ? v : prev;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _ordersTrend.map((point) {
              final label = point['label']?.toString() ?? '';
              final val = (point['value'] is num) ? (point['value'] as num).toInt() : 0;
              final height = (val / maxVal * 120).clamp(12.0, 120.0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$val',
                    style: const TextStyle(color: Color(0xFF14B8A6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 28,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Created':
        return const Color(0xFF3B82F6);
      case 'Raw Material Updated':
        return const Color(0xFF0D9488);
      case 'Casting Completed':
        return const Color(0xFFF97316);
      case 'Blanking Completed':
        return const Color(0xFFEAB308);
      case 'Turning Completed':
        return const Color(0xFF3B82F6);
      case 'Polishing Completed':
        return const Color(0xFFA855F7);
      case 'Packing Completed':
        return const Color(0xFF10B981);
      case 'Ready To Dispatch':
        return const Color(0xFF14B8A6);
      case 'Dispatched':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF64748B);
    }
  }
}
