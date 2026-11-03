# Graph Report - btn-factory  (2026-11-03)

## Corpus Check
- 136 files · ~67,186 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1117 nodes · 2126 edges · 71 communities (46 shown, 5 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 190 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `978e3b58`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- routes/auth.py
- Win32Window
- sync_schema_and_data.py
- BackupService
- secure_storage.dart
- GeneratedPluginRegistrant.swift
- app_image_preview.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- app_router.dart
- profile_page.dart
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- ConsumerState
- _ActionCard
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- setup_local_postgres.py
- login_page.dart
- authControllerProvider
- wWinMain
- pdf_export_service.dart
- manifest.json
- dashboard_page.dart
- dioProvider
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
- Base
- package:flutter_riverpod/flutter_riverpod.dart
- sync_database_schema
- package:flutter/material.dart
- StatelessWidget
- package:btn_factory/shared/widgets/app_scaffold.dart
- metric_card.dart
- analytics_page.dart
- widget_test.dart
- OrderService
- auth_controller.dart

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 70 edges
2. `Base` - 46 edges
3. `User` - 41 edges
4. `Order` - 38 edges
5. `dioProvider` - 28 edges
6. `OrderRepository` - 27 edges
7. `ReportService` - 25 edges
8. `Win32Window` - 24 edges
9. `OrderStatus` - 21 edges
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

## Communities (71 total, 5 thin omitted)

### Community 0 - "routes/auth.py"
Cohesion: 0.09
Nodes (33): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+25 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "sync_schema_and_data.py"
Cohesion: 0.18
Nodes (15): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, apply_schema_update(), create_safety_backup(), get_table_counts(), main(), print_banner(), Universal Schema Migration and Data Sync Script. Safely updates database… (+7 more)

### Community 3 - "BackupService"
Cohesion: 0.15
Nodes (10): BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Keep only the latest N snapshot files., Sync schema and data from local database to a PostgreSQL target (Local Postgres…, Sync schema and data from local database to on-premises Local PostgreSQL., Sync schema and data from local database to Neon Cloud PostgreSQL., Run local snapshot creation, Local Postgres sync, and Neon cloud sync., Create a safe timestamped copy of the local SQLite database. (+2 more)

### Community 4 - "secure_storage.dart"
Cohesion: 0.06
Nodes (31): Resolve the active database connection string based on ACTIVE_DB_TIER., Settings, FastAPI Python Dependencies, BaseSettings, accessToken, AppConstants, appName, AppStorageKeys (+23 more)

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
Cohesion: 0.09
Nodes (21): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+13 more)

### Community 11 - "app_router.dart"
Cohesion: 0.13
Nodes (14): authState, authStateVal, GoRouter, package:btn_factory/features/auth/presentation/login_page.dart, package:btn_factory/features/auth/presentation/profile_page.dart, package:btn_factory/features/auth/presentation/splash_page.dart, package:btn_factory/features/dashboard/presentation/analytics_page.dart, package:btn_factory/features/dashboard/presentation/dashboard_page.dart (+6 more)

### Community 12 - "profile_page.dart"
Cohesion: 0.14
Nodes (13): AsyncValue, _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, createState (+5 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.15
Nodes (12): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+4 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.09
Nodes (22): buttonImage, companyName, _confirmAndDispatch, createState, _deletingToken, _dispatchingToken, dispose, _error (+14 more)

### Community 16 - "ConsumerState"
Cohesion: 0.20
Nodes (14): LoginPage, _LoginPageState, SplashPage, _SplashPageState, DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState (+6 more)

### Community 17 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 18 - "reports_page.dart"
Cohesion: 0.07
Nodes (27): build, color, createState, department, details, dispose, _error, _expandedOrderTokens (+19 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.12
Nodes (16): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+8 more)

### Community 21 - "setup_local_postgres.py"
Cohesion: 0.19
Nodes (13): main(), print_banner(), Universal PostgreSQL Discovery, Credential Resolver, and Schema Initializer.…, Attempt connecting with psycopg or psycopg2., Write or update LOCAL_POSTGRES_URL and optionally ACTIVE_DB_TIER in…, Scan local host for open TCP ports typical for PostgreSQL., Look for credentials in ~/.pgpass (Linux/macOS) or…, Inspect backend/.env for current configured credentials. (+5 more)

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
Cohesion: 0.13
Nodes (14): _buildBlankingTable, _buildCastingTable, _buildSectionHeader, exportOrderPdf, exportRawMaterialsAndImagePdf, exportReportPdf, _fetchImageBytes, PdfExportService (+6 more)

### Community 27 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "dashboard_page.dart"
Cohesion: 0.10
Nodes (19): color, _completedOrders, createState, description, _error, _formatCurrency, icon, initState (+11 more)

### Community 30 - "dioProvider"
Cohesion: 0.13
Nodes (15): dioProvider, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails (+7 more)

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
Cohesion: 0.29
Nodes (6): dio, storage, dart:async, Dio, package:dio/dio.dart, return

### Community 55 - "main.py"
Cohesion: 0.05
Nodes (44): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+36 more)

### Community 56 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 59 - "Base"
Cohesion: 0.07
Nodes (45): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+37 more)

