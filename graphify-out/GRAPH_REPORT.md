# Graph Report - button_factory  (2026-10-14)

## Corpus Check
- 119 files · ~53,662 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 75 file(s) not represented in the graph (top: .db 11, (none) 10, .xcconfig 8)

## Summary
- 997 nodes · 1884 edges · 59 communities (40 shown, 19 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 158 edges (avg confidence: 0.94)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `32066660`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- schemas/order.py
- Win32Window
- OrderService
- BackupService
- app_router.dart
- GeneratedPluginRegistrant.swift
- dashboard_page.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- secure_storage.dart
- custom_http_exception_handler
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- ConsumerState
- profile_page.dart
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- dioProvider
- app_image_preview.dart
- login_page.dart
- _buildActionCards
- wWinMain
- pdf_export_service.dart
- manifest.json
- Order
- feature_placeholder_page.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- package:flutter/material.dart
- test_order_tokens_and_delete.py
- rules/graphify.md
- workflows/graphify.md
- README.md
- User
- .__init__
- .next_token
- .__init__
- OrderStatus
- .__init__
- get_settings
- routes/reports.py
- authControllerProvider
- routes/analytics.py
- package:flutter_riverpod/flutter_riverpod.dart

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 64 edges
2. `User` - 41 edges
3. `Order` - 36 edges
4. `Base` - 34 edges
5. `OrderRepository` - 27 edges
6. `dioProvider` - 25 edges
7. `Win32Window` - 24 edges
8. `OrderCreate` - 18 edges
9. `authControllerProvider` - 18 edges
10. `ReportService` - 17 edges

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

## Communities (59 total, 19 thin omitted)

### Community 0 - "schemas/order.py"
Cohesion: 0.21
Nodes (15): BlankingRead, CastingRead, OrderBase, OrderListItem, OrderStatusResponse, PackingRead, PolishingRead, BaseModel (+7 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (59): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+51 more)

### Community 2 - "OrderService"
Cohesion: 0.14
Nodes (27): add_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting(), update_packing() (+19 more)

### Community 3 - "BackupService"
Cohesion: 0.07
Nodes (31): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Sync schema and data from local database to a PostgreSQL target (Local Postgres…, Sync schema and data from local database to on-premises Local PostgreSQL. (+23 more)

### Community 4 - "app_router.dart"
Cohesion: 0.07
Nodes (26): appRouterProvider, authState, authStateVal, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets (+18 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (29): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+21 more)

### Community 6 - "dashboard_page.dart"
Cohesion: 0.09
Nodes (22): _ActionCard, _ActionCardState, color, _completedOrders, createState, description, _error, _formatCurrency (+14 more)

### Community 7 - "department_update_page.dart"
Cohesion: 0.05
Nodes (39): build, _buildRawMaterialRow, _buildUniversalMaterialSummary, color, createState, currentStatusLabel, description, dispose (+31 more)

### Community 8 - "order_form_page.dart"
Cohesion: 0.05
Nodes (37): _boxTypeController, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+29 more)

### Community 9 - "my_application.cc"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "staff_page.dart"
Cohesion: 0.08
Nodes (25): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+17 more)

### Community 11 - "secure_storage.dart"
Cohesion: 0.10
Nodes (21): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+13 more)

