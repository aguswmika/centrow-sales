# CLAUDE.md

Guidance for AI coding agents working in this repository. Follow these rules when
generating or modifying code.

## Mandatory tooling

- **CodeGraph is required.** If `.codegraph/` exists at the repo root, you MUST use
  `codegraph_explore` (MCP) or `codegraph explore "<query>"` (shell) BEFORE grep, find, or
  reading files to locate or understand code. Do not fall back to manual grep/read
  exploration unless CodeGraph has no answer or `.codegraph/` doesn't exist.
- **RTK is required.** Every shell command MUST be prefixed with `rtk` (e.g. `rtk git status`,
  `rtk flutter analyze`, `rtk grep <pattern>`), including each command in a `&&` chain. RTK is
  always safe to use — it applies a dedicated filter when one exists, or passes the command
  through unchanged otherwise. Do not run raw/unprefixed shell commands.

## Project overview

A Flutter mobile app using a **layered architecture** with **Signals** for state
management. Data flows in one direction:

```
View  ──►  Controller  ──►  Repository  ──►  (Dio / API)
             │                 │
             ▼                 ▼
         (Signals)          Entity  ◄── mapped from DTO
```

**Tech stack:** Flutter, `signals`, `get_it` (DI), `dio` (HTTP), `go_router` (routing).

## The golden rule

Dependencies point **inward only**: `View → Controller → Repository → Entity`.
An inner layer must never know about an outer layer.

- Entity knows nothing about Repository, Controller, or Flutter.
- Repository knows nothing about Controller or widgets.
- Controller knows nothing about widgets.
- View may depend on Controller, never on Repository or Dio directly.

If an import points "outward" (e.g. an entity importing `signals` or `flutter`),
it is wrong — restructure instead.

## Directory structure

Module-first. Each ERP module (`core`, `sales`, dll.) has exactly four layer sub-folders.

```
lib/
├── main.dart
├── app/
│   ├── app.dart            # MaterialApp + router
│   ├── di.dart             # get_it service locator
│   └── router.dart         # go_router config
├── shared/
│   ├── config/             # app config (base url, env)
│   ├── theme/              # theme config (app theme (default), colors, spacing, radius, typography, etc.)
│   ├── error/failure.dart  # sealed Failure
│   ├── result/result.dart  # sealed Result<T> (Ok / Err)
│   ├── state/ui_state.dart # sealed UiState<T>
│   ├── network/            # dio_client + interceptors
│   └── widgets/            # shared widgets (ErrorView, etc.)
└── modules/
    ├── core/               # auth + user session (cross-cutting)
    │   ├── entities/
    │   ├── repositories/
    │   │   └── dtos/
    │   ├── controllers/
    │   └── views/
    │       ├── pages/
    │       └── widgets/
    └── sales/                 # Human Resources module
        ├── entities/
        ├── repositories/
        │   └── dtos/
        ├── controllers/
        └── views/
            ├── pages/
            └── widgets/
```

`shared/` dan `app/` dipakai lintas modul. Widget yang dipakai lebih dari satu modul naik ke `shared/widgets/`.

## Layer rules

### Entity (`entities/`)
- Pure Dart, immutable. No serialization logic, no `fromJson`/`toJson`.
- May import Dart only. **Never** import `flutter`, `dio`, or `signals`.

### Repository (`repositories/`)
- The **impl** holds `Dio` directly — it performs the request, parses JSON, maps
  DTO → Entity, and translates errors. There is **no separate DataSource layer**.
- This is the **only** layer allowed to use `try/catch`.
- Every method returns `Future<Result<T>>` — it **never throws** to the caller.
- Translate technical errors (e.g. `DioException`) into a `Failure` and return `Err`.
- JSON is only ever touched inside `dtos/`. Outer layers only see Entities.

```dart
class ProductRepository implements ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final res = await _dio.get('/products');
      final list = (res.data['data'] as List).cast<Map<String, dynamic>>();
      return Ok(list.map(ProductDto.fromJson).map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
```

> Only add abstraction (cache, alternate sources) when a real second source
> appears. Until then, Dio lives directly in the repository.

### Controller (`controllers/`)
- Holds state via signals and orchestrates repository calls.
- Import `package:signals/signals.dart` (core, pure Dart) — **not**
  `signals_flutter.dart`. This keeps controllers UI-free and unit-testable.
- Keep the writable `Signal` **private**; expose a `ReadonlySignal` getter to the View.
- Expose **intents** as verb methods (`loadProducts`, `refresh`, `submit`).
- No `try/catch` — pattern-match the `Result` returned by the repository.
- Provide a `dispose()` that disposes every signal/computed it owns.

```dart
class ProductController {
  final ProductRepository _repository;
  ProductController(this._repository);

  final _state = signal<UiState<List<Product>>>(const UiInitial());
  ReadonlySignal<UiState<List<Product>>> get state => _state;

  Future<void> loadProducts() async {
    _state.value = const UiLoading();
    final result = await _repository.getProducts();
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void dispose() => _state.dispose();
}
```