### Community 61 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.15
Nodes (13): appRouterProvider, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets, GitHub Actions Release Workflow, package:btn_factory/core/router/app_router.dart (+5 more)

### Community 62 - "sync_database_schema"
Cohesion: 0.23
Nodes (12): Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), main(), print_banner(), Universal Database Repair & Multi-Tier Sync Script. Runs on ANY system…, Audit and reconstruct all tables and records in SQLite with complete history., Synchronize schema and sanitized records into a PostgreSQL target., Ensure val conforms strictly to the SQLAlchemy column's expected python type. (+4 more)

### Community 63 - "package:flutter/material.dart"
Cohesion: 0.18
Nodes (9): AppTheme, light, build, child, SectionCard, title, trailing, package:flutter/material.dart (+1 more)

### Community 64 - "StatelessWidget"
Cohesion: 0.15
Nodes (13): _SnapshotChip, _DetailChip, _IndividualOrderCard, _InfoBadge, _LogDetailRow, _MetricChip, _ReportSummary, _SummaryTile (+5 more)

### Community 65 - "package:btn_factory/shared/widgets/app_scaffold.dart"
Cohesion: 0.25
Nodes (7): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, package:btn_factory/shared/widgets/app_scaffold.dart

### Community 66 - "metric_card.dart"
Cohesion: 0.25
Nodes (7): build, icon, MetricCard, tint, title, value, IconData

### Community 67 - "analytics_page.dart"
Cohesion: 0.12
Nodes (17): AnalyticsPage, _AnalyticsPageState, build, _buildKpiGrid, _buildOrdersTrendChart, _buildProductionStatusChart, _buildStatCard, createState (+9 more)

### Community 68 - "widget_test.dart"
Cohesion: 0.33
Nodes (5): main, read, package:btn_factory/core/storage/secure_storage.dart, package:btn_factory/main.dart, package:flutter_test/flutter_test.dart

### Community 69 - "OrderService"
Cohesion: 0.07
Nodes (79): add_raw_material(), delete_universal_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting() (+71 more)

### Community 70 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

## Knowledge Gaps
- **342 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+337 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 550 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `OrderService` to `routes/auth.py`, `Base`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Why does `Base` connect `Base` to `sync_schema_and_data.py`, `BackupService`, `OrderService`, `setup_local_postgres.py`, `main.py`, `sync_database_schema`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Why does `dioProvider` connect `dioProvider` to `analytics_page.dart`, `auth_controller.dart`, `order_form_page.dart`, `order_list_page.dart`, `ConsumerState`, `reports_page.dart`, `order_details_page.dart`, `api_client.dart`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Are the 35 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 35 INFERRED edges - model-reasoned connections that need verification._
- **Are the 16 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._