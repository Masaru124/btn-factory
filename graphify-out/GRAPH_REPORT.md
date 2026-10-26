# Graph Report - btn-factory  (2026-10-26)

## Corpus Check
- 135 files · ~64,262 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1097 nodes · 2079 edges · 75 communities (50 shown, 5 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 185 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `92395bba`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- User
- Win32Window
- order_service.py
- BackupService
- secure_storage.dart
- GeneratedPluginRegistrant.swift
- app_image_preview.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- app_router.dart
- Order
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
- get_settings
- routes/reports.py
- schemas/order.py
- OrderService
- main.py
- package:flutter/material.dart
- routes/auth.py
- models/user.py
- orders.py
- analytics_page.dart
- Base
- departments.py
- auth_controller.dart
- UniversalRawMaterial
- package:btn_factory/shared/widgets/app_scaffold.dart
- schemas/__init__.py
- package:flutter_riverpod/flutter_riverpod.dart

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 69 edges
2. `Base` - 42 edges
3. `User` - 41 edges
4. `Order` - 37 edges
5. `OrderRepository` - 27 edges
6. `dioProvider` - 27 edges
7. `ReportService` - 25 edges
8. `Win32Window` - 24 edges
9. `OrderCreate` - 19 edges
10. `OrderStatus` - 18 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `delete_user()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/auth.py → btn_factory/lib/core/storage/secure_storage.dart
- `delete_universal_raw_material()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/departments.py → btn_factory/lib/core/storage/secure_storage.dart
- `Storage & Database Persistence` --conceptually_related_to--> `Docker Volume backend_data`  [INFERRED]
  DEPLOYMENT_GUIDE.md → docker-compose.yml
- `Button Factory MES Specifications` --conceptually_related_to--> `Button Factory MES Overview`  [INFERRED]
  btn_factory/plan-buttonFactoryMes.prompt.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (75 total, 5 thin omitted)

### Community 0 - "User"
Cohesion: 0.19
Nodes (10): create_access_token(), create_refresh_token(), get_password_hash(), verify_password(), User, Session, UserRepository, AuthService (+2 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "order_service.py"
Cohesion: 0.22
Nodes (17): BlankingProcess, CastingProcess, OrderStatus, PackingProcess, PolishingProcess, str, RawMaterial, TurningProcess (+9 more)

### Community 3 - "BackupService"
Cohesion: 0.06
Nodes (37): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Keep only the latest N snapshot files., Sync schema and data from local database to a PostgreSQL target (Local Postgres… (+29 more)

### Community 4 - "secure_storage.dart"
Cohesion: 0.08
Nodes (25): accessToken, AppConstants, appName, AppStorageKeys, refreshToken, userDepartment, userEmail, userName (+17 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (31): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+23 more)

### Community 6 - "app_image_preview.dart"
Cohesion: 0.06
Nodes (33): BorderRadius?, BoxFit, borderRadius, build, _buildFallbackGraphic, _buildImageWidget, _bytes, _cache (+25 more)

### Community 7 - "department_update_page.dart"
Cohesion: 0.04
Nodes (46): build, _buildRawMaterialRow, _buildUniversalMaterialSummary, color, createState, currentStatusLabel, defaultUnit, description (+38 more)

### Community 8 - "order_form_page.dart"
Cohesion: 0.05
Nodes (39): _boxTypeController, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+31 more)

### Community 9 - "my_application.cc"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "staff_page.dart"
Cohesion: 0.08
Nodes (25): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+17 more)

### Community 11 - "app_router.dart"
Cohesion: 0.06
Nodes (32): appRouterProvider, authState, authStateVal, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets (+24 more)

### Community 12 - "Order"
Cohesion: 0.11
Nodes (9): dashboard_stats(), Return real-time dashboard metrics computed from the database., Order, BaseRepository, Session, OrderRepository, Session, Return the lowest available numeric order token >= 1001. If an order is… (+1 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.10
Nodes (20): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+12 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.10
Nodes (19): buttonImage, companyName, _confirmAndDelete, createState, _deletingToken, dispose, _error, initState (+11 more)

### Community 16 - "ConsumerState"
Cohesion: 0.16
Nodes (18): SplashPage, _SplashPageState, AnalyticsPage, _AnalyticsPageState, DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState (+10 more)

### Community 17 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 18 - "reports_page.dart"
Cohesion: 0.06
Nodes (38): _SnapshotChip, _DetailChip, build, color, createState, department, details, dispose (+30 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.14
Nodes (13): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+5 more)

### Community 21 - "dioProvider"
Cohesion: 0.14
Nodes (14): dioProvider, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails (+6 more)

### Community 23 - "login_page.dart"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 24 - "authControllerProvider"
Cohesion: 0.09
Nodes (27): authControllerProvider, build, _submit, build, ProfilePage, build, build, _buildActionCards (+19 more)

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
Nodes (19): color, _completedOrders, createState, description, _error, _formatCurrency, icon, initState (+11 more)

### Community 30 - "profile_page.dart"
Cohesion: 0.15
Nodes (12): AsyncValue, _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, createState (+4 more)

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
Cohesion: 0.25
Nodes (7): dio, storage, dart:async, Dio, package:btn_factory/core/storage/secure_storage.dart, package:dio/dio.dart, return

### Community 55 - "get_settings"
Cohesion: 0.08
Nodes (28): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+20 more)

### Community 56 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 59 - "schemas/order.py"
Cohesion: 0.13
Nodes (32): CastingUpdateRequest, DepartmentTokenPayload, PackingUpdateRequest, PolishUpdateRequest, BaseModel, RawMaterialUpdateRequest, TurningUpdateRequest, BlankingRead (+24 more)

### Community 61 - "OrderService"
Cohesion: 0.20
Nodes (14): CastingUpdate, OrderUpdate, OrderService, _order_payload(), Deleting an order with process rows must not leave orphans behind., setup_test_db(), test_delete_is_atomic_when_child_rows_exist(), test_delete_only_removes_target_order() (+6 more)

### Community 62 - "main.py"
Cohesion: 0.12
Nodes (15): custom_http_exception_handler(), health_check(), on_startup(), get, Request, trace_and_timing_middleware(), unhandled_exception_handler(), Helper to launch backup in a separate thread so it never blocks startup. (+7 more)

### Community 63 - "package:flutter/material.dart"
Cohesion: 0.18
Nodes (9): AppTheme, light, build, child, SectionCard, title, trailing, package:flutter/material.dart (+1 more)

### Community 64 - "routes/auth.py"
Cohesion: 0.27
Nodes (17): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+9 more)

