# Copilot instructions for astor_mobile

This file gives concise, actionable guidance for an AI coding agent working on this Flutter app.

- **Project Type:** Flutter mobile/web app (Dart 3+, Flutter). See `pubspec.yaml` for deps.
- **Entry point:** `lib/main.dart` — app uses `MultiProvider` and `AstorProvider` to load `AstorApp`.

- **Big-picture architecture:**
  - UI: Flutter widgets under `lib/` (notably `lib/astorScreen.dart` and `lib/json_textform/*` for dynamic JSON-driven forms).
  - State: `lib/model/AstorProvider.dart` (a `ChangeNotifier`) holds `futureAstorApp`, `astorApp`, and exposes `doAction`, `subscribe`, and other flows.
  - Network layer: `lib/http/astorHttp.dart` defines `AstorWebHttp` interface; platform-specific implementations live in `lib/http/httpPhone.dart`, `lib/http/httpJs.dart`, and `lib/http/httpStub.dart` (conditional imports used). Use these for tracing HTTP and socket/push flows.
  - Schema & forms: `lib/model/astorSchema.dart` defines the AST the UI renders. The JSON-driven form system is in `lib/json_textform` and `lib/json_schema_form.dart`.

- **Key patterns & conventions (project-specific):**
  - Backend contract: endpoints and actions use verbs like `do-...` (e.g., `/mobile-do`) and rely on a `mainForm` map carrying `dg_*` fields. Look for `dg_` prefixes across `AstorProvider`.
  - Async flow: network calls return `Future<AstorApp>` and are assigned to `AstorProvider.futureAstorApp`; `AstorPage` uses `FutureBuilder` to wait on it. Changing `futureAstorApp` or `redraw` triggers UI updates.
  - Platform branching: `kIsWeb` toggles base URL selection in `AstorProvider` (reads `assets/config.env` via `flutter_dotenv`). To change base URL, edit `assets/config.env` (`URL` / `LOCAL_URL`).
  - Conditional imports: `astorHttp.dart` uses conditional imports to route to appropriate HTTP implementation — inspect these files to debug networking.
  - Naming / language: many symbols and comments are Spanish-like (e.g., `dg_request`, `do-`) — expect Spanish variable names and strings.

- **Developer workflows & commands (how to run/test locally):**
  - Install deps and run on default device:

```powershell
flutter pub get; flutter run
```

  - Run for web (uses `LOCAL_URL`):

```powershell
flutter pub get; flutter run -d chrome
```

  - Build for Android/iOS:

```powershell
flutter build apk
flutter build ios
```

  - Ensure `assets/config.env` exists and has `URL` (mobile) and `LOCAL_URL` (web) keys before running.

- **What to inspect when debugging a feature or bug:**
  - Network/API: start with `lib/http/astorHttp.dart` and the concrete implementations in `lib/http/` to see request/response parsing.
  - State lifecycle: `lib/model/AstorProvider.dart` — methods `doAction`, `doDiferido`, `firstAction`, and `processResponse` control app updates.
  - Dynamic UI generation: `lib/json_textform` and `lib/json_schema_form.dart` — these files contain the renderer and components used to render backend-driven forms.
  - Push notifications: `lib/json_textform/utils-components/pushNotification.dart` and code paths that call `subscribe()` in `AstorProvider`.

- **Safe edit guidelines for AI agents:**
  - Prefer minimal, focused changes. Touch `AstorProvider` or `astorHttp` only when necessary — they're central to app behavior.
  - When changing network URLs, update `assets/config.env` or use `kIsWeb` aware code paths; do not hardcode URLs in multiple files.
  - Preserve the `mainForm` param structure and `dg_` keys when creating or modifying requests — backend expects those fields.

- **Files to reference for examples and patterns:**
  - `lib/main.dart` — app boot and provider wiring.
  - `lib/model/AstorProvider.dart` — core state, network orchestration, and request param construction.
  - `lib/http/astorHttp.dart` and `lib/http/httpPhone.dart`/`httpJs.dart`/`httpStub.dart` — network abstractions and platform-specific behavior.
  - `lib/json_textform/` — custom JSON-driven form components and controllers.

If anything in this guide is unclear or you want deeper coverage (e.g., example pull-request templates or unit-test patterns), tell me which area to expand. 