### Community 12 - "custom_http_exception_handler"
Cohesion: 0.24
Nodes (10): custom_http_exception_handler(), Request, trace_and_timing_middleware(), unhandled_exception_handler(), Exception, exception_handler, HTTPException, JSONResponse (+2 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.15
Nodes (12): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+4 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.11
Nodes (18): buttonImage, companyName, createState, _deletingToken, dispose, _error, initState, _isLoading (+10 more)

### Community 16 - "ConsumerState"
Cohesion: 0.17
Nodes (16): SplashPage, _SplashPageState, DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState, OrderDetailsPage, _OrderDetailsPageState (+8 more)

### Community 17 - "profile_page.dart"
Cohesion: 0.15
Nodes (12): AsyncValue, _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, createState (+4 more)

### Community 18 - "reports_page.dart"
Cohesion: 0.12
Nodes (15): build, createState, _error, _fetchReport, _formatCount, _formatCurrency, initState, _isLoading (+7 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.06
Nodes (32): AsyncNotifier, bool get, dio, storage, secureStorageProvider, AuthController, build, _extractMessage (+24 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.14
Nodes (13): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+5 more)

### Community 21 - "dioProvider"
Cohesion: 0.14
Nodes (14): dioProvider, _fetchDashboard, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails, _pickImage (+6 more)

### Community 22 - "app_image_preview.dart"
Cohesion: 0.06
Nodes (36): BorderRadius?, BoxFit, _SnapshotChip, _DetailChip, _ReportSummary, _SummaryTile, WidgetBorderStatus, AppImagePreview (+28 more)

### Community 23 - "login_page.dart"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 24 - "_buildActionCards"
Cohesion: 0.20
Nodes (10): _buildActionCards, build, Route /analytics, Route /casting, Route /orders/create, Route /packing, Route /polish, Route /raw-material (+2 more)

### Community 25 - "wWinMain"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 26 - "pdf_export_service.dart"
Cohesion: 0.18
Nodes (10): _buildBlankingTable, _buildCastingTable, _buildSectionHeader, exportOrderPdf, exportReportPdf, PdfExportService, package:intl/intl.dart, package:pdf/pdf.dart (+2 more)

### Community 27 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "Order"
Cohesion: 0.15
Nodes (16): Base, BlankingProcess, CastingProcess, Order, PackingProcess, PolishingProcess, Persistent monotonic order-token sequence (1001, 1002, ...). Stored in the…, RawMaterial (+8 more)

### Community 30 - "feature_placeholder_page.dart"
Cohesion: 0.22
Nodes (8): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, IconData, package:btn_factory/shared/widgets/app_scaffold.dart

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "package:flutter/material.dart"
Cohesion: 0.17
Nodes (10): AppTheme, light, build, icon, MetricCard, tint, title, value (+2 more)

### Community 43 - "test_order_tokens_and_delete.py"
Cohesion: 0.27
Nodes (14): CastingUpdate, OrderCreate, OrderUpdate, _order_payload(), Deleting an order with process rows must not leave orphans behind., setup_test_db(), test_delete_is_atomic_when_child_rows_exist(), test_delete_only_removes_target_order() (+6 more)

### Community 49 - "User"
Cohesion: 0.05
Nodes (61): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+53 more)

### Community 53 - "OrderStatus"
Cohesion: 0.47
Nodes (6): OrderStatus, str, determine_order_status(), recompute_order_status(), make_order(), test_status_progression_matches_workflow()

### Community 55 - "get_settings"
Cohesion: 0.06
Nodes (37): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+29 more)

### Community 56 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 57 - "authControllerProvider"
Cohesion: 0.15
Nodes (17): authControllerProvider, build, _submit, build, ProfilePage, build, build, build (+9 more)

### Community 59 - "routes/analytics.py"
Cohesion: 0.19
Nodes (12): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+4 more)

### Community 60 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.33
Nodes (5): main, read, package:btn_factory/main.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart

## Knowledge Gaps
- **285 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+280 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 472 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `get_settings()` connect `get_settings` to `BackupService`, `User`, `routes/analytics.py`, `InMemoryFallbackCache`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `OrderService`, `routes/analytics.py`, `Order`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Why does `Base` connect `Order` to `OrderService`, `BackupService`, `test_order_tokens_and_delete.py`, `User`, `get_settings`, `routes/analytics.py`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Are the 33 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `get_universal_raw_materials()`) actually correct?**
  _`OrderService` has 33 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 9 INFERRED edges - model-reasoned connections that need verification._