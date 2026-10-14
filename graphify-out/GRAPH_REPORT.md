# Graph Report - btn-factory  (2026-10-14)

## Corpus Check
- 122 files · ~58,900 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1051 nodes · 2004 edges · 69 communities (53 shown, 6 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 179 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `de8734df`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- routes/auth.py
- Win32Window
- order_service.py
- setup_local_postgres.py
- secure_storage.dart
- GeneratedPluginRegistrant.swift
- app_image_preview.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- app_router.dart
- main.py
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- ConsumerState
- splash_page.dart
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- dioProvider
- HTTPException
- login_page.dart
- authControllerProvider
- wWinMain
- pdf_export_service.dart
- manifest.json
- dashboard_page.dart
- Base
- profile_page.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- web/vercel.json
- vercel.json
- rules/graphify.md
- workflows/graphify.md
- README.md
- User
- orders.py
- OrderService
- schemas/order.py
- auth_controller.dart
- api_client.dart
- get_settings
- routes/reports.py
- orders_trend
- schemas/__init__.py
- test_workflow_edits.py
- widget_test.dart
- test_order_tokens_and_delete.py
- package:flutter_riverpod/flutter_riverpod.dart
- package:flutter/material.dart
- _buildActionCards
- metric_card.dart
- _ActionCard
- Cloud Deployment Architecture
- BaseRepository

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 69 edges
2. `User` - 41 edges
3. `Base` - 36 edges
4. `Order` - 35 edges
5. `OrderRepository` - 27 edges
6. `dioProvider` - 25 edges
7. `Win32Window` - 24 edges
8. `ReportService` - 22 edges
9. `OrderCreate` - 19 edges
10. `authControllerProvider` - 18 edges

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

## Communities (69 total, 6 thin omitted)

### Community 0 - "routes/auth.py"
Cohesion: 0.26
Nodes (18): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+10 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "order_service.py"
Cohesion: 0.18
Nodes (19): dashboard_stats(), Return real-time dashboard metrics computed from the database., BlankingProcess, CastingProcess, OrderStatus, PackingProcess, PolishingProcess, str (+11 more)

### Community 3 - "setup_local_postgres.py"
Cohesion: 0.07
Nodes (30): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, set_sqlite_pragma(), Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), BackupService, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, Sync schema and data from local database to a PostgreSQL target (Local Postgres… (+22 more)

### Community 4 - "secure_storage.dart"
Cohesion: 0.16
Nodes (14): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+6 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (31): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+23 more)

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
Cohesion: 0.09
Nodes (21): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+13 more)

### Community 11 - "app_router.dart"
Cohesion: 0.13
Nodes (14): authState, authStateVal, GoRouter, package:btn_factory/features/auth/presentation/login_page.dart, package:btn_factory/features/auth/presentation/profile_page.dart, package:btn_factory/features/auth/presentation/splash_page.dart, package:btn_factory/features/dashboard/presentation/dashboard_page.dart, package:btn_factory/features/departments/presentation/department_update_page.dart (+6 more)

### Community 12 - "main.py"
Cohesion: 0.11
Nodes (18): custom_http_exception_handler(), health_check(), on_startup(), get, Request, trace_and_timing_middleware(), unhandled_exception_handler(), str (+10 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.15
Nodes (12): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+4 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.10
Nodes (21): buttonImage, companyName, createState, _deletingToken, dispose, _error, initState, _isLoading (+13 more)

### Community 16 - "ConsumerState"
Cohesion: 0.20
Nodes (14): DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState, OrderFormPage, _OrderFormPageState, ReportsPage, _ReportsPageState (+6 more)

### Community 17 - "splash_page.dart"
Cohesion: 0.33
Nodes (6): AsyncValue, createState, _navigated, SplashPage, _SplashPageState, package:go_router/go_router.dart

### Community 18 - "reports_page.dart"
Cohesion: 0.06
Nodes (38): _SnapshotChip, _DetailChip, build, color, createState, department, details, dispose (+30 more)

### Community 19 - "auth_state.dart"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 20 - "order_details_page.dart"
Cohesion: 0.13
Nodes (15): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+7 more)

### Community 21 - "dioProvider"
Cohesion: 0.13
Nodes (15): dioProvider, _fetchDashboard, _confirmDeleteUniversalMaterialDirect, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchNextToken, _fetchOrderDetails (+7 more)

### Community 22 - "HTTPException"
Cohesion: 0.26
Nodes (14): add_raw_material(), delete_universal_raw_material(), post, Session, update_blanking(), update_casting(), update_packing(), update_polish() (+6 more)

### Community 23 - "login_page.dart"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 24 - "authControllerProvider"
Cohesion: 0.15
Nodes (17): authControllerProvider, build, _submit, build, ProfilePage, build, build, build (+9 more)

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

