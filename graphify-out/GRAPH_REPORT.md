# Graph Report - btn-factory  (2026-10-27)

## Corpus Check
- 135 files · ~65,623 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1101 nodes · 2093 edges · 68 communities (43 shown, 5 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 187 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9121eea6`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- User
- Win32Window
- custom_http_exception_handler
- BackupService
- secure_storage.dart
- GeneratedPluginRegistrant.swift
- app_image_preview.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- app_router.dart
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- ConsumerState
- _ActionCard
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- login_page.dart
- authControllerProvider
- wWinMain
- pdf_export_service.dart
- manifest.json
- dashboard_page.dart
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
- OrderService
- main.py
- package:flutter/material.dart
- routes/auth.py
- routes/analytics.py
- orders.py
- analytics_page.dart
- models/user.py
- departments.py
- auth_controller.dart
- schemas/__init__.py

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 69 edges
2. `Base` - 43 edges
3. `User` - 41 edges
4. `Order` - 38 edges
5. `dioProvider` - 28 edges
6. `OrderRepository` - 27 edges
7. `ReportService` - 25 edges
8. `Win32Window` - 24 edges
9. `OrderStatus` - 19 edges
10. `OrderCreate` - 19 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `delete_user()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/auth.py → btn_factory/lib/core/storage/secure_storage.dart
- `delete_universal_raw_material()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/departments.py → btn_factory/lib/core/storage/secure_storage.dart
- `delete_order()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/orders.py → btn_factory/lib/core/storage/secure_storage.dart
- `Storage & Database Persistence` --conceptually_related_to--> `Docker Volume backend_data`  [INFERRED]
  DEPLOYMENT_GUIDE.md → docker-compose.yml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (68 total, 5 thin omitted)

### Community 0 - "User"
Cohesion: 0.15
Nodes (11): create_access_token(), create_refresh_token(), verify_password(), User, BaseRepository, Session, Session, UserRepository (+3 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "custom_http_exception_handler"
Cohesion: 0.28
Nodes (9): custom_http_exception_handler(), Request, trace_and_timing_middleware(), unhandled_exception_handler(), Exception, exception_handler, JSONResponse, middleware (+1 more)

### Community 3 - "BackupService"
Cohesion: 0.06
Nodes (37): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Keep only the latest N snapshot files., Sync schema and data from local database to a PostgreSQL target (Local Postgres… (+29 more)

### Community 4 - "secure_storage.dart"
Cohesion: 0.08
Nodes (26): accessToken, AppConstants, appName, AppStorageKeys, refreshToken, userDepartment, userEmail, userName (+18 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (31): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+23 more)

### Community 6 - "app_image_preview.dart"
Cohesion: 0.06
Nodes (33): BorderRadius?, BoxFit, borderRadius, build, _buildFallbackGraphic, _buildImageWidget, _bytes, _cache (+25 more)

### Community 7 - "department_update_page.dart"
Cohesion: 0.04
Nodes (47): build, _buildRawMaterialRow, _buildUniversalMaterialSummary, color, createState, currentStatusLabel, defaultUnit, description (+39 more)

### Community 8 - "order_form_page.dart"
Cohesion: 0.05
Nodes (42): _boxTypeController, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+34 more)

### Community 9 - "my_application.cc"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "staff_page.dart"
Cohesion: 0.06
Nodes (40): dioProvider, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails (+32 more)

### Community 11 - "app_router.dart"
Cohesion: 0.06
Nodes (32): appRouterProvider, authState, authStateVal, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets (+24 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.10
Nodes (20): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+12 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.10
Nodes (20): buttonImage, companyName, createState, _deletingToken, dispose, _error, initState, _isLoading (+12 more)

### Community 16 - "ConsumerState"
Cohesion: 0.23
Nodes (12): LoginPage, _LoginPageState, SplashPage, _SplashPageState, DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState (+4 more)

### Community 17 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 18 - "reports_page.dart"
Cohesion: 0.06
Nodes (40): _SnapshotChip, _DetailChip, build, color, createState, department, details, dispose (+32 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.07
Nodes (31): AsyncValue, _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, createState (+23 more)

### Community 23 - "login_page.dart"
Cohesion: 0.17
Nodes (11): createState, dispose, _emailController, _formKey, _passwordController, _submit, _submitting, FormState (+3 more)

### Community 24 - "authControllerProvider"
Cohesion: 0.10
Nodes (25): authControllerProvider, build, build, ProfilePage, build, build, _buildActionCards, build (+17 more)

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

### Community 59 - "OrderService"
Cohesion: 0.06
Nodes (77): Base, BlankingProcess, CastingProcess, Order, OrderStatus, PackingProcess, PolishingProcess, str (+69 more)

### Community 62 - "main.py"
Cohesion: 0.18
Nodes (6): health_check(), on_startup(), get, Helper to launch backup in a separate thread so it never blocks startup., run_background_backup(), on_event

### Community 63 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (16): AppTheme, light, build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title (+8 more)

### Community 64 - "routes/auth.py"
Cohesion: 0.27
Nodes (17): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+9 more)

### Community 65 - "routes/analytics.py"
Cohesion: 0.33
Nodes (8): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database.

### Community 66 - "orders.py"
Cohesion: 0.30
Nodes (14): create_order(), delete_order(), dispatch_order(), get_next_token(), get_order(), list_orders(), get, post (+6 more)

### Community 67 - "analytics_page.dart"
Cohesion: 0.12
Nodes (17): AnalyticsPage, _AnalyticsPageState, build, _buildKpiGrid, _buildOrdersTrendChart, _buildProductionStatusChart, _buildStatCard, createState (+9 more)

### Community 68 - "models/user.py"
Cohesion: 0.39
Nodes (6): get_password_hash(), str, UserRole, main(), run_seed(), Enum

### Community 69 - "departments.py"
Cohesion: 0.21
Nodes (19): add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting() (+11 more)

### Community 70 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 73 - "schemas/__init__.py"
Cohesion: 0.62
Nodes (5): BaseModel, UserBase, UserCreate, UserRead, UserUpdate

## Knowledge Gaps
- **340 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+335 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 542 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `routes/auth.py`, `routes/analytics.py`, `orders.py`, `models/user.py`, `departments.py`, `OrderService`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Why does `Base` connect `OrderService` to `User`, `BackupService`, `models/user.py`, `get_settings`, `main.py`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Why does `get_settings()` connect `get_settings` to `User`, `BackupService`, `InMemoryFallbackCache`, `OrderService`, `main.py`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Are the 34 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 34 INFERRED edges - model-reasoned connections that need verification._
- **Are the 14 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._