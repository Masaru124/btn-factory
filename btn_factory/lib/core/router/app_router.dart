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
import 'package:btn_factory/features/dashboard/presentation/analytics_page.dart';
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
        builder: (context, state) => DepartmentUpdatePage(
          title: 'Raw Material',
          selectedIndex: 2,
          description: 'Search an order, view universal raw materials, and submit raw material details for the order.',
          currentStatusLabel: 'Created',
          fieldLabels: const <String>['Material Name', 'Total Available Raw Material', 'Quantity for Order', 'Unit', 'Price'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/casting',
        builder: (context, state) => DepartmentUpdatePage(
          title: 'Casting',
          selectedIndex: 3,
          description: 'Update casting metrics: date of casting, total raw material, rods or sheets, and thickness.',
          currentStatusLabel: 'Raw Material Updated',
          fieldLabels: const <String>['Casting Type', 'Date of Casting', 'Total Raw Material (kg)', 'Number of Rods', 'Number of Sheets', 'Blank Thickness', 'Remarks'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/blanking',
        builder: (context, state) => DepartmentUpdatePage(
          title: 'Blanking',
          selectedIndex: 4,
          description: 'Record blank cutting output: weight in kgs, in Gross, rejection in kgs, and operator.',
          currentStatusLabel: 'Casting Completed',
          fieldLabels: const <String>['Weight in kgs', 'In Gross', 'Rejection in kgs', 'Operator', 'Blank Thickness', 'Remarks'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/turning',
        builder: (context, state) => DepartmentUpdatePage(
          title: 'Turning',
          selectedIndex: 5,
          description: 'Record turning tool number, inward weight, and outward weight.',
          currentStatusLabel: 'Casting Completed',
          fieldLabels: const <String>['Receiving Date', 'Date of Turning', 'Inwards Weight (kg)', 'Tool Number', 'Hole', 'M/C No.', 'Outward Weight (kg)', 'Gross (Approx)', 'Blank Thickness', 'Finish Thickness', 'Operator', 'Remarks'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/polish',
        builder: (context, state) => DepartmentUpdatePage(
          title: 'Polish',
          selectedIndex: 6,
          description: 'Capture polishing inward and outward weight, operator, and timings.',
          currentStatusLabel: 'Turning Completed',
          fieldLabels: const <String>['Receiving Date', 'Inward Weight (kg)', 'Outward Weight (kg)', 'In Gross', 'Finishing', 'In Time', 'Out Time', 'Operator', 'Remarks'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/packing',
        builder: (context, state) => DepartmentUpdatePage(
          title: 'Packing',
          selectedIndex: 7,
          description: 'Enter packed, rejected, short, and excess quantities before dispatch readiness.',
          currentStatusLabel: 'Polishing Completed',
          fieldLabels: const <String>['Receiving Date', 'Inward Weight (kg)', 'Outward Weight (kg)', 'One Gross Weight (kg)', 'In Gross', 'Finishing', 'Packed in Gross', 'Excess Qty', 'Short Qty', 'Rejection Qty', 'Reason for Rejection', 'Operator'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsPage(),
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