### Community 29 - "Base"
Cohesion: 0.14
Nodes (9): Base, Order, OrderRepository, Session, Return the lowest available numeric order token >= 1001. If an order is…, Session, main(), run_seed() (+1 more)

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

### Community 49 - "User"
Cohesion: 0.19
Nodes (9): create_access_token(), create_refresh_token(), verify_password(), User, Session, UserRepository, AuthService, Session (+1 more)

### Community 50 - "orders.py"
Cohesion: 0.22
Nodes (16): create_order(), delete_order(), dispatch_order(), get_next_token(), get_order(), list_orders(), get, post (+8 more)

### Community 51 - "OrderService"
Cohesion: 0.17
Nodes (6): UniversalRawMaterial, UniversalRawMaterialCreate, OrderService, recompute_order_status(), setup_test_db(), test_upsert_and_delete_universal_raw_material()

### Community 52 - "schemas/order.py"
Cohesion: 0.19
Nodes (18): get_universal_raw_materials(), get, upsert_universal_raw_material(), BlankingRead, BlankingUpdate, CastingRead, OrderBase, OrderListItem (+10 more)

### Community 53 - "auth_controller.dart"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 54 - "api_client.dart"
Cohesion: 0.25
Nodes (7): dio, storage, dart:async, Dio, package:btn_factory/features/auth/application/auth_controller.dart, package:dio/dio.dart, return

### Community 55 - "get_settings"
Cohesion: 0.05
Nodes (37): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+29 more)

### Community 56 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 57 - "orders_trend"
Cohesion: 0.40
Nodes (6): orders_trend(), production_trend(), get, Session, Monthly order counts from the database., Per-status breakdown from the database.

### Community 58 - "schemas/__init__.py"
Cohesion: 0.62
Nodes (5): BaseModel, UserBase, UserCreate, UserRead, UserUpdate

### Community 59 - "test_workflow_edits.py"
Cohesion: 0.26
Nodes (17): CastingUpdateRequest, DepartmentTokenPayload, PackingUpdateRequest, PolishUpdateRequest, BaseModel, RawMaterialUpdateRequest, TurningUpdateRequest, OrderCreate (+9 more)

### Community 60 - "widget_test.dart"
Cohesion: 0.29
Nodes (6): DelayedInMemorySecureStorage, main, read, package:btn_factory/core/storage/secure_storage.dart, package:btn_factory/main.dart, package:flutter_test/flutter_test.dart

### Community 61 - "test_order_tokens_and_delete.py"
Cohesion: 0.29
Nodes (13): CastingUpdate, OrderUpdate, _order_payload(), Deleting an order with process rows must not leave orphans behind., setup_test_db(), test_delete_is_atomic_when_child_rows_exist(), test_delete_only_removes_target_order(), test_deleted_tokens_are_reused_and_editable() (+5 more)

### Community 62 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.15
Nodes (13): appRouterProvider, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets, GitHub Actions Release Workflow, package:btn_factory/core/router/app_router.dart (+5 more)

### Community 63 - "package:flutter/material.dart"
Cohesion: 0.18
Nodes (9): AppTheme, light, build, child, SectionCard, title, trailing, package:flutter/material.dart (+1 more)

### Community 64 - "_buildActionCards"
Cohesion: 0.20
Nodes (10): _buildActionCards, build, Route /analytics, Route /casting, Route /orders/create, Route /packing, Route /polish, Route /raw-material (+2 more)

### Community 65 - "metric_card.dart"
Cohesion: 0.25
Nodes (7): build, icon, MetricCard, tint, title, value, Color

### Community 66 - "_ActionCard"
Cohesion: 0.40
Nodes (6): _ActionCard, _ActionCardState, _NetworkImageLoader, _NetworkImageLoaderState, State, StatefulWidget

### Community 67 - "Cloud Deployment Architecture"
Cohesion: 0.33
Nodes (6): Cloud Deployment Architecture, Render Backend Deployment, Storage & Database Persistence, Vercel Frontend Deployment, Docker Compose Backend Container, Docker Volume backend_data

## Knowledge Gaps
- **322 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+317 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 507 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `routes/auth.py`, `order_service.py`, `main.py`, `orders.py`, `schemas/order.py`, `HTTPException`, `orders_trend`, `Base`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Why does `AuthService` connect `User` to `routes/auth.py`, `order_service.py`, `setup_local_postgres.py`, `main.py`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Why does `Base` connect `Base` to `order_service.py`, `setup_local_postgres.py`, `main.py`, `User`, `OrderService`, `get_settings`, `test_workflow_edits.py`, `test_order_tokens_and_delete.py`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Are the 34 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `delete_universal_raw_material()`) actually correct?**
  _`OrderService` has 34 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 10 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 10 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._