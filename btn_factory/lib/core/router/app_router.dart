import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:btn_factory/features/auth/presentation/login_page.dart';
import 'package:btn_factory/features/auth/presentation/profile_page.dart';
import 'package:btn_factory/features/auth/presentation/splash_page.dart';
import 'package:btn_factory/features/dashboard/presentation/dashboard_page.dart';
import 'package:btn_factory/features/departments/presentation/department_update_page.dart';
import 'package:btn_factory/features/orders/presentation/order_details_page.dart';
import 'package:btn_factory/features/orders/presentation/order_form_page.dart';
import 'package:btn_factory/features/orders/presentation/order_list_page.dart';
import 'package:btn_factory/features/reports/presentation/reports_page.dart';
import 'package:btn_factory/features/staff/presentation/staff_page.dart';
import 'package:btn_factory/shared/widgets/feature_placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateVal = ref.watch(authControllerProvider);
  final authState = authStateVal.value;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState == null) {
        return null;
      }
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';

      if (!isAuthenticated) {
        if (!isLoggingIn) {
          return '/login';
        }
      } else {
        final role = authState.userRole;
        final isStaff = role != 'super_admin';
        final matchedLoc = state.matchedLocation;

        if (isStaff) {
          final isRestricted = matchedLoc == '/' ||
              matchedLoc == '/login' ||
              matchedLoc == '/dashboard' ||
              matchedLoc.startsWith('/orders') ||
              matchedLoc == '/reports' ||
              matchedLoc == '/analytics' ||
              matchedLoc == '/staff';
          if (isRestricted) {
            switch (role) {
              case 'raw_material':
                return '/raw-material';
              case 'casting':
                return '/casting';
              case 'turning':
                return '/turning';
              case 'polish':
                return '/polish';
              case 'packing':
                return '/packing';
              default:
                return '/profile';
            }
          }
        } else {
          if (isLoggingIn || isSplash) {
            return '/dashboard';
          }
        }
      }
      return null;
    },
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
                builder: (context, state) => OrderFormPage(
                  mode: OrderFormMode.edit,
                  orderToken: state.pathParameters['token'],
                ),
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
          description: 'Search an order, view universal raw materials, and submit raw material details for the order.',
          currentStatusLabel: 'Created',
          fieldLabels: <String>['Material Name', 'Total Available Raw Material', 'Quantity for Order', 'Unit', 'Price'],
        ),
      ),
      GoRoute(
        path: '/casting',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Casting',
          selectedIndex: 3,
          description: 'Update casting metrics including date, total weight, blank thickness, and sheets.',
          currentStatusLabel: 'Raw Material Updated',
          fieldLabels: <String>['Casting Type', 'Date of Casting', 'Total Weight (kg)', 'Blank Thickness', 'No. of Sheets', 'Gross Quantity', 'Machine No', 'Start Time', 'End Time', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/turning',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Turning',
          selectedIndex: 4,
          description: 'Record turning tool number, inward weight, and outward weight.',
          currentStatusLabel: 'Casting Completed',
          fieldLabels: <String>['Receiving Date', 'Date of Turning', 'Inwards Weight (kg)', 'Tool Number', 'Hole', 'M/C No.', 'Outward Weight (kg)', 'Gross (Approx)', 'Semi Finish Thickness', 'Finish Thickness', 'Operator', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/polish',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Polish',
          selectedIndex: 5,
          description: 'Capture polishing inward and outward weight, operator, and timings.',
          currentStatusLabel: 'Turning Completed',
          fieldLabels: <String>['Tool Number', 'Receiving Date', 'Inward Weight (kg)', 'Outward Weight (kg)', 'In Gross', 'Finishing', 'Time of Feeding', 'Out Time', 'Operator', 'Remarks'],
        ),
      ),
      GoRoute(
        path: '/packing',
        builder: (context, state) => const DepartmentUpdatePage(
          title: 'Packing',
          selectedIndex: 6,
          description: 'Enter packed, rejected, short, and excess quantities before dispatch readiness.',
          currentStatusLabel: 'Polishing Completed',
          fieldLabels: <String>['Receiving Date', 'Tool Number', 'Inward Weight (kg)', 'In Gross', 'Finishing', 'Packed in Gross', 'Excess Qty', 'Short Qty', 'Rejection Qty', 'Reason for Rejection', 'Operator'],
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
        builder: (context, state) => const StaffPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});