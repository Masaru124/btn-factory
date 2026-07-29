import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String route;
  final Color activeColor;

  const NavItem(this.icon, this.label, this.route, {this.activeColor = const Color(0xFF14B8A6)});
}

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.child,
  });

  final int selectedIndex;
  final String title;
  final Widget child;

  List<NavItem> _getNavItems(String role) {
    switch (role) {
      case 'super_admin':
        return const [
          NavItem(Icons.dashboard_outlined, 'Dashboard', '/dashboard', activeColor: Color(0xFF14B8A6)),
          NavItem(Icons.list_alt_outlined, 'Orders', '/orders', activeColor: Color(0xFF14B8A6)),
          NavItem(Icons.grain_outlined, 'Raw Material', '/raw-material', activeColor: Color(0xFF0D9488)),
          NavItem(Icons.local_fire_department_outlined, 'Casting', '/casting', activeColor: Color(0xFFF97316)),
          NavItem(Icons.precision_manufacturing_outlined, 'Turning', '/turning', activeColor: Color(0xFF3B82F6)),
          NavItem(Icons.auto_fix_high_outlined, 'Polishing', '/polish', activeColor: Color(0xFFA855F7)),
          NavItem(Icons.inventory_2_outlined, 'Packing', '/packing', activeColor: Color(0xFF10B981)),
          NavItem(Icons.assessment_outlined, 'Reports', '/reports', activeColor: Color(0xFF6366F1)),
          NavItem(Icons.group_outlined, 'Staff', '/staff', activeColor: Color(0xFF6366F1)),
        ];
      case 'raw_material':
        return const [NavItem(Icons.grain_outlined, 'Raw Material', '/raw-material')];
      case 'casting':
        return const [NavItem(Icons.local_fire_department_outlined, 'Casting', '/casting')];
      case 'turning':
        return const [NavItem(Icons.precision_manufacturing_outlined, 'Turning', '/turning')];
      case 'polish':
        return const [NavItem(Icons.auto_fix_high_outlined, 'Polishing', '/polish')];
      case 'packing':
        return const [NavItem(Icons.inventory_2_outlined, 'Packing', '/packing')];
      default:
        return const [
          NavItem(Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
          NavItem(Icons.list_alt_outlined, 'Orders', '/orders'),
        ];
    }
  }

  String _getRouteForStaticIndex(int index) {
    switch (index) {
      case 0:
        return '/dashboard';
      case 1:
        return '/orders';
      case 2:
        return '/raw-material';
      case 3:
        return '/casting';
      case 4:
        return '/turning';
      case 5:
        return '/polish';
      case 6:
        return '/packing';
      case 7:
        return '/reports';
      case 8:
        return '/staff';
      case 176:
        return '/profile';
      default:
        return '/dashboard';
    }
  }

  void _showDepartmentsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Departments',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFF8FAFC),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _buildDepartmentTile(context, Icons.grain_outlined, 'Raw Material', '/raw-material', const Color(0xFF0D9488)),
                _buildDepartmentTile(context, Icons.local_fire_department_outlined, 'Casting', '/casting', const Color(0xFFF97316)),
                _buildDepartmentTile(context, Icons.precision_manufacturing_outlined, 'Turning', '/turning', const Color(0xFF3B82F6)),
                _buildDepartmentTile(context, Icons.auto_fix_high_outlined, 'Polishing', '/polish', const Color(0xFFA855F7)),
                _buildDepartmentTile(context, Icons.inventory_2_outlined, 'Packing', '/packing', const Color(0xFF10B981)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartmentTile(BuildContext context, IconData icon, String label, String route, Color color) {
    return Card(
      color: const Color(0xFF1F2937),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF374151), width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider).value;
    final userRole = authState?.userRole ?? 'super_admin';
    final navItems = _getNavItems(userRole);

    final currentRoute = _getRouteForStaticIndex(selectedIndex);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    if (isDesktop) {
      // DESKTOP LAYOUT (WITH SIDEBAR)
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Navigation
            Container(
              width: 280,
              color: const Color(0xFF0F172A),
              child: Column(
                children: [
                  // Sidebar Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.precision_manufacturing_outlined,
                            color: Color(0xFF14B8A6),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Button Factory',
                                style: TextStyle(
                                  color: Color(0xFFF8FAFC),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'MES PLATFORM',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const SizedBox(height: 16),
                  // Sidebar Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: navItems.length,
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = item.route == currentRoute;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? item.activeColor.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              item.icon,
                              color: isSelected ? item.activeColor : const Color(0xFF94A3B8),
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onTap: () => context.go(item.route),
                          ),
                        );
                      },
                    ),
                  ),
                  // Sidebar Footer
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF1E293B),
                            child: const Icon(Icons.person_outline, color: Color(0xFFF8FAFC)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState?.userName ?? 'Unknown User',
                                style: const TextStyle(
                                  color: Color(0xFFF8FAFC),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                userRole.toUpperCase().replaceAll('_', ' '),
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                          tooltip: 'Sign Out',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sign out?'),
                                content: const Text('Are you sure you want to sign out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Sign out'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref.read(authControllerProvider.notifier).logout();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Area
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title),
                ),
                body: SafeArea(child: child),
              ),
            ),
          ],
        ),
      );
    } else {
      // MOBILE LAYOUT (WITH BOTTOM NAV BAR)
      // Limit to 5 tabs: Dashboard, Orders, Departments (trigger Sheet), Reports, Profile
      final bool hasMultipleTabs = navItems.length > 1;
      
      int activeBottomIndex = 0;
      if (selectedIndex == 0) {
        activeBottomIndex = 0; // Dashboard
      } else if (selectedIndex == 1) {
        activeBottomIndex = 1; // Orders
      } else if (selectedIndex >= 2 && selectedIndex <= 6) {
        activeBottomIndex = 2; // Departments page (we will highlight the 'Departments' tab)
      } else if (selectedIndex == 7) {
        activeBottomIndex = 3; // Reports
      } else if (selectedIndex == 176) {
        activeBottomIndex = 4; // Profile
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            if (!hasMultipleTabs)
              IconButton(
                icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
          ],
        ),
        body: SafeArea(child: child),
        bottomNavigationBar: hasMultipleTabs
            ? NavigationBar(
                selectedIndex: activeBottomIndex,
                onDestinationSelected: (int index) {
                  if (index == 0) {
                    context.go('/dashboard');
                  } else if (index == 1) {
                    context.go('/orders');
                  } else if (index == 2) {
                    _showDepartmentsBottomSheet(context);
                  } else if (index == 3) {
                    context.go('/reports');
                  } else if (index == 4) {
                    context.go('/profile');
                  }
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.list_alt_outlined),
                    selectedIcon: Icon(Icons.list_alt),
                    label: 'Orders',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view),
                    label: 'Depts',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assessment_outlined),
                    selectedIcon: Icon(Icons.assessment),
                    label: 'Reports',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
            : null,
      );
    }
  }
}

