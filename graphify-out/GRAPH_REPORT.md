# Graph Report - btn-factory  (2026-11-16)

## Corpus Check
- 145 files · ~94,623 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1221 nodes · 2306 edges · 76 communities (50 shown, 6 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 202 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `22fd3686`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- AuthService
- Win32Window
- ReportService
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
- Order
- reports_page.dart
- auth_state.dart
- app_constants.dart
- get_settings
- login_page.dart
- session_storage_adapter_web.dart
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
- main.dart
- routes/auth.py
- models/order.py
- routes/reports.py
- package:flutter_riverpod/flutter_riverpod.dart
- package:flutter/material.dart
- repair_and_sync_db.py
- Cloud Deployment Architecture
- manage_startup.py
- analytics_page.dart
- dashboard_stats
- api_client.dart
- auth_controller.dart
- setup_web_servers.py
- authControllerProvider
- custom_http_exception_handler
- _ActionCard
- Base
- vercel_build.sh

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 71 edges
2. `Base` - 52 edges
3. `User` - 49 edges
4. `Order` - 38 edges
5. `dioProvider` - 28 edges
6. `OrderRepository` - 27 edges
7. `ReportService` - 25 edges
8. `Win32Window` - 24 edges
9. `get_settings()` - 23 edges
10. `OrderStatus` - 21 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `Storage & Database Persistence` --conceptually_related_to--> `Docker Volume backend_data`  [INFERRED]
  DEPLOYMENT_GUIDE.md → docker-compose.yml
- `Button Factory MES Specifications` --conceptually_related_to--> `Button Factory MES Overview`  [INFERRED]
  btn_factory/plan-buttonFactoryMes.prompt.md → README.md
- `dashboard_stats()` --uses--> `Order`  [INFERRED]
  backend/app/api/routes/analytics.py → backend/app/models/order.py
- `dashboard_stats()` --uses--> `OrderStatus`  [INFERRED]
  backend/app/api/routes/analytics.py → backend/app/models/order.py

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (76 total, 6 thin omitted)

### Community 0 - "AuthService"
Cohesion: 0.08
Nodes (23): create_access_token(), create_refresh_token(), verify_password(), BaseRepository, Session, Session, UserRepository, AuthService (+15 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "ReportService"
Cohesion: 0.16
Nodes (15): CastingProcess, OrderStatus, PackingProcess, str, Session, ReportService, determine_order_status(), recompute_order_status() (+7 more)

### Community 3 - "BackupService"
Cohesion: 0.07
Nodes (25): on_shutdown(), BackupService, HourlyBackupScheduler, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Create a safe timestamped copy of the local SQLite database., Incrementally sync/copy all files from media_dir to backup_media_dir., Keep only the latest N snapshot files., Sync schema and data from local database to a PostgreSQL target (Local Postgres… (+17 more)

### Community 4 - "OrderService"
Cohesion: 0.06
Nodes (90): delete_user(), delete, add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), delete, get, post (+82 more)

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
Nodes (35): dioProvider, AnalyticsPage, _AnalyticsPageState, DashboardPage, _DashboardPageState, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, DepartmentUpdatePage (+27 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.10
Nodes (20): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+12 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.08
Nodes (24): buttonImage, companyName, _confirmAndDispatch, createState, _deletingToken, _dispatchingToken, dispatchQuantity, dispose (+16 more)

### Community 16 - "secure_storage.dart"
Cohesion: 0.14
Nodes (16): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+8 more)

### Community 17 - "Order"
Cohesion: 0.15
Nodes (9): BlankingProcess, Order, PolishingProcess, RawMaterial, TurningProcess, OrderRepository, Session, Return the lowest available numeric order token >= 1001. If an order is… (+1 more)

### Community 18 - "reports_page.dart"
Cohesion: 0.06
Nodes (37): _SnapshotChip, _DetailChip, build, color, createState, department, details, dispose (+29 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "app_constants.dart"
Cohesion: 0.06
Nodes (29): Resolve active media directory as an absolute path., Resolve backup directory for database snapshots as an absolute path., Resolve backup directory for media files as an absolute path., Resolve the active database connection string based on ACTIVE_DB_TIER., Settings, FastAPI Python Dependencies, BaseSettings, accessToken (+21 more)

### Community 21 - "get_settings"
Cohesion: 0.07
Nodes (38): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+30 more)

### Community 23 - "login_page.dart"
Cohesion: 0.17
Nodes (12): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _showServerSelectionDialog (+4 more)

### Community 24 - "session_storage_adapter_web.dart"
Cohesion: 0.14
Nodes (11): createWebSessionStorage, getWebSessionStorage, delete, deleteAll, getWebSessionStorage, read, WebSessionStorageAdapter, write (+3 more)

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
Cohesion: 0.09
Nodes (21): AsyncValue, createState, _navigated, SplashPage, _SplashPageState, createState, _error, _fetchOrder (+13 more)

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "web/vercel.json"
Cohesion: 0.40
Nodes (4): cleanUrls, headers, rewrites, $schema

### Community 43 - "vercel.json"
Cohesion: 0.40
Nodes (4): cleanUrls, headers, rewrites, $schema

### Community 54 - "main.dart"
Cohesion: 0.15
Nodes (13): appRouterProvider, build, ButtonFactoryApp, loadEnv, main, Button Factory MES Specifications, Flutter App Manifest & Assets, GitHub Actions Release Workflow (+5 more)

### Community 55 - "routes/auth.py"
Cohesion: 0.21
Nodes (21): list_users(), login(), get, post, put, Session, refresh(), register_user() (+13 more)

### Community 56 - "models/order.py"
Cohesion: 0.15
Nodes (5): health_check(), get, Persistent monotonic order-token sequence (1001, 1002, ...). Stored in the…, TokenCounter, Enum

### Community 59 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 61 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.29
Nodes (6): main, read, package:btn_factory/core/storage/secure_storage.dart, package:btn_factory/main.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart

### Community 62 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (16): AppTheme, light, build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title (+8 more)

### Community 63 - "repair_and_sync_db.py"
Cohesion: 0.29
Nodes (9): main(), print_banner(), Universal Database Repair & Multi-Tier Sync Script. Runs on ANY system…, Audit and reconstruct all tables and records in SQLite with complete history., Synchronize schema and sanitized records into a PostgreSQL target., Ensure val conforms strictly to the SQLAlchemy column's expected python type., repair_sqlite_database(), sanitize_val() (+1 more)

### Community 64 - "Cloud Deployment Architecture"
Cohesion: 0.33
Nodes (6): Cloud Deployment Architecture, Render Backend Deployment, Storage & Database Persistence, Vercel Frontend Deployment, Docker Compose Backend Container, Docker Volume backend_data

### Community 66 - "manage_startup.py"
Cohesion: 0.31
Nodes (8): add_to_startup(), create_vbs_shortcut(), get_startup_dir(), Button Factory MES - Windows Startup Manager. Configures automatic background…, Remove Button Factory MES from Windows Startup., Create Windows .lnk shortcut via temporary VBScript., Add Button Factory MES to Windows Startup., remove_from_startup()

### Community 67 - "analytics_page.dart"
Cohesion: 0.12
Nodes (15): build, _buildKpiGrid, _buildOrdersTrendChart, _buildProductionStatusChart, _buildStatCard, createState, _dashboardStats, _errorMessage (+7 more)

### Community 69 - "dashboard_stats"
Cohesion: 0.32
Nodes (8): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database.

### Community 70 - "api_client.dart"
Cohesion: 0.25
Nodes (7): dio, storage, dart:async, Dio, package:dio/dio.dart, package:flutter/foundation.dart, return

### Community 72 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 73 - "setup_web_servers.py"
Cohesion: 0.23
Nodes (12): ensure_nginx_binary(), generate_iis_config(), generate_nginx_config(), get_public_domain(), get_web_port(), main(), Web Server Configuration Generator for Nginx and IIS (Backend-Only Mode).…, Generate production web.config for IIS with pure ARR reverse proxy to FastAPI… (+4 more)

### Community 75 - "authControllerProvider"
Cohesion: 0.07
Nodes (34): authControllerProvider, build, _submit, build, _formatDepartment, _formatRole, icon, label (+26 more)

### Community 76 - "custom_http_exception_handler"
Cohesion: 0.28
Nodes (9): custom_http_exception_handler(), Request, trace_and_timing_middleware(), unhandled_exception_handler(), Exception, exception_handler, JSONResponse, middleware (+1 more)

### Community 78 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 79 - "Base"
Cohesion: 0.14
Nodes (23): Base, Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), get_password_hash(), on_startup(), str, UserRole, main() (+15 more)

## Knowledge Gaps
- **366 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `logoAsset`, `_configuredApiBaseUrl` (+361 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 609 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `OrderService` to `AuthService`, `ReportService`, `dashboard_stats`, `Base`, `routes/auth.py`, `models/order.py`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Why does `Base` connect `Base` to `AuthService`, `ReportService`, `BackupService`, `OrderService`, `Order`, `get_settings`, `models/order.py`, `repair_and_sync_db.py`?**
  _High betweenness centrality (0.074) - this node is a cross-community bridge._
- **Why does `get_settings()` connect `get_settings` to `AuthService`, `BackupService`, `InMemoryFallbackCache`, `Base`, `app_constants.dart`, `models/order.py`, `repair_and_sync_db.py`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Are the 35 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 35 INFERRED edges - model-reasoned connections that need verification._
- **Are the 20 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 20 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._