# Graph Report - button_factory  (2026-09-16)

## Corpus Check
- Corpus is ~42,868 words - fits in a single context window. You may not need a graph.

## Summary
- 839 nodes · 1565 edges · 42 communities (32 shown, 10 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 141 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Database Migrations & Analytics Routes
- Windows Flutter Desktop Host
- Department & Raw Material Endpoints
- Backend Authentication & User Management
- App Configuration & Cross-Platform Settings
- iOS Runner & Engine Lifecycle
- Dashboard Overview & Quick Actions
- Department Material Tracking View
- Order Creation & Image Upload
- Linux Desktop Runner & Plugins
- Staff Management & Department Roles
- Multi-Platform Secure Storage Adapters
- Asset Previews & Fallback Graphics
- App Theme & Splash Lifecycle
- User Profile & Department Badges
- Order Queue & List Presentation
- Main Route Screens & Navigation State
- Client-Side Auth State Model
- Reports & Financial Presentation
- Dio HTTP Client & Token Interceptors
- Order Detail View & Status Modals
- Responsive App Shell & Nav Drawer
- Riverpod Auth Controller
- Data Fetching & Material State
- Login Form & Validation UI
- Windows Desktop Entry & Console Utilities
- Protected Route Controller Bindings
- PWA Web Manifest & Assets
- PDF Generation & Export Utilities
- Dashboard Metrics & Summary Chips
- Section Card Reusable Widget
- Analytics Pydantic Data Models
- Android Native Activity Runner
- Dart Utility Extension Types

## God Nodes (most connected - your core abstractions)
1. `OrderService` - 49 edges
2. `User` - 39 edges
3. `Order` - 32 edges
4. `Win32Window` - 24 edges
5. `OrderRepository` - 23 edges
6. `Base` - 22 edges
7. `dioProvider` - 22 edges
8. `authControllerProvider` - 18 edges
9. `ReportService` - 17 edges
10. `RawMaterial` - 14 edges

## Surprising Connections (you probably didn't know these)
- `FastAPI Python Dependencies` --references--> `Settings`  [INFERRED]
  backend/requirements.txt → backend/app/core/config.py
- `delete_user()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/auth.py → btn_factory/lib/core/storage/secure_storage.dart
- `delete_order()` --references--> `delete`  [EXTRACTED]
  backend/app/api/routes/orders.py → btn_factory/lib/core/storage/secure_storage.dart
- `Button Factory MES Specifications` --conceptually_related_to--> `Button Factory MES Overview`  [INFERRED]
  btn_factory/plan-buttonFactoryMes.prompt.md → README.md
- `Storage & Database Persistence` --conceptually_related_to--> `Docker Volume backend_data`  [INFERRED]
  DEPLOYMENT_GUIDE.md → docker-compose.yml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Authentication & Storage Persistence Flow** — backend_app_api_routes_auth_login, btn_factory_lib_core_network_api_client, btn_factory_lib_core_storage_secure_storage, deployment_guide_storage_persistence [INFERRED 0.85]

## Communities (42 total, 10 thin omitted)

### Community 0 - "Database Migrations & Analytics Routes"
Cohesion: 0.06
Nodes (51): dashboard_stats(), orders_trend(), production_trend(), get, Session, Return real-time dashboard metrics computed from the database., Monthly order counts from the database., Per-status breakdown from the database. (+43 more)

### Community 1 - "Windows Flutter Desktop Host"
Cohesion: 0.05
Nodes (59): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+51 more)

### Community 2 - "Department & Raw Material Endpoints"
Cohesion: 0.08
Nodes (54): add_raw_material(), get_universal_raw_materials(), get, post, Session, update_casting(), update_packing(), update_polish() (+46 more)

### Community 3 - "Backend Authentication & User Management"
Cohesion: 0.08
Nodes (38): delete_user(), list_users(), login(), get, post, put, Session, refresh() (+30 more)

### Community 4 - "App Configuration & Cross-Platform Settings"
Cohesion: 0.05
Nodes (41): get_settings(), Settings, FastAPI Python Dependencies, BaseSettings, accessToken, AppConstants, appName, AppStorageKeys (+33 more)

### Community 5 - "iOS Runner & Engine Lifecycle"
Cohesion: 0.06
Nodes (29): Any, AppDelegate, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, Bool (+21 more)

### Community 6 - "Dashboard Overview & Quick Actions"
Cohesion: 0.05
Nodes (38): _submit, _ActionCard, _ActionCardState, _buildActionCards, color, _completedOrders, createState, description (+30 more)

### Community 7 - "Department Material Tracking View"
Cohesion: 0.05
Nodes (38): build, _buildRawMaterialRow, _buildUniversalMaterialSummary, color, createState, currentStatusLabel, description, dispose (+30 more)

### Community 8 - "Order Creation & Image Upload"
Cohesion: 0.06
Nodes (35): _boxType, _buildDateField, _buildDropdown, _buttonImageBytes, _buttonImageName, _castingType, _companyController, createState (+27 more)

### Community 9 - "Linux Desktop Runner & Plugins"
Cohesion: 0.09
Nodes (22): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+14 more)

### Community 10 - "Staff Management & Department Roles"
Cohesion: 0.08
Nodes (25): build, createState, _department, _departments, dispose, _emailController, _error, _formatRole (+17 more)

### Community 11 - "Multi-Platform Secure Storage Adapters"
Cohesion: 0.10
Nodes (22): delete, deleteAll, FlutterSecureStorageAdapter, InMemorySecureStorage, read, SecureStorage, SharedPreferencesStorageAdapter, _storage (+14 more)

### Community 12 - "Asset Previews & Fallback Graphics"
Cohesion: 0.09
Nodes (21): BorderRadius?, BoxFit, borderRadius, build, _buildFallbackGraphic, _buildImageWidget, fit, height (+13 more)

### Community 13 - "App Theme & Splash Lifecycle"
Cohesion: 0.12
Nodes (14): AsyncValue, AppTheme, light, createState, _navigated, build, icon, MetricCard (+6 more)

### Community 14 - "User Profile & Department Badges"
Cohesion: 0.12
Nodes (15): _formatDepartment, _formatRole, icon, label, _ProfileDetailRow, value, build, FeaturePlaceholderPage (+7 more)

### Community 15 - "Order Queue & List Presentation"
Cohesion: 0.12
Nodes (16): buttonImage, companyName, createState, dispose, _error, initState, _isLoading, _OrderRow (+8 more)

### Community 16 - "Main Route Screens & Navigation State"
Cohesion: 0.17
Nodes (16): SplashPage, _SplashPageState, DashboardPage, _DashboardPageState, DepartmentUpdatePage, _DepartmentUpdatePageState, OrderDetailsPage, _OrderDetailsPageState (+8 more)

### Community 17 - "Client-Side Auth State Model"
Cohesion: 0.13
Nodes (14): bool get, accessToken, authenticated, AuthStatus, copyWith, errorMessage, isAuthenticated, loading (+6 more)

### Community 18 - "Reports & Financial Presentation"
Cohesion: 0.13
Nodes (14): build, createState, _error, _formatCount, _formatCurrency, initState, _isLoading, label (+6 more)

### Community 19 - "Dio HTTP Client & Token Interceptors"
Cohesion: 0.15
Nodes (12): dio, storage, main, read, Dio, package:btn_factory/core/constants/app_constants.dart, package:btn_factory/core/storage/secure_storage.dart, package:btn_factory/features/auth/application/auth_controller.dart (+4 more)

### Community 20 - "Order Detail View & Status Modals"
Cohesion: 0.14
Nodes (13): createState, _error, _fetchOrder, _formatDate, _formatDateTime, initState, _isLoading, label (+5 more)

### Community 21 - "Responsive App Shell & Nav Drawer"
Cohesion: 0.15
Nodes (12): activeColor, _buildDepartmentTile, child, _getNavItems, _getRouteForStaticIndex, icon, label, NavItem (+4 more)

### Community 22 - "Riverpod Auth Controller"
Cohesion: 0.20
Nodes (11): AsyncNotifier, secureStorageProvider, AuthController, build, _extractMessage, login, logout, AuthState (+3 more)

### Community 23 - "Data Fetching & Material State"
Cohesion: 0.17
Nodes (12): dioProvider, _fetchDashboard, _fetchOrder, _fetchUniversalMaterials, _submitUpdate, _fetchOrderDetails, _submit, _fetchOrders (+4 more)

### Community 24 - "Login Form & Validation UI"
Cohesion: 0.18
Nodes (11): createState, dispose, _emailController, _formKey, LoginPage, _LoginPageState, _passwordController, _submitting (+3 more)

### Community 25 - "Windows Desktop Entry & Console Utilities"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 26 - "Protected Route Controller Bindings"
Cohesion: 0.22
Nodes (11): authControllerProvider, build, build, ProfilePage, build, build, build, build (+3 more)

### Community 27 - "PWA Web Manifest & Assets"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "PDF Generation & Export Utilities"
Cohesion: 0.22
Nodes (8): _buildSectionHeader, exportOrderPdf, exportReportPdf, PdfExportService, package:intl/intl.dart, package:pdf/pdf.dart, package:pdf/widgets.dart, package:printing/printing.dart

### Community 29 - "Dashboard Metrics & Summary Chips"
Cohesion: 0.22
Nodes (9): _SnapshotChip, _DetailChip, _ReportSummary, _SummaryTile, WidgetBorderStatus, AppImagePreview, AppImagePreviewCard, AppImageUploadCard (+1 more)

### Community 30 - "Section Card Reusable Widget"
Cohesion: 0.29
Nodes (6): build, child, SectionCard, title, trailing, Widget

### Community 31 - "Analytics Pydantic Data Models"
Cohesion: 0.67
Nodes (3): AnalyticsSeries, Point, BaseModel

## Knowledge Gaps
- **275 isolated node(s):** `AppConstants`, `AppStorageKeys`, `appName`, `accessToken`, `refreshToken` (+270 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 403 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `Backend Authentication & User Management` to `Database Migrations & Analytics Routes`, `Department & Raw Material Endpoints`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Why does `AuthController` connect `Riverpod Auth Controller` to `Data Fetching & Material State`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `dioProvider` connect `Data Fetching & Material State` to `Staff Management & Department Roles`, `Main Route Screens & Navigation State`, `Dio HTTP Client & Token Interceptors`, `Order Detail View & Status Modals`, `Riverpod Auth Controller`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Are the 29 inferred relationships involving `OrderService` (e.g. with `add_raw_material()` and `get_universal_raw_materials()`) actually correct?**
  _`OrderService` has 29 INFERRED edges - model-reasoned connections that need verification._
- **Are the 21 inferred relationships involving `User` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`User` has 21 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `Order` (e.g. with `dashboard_stats()` and `orders_trend()`) actually correct?**
  _`Order` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Are the 7 inferred relationships involving `OrderRepository` (e.g. with `CastingProcess` and `Order`) actually correct?**
  _`OrderRepository` has 7 INFERRED edges - model-reasoned connections that need verification._