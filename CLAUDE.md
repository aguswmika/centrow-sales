# CLAUDE.md

Guidance for AI coding agents working in this repository. Follow these rules when
generating or modifying code.

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

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (60-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk go test             # Go test failures only (90%)
rtk jest                # Jest failures only (99.5%)
rtk vitest              # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk pytest              # Python test failures only (90%)
rtk rake test           # Ruby test failures only (90%)
rtk rspec               # RSpec test failures only (60%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
rtk uv run <cmd>        # Compact uv project command output
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%). Format flags (-c, -l, -L, -o, -Z) run raw.
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->