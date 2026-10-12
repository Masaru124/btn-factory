# Graph Report - button_factory  (2026-10-12)

## Corpus Check
- 113 files · ~49,211 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 61 file(s) not represented in the graph (top: (none) 11, .xcconfig 8, .xml 7)

## Summary
- 935 nodes · 1764 edges · 58 communities (42 shown, 16 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 155 edges (avg confidence: 0.94)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `849e8b6c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Base
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
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- authControllerProvider
- profile_page.dart
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- dioProvider
- splash_page.dart
- login_page.dart
- package:flutter/material.dart
- wWinMain
- pdf_export_service.dart
- manifest.json
- custom_http_exception_handler
- StatelessWidget
- feature_placeholder_page.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- metric_card.dart
- package:flutter_riverpod/flutter_riverpod.dart
- rules/graphify.md
- workflows/graphify.md
- README.md
- ReportService
- Order
- auth_controller.dart
- routes/analytics.py
- models/order.py
- OrderStatus
- router.py
- api_client.dart
- upload_media

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 64 edges
2. `User` - 41 edges
3. `Order` - 36 edges
4. `Base` - 30 edges
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

## Communities (58 total, 16 thin omitted)

### Community 0 - "Base"
Cohesion: 0.11
Nodes (15): get_settings(), Base, set_sqlite_pragma(), Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), health_check(), get, str (+7 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (59): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+51 more)

### Community 2 - "OrderService"
Cohesion: 0.09
Nodes (57): add_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting(), update_packing() (+49 more)

### Community 3 - "User"
Cohesion: 0.06
Nodes (54): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+46 more)

### Community 4 - "app_router.dart"
Cohesion: 0.06
Nodes (32): appRouterProvider, authState, authStateVal, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets (+24 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (29): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+21 more)

### Community 6 - "dashboard_page.dart"
Cohesion: 0.06
Nodes (36): _ActionCard, _ActionCardState, _buildActionCards, color, _completedOrders, createState, description, _error (+28 more)

### Community 7 - "department_update_page.dart"
Cohesion: 0.05
Nodes (38): build, _buildRawMaterialRow, _buildUniversalMaterialSummary, color, createState, currentStatusLabel, description, dispose (+30 more)

### Community 8 - "order_form_page.dart"
Cohesion: 0.05
Nodes (37): _boxTypeController, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+29 more)

### Community 9 - "my_application.cc"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "staff_page.dart"
Cohesion: 0.09
Nodes (23): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+15 more)

### Community 11 - "secure_storage.dart"
Cohesion: 0.15
Nodes (15): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+7 more)

### Community 12 - "app_image_preview.dart"
Cohesion: 0.05
Nodes (35): Settings, FastAPI Python Dependencies, BaseSettings, BorderRadius?, BoxFit, accessToken, AppConstants, appName (+27 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.15
Nodes (12): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+4 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.11
Nodes (18): buttonImage, companyName, createState, _deletingToken, dispose, _error, initState, _isLoading (+10 more)

### Community 16 - "authControllerProvider"
Cohesion: 0.12
Nodes (25): authControllerProvider, build, _submit, SplashPage, _SplashPageState, build, DashboardPage, _DashboardPageState (+17 more)

### Community 17 - "profile_page.dart"
Cohesion: 0.18
Nodes (10): _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, ProfilePage, value, AppScaffold (+2 more)

### Community 18 - "reports_page.dart"
Cohesion: 0.12
Nodes (15): build, createState, _error, _fetchReport, _formatCount, _formatCurrency, initState, _isLoading (+7 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.14
Nodes (13): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+5 more)

### Community 21 - "dioProvider"
Cohesion: 0.14
Nodes (14): dioProvider, _fetchDashboard, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails, _pickImage (+6 more)

### Community 22 - "splash_page.dart"
Cohesion: 0.22
Nodes (8): AsyncValue, build, build, createState, _navigated, Color, package:go_router/go_router.dart, Route /login

### Community 23 - "login_page.dart"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 24 - "package:flutter/material.dart"
Cohesion: 0.18
Nodes (9): AppTheme, light, build, child, SectionCard, title, trailing, package:flutter/material.dart (+1 more)

### Community 25 - "wWinMain"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 26 - "pdf_export_service.dart"
Cohesion: 0.18
Nodes (10): _buildBlankingTable, _buildCastingTable, _buildSectionHeader, exportOrderPdf, exportReportPdf, PdfExportService, package:intl/intl.dart, package:pdf/pdf.dart (+2 more)

### Community 27 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "custom_http_exception_handler"
Cohesion: 0.24
Nodes (10): custom_http_exception_handler(), Request, trace_and_timing_middleware(), unhandled_exception_handler(), Exception, exception_handler, HTTPException, JSONResponse (+2 more)

### Community 29 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): _SnapshotChip, _DetailChip, _ReportSummary, _SummaryTile, WidgetBorderStatus, AppImagePreview, AppImagePreviewCard, AppImageUploadCard (+1 more)

### Community 30 - "feature_placeholder_page.dart"
Cohesion: 0.25
Nodes (7): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, package:btn_factory/shared/widgets/app_scaffold.dart

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "metric_card.dart"
Cohesion: 0.25
Nodes (7): build, icon, MetricCard, tint, title, value, IconData

### Community 43 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.29
Nodes (6): main, read, package:btn_factory/core/storage/secure_storage.dart, package:btn_factory/main.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart

### Community 49 - "ReportService"
Cohesion: 0.16
Nodes (14): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+6 more)

### Community 50 - "Order"
Cohesion: 0.17
Nodes (5): BlankingProcess, Order, OrderRepository, Session, Return the lowest available numeric order token >= 1001. If an order is…

### Community 51 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 52 - "routes/analytics.py"
Cohesion: 0.25
Nodes (10): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+2 more)

### Community 53 - "models/order.py"
Cohesion: 0.47
Nodes (7): CastingProcess, PackingProcess, PolishingProcess, Persistent monotonic order-token sequence (1001, 1002, ...). Stored in the…, RawMaterial, TokenCounter, TurningProcess

### Community 54 - "OrderStatus"
Cohesion: 0.35
Nodes (7): OrderStatus, str, determine_order_status(), setup_test_db(), test_order_creation_with_sample_and_rod_casting(), make_order(), test_status_progression_matches_workflow()

### Community 56 - "api_client.dart"
Cohesion: 0.25
Nodes (7): dio, storage, dart:async, Dio, package:btn_factory/core/constants/app_constants.dart, package:btn_factory/features/auth/application/auth_controller.dart, return

### Community 57 - "upload_media"
Cohesion: 0.50
Nodes (4): post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), UploadFile

## Knowledge Gaps
- **284 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+279 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 446 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `get_settings()` connect `Base` to `User`, `app_image_preview.dart`, `InMemoryFallbackCache`, `router.py`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `Base`, `OrderService`, `routes/analytics.py`, `models/order.py`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Why does `dioProvider` connect `dioProvider` to `staff_page.dart`, `authControllerProvider`, `reports_page.dart`, `auth_controller.dart`, `order_details_page.dart`, `api_client.dart`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **Are the 33 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `get_universal_raw_materials()`) actually correct?**
  _`OrderService` has 33 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Are the 7 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 7 INFERRED edges - model-reasoned connections that need verification._