## Plan: Button Factory MES Rebuild

Build this as a greenfield, production-oriented MES with a FastAPI backend and a Flutter client. The plan assumes the current Flutter starter app will be replaced, and that backend and frontend will be delivered together with a strict backend-owned status engine, role-based access control, and a reusable order/department workflow.

**Steps**
1. Freeze scope and architecture boundaries first: confirm the repo layout for frontend and backend, define the role matrix, define the order lifecycle rules, and lock the API contract for auth, orders, department updates, reports, analytics, and file uploads. This step should also decide what is in MVP versus V2 so the implementation does not drift into inventory, QR, notifications, or other roadmap items too early.
2. Set up the backend foundation: create the FastAPI project structure, settings/config layer, SQLAlchemy models, Alembic migrations, JWT auth, role/department authorization, and repository/service layers. Implement the core entities for users, orders, raw materials, casting, turning, polishing, packing, audit fields, and file metadata. Make PostgreSQL the production target and SQLite the development default.
3. Implement the order status engine in the backend: derive status only from department submissions and order completeness, prevent manual status edits from the client, and persist a clear audit trail. Add validation rules so each department can update only its own data and only when the order is in a valid state for that step.
4. Add backend support services: background tasks for notifications and report generation, document/image storage integration points for Cloudinary and S3, and export-ready endpoints for job cards and production reports. Keep these behind abstractions so deployment target differences do not leak into business logic.
5. Replace the Flutter starter app with the real app shell: add Riverpod, GoRouter, Dio, and Flutter Secure Storage; build app bootstrap, JWT check on splash, login flow, authenticated route guards, and a consistent theme/layout system. This should be the first frontend milestone after the backend contract is stable.
6. Build the Flutter MES feature modules in layers: dashboard, order list/search/filter, order create/edit using shared form widgets, order details, and department-specific screens for raw material, casting, turning, polish, and packing. Reuse the same form primitives for create and edit, especially for date pickers, dropdowns, radios, and image uploads.
7. Add the admin visibility layer: dashboard cards, analytics charts, reports screens, production summaries, rejection analysis, revenue reporting, job card download, and staff management screens. Ensure admin-only routes and actions are enforced both in the UI and by backend authorization.
8. Add quality and release infrastructure: automated tests for auth, order workflow, status transitions, and department permissions; widget tests for the main Flutter flows; seed data for local development; Docker-based local startup; and deployment configuration for the chosen cloud target. Finish with end-to-end validation against the full order journey from order creation to dispatch.

**Relevant files**
- /Users/User/Desktop/button_factory/btn_factory/pubspec.yaml — replace starter dependencies with Flutter app dependencies for Riverpod, GoRouter, Dio, and Secure Storage.
- /Users/User/Desktop/button_factory/btn_factory/lib/main.dart — replace the counter app with the bootstrap, routing, and authenticated app shell.
- /Users/User/Desktop/button_factory/btn_factory/test/widget_test.dart — update or replace the starter widget test with coverage for the real landing/auth flow.
- backend/app/main.py — FastAPI entrypoint for routers, middleware, and startup wiring.
- backend/app/core/config.py — environment and settings management for DB, auth, storage, and cloud providers.
- backend/app/models/* — SQLAlchemy models for users, orders, and all process tables.
- backend/app/schemas/* — Pydantic request and response models.
- backend/app/api/routes/* — auth, orders, department, reports, and analytics endpoints.
- backend/app/services/* — status engine, workflow rules, report generation, and background task orchestration.
- backend/alembic/* — database migrations and schema versioning.
- backend/tests/* — backend test coverage for auth, RBAC, workflow transitions, and API contracts.
- lib/core/* and lib/features/* — planned Flutter feature structure for auth, dashboard, orders, department screens, reports, and shared widgets.

**Verification**
1. Run backend tests for auth, RBAC, order creation, department updates, and status transition rules once the backend is scaffolded.
2. Run Flutter analyzer and widget tests after replacing the starter app to catch routing, state, and form issues early.
3. Validate the order lifecycle end to end with a seeded user set covering Super Admin, Raw Material, Casting, Turning, Polish, and Packing.
4. Verify SQLite local startup and PostgreSQL migration compatibility before deployment work begins.
5. Confirm that manual status mutation is impossible from the API and that status changes only occur from department submissions.
6. Exercise file upload and export flows for PO images, button images, and job card/report downloads.

**Sprint Test Discipline**
- After every sprint, run the full test set for the scope touched in that sprint before moving to the next sprint.
- Treat failures as blocking defects: fix them immediately, rerun the same tests, and only then continue.
- Cover normal flows, invalid inputs, permission boundaries, missing required fields, duplicate submissions, empty states, and status-transition edge cases.
- Add tests for any bug found during development so the issue cannot recur silently in later sprints.
- Keep each sprint definition of done tied to passing tests, not just implemented screens or endpoints.
- Use backend tests for workflow, authorization, validation, and persistence behavior; use Flutter tests for routing, forms, state, and conditional UI behavior.

**Decisions**
- Treat the current repository as a greenfield rebuild rather than a refactor of an existing MES.
- Keep status progression backend-owned and derived from workflow events, not editable from the UI.
- Prioritize the production order and department workflow first, then reports and analytics, then release engineering.
- Exclude V2 items such as inventory, QR scanning, and notifications from the initial implementation plan except for backend extension points.

**Further Considerations**
1. Decide whether the backend should live inside this workspace as a sibling folder or in a separate repository. Recommendation: keep both in one workspace if you want faster coordinated development and shared planning.
2. Confirm whether admin is allowed to override any workflow state for exceptional cases. Recommendation: default to no override, with a tightly audited escape hatch only if operations require it.
3. Confirm whether mobile-first Flutter is the only client for MVP or whether a web admin experience is also expected. Recommendation: build the Flutter app responsively so it can serve both mobile and desktop/tablet admin usage without a separate front end.