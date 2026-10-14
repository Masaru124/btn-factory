# Graph Report - btn-factory  (2026-10-14)

## Corpus Check
- 119 files · ~53,732 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 994 nodes · 1900 edges · 64 communities (48 shown, 6 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 173 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a39b2eb2`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- routes/auth.py
- Win32Window
- schemas/order.py
- setup_local_postgres.py
- app_router.dart
- GeneratedPluginRegistrant.swift
- dashboard_page.dart
- department_update_page.dart
- order_form_page.dart
- my_application.cc
- staff_page.dart
- secure_storage.dart
- custom_http_exception_handler
- InMemoryFallbackCache
- app_scaffold.dart
- order_list_page.dart
- authControllerProvider
- profile_page.dart
- reports_page.dart
- auth_state.dart
- order_details_page.dart
- dioProvider
- StatelessWidget
- login_page.dart
- _buildActionCards
- wWinMain
- pdf_export_service.dart
- manifest.json
- Order
- Base
- feature_placeholder_page.dart
- schemas/analytics.py
- MainActivity.kt
- String?
- package:flutter/material.dart
- OrderService
- rules/graphify.md
- workflows/graphify.md
- README.md
- main.py
- orders.py
- package:flutter_riverpod/flutter_riverpod.dart
- auth_controller.dart
- OrderStatus
- app_constants.dart
- get_settings
- routes/reports.py
- User
- schemas/__init__.py
- departments.py
- widget_test.dart
- api_client.dart
- Cloud Deployment Architecture
- repositories/user.py

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 63 edges
2. `User` - 41 edges
3. `Order` - 35 edges
4. `Base` - 34 edges
5. `OrderRepository` - 27 edges
6. `dioProvider` - 25 edges
7. `Win32Window` - 24 edges
8. `authControllerProvider` - 18 edges
9. `OrderCreate` - 17 edges
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

## Communities (64 total, 6 thin omitted)

### Community 0 - "routes/auth.py"
Cohesion: 0.27
Nodes (17): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+9 more)

### Community 1 - "Win32Window"
Cohesion: 0.05
Nodes (58): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+50 more)

### Community 2 - "schemas/order.py"
Cohesion: 0.13
Nodes (31): UniversalRawMaterial, CastingUpdateRequest, DepartmentTokenPayload, PackingUpdateRequest, PolishUpdateRequest, BaseModel, RawMaterialUpdateRequest, TurningUpdateRequest (+23 more)

### Community 3 - "setup_local_postgres.py"
Cohesion: 0.07
Nodes (29): normalize_database_url(), Normalize PostgreSQL connection URLs to work with whichever driver is installed…, set_sqlite_pragma(), Ensure all columns defined in SQLAlchemy models exist in the target database.…, sync_database_schema(), BackupService, Sync schema and data from local database to a PostgreSQL target (Local Postgres…, Sync schema and data from local database to on-premises Local PostgreSQL. (+21 more)

### Community 4 - "app_router.dart"
Cohesion: 0.13
Nodes (14): authState, authStateVal, GoRouter, package:btn_factory/features/auth/presentation/login_page.dart, package:btn_factory/features/auth/presentation/profile_page.dart, package:btn_factory/features/auth/presentation/splash_page.dart, package:btn_factory/features/dashboard/presentation/dashboard_page.dart, package:btn_factory/features/departments/presentation/department_update_page.dart (+6 more)

### Community 5 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (30): AppDelegate, Any, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+22 more)

### Community 6 - "dashboard_page.dart"
Cohesion: 0.05
Nodes (43): BorderRadius?, BoxFit, _ActionCard, _ActionCardState, color, _completedOrders, createState, description (+35 more)

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
Cohesion: 0.16
Nodes (14): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+6 more)

### Community 12 - "custom_http_exception_handler"
Cohesion: 0.28
Nodes (9): custom_http_exception_handler(), Request, trace_and_timing_middleware(), unhandled_exception_handler(), Exception, exception_handler, JSONResponse, middleware (+1 more)

### Community 13 - "InMemoryFallbackCache"
Cohesion: 0.10
Nodes (8): InMemoryFallbackCache, Any, A thread-safe in-memory cache with TTL expiration fallback when Redis is not…, Idempotency key check: Prevents duplicate double-tap writes from tablets.…, Fixed window rate limiting., Returns True if this is the first submission, False if duplicate within TTL., Simple fixed window rate limiter. Returns True if allowed, False if exceeded., RedisClient

### Community 14 - "app_scaffold.dart"
Cohesion: 0.12
Nodes (15): ProfilePage, activeColor, AppScaffold, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon (+7 more)

### Community 15 - "order_list_page.dart"
Cohesion: 0.11
Nodes (18): buttonImage, companyName, createState, _deletingToken, dispose, _error, initState, _isLoading (+10 more)

### Community 16 - "authControllerProvider"
Cohesion: 0.12
Nodes (25): authControllerProvider, build, _submit, SplashPage, _SplashPageState, build, DashboardPage, _DashboardPageState (+17 more)

### Community 17 - "profile_page.dart"
Cohesion: 0.13
Nodes (15): AsyncValue, build, _formatDepartment, _formatRole, icon, label, value, build (+7 more)

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

### Community 22 - "StatelessWidget"
Cohesion: 0.12
Nodes (16): _ProfileDetailRow, _SnapshotChip, _DetailChip, _ReportSummary, _SummaryTile, WidgetBorderStatus, AppImagePreview, AppImagePreviewCard (+8 more)

### Community 23 - "login_page.dart"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 24 - "_buildActionCards"
Cohesion: 0.15
Nodes (14): _buildActionCards, build, build, Route /analytics, Route /casting, Route /orders, Route /orders/create, Route /packing (+6 more)

### Community 25 - "wWinMain"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 26 - "pdf_export_service.dart"
Cohesion: 0.18
Nodes (10): _buildBlankingTable, _buildCastingTable, _buildSectionHeader, exportOrderPdf, exportReportPdf, PdfExportService, package:intl/intl.dart, package:pdf/pdf.dart (+2 more)

### Community 27 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "Order"
Cohesion: 0.13
Nodes (15): BlankingProcess, CastingProcess, Order, PackingProcess, PolishingProcess, Persistent monotonic order-token sequence (1001, 1002, ...). Stored in the…, RawMaterial, TokenCounter (+7 more)

### Community 29 - "Base"
Cohesion: 0.21
Nodes (9): Base, str, UserRole, Automated Multi-Tier Database Backup & Disaster Recovery Sync Service.…, main(), run_seed(), DateTime?, DeclarativeBase (+1 more)

### Community 30 - "feature_placeholder_page.dart"
Cohesion: 0.25
Nodes (7): build, FeaturePlaceholderPage, icon, selectedIndex, subtitle, title, package:btn_factory/shared/widgets/app_scaffold.dart

### Community 31 - "schemas/analytics.py"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

### Community 42 - "package:flutter/material.dart"
Cohesion: 0.17
Nodes (10): AppTheme, light, build, icon, MetricCard, tint, title, value (+2 more)

### Community 43 - "OrderService"
Cohesion: 0.20
Nodes (16): CastingUpdate, OrderCreate, OrderUpdate, OrderService, Session, _order_payload(), Deleting an order with process rows must not leave orphans behind., setup_test_db() (+8 more)

### Community 49 - "main.py"
Cohesion: 0.15
Nodes (12): create_access_token(), create_refresh_token(), get_password_hash(), verify_password(), health_check(), on_startup(), get, AuthService (+4 more)

### Community 50 - "orders.py"
Cohesion: 0.24
Nodes (14): create_order(), delete_order(), dispatch_order(), get_next_token(), get_order(), list_orders(), get, post (+6 more)

### Community 51 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.15
Nodes (13): appRouterProvider, build, ButtonFactoryApp, main, Button Factory MES Specifications, Flutter App Manifest & Assets, GitHub Actions Release Workflow, package:btn_factory/core/router/app_router.dart (+5 more)

### Community 52 - "auth_controller.dart"
Cohesion: 0.18
Nodes (12): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+4 more)

### Community 53 - "OrderStatus"
Cohesion: 0.16
Nodes (14): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+6 more)

### Community 54 - "app_constants.dart"
Cohesion: 0.18
Nodes (10): accessToken, AppConstants, appName, AppStorageKeys, refreshToken, userDepartment, userEmail, userName (+2 more)

### Community 55 - "get_settings"
Cohesion: 0.09
Nodes (26): get_database_diagnostics(), get, Database diagnostics and health status endpoint., Run connection & latency tests across all 3 configured database tiers., post, Accepts an image file upload, optimizes it to WebP format, generates a…, upload_media(), get_settings() (+18 more)

### Community 56 - "routes/reports.py"
Cohesion: 0.27
Nodes (10): production_report(), get, post, Session, reports_summary(), revenue_report(), DateRangeRequest, MetricValue (+2 more)

### Community 57 - "User"
Cohesion: 0.31
Nodes (4): User, Session, UserRepository, Session

### Community 58 - "schemas/__init__.py"
Cohesion: 0.62
Nodes (5): BaseModel, UserBase, UserCreate, UserRead, UserUpdate

### Community 59 - "departments.py"
Cohesion: 0.22
Nodes (18): add_raw_material(), get_universal_raw_materials(), get, post, Session, update_blanking(), update_casting(), update_packing() (+10 more)

### Community 60 - "widget_test.dart"
Cohesion: 0.29
Nodes (6): DelayedInMemorySecureStorage, main, read, package:btn_factory/core/storage/secure_storage.dart, package:btn_factory/main.dart, package:flutter_test/flutter_test.dart

### Community 61 - "api_client.dart"
Cohesion: 0.29
Nodes (6): dio, storage, dart:async, Dio, package:flutter/foundation.dart, return

### Community 62 - "Cloud Deployment Architecture"
Cohesion: 0.33
Nodes (6): Cloud Deployment Architecture, Render Backend Deployment, Storage & Database Persistence, Vercel Frontend Deployment, Docker Compose Backend Container, Docker Volume backend_data

## Knowledge Gaps
- **285 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+280 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 468 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `get_settings()` connect `get_settings` to `main.py`, `InMemoryFallbackCache`, `setup_local_postgres.py`, `Base`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Why does `User` connect `User` to `routes/auth.py`, `main.py`, `orders.py`, `OrderStatus`, `departments.py`, `Order`, `Base`, `repositories/user.py`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Why does `Base` connect `Base` to `schemas/order.py`, `setup_local_postgres.py`, `OrderService`, `main.py`, `User`, `Order`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **Are the 33 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `get_universal_raw_materials()`) actually correct?**
  _`OrderService` has 33 INFERRED edges - model-reasoned connections that need verification._
- **Are the 23 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 23 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Are the 9 inferred relationships involving `Base` (e.g. with `sync_database_schema()` and `on_startup()`) actually correct?**
  _`Base` has 9 INFERRED edges - model-reasoned connections that need verification._