### Community 65 - "models/user.py"
Cohesion: 0.15
Nodes (15): orders_trend(), production_trend(), get, Session, Monthly order counts from the database., Per-status breakdown from the database., get_db(), Session (+7 more)

### Community 66 - "orders.py"
Cohesion: 0.27
Nodes (15): create_order(), delete_order(), dispatch_order(), get_next_token(), get_order(), list_orders(), get, post (+7 more)

### Community 67 - "analytics_page.dart"
Cohesion: 0.12
Nodes (15): build, _buildKpiGrid, _buildOrdersTrendChart, _buildProductionStatusChart, _buildStatCard, createState, _dashboardStats, _errorMessage (+7 more)

### Community 68 - "Base"
Cohesion: 0.18
Nodes (6): Base, Persistent monotonic order-token sequence (1001, 1002, ...). Stored in the…, TokenCounter, main(), run_seed(), DeclarativeBase

### Community 69 - "departments.py"
Cohesion: 0.36
Nodes (13): add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting() (+5 more)

### Community 70 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 71 - "UniversalRawMaterial"
Cohesion: 0.39
Nodes (4): UniversalRawMaterial, UniversalRawMaterialCreate, setup_test_db(), test_upsert_and_delete_universal_raw_material()

### Community 72 - "package:btn_factory/shared/widgets/app_scaffold.dart"
Cohesion: 0.25
Nodes (7): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, package:btn_factory/shared/widgets/app_scaffold.dart

### Community 73 - "schemas/__init__.py"
Cohesion: 0.62
Nodes (5): BaseModel, UserBase, UserCreate, UserRead, UserUpdate

### Community 74 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.33
Nodes (5): main, read, package:btn_factory/main.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart

## Knowledge Gaps
- **338 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+333 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 540 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `routes/auth.py`, `models/user.py`, `orders.py`, `order_service.py`, `Base`, `departments.py`, `Order`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Why does `Base` connect `Base` to `User`, `models/user.py`, `order_service.py`, `BackupService`, `UniversalRawMaterial`, `Order`, `get_settings`, `schemas/order.py`, `OrderService`, `main.py`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Why does `get_settings()` connect `get_settings` to `User`, `BackupService`, `Base`, `InMemoryFallbackCache`, `main.py`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Are the 34 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 34 INFERRED edges - model-reasoned connections that need verification._
- **Are the 13 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 13 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._