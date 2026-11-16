# Graph Report - btn-factory  (2026-11-16)

## Corpus Check
- 147 files · ~96,773 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1251 nodes · 2381 edges · 72 communities (46 shown, 6 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 211 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `95cd3b6e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- sync_database_schema
- Win32Window
- Base
- main.py
- routes/auth.py
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
- fix_and_restore_admin.py
- reports_page.dart
- auth_state.dart
- Settings
- get_settings
- main.dart
- router.py
- wWinMain
- pdf_export_service.dart
- manifest.json
- dashboard_page.dart
- order_details_page.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- web/vercel.json
- vercel.json
- rules/graphify.md
- workflows/graphify.md
- README.md
- OrderService
- profile_page.dart
- routes/reports.py
- package:flutter_riverpod/flutter_riverpod.dart
- Cloud Deployment Architecture
- BackupService
- manage_startup.py
- analytics_page.dart
- package:btn_factory/shared/widgets/app_scaffold.dart
- auth_controller.dart
- setup_web_servers.py
- authControllerProvider
- custom_http_exception_handler
- _ActionCard
- vercel_build.sh

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 71 edges
2. `Base` - 54 edges
3. `User` - 52 edges
4. `Order` - 38 edges
5. `dioProvider` - 30 edges
6. `OrderRepository` - 27 edges
7. `ReportService` - 25 edges
8. `Win32Window` - 24 edges
9. `get_settings()` - 23 edges
10. `OrderStatus` - 21 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `Button Factory MES Specifications` --conceptually_related_to--> `Button Factory MES Overview`  [INFERRED]
  btn_factory/plan-buttonFactoryMes.prompt.md → README.md
- `Storage & Database Persistence` --conceptually_related_to--> `Docker Volume backend_data`  [INFERRED]
  DEPLOYMENT_GUIDE.md → docker-compose.yml
- `dashboard_stats()` --uses--> `User`  [INFERRED]
  backend/app/api/routes/analytics.py → backend/app/models/user.py
- `orders_trend()` --uses--> `User`  [INFERRED]
  backend/app/api/routes/analytics.py → backend/app/models/user.py

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (72 total, 6 thin omitted)

### Community 0 - "sync_database_schema"
Cohesion: 0.07
Nodes (40): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), main(), print_banner(), Universal Database Repair & Multi-Tier Sync Script. Runs on ANY system…, Audit and reconstruct all tables and records in SQLite with complete history. (+32 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "Base"
Cohesion: 0.06
Nodes (55): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+47 more)

### Community 3 - "main.py"
Cohesion: 0.16
Nodes (11): health_check(), on_shutdown(), on_startup(), get, HourlyBackupScheduler, Recurring background backup daemon that runs every hour as long as the server…, Start the background recurring backup worker if not already running., Stop the background recurring backup worker. (+3 more)

### Community 4 - "routes/auth.py"
Cohesion: 0.10
Nodes (35): change_password(), delete_user(), list_users(), login(), delete, get, post, put (+27 more)

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
Cohesion: 0.13
Nodes (14): authState, authStateVal, GoRouter, package:btn_factory/features/auth/presentation/login_page.dart, package:btn_factory/features/auth/presentation/profile_page.dart, package:btn_factory/features/auth/presentation/splash_page.dart, package:btn_factory/features/dashboard/presentation/analytics_page.dart, package:btn_factory/features/dashboard/presentation/dashboard_page.dart (+6 more)

### Community 12 - "dioProvider"
Cohesion: 0.08
Nodes (37): dioProvider, LoginPage, _LoginPageState, _ChangePasswordDialog, _ChangePasswordDialogState, AnalyticsPage, _AnalyticsPageState, DashboardPage (+29 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.06
Nodes (35): AsyncValue, AppTheme, light, createState, _navigated, SplashPage, _SplashPageState, activeColor (+27 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.04
Nodes (47): accessToken, AppConstants, appName, AppStorageKeys, backendUrls, _configuredApiBaseUrl, defaultDuckDnsDomain, loadEnv (+39 more)

### Community 16 - "secure_storage.dart"
Cohesion: 0.07
Nodes (27): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+19 more)

### Community 17 - "fix_and_restore_admin.py"
Cohesion: 0.17
Nodes (19): check_sqlite_integrity(), deep_salvage_sqlite_database(), ensure_super_admin(), find_best_backup(), find_processes_locking_file(), heal_sqlite_database(), kill_all_database_lockers(), main() (+11 more)

### Community 18 - "reports_page.dart"
Cohesion: 0.06
Nodes (38): _ProfileDetailRow, _SnapshotChip, _DetailChip, build, color, createState, department, details (+30 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "Settings"
Cohesion: 0.15
Nodes (8): Resolve active media directory as an absolute path., Resolve backup directory for database snapshots as an absolute path., Resolve backup directory for media files as an absolute path., Resolve the active database connection string based on ACTIVE_DB_TIER., Settings, FastAPI Python Dependencies, BaseSettings, field_validator

### Community 21 - "get_settings"
Cohesion: 0.23
Nodes (15): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., get_settings(), check_postgres_connection(), check_sqlite_connection(), is_placeholder() (+7 more)

### Community 23 - "main.dart"
Cohesion: 0.14
Nodes (14): appRouterProvider, build, ButtonFactoryApp, loadEnv, main, Button Factory MES Specifications, Flutter App Manifest & Assets, GitHub Actions Release Workflow (+6 more)

### Community 24 - "router.py"
Cohesion: 0.18
Nodes (6): post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), MediaService, Validates, optimizes, and stores an image on local disk: 1. Validates image…, UploadFile

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

### Community 30 - "order_details_page.dart"
Cohesion: 0.13
Nodes (14): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+6 more)

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "web/vercel.json"
Cohesion: 0.40
Nodes (4): cleanUrls, headers, rewrites, $schema

### Community 43 - "vercel.json"
Cohesion: 0.40
Nodes (4): cleanUrls, headers, rewrites, $schema

### Community 54 - "OrderService"
Cohesion: 0.06
Nodes (83): add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), delete, get, post, Session, update_blanking() (+75 more)

### Community 56 - "profile_page.dart"
Cohesion: 0.08
Nodes (25): createState, dispose, _emailController, _formKey, _passwordController, _showServerSelectionDialog, _submitting, _confirmPasswordController (+17 more)

### Community 59 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 61 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.14
Nodes (13): dio, storage, main, read, dart:async, Dio, package:btn_factory/core/storage/secure_storage.dart, package:btn_factory/features/auth/application/auth_controller.dart (+5 more)

### Community 64 - "Cloud Deployment Architecture"
Cohesion: 0.33
Nodes (6): Cloud Deployment Architecture, Render Backend Deployment, Storage & Database Persistence, Vercel Frontend Deployment, Docker Compose Backend Container, Docker Volume backend_data

### Community 65 - "BackupService"
Cohesion: 0.10
Nodes (17): BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Create a safe timestamped copy of the local SQLite database., Incrementally sync/copy all files from media_dir to backup_media_dir., Keep only the latest N snapshot files., Sync schema and data from local database to a PostgreSQL target (Local Postgres…, Sync schema and data from local database to on-premises Local PostgreSQL., Sync schema and data from local database to Neon Cloud PostgreSQL. (+9 more)

### Community 66 - "manage_startup.py"
Cohesion: 0.31
Nodes (8): add_to_startup(), create_vbs_shortcut(), get_startup_dir(), Button Factory MES - Windows Startup Manager. Configures automatic background…, Remove Button Factory MES from Windows Startup., Create Windows .lnk shortcut via temporary VBScript., Add Button Factory MES to Windows Startup., remove_from_startup()

### Community 67 - "analytics_page.dart"
Cohesion: 0.12
Nodes (16): build, _buildKpiGrid, _buildOrdersTrendChart, _buildProductionStatusChart, _buildStatCard, createState, _dashboardStats, _errorMessage (+8 more)

### Community 71 - "package:btn_factory/shared/widgets/app_scaffold.dart"
Cohesion: 0.25
Nodes (7): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, package:btn_factory/shared/widgets/app_scaffold.dart

### Community 72 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 73 - "setup_web_servers.py"
Cohesion: 0.23
Nodes (12): ensure_nginx_binary(), generate_iis_config(), generate_nginx_config(), get_public_domain(), get_web_port(), main(), Web Server Configuration Generator for Nginx and IIS (Backend-Only Mode).…, Generate production web.config for IIS with pure ARR reverse proxy to FastAPI… (+4 more)

### Community 75 - "authControllerProvider"
Cohesion: 0.09
Nodes (27): authControllerProvider, build, _submit, build, ProfilePage, build, build, _buildActionCards (+19 more)

### Community 76 - "custom_http_exception_handler"
Cohesion: 0.28
Nodes (9): custom_http_exception_handler(), Request, trace_and_timing_middleware(), unhandled_exception_handler(), Exception, exception_handler, JSONResponse, middleware (+1 more)

### Community 78 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

## Knowledge Gaps
- **375 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `logoAsset`, `_configuredApiBaseUrl` (+370 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 625 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `OrderService` to `fix_and_restore_admin.py`, `Base`, `routes/auth.py`?**
  _High betweenness centrality (0.090) - this node is a cross-community bridge._
- **Why does `Base` connect `Base` to `sync_database_schema`, `BackupService`, `main.py`, `fix_and_restore_admin.py`, `OrderService`?**
  _High betweenness centrality (0.080) - this node is a cross-community bridge._
- **Why does `get_settings()` connect `get_settings` to `sync_database_schema`, `BackupService`, `Base`, `main.py`, `routes/auth.py`, `InMemoryFallbackCache`, `fix_and_restore_admin.py`, `Settings`, `router.py`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Are the 35 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 35 INFERRED edges - model-reasoned connections that need verification._
- **Are the 21 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 21 INFERRED edges - model-reasoned connections that need verification._
- **Are the 24 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 24 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._