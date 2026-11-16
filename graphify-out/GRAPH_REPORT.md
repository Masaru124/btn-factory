# Graph Report - btn-factory  (2026-11-16)

## Corpus Check
- 142 files · ~71,175 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1187 nodes · 2230 edges · 76 communities (51 shown, 5 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 195 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8899fc27`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- User
- Win32Window
- Settings
- BackupService
- OrderService
- GeneratedPluginRegistrant.swift
- app_image_preview.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- app_router.dart
- dioProvider
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- secure_storage.dart
- _ActionCard
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- routes/analytics.py
- login_page.dart
- package:btn_factory/shared/widgets/app_scaffold.dart
- wWinMain
- pdf_export_service.dart
- manifest.json
- dashboard_page.dart
- routes/auth.py
- schemas/analytics.py
- MainActivity.kt
- String?
- web/vercel.json
- vercel.json
- rules/graphify.md
- workflows/graphify.md
- README.md
- api_client.dart
- orders.py
- get_settings
- app_constants.dart
- main.py
- departments.py
- setup_local_postgres.py
- models/user.py
- package:flutter_riverpod/flutter_riverpod.dart
- manage_startup.py
- analytics_page.dart
- routes/reports.py
- schemas/__init__.py
- auth_controller.dart
- setup_web_servers.py
- upload_media
- authControllerProvider
- custom_http_exception_handler
- Cloud Deployment Architecture

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 70 edges
2. `Base` - 47 edges
3. `User` - 43 edges
4. `Order` - 38 edges
5. `dioProvider` - 28 edges
6. `OrderRepository` - 27 edges
7. `ReportService` - 25 edges
8. `Win32Window` - 24 edges
9. `OrderStatus` - 21 edges
10. `get_settings()` - 19 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `Button Factory MES Specifications` --conceptually_related_to--> `Button Factory MES Overview`  [INFERRED]
  btn_factory/plan-buttonFactoryMes.prompt.md → README.md
- `Storage & Database Persistence` --conceptually_related_to--> `Docker Volume backend_data`  [INFERRED]
  DEPLOYMENT_GUIDE.md → docker-compose.yml
- `dashboard_stats()` --uses--> `Order`  [INFERRED]
  backend/app/api/routes/analytics.py → backend/app/models/order.py
- `dashboard_stats()` --uses--> `OrderStatus`  [INFERRED]
  backend/app/api/routes/analytics.py → backend/app/models/order.py

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (76 total, 5 thin omitted)

### Community 0 - "User"
Cohesion: 0.15
Nodes (12): create_access_token(), create_refresh_token(), get_password_hash(), verify_password(), User, BaseRepository, Session, Session (+4 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "Settings"
Cohesion: 0.14
Nodes (9): Resolve backup directory for database snapshots as an absolute path., Resolve backup directory for media files as an absolute path., Resolve the active database connection string based on ACTIVE_DB_TIER., Resolve active media directory as an absolute path., Settings, FastAPI Python Dependencies, test_custom_backup_and_media_paths(), BaseSettings (+1 more)

### Community 3 - "BackupService"
Cohesion: 0.12
Nodes (12): BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Create a safe timestamped copy of the local SQLite database., Incrementally sync/copy all files from media_dir to backup_media_dir., Keep only the latest N snapshot files., Sync schema and data from local database to a PostgreSQL target (Local Postgres…, Sync schema and data from local database to on-premises Local PostgreSQL., Sync schema and data from local database to Neon Cloud PostgreSQL. (+4 more)

### Community 4 - "OrderService"
Cohesion: 0.05
Nodes (81): Base, BlankingProcess, CastingProcess, Order, OrderStatus, PackingProcess, PolishingProcess, str (+73 more)

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
Nodes (41): _boxTypeController, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+33 more)

### Community 9 - "my_application.cc"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "staff_page.dart"
Cohesion: 0.09
Nodes (21): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+13 more)

### Community 11 - "app_router.dart"
Cohesion: 0.07
Nodes (26): appRouterProvider, authState, authStateVal, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets (+18 more)

### Community 12 - "dioProvider"
Cohesion: 0.08
Nodes (35): dioProvider, AnalyticsPage, _AnalyticsPageState, DashboardPage, _DashboardPageState, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, DepartmentUpdatePage (+27 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.08
Nodes (23): AppTheme, light, activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon (+15 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.08
Nodes (24): buttonImage, companyName, _confirmAndDispatch, createState, _deletingToken, _dispatchingToken, dispatchQuantity, dispose (+16 more)

### Community 16 - "secure_storage.dart"
Cohesion: 0.07
Nodes (27): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+19 more)

### Community 17 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 18 - "reports_page.dart"
Cohesion: 0.05
Nodes (44): _SnapshotChip, _DetailChip, build, color, createState, department, details, dispose (+36 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.12
Nodes (15): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+7 more)

### Community 21 - "routes/analytics.py"
Cohesion: 0.21
Nodes (10): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+2 more)

### Community 23 - "login_page.dart"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 24 - "package:btn_factory/shared/widgets/app_scaffold.dart"
Cohesion: 0.25
Nodes (7): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, package:btn_factory/shared/widgets/app_scaffold.dart

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

### Community 30 - "routes/auth.py"
Cohesion: 0.25
Nodes (18): delete_user(), list_users(), login(), delete, get, post, put, Session (+10 more)

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

### Community 55 - "orders.py"
Cohesion: 0.27
Nodes (15): create_order(), delete_order(), dispatch_order(), get_next_token(), get_order(), list_orders(), delete, get (+7 more)

### Community 56 - "get_settings"
Cohesion: 0.23
Nodes (15): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., get_settings(), check_postgres_connection(), check_sqlite_connection(), is_placeholder() (+7 more)

### Community 59 - "app_constants.dart"
Cohesion: 0.17
Nodes (11): accessToken, AppConstants, appName, AppStorageKeys, refreshToken, userDepartment, userEmail, userName (+3 more)

### Community 61 - "main.py"
Cohesion: 0.14
Nodes (13): health_check(), on_shutdown(), on_startup(), get, HourlyBackupScheduler, Recurring background backup daemon that runs every hour as long as the server…, Start the background recurring backup worker if not already running., Stop the background recurring backup worker. (+5 more)

### Community 62 - "departments.py"
Cohesion: 0.32
Nodes (14): add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), delete, get, post, Session, update_blanking() (+6 more)

### Community 63 - "setup_local_postgres.py"
Cohesion: 0.07
Nodes (42): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, set_sqlite_pragma(), Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), main(), print_banner(), Universal Database Repair & Multi-Tier Sync Script. Runs on ANY system… (+34 more)

### Community 64 - "models/user.py"
Cohesion: 0.28
Nodes (7): get_current_user(), Session, require_roles(), decode_token(), str, UserRole, Enum

### Community 65 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.10
Nodes (19): AsyncValue, _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, createState (+11 more)

### Community 66 - "manage_startup.py"
Cohesion: 0.31
Nodes (8): add_to_startup(), create_vbs_shortcut(), get_startup_dir(), Button Factory MES - Windows Startup Manager. Configures automatic background…, Remove Button Factory MES from Windows Startup., Create Windows .lnk shortcut via temporary VBScript., Add Button Factory MES to Windows Startup., remove_from_startup()

### Community 67 - "analytics_page.dart"
Cohesion: 0.12
Nodes (15): build, _buildKpiGrid, _buildOrdersTrendChart, _buildProductionStatusChart, _buildStatCard, createState, _dashboardStats, _errorMessage (+7 more)

### Community 68 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 69 - "schemas/__init__.py"
Cohesion: 0.62
Nodes (5): BaseModel, UserBase, UserCreate, UserRead, UserUpdate

### Community 70 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 73 - "setup_web_servers.py"
Cohesion: 0.23
Nodes (12): ensure_nginx_binary(), generate_iis_config(), generate_nginx_config(), get_public_domain(), get_web_port(), main(), Web Server Configuration Generator for Nginx and IIS (Backend-Only Mode).…, Generate production web.config for IIS with pure ARR reverse proxy to FastAPI… (+4 more)

### Community 74 - "upload_media"
Cohesion: 0.22
Nodes (6): post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), MediaService, Validates, optimizes, and stores an image on local disk: 1. Validates image…, UploadFile

### Community 75 - "authControllerProvider"
Cohesion: 0.09
Nodes (27): authControllerProvider, build, _submit, build, ProfilePage, build, build, _buildActionCards (+19 more)

### Community 76 - "custom_http_exception_handler"
Cohesion: 0.28
Nodes (9): custom_http_exception_handler(), Request, trace_and_timing_middleware(), unhandled_exception_handler(), Exception, exception_handler, JSONResponse, middleware (+1 more)

### Community 82 - "Cloud Deployment Architecture"
Cohesion: 0.33
Nodes (6): Cloud Deployment Architecture, Render Backend Deployment, Storage & Database Persistence, Vercel Frontend Deployment, Docker Compose Backend Container, Docker Volume backend_data

## Knowledge Gaps
- **354 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+349 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 587 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `models/user.py`, `OrderService`, `routes/analytics.py`, `orders.py`, `routes/auth.py`, `departments.py`?**
  _High betweenness centrality (0.095) - this node is a cross-community bridge._
- **Why does `Base` connect `OrderService` to `models/user.py`, `User`, `BackupService`, `main.py`, `setup_local_postgres.py`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Why does `get_settings()` connect `get_settings` to `User`, `Settings`, `BackupService`, `OrderService`, `upload_media`, `InMemoryFallbackCache`, `main.py`, `setup_local_postgres.py`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Are the 35 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 35 INFERRED edges - model-reasoned connections that need verification._
- **Are the 17 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 17 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._