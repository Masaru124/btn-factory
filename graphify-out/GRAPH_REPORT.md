# Graph Report - button_factory  (2026-10-14)

## Corpus Check
- 134 files · ~62,232 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 89 file(s) not represented in the graph (top: .db 23, (none) 10, .xcconfig 8)

## Summary
- 1081 nodes · 2052 edges · 62 communities (37 shown, 25 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 169 edges (avg confidence: 0.94)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3750b561`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- User
- Win32Window
- OrderService
- BackupService
- secure_storage.dart
- GeneratedPluginRegistrant.swift
- app_image_preview.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- app_router.dart
- _buildActionCards
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- ConsumerState
- _ActionCard
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- dioProvider
- login_page.dart
- authControllerProvider
- wWinMain
- pdf_export_service.dart
- manifest.json
- dashboard_page.dart
- profile_page.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- web/vercel.json
- vercel.json
- rules/graphify.md
- workflows/graphify.md
- README.md
- api_client.dart
- main.py
- routes/reports.py
- schemas/order.py
- section_card.dart

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 70 edges
2. `Base` - 42 edges
3. `User` - 41 edges
4. `Order` - 38 edges
5. `OrderRepository` - 27 edges
6. `ReportService` - 25 edges
7. `dioProvider` - 25 edges
8. `Win32Window` - 24 edges
9. `OrderCreate` - 20 edges
10. `OrderStatus` - 18 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `delete_user()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/auth.py → btn_factory/lib/core/storage/secure_storage.dart
- `delete_universal_raw_material()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/departments.py → btn_factory/lib/core/storage/secure_storage.dart
- `delete_order()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/orders.py → btn_factory/lib/core/storage/secure_storage.dart
- `Button Factory MES Specifications` --conceptually_related_to--> `Button Factory MES Overview`  [INFERRED]
  btn_factory/plan-buttonFactoryMes.prompt.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (62 total, 25 thin omitted)

### Community 0 - "User"
Cohesion: 0.07
Nodes (54): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+46 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (59): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+51 more)

### Community 2 - "OrderService"
Cohesion: 0.06
Nodes (62): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+54 more)

### Community 3 - "BackupService"
Cohesion: 0.06
Nodes (42): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), on_startup(), BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Keep only the latest N snapshot files. (+34 more)

### Community 4 - "secure_storage.dart"
Cohesion: 0.06
Nodes (31): Resolve the active database connection string based on ACTIVE_DB_TIER., Settings, FastAPI Python Dependencies, BaseSettings, accessToken, AppConstants, appName, AppStorageKeys (+23 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (30): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+22 more)

### Community 6 - "app_image_preview.dart"
Cohesion: 0.06
Nodes (33): BorderRadius?, BoxFit, borderRadius, build, _buildFallbackGraphic, _buildImageWidget, _bytes, _cache (+25 more)

### Community 7 - "department_update_page.dart"
Cohesion: 0.04
Nodes (44): build, _buildRawMaterialRow, _buildUniversalMaterialSummary, color, createState, currentStatusLabel, defaultUnit, description (+36 more)

### Community 8 - "order_form_page.dart"
Cohesion: 0.05
Nodes (38): _boxTypeController, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+30 more)

### Community 9 - "my_application.cc"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "staff_page.dart"
Cohesion: 0.08
Nodes (25): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+17 more)

### Community 11 - "app_router.dart"
Cohesion: 0.09
Nodes (23): appRouterProvider, authState, authStateVal, build, ButtonFactoryApp, main, Flutter App Manifest & Assets, GitHub Actions Release Workflow (+15 more)

### Community 12 - "_buildActionCards"
Cohesion: 0.20
Nodes (10): _buildActionCards, build, Route /analytics, Route /casting, Route /orders/create, Route /packing, Route /polish, Route /raw-material (+2 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.12
Nodes (15): ProfilePage, activeColor, AppScaffold, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon (+7 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.10
Nodes (19): buttonImage, companyName, createState, _deletingToken, dispose, _error, initState, _isLoading (+11 more)

### Community 16 - "ConsumerState"
Cohesion: 0.17
Nodes (16): LoginPage, _LoginPageState, SplashPage, _SplashPageState, DepartmentUpdatePage, _DepartmentUpdatePageState, OrderDetailsPage, _OrderDetailsPageState (+8 more)

### Community 17 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 18 - "reports_page.dart"
Cohesion: 0.06
Nodes (38): _SnapshotChip, _DetailChip, build, color, createState, department, details, dispose (+30 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.10
Nodes (20): AsyncNotifier, bool get, secureStorageProvider, AuthController, build, logout, accessToken, authenticated (+12 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.14
Nodes (13): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+5 more)

### Community 21 - "dioProvider"
Cohesion: 0.13
Nodes (15): dioProvider, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails (+7 more)

### Community 23 - "login_page.dart"
Cohesion: 0.08
Nodes (23): AsyncValue, AppTheme, light, createState, dispose, _emailController, _formKey, _passwordController (+15 more)

### Community 24 - "authControllerProvider"
Cohesion: 0.18
Nodes (14): authControllerProvider, build, _submit, build, build, build, build, build (+6 more)

### Community 25 - "wWinMain"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 26 - "pdf_export_service.dart"
Cohesion: 0.13
Nodes (14): _buildBlankingTable, _buildCastingTable, _buildSectionHeader, exportOrderPdf, exportRawMaterialsAndImagePdf, exportReportPdf, _fetchImageBytes, PdfExportService (+6 more)

### Community 27 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "dashboard_page.dart"
Cohesion: 0.10
Nodes (21): color, _completedOrders, createState, DashboardPage, _DashboardPageState, description, _error, _formatCurrency (+13 more)

### Community 30 - "profile_page.dart"
Cohesion: 0.12
Nodes (15): _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, build, FeaturePlaceholderPage (+7 more)

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "web/vercel.json"
Cohesion: 0.50
Nodes (3): headers, rewrites, $schema

### Community 43 - "vercel.json"
Cohesion: 0.50
Nodes (3): headers, rewrites, $schema

### Community 54 - "api_client.dart"
Cohesion: 0.11
Nodes (17): dio, storage, _extractMessage, login, main, read, dart:async, Dio (+9 more)

### Community 55 - "main.py"
Cohesion: 0.05
Nodes (45): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+37 more)

### Community 56 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 59 - "schemas/order.py"
Cohesion: 0.12
Nodes (40): add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting() (+32 more)

### Community 63 - "section_card.dart"
Cohesion: 0.29
Nodes (6): build, child, SectionCard, title, trailing, Widget

## Knowledge Gaps
- **322 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+317 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 528 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **25 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `OrderService`, `schemas/order.py`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **Why does `get_settings()` connect `main.py` to `User`, `OrderService`, `BackupService`, `secure_storage.dart`, `InMemoryFallbackCache`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Why does `Base` connect `OrderService` to `User`, `BackupService`, `main.py`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **Are the 34 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 34 INFERRED edges - model-reasoned connections that need verification._
- **Are the 13 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 13 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._