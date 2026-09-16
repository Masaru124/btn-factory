# Graph Report - btn-factory  (2026-09-16)

## Corpus Check
- 103 files · ~42,846 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 844 nodes · 1571 edges · 49 communities (34 shown, 7 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 138 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a6cad854`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- schemas/reports.py
- Win32Window
- OrderService
- User
- app_router.dart
- GeneratedPluginRegistrant.swift
- dashboard_page.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- secure_storage.dart
- app_image_preview.dart
- metric_card.dart
- profile_page.dart
- order_list_page.dart
- ConsumerState
- orders.py
- reports_page.dart
- package:flutter_riverpod/flutter_riverpod.dart
- order_details_page.dart
- app_scaffold.dart
- _buildActionCards
- dioProvider
- login_page.dart
- wWinMain
- authControllerProvider
- manifest.json
- pdf_export_service.dart
- StatelessWidget
- package:flutter/material.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- feature_placeholder_page.dart
- _ActionCard
- rules/graphify.md
- workflows/graphify.md
- README.md
- _submit
- build

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 49 edges
2. `User` - 39 edges
3. `Order` - 32 edges
4. `Win32Window` - 24 edges
5. `OrderRepository` - 23 edges
6. `Base` - 22 edges
7. `dioProvider` - 22 edges
8. `authControllerProvider` - 18 edges
9. `ReportService` - 17 edges
10. `RawMaterial` - 14 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `delete_user()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/auth.py → btn_factory/lib/core/storage/secure_storage.dart
- `delete_order()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/orders.py → btn_factory/lib/core/storage/secure_storage.dart
- `Storage & Database Persistence` --conceptually_related_to--> `Docker Volume backend_data`  [INFERRED]
  DEPLOYMENT_GUIDE.md → docker-compose.yml
- `Button Factory MES Specifications` --conceptually_related_to--> `Button Factory MES Overview`  [INFERRED]
  btn_factory/plan-buttonFactoryMes.prompt.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (49 total, 7 thin omitted)

### Community 0 - "schemas/reports.py"
Cohesion: 0.60
Nodes (4): DateRangeRequest, MetricValue, BaseModel, ReportSummary

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "OrderService"
Cohesion: 0.06
Nodes (68): add_raw_material(), get_universal_raw_materials(), get, post, Session, update_casting(), update_packing(), update_polish() (+60 more)

### Community 3 - "User"
Cohesion: 0.05
Nodes (58): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+50 more)

### Community 4 - "app_router.dart"
Cohesion: 0.04
Nodes (43): accessToken, AppConstants, appName, AppStorageKeys, refreshToken, userDepartment, userEmail, userName (+35 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (30): Any, AppDelegate, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+22 more)

### Community 6 - "dashboard_page.dart"
Cohesion: 0.11
Nodes (18): color, _completedOrders, createState, description, _error, _formatCurrency, icon, initState (+10 more)

### Community 7 - "department_update_page.dart"
Cohesion: 0.05
Nodes (38): build, _buildRawMaterialRow, _buildUniversalMaterialSummary, color, createState, currentStatusLabel, description, dispose (+30 more)

### Community 8 - "order_form_page.dart"
Cohesion: 0.06
Nodes (35): _boxType, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+27 more)

### Community 9 - "my_application.cc"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "staff_page.dart"
Cohesion: 0.09
Nodes (23): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+15 more)

### Community 11 - "secure_storage.dart"
Cohesion: 0.06
Nodes (36): AsyncNotifier, bool get, delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage (+28 more)

### Community 12 - "app_image_preview.dart"
Cohesion: 0.09
Nodes (21): BorderRadius?, BoxFit, borderRadius, build, _buildFallbackGraphic, _buildImageWidget, fit, height (+13 more)

### Community 13 - "metric_card.dart"
Cohesion: 0.25
Nodes (7): build, icon, MetricCard, tint, title, value, IconData

### Community 14 - "profile_page.dart"
Cohesion: 0.25
Nodes (7): _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, package:btn_factory/shared/widgets/section_card.dart

### Community 15 - "order_list_page.dart"
Cohesion: 0.12
Nodes (16): buttonImage, companyName, createState, dispose, _error, initState, _isLoading, _OrderRow (+8 more)

### Community 16 - "ConsumerState"
Cohesion: 0.16
Nodes (18): SplashPage, _SplashPageState, DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState, OrderDetailsPage, _OrderDetailsPageState (+10 more)

### Community 17 - "orders.py"
Cohesion: 0.22
Nodes (17): create_order(), delete_order(), dispatch_order(), get_order(), list_orders(), get, post, put (+9 more)

### Community 18 - "reports_page.dart"
Cohesion: 0.13
Nodes (14): build, createState, _error, _formatCount, _formatCurrency, initState, _isLoading, label (+6 more)

### Community 19 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.12
Nodes (17): dio, storage, _extractMessage, login, main, read, Dio, package:btn_factory/core/constants/app_constants.dart (+9 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.14
Nodes (13): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+5 more)

### Community 21 - "app_scaffold.dart"
Cohesion: 0.11
Nodes (17): AsyncValue, createState, _navigated, activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex (+9 more)

### Community 22 - "_buildActionCards"
Cohesion: 0.18
Nodes (12): _buildActionCards, build, Route /analytics, Route /casting, Route /orders, Route /packing, Route /polish, Route /profile (+4 more)

### Community 23 - "dioProvider"
Cohesion: 0.17
Nodes (12): dioProvider, _fetchDashboard, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchOrderDetails, _submit, _fetchOrders (+4 more)

### Community 24 - "login_page.dart"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 25 - "wWinMain"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 26 - "authControllerProvider"
Cohesion: 0.22
Nodes (11): authControllerProvider, build, build, ProfilePage, build, build, build, build (+3 more)

### Community 27 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "pdf_export_service.dart"
Cohesion: 0.22
Nodes (8): _buildSectionHeader, exportOrderPdf, exportReportPdf, PdfExportService, package:intl/intl.dart, package:pdf/pdf.dart, package:pdf/widgets.dart, package:printing/printing.dart

### Community 29 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): _SnapshotChip, _DetailChip, _ReportSummary, _SummaryTile, WidgetBorderStatus, AppImagePreview, AppImagePreviewCard, AppImageUploadCard (+1 more)

### Community 30 - "package:flutter/material.dart"
Cohesion: 0.18
Nodes (9): AppTheme, light, build, child, SectionCard, title, trailing, package:flutter/material.dart (+1 more)

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "feature_placeholder_page.dart"
Cohesion: 0.25
Nodes (7): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, package:btn_factory/shared/widgets/app_scaffold.dart

### Community 43 - "_ActionCard"
Cohesion: 0.50
Nodes (4): _ActionCard, _ActionCardState, State, StatefulWidget

## Knowledge Gaps
- **278 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+273 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 406 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `orders.py`, `OrderService`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Why does `AuthController` connect `secure_storage.dart` to `package:flutter_riverpod/flutter_riverpod.dart`, `dioProvider`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `dioProvider` connect `dioProvider` to `staff_page.dart`, `secure_storage.dart`, `ConsumerState`, `package:flutter_riverpod/flutter_riverpod.dart`, `order_details_page.dart`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Are the 29 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `get_universal_raw_materials()`) actually correct?**
  _`OrderService` has 29 INFERRED edges - model-reasoned connections that need verification._
- **Are the 21 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 21 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Are the 7 inferred relationships involving `OrderRepository` (e.g. with `CastingProcess` and `Order`) actually correct?**
  _`OrderRepository` has 7 INFERRED edges - model-reasoned connections that need verification._