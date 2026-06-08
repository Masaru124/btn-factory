import 'package:btn_factory/features/auth/presentation/login_page.dart';
import 'package:btn_factory/features/auth/presentation/splash_page.dart';
import 'package:btn_factory/features/dashboard/presentation/dashboard_page.dart';
import 'package:btn_factory/features/departments/presentation/department_update_page.dart';
import 'package:btn_factory/features/orders/presentation/order_details_page.dart';
import 'package:btn_factory/features/orders/presentation/order_form_page.dart';
import 'package:btn_factory/features/orders/presentation/order_list_page.dart';
import 'package:btn_factory/features/reports/presentation/reports_page.dart';
import 'package:btn_factory/shared/widgets/feature_placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderListPage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'create',
            builder: (context, state) => const OrderFormPage(mode: OrderFormMode.create),
          ),
          GoRoute(
            path: ':token',
            builder: (context, state) => OrderDetailsPage(orderToken: state.pathParameters['token'] ?? 'BTN-UNKNOWN'),
            routes: <RouteBase>[
              GoRoute(
                path: 'edit',
                builder: (context, state) => const OrderFormPage(mode: OrderFormMode.edit),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/raw-material',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Raw Material',
          selectedIndex: 2,
          description: 'Search an order, record material usage, and submit raw material details.',
          currentStatusLabel: 'Created',
          fieldLabels: <String>['Material Name', 'Quantity', 'Unit', 'Price', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/casting',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Casting',
          selectedIndex: 3,
          description: 'Update casting metrics after the order reaches the casting line.',
          currentStatusLabel: 'Raw Material Updated',
          fieldLabels: <String>['Sheet Type', 'Weight', 'Thickness', 'Gross Quantity', 'Machine No', 'Start Time', 'End Time', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/turning',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Turning',
          selectedIndex: 4,
          description: 'Record turning machine data and finish dimensions.',
          currentStatusLabel: 'Casting Completed',
          fieldLabels: <String>['Machine No', 'Hole Size', 'Weight', 'Gross Quantity', 'Semi Finish Thickness', 'Finish Thickness', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/polish',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Polish',
          selectedIndex: 5,
          description: 'Capture polishing timings and output for the current order.',
          currentStatusLabel: 'Turning Completed',
          fieldLabels: <String>['Polish Type', 'Feeding Time', 'Out Time', 'Operator', 'Gross Quantity', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/packing',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Packing',
          selectedIndex: 6,
          description: 'Enter packed, rejected, short, and excess quantities before dispatch readiness.',
          currentStatusLabel: 'Polishing Completed',
          fieldLabels: <String>['Packed Qty', 'Rejected Qty', 'Short Qty', 'Excess Qty', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const FeaturePlaceholderPage(
          title: 'Analytics',
          subtitle: 'Orders trend, production trend, material consumption, and rejection analysis will be charted here.',
          icon: Icons.insights_outlined,
          selectedIndex: 7,
        ),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const FeaturePlaceholderPage(
          title: 'Manage Staff',
          subtitle: 'Create staff accounts, assign departments, and manage role-based access from this screen.',
          icon: Icons.group_outlined,
          selectedIndex: 0,
        ),
      ),
    ],
  );
});