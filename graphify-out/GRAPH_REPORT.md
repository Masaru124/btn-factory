# Graph Report - btn-factory  (2026-10-14)

## Corpus Check
- 122 files · ~54,518 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1020 nodes · 1945 edges · 58 communities (43 shown, 5 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 177 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1e186223`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- routes/auth.py
- Win32Window
- OrderService
- setup_local_postgres.py
- app_router.dart
- GeneratedPluginRegistrant.swift
- app_image_preview.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- secure_storage.dart
- main.py
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- ConsumerState
- profile_page.dart
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- dioProvider
- StatelessWidget
- login_page.dart
- authControllerProvider
- wWinMain
- pdf_export_service.dart
- manifest.json
- dashboard_page.dart
- _ActionCard
- package:flutter/material.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- web/vercel.json
- vercel.json
- rules/graphify.md
- workflows/graphify.md
- README.md
- User
- HTTPException
- metric_card.dart
- section_card.dart
- get_settings
- routes/reports.py
- models/user.py
- schemas/__init__.py
- package:flutter_riverpod/flutter_riverpod.dart

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 67 edges
2. `User` - 41 edges
3. `Base` - 36 edges
4. `Order` - 35 edges
5. `OrderRepository` - 27 edges
6. `dioProvider` - 26 edges
7. `Win32Window` - 24 edges
8. `authControllerProvider` - 18 edges
9. `OrderCreate` - 17 edges
10. `ReportService` - 17 edges

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

## Communities (58 total, 5 thin omitted)

### Community 0 - "routes/auth.py"
Cohesion: 0.27
Nodes (17): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+9 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "OrderService"
Cohesion: 0.05
Nodes (87): add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting() (+79 more)

### Community 3 - "setup_local_postgres.py"
Cohesion: 0.07
Nodes (30): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, set_sqlite_pragma(), Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Sync schema and data from local database to a PostgreSQL target (Local Postgres… (+22 more)

### Community 4 - "app_router.dart"
Cohesion: 0.13
Nodes (14): authState, authStateVal, GoRouter, package:btn_factory/features/auth/presentation/login_page.dart, package:btn_factory/features/auth/presentation/profile_page.dart, package:btn_factory/features/auth/presentation/splash_page.dart, package:btn_factory/features/dashboard/presentation/dashboard_page.dart, package:btn_factory/features/departments/presentation/department_update_page.dart (+6 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (30): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+22 more)

### Community 6 - "app_image_preview.dart"
Cohesion: 0.06
Nodes (30): BorderRadius?, BoxFit, borderRadius, build, _buildFallbackGraphic, _buildImageWidget, _bytes, _cache (+22 more)

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
Cohesion: 0.09
Nodes (23): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+15 more)

### Community 11 - "secure_storage.dart"
Cohesion: 0.06
Nodes (33): appRouterProvider, delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter (+25 more)

### Community 12 - "main.py"
Cohesion: 0.12
Nodes (15): custom_http_exception_handler(), health_check(), on_startup(), get, Request, trace_and_timing_middleware(), unhandled_exception_handler(), Helper to launch backup in a separate thread so it never blocks startup. (+7 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.15
Nodes (12): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+4 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.10
Nodes (21): buttonImage, companyName, _confirmAndDelete, createState, _deletingToken, dispose, _error, initState (+13 more)

### Community 16 - "ConsumerState"
Cohesion: 0.17
Nodes (16): LoginPage, _LoginPageState, SplashPage, _SplashPageState, DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState (+8 more)

### Community 17 - "profile_page.dart"
Cohesion: 0.15
Nodes (12): AsyncValue, _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, createState (+4 more)

### Community 18 - "reports_page.dart"
Cohesion: 0.12
Nodes (17): build, createState, _error, _fetchReport, _formatCount, _formatCurrency, initState, _isLoading (+9 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.06
Nodes (32): AsyncNotifier, bool get, dio, storage, secureStorageProvider, AuthController, build, _extractMessage (+24 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.14
Nodes (13): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+5 more)

### Community 21 - "dioProvider"
Cohesion: 0.14
Nodes (14): dioProvider, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails (+6 more)

### Community 22 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): _SnapshotChip, _DetailChip, _ReportSummary, _SummaryTile, WidgetBorderStatus, AppImagePreview, AppImagePreviewCard, AppImageUploadCard (+1 more)

### Community 23 - "login_page.dart"
Cohesion: 0.20
Nodes (9): createState, dispose, _emailController, _formKey, _passwordController, _submitting, FormState, GlobalKey (+1 more)

### Community 24 - "authControllerProvider"
Cohesion: 0.09
Nodes (27): authControllerProvider, build, _submit, build, ProfilePage, build, build, _buildActionCards (+19 more)

### Community 25 - "wWinMain"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 26 - "pdf_export_service.dart"
Cohesion: 0.18
Nodes (10): _buildBlankingTable, _buildCastingTable, _buildSectionHeader, exportOrderPdf, exportReportPdf, PdfExportService, package:intl/intl.dart, package:pdf/pdf.dart (+2 more)

### Community 27 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "dashboard_page.dart"
Cohesion: 0.10
Nodes (19): color, _completedOrders, createState, description, _error, _formatCurrency, icon, initState (+11 more)

### Community 29 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 30 - "package:flutter/material.dart"
Cohesion: 0.17
Nodes (10): AppTheme, light, build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title (+2 more)

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "web/vercel.json"
Cohesion: 0.50
Nodes (3): headers, rewrites, $schema

### Community 43 - "vercel.json"
Cohesion: 0.50
Nodes (3): headers, rewrites, $schema

### Community 49 - "User"
Cohesion: 0.15
Nodes (12): create_access_token(), create_refresh_token(), get_password_hash(), verify_password(), User, BaseRepository, Session, Session (+4 more)

### Community 50 - "HTTPException"
Cohesion: 0.30
Nodes (15): create_order(), delete_order(), dispatch_order(), get_next_token(), get_order(), list_orders(), get, post (+7 more)

### Community 51 - "metric_card.dart"
Cohesion: 0.22
Nodes (8): build, icon, MetricCard, tint, title, value, Color, IconData

### Community 52 - "section_card.dart"
Cohesion: 0.29
Nodes (6): build, child, SectionCard, title, trailing, Widget

### Community 55 - "get_settings"
Cohesion: 0.06
Nodes (37): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+29 more)

### Community 56 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 57 - "models/user.py"
Cohesion: 0.14
Nodes (17): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+9 more)

### Community 58 - "schemas/__init__.py"
Cohesion: 0.62
Nodes (5): BaseModel, UserBase, UserCreate, UserRead, UserUpdate

### Community 60 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.33
Nodes (5): main, read, package:btn_factory/main.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart

## Knowledge Gaps
- **300 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+295 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 483 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `get_settings()` connect `get_settings` to `User`, `setup_local_postgres.py`, `main.py`, `InMemoryFallbackCache`?**
  _High betweenness centrality (0.063) - this node is a cross-community bridge._
- **Why does `Base` connect `OrderService` to `setup_local_postgres.py`, `main.py`, `User`, `get_settings`, `models/user.py`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **Why does `OrderService` connect `OrderService` to `HTTPException`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **Are the 34 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 34 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 10 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 10 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._