### View (`views/`)
- Import `package:signals/signals_flutter.dart`.
- Wrap **only** the reactive part in `SignalBuilder` for surgical rebuilds — never the
  whole subtree.
- The page **owns** its controller: resolve it from `get_it`, trigger the initial
  load in `initState`, and call `controller.dispose()` in `dispose`.
- Render state with an exhaustive `switch` over `UiState`.

```dart
late final _controller = getIt<ProductController>();

@override
void initState() { super.initState(); _controller.loadProducts(); }

@override
void dispose() { _controller.dispose(); super.dispose(); }

// in build:
SignalBuilder(builder: (context) {
  return switch (_controller.state.value) {
    UiInitial() || UiLoading() => const Center(child: CircularProgressIndicator()),
    UiFailure(:final failure) => ErrorView(message: failure.message, onRetry: _controller.loadProducts),
    UiSuccess(:final data) => ListView(...),
  };
});
```

## Signals rules

- **Never** create a signal (`signal()`, `computed()`) inside `build()` — it makes
  a new instance on every rebuild.
- Controllers use core signals; Views use `signals_flutter`.
- Private writable `Signal` in the controller, public `ReadonlySignal` to the View.
- Use `computed()` for derived state; it recomputes only when dependencies change.
- Use `effect()` for side effects (logging, analytics, persistence) and dispose the
  returned cleanup.
- Use `batch()` to group multiple writes into a single rebuild.
- Always `dispose()` controller-owned signals.
- `Watch` is deprecated — use `SignalBuilder` (from `signals_flutter`). `SignalWidget` was removed — do not reintroduce either.

## Error handling

- `Result<T>` is `sealed` with `Ok<T>(value)` and `Err<T>(failure)`. Repositories
  return it.
- `Failure` is `sealed`: `NetworkFailure`, `ServerFailure`, `CacheFailure`,
  `UnknownFailure`. Repositories produce these from raw exceptions.
- `UiState<T>` is `sealed`: `UiInitial`, `UiLoading`, `UiSuccess(data)`,
  `UiFailure(failure)`. Controllers hold it; Views render it.
- Prefer exhaustive `switch` expressions over `if`/`is` chains so new cases fail
  the compiler.

## Naming conventions

- Entity: singular noun — `Product`.
- DTO: `ProductDto`.
- Repository: `ProductRepository`.
- Controller: `ProductController`.
- Page: `ProductListPage`, `ProductDetailPage`.
- Controller intents: verbs — `loadProducts`, `refresh`, `submitOrder`.
- Files: `snake_case.dart` matching the class name.

## Dependency injection (`app/di.dart`)

Register from inner to outer: `Dio → Repository → Controller`.

- `Dio` and repositories: `registerLazySingleton`.
- Controllers: `registerFactory` (a fresh instance per page, since the page owns
  and disposes it).
- Register repositories under their **interface** type, not the `Impl`.

```dart
getIt.registerLazySingleton<Dio>(createDio);
getIt.registerLazySingleton<ProductRepository>(() => ProductRepository(getIt<Dio>()));
getIt.registerFactory<ProductController>(() => ProductController(getIt<ProductRepository>()));
```

> If state must persist across pages (e.g. cart, session), register that controller
> as a `lazySingleton` and do **not** dispose it in a page.

## Adding a new feature (checklist)

1. Determine the module (`modules/core/`, `modules/sales/`, or a new module).
2. Add the files to the appropriate layer within that module:
  - `entities/<name>.dart` — pure Dart entity
  - `repositories/<name>_repository.dart` — interface + implementation (holds Dio)
  - `repositories/dtos/<name>_dto.dart` — DTO + `toEntity()`
  - `controllers/<name>_controller.dart` — signals + intents
  - `views/pages/<name>_page.dart` — StatefulWidget
3. Register it in `app/di.dart`.
4. Add the route in `app/router.dart`.


## Do / Don't

**Do**
- Keep imports pointing inward.
- Return `Result` from repositories; pattern-match it in controllers.
- Expose `ReadonlySignal` from controllers.
- Wrap only reactive widgets in `Watch`.
- Dispose controllers and their signals.

**Don't**
- Don't put `try/catch` outside repository impls.
- Don't touch JSON outside `dtos/`.
- Don't create signals in `build()`.
- Don't import `signals_flutter.dart` in controllers.
- Don't let Views call repositories or Dio directly.
- Don't add a DataSource layer unless a second data source genuinely exists.

## Commands

```bash
flutter pub get          # install dependencies
flutter run              # run the app
flutter analyze          # static analysis (must pass clean)
dart format .            # format before committing
```

> Testing conventions are not defined yet — skip test generation until they are
> added to this file.
