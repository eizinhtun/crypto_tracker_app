# Crypto Tracker App

A production-oriented Flutter take-home assignment for tracking cryptocurrency
markets with CoinGecko. The app uses Clean Architecture, MVVM with BLoC-backed
ViewModels, local Hive persistence, offline cache fallback, favorites, system
theme support, English/Myanmar language switching, tests, and GitHub Actions CI.

## Features

- Global market cap and 24h volume summary.
- Trending coins from CoinGecko.
- Paginated cryptocurrency markets list with infinite scroll.
- Pull to refresh.
- Search by coin name/symbol.
- Coin detail screen with rank, price, 24h change, market cap, volume, ATH,
  ATL, circulating supply, max supply, description, and source link.
- Mark/unmark favorites with Hive persistence.
- Cached offline responses for markets, trending, global market, and detail.
- Loading, error, empty, and offline states.
- Light/dark theme via `ThemeMode.system`.
- English/Myanmar in-app language toggle.

## Screenshots

Screenshots are not included in this repository yet. Add light and dark mode
screenshots here before publishing a recruiter-facing or store-facing build.

## Tech Stack

- Flutter
- `flutter_bloc` as the ViewModel/state-management implementation
- Dio for REST API calls
- Hive for local cache and favorites
- get_it for dependency injection
- go_router for navigation
- Flutter localization delegates with app-owned typed localization access
- bloc_test, mocktail, and flutter_test for tests
- GitHub Actions for CI

## Architecture

The project follows Clean Architecture:

```text
presentation -> domain -> data/core infrastructure
```

- `presentation`: pages, widgets, BLoC-backed ViewModels, events, states.
- `domain`: entities, repository interfaces, use cases.
- `data`: models/DTOs, remote/local data sources, repository implementation.
- `core`: network, errors/results, database, DI, theme, localization, utils.

Dependency direction is enforced by tests. UI does not call Dio or Hive.
ViewModels call use cases only. Use cases depend on repository interfaces. The
repository implementation coordinates remote and local data sources.

## MVVM Mapping

```text
View       = Flutter pages and widgets
ViewModel  = BLoC classes in presentation/viewmodels
Model      = domain entities plus data models/DTOs
```

BLoC is intentionally used as the ViewModel layer. Each ViewModel receives UI
events, exposes immutable UI state, calls domain use cases, and maps domain
results into renderable loading/success/error/offline states. No duplicate
ViewModel classes are needed.

See [ARCHITECTURE.md](ARCHITECTURE.md) for deeper reviewer notes.

## REST API Strategy

CoinGecko integration is isolated in `CryptoRemoteDataSource` behind
`DioClient`. Implemented endpoints include:

- `/coins/markets`
- `/global`
- `/search/trending`
- `/coins/{id}`
- `/search` followed by `/coins/markets?ids=...` for submitted search rows with
  live price, market cap, and 24h change

`DioClient` owns:

- base URL and timeout configuration;
- JSON accept headers;
- debug-only logging;
- retry/backoff for GET requests on 429 and transient server/network failures;
- structured mapping for 400, 401/403, 404, 408/timeouts, 429, 500+, and
  connection errors.

Raw `DioException` messages are not exposed directly to UI state.

## Security Considerations

- CoinGecko Free API is used without an API key.
- No API keys, tokens, or secrets are hardcoded.
- API communication uses HTTPS through the centralized CoinGecko base URL.
- Dio logging is enabled only in debug mode and does not log headers or bodies.
- Network errors are mapped to user-friendly messages.
- Hive stores only non-sensitive public market cache and favorite coin IDs.
- Duplicate requests are prevented to reduce unnecessary traffic and rate-limit
  issues.
- For production apps with authentication, secure storage and stronger runtime
  protections would be considered.

## Offline Cache

Successful API responses are cached in typed Hive records:

- coin market pages;
- global market data;
- trending coins;
- coin detail responses;
- favorites in a separate boolean box keyed by coin id.

When the remote request fails or the device is offline, the repository returns
cached data if available and marks the result as `ResultSource.cache`. ViewModels
translate required list/detail cache into `isOffline` and any cached overview
fallback into `hasCachedData`, so the UI can show cached-data messaging without
mislabeling every optional fallback as offline. Expired cache is invalidated on
normal reads, but stale cache is allowed only as an explicit offline/failure
fallback.

## Dependency Injection

`get_it` is configured once in `main()` after Hive initialization.
`app_router.dart` is the composition boundary for feature ViewModels through
`BlocProvider`. Tests can call `resetDependencies()` to clear GetIt safely.

## Navigation

`go_router` is used for list-to-detail navigation. The list uses `pushNamed` so
normal back navigation works. The detail top bar uses `context.pop()` when
possible and falls back to `context.goNamed(AppRouteNames.home)` when the detail
route is the first page.

## Theme And Localization

The app uses warm cream light colors and near-black dark colors with
theme-aware text, borders, cards, and positive/negative market colors. The
detail page uses a custom top row, large price header, two-column stat cards,
uppercase section labels, and premium spacing.

Localization supports English and Myanmar. User-facing labels for search,
retry, no-data, offline, market stats, about, favorites, and loading/error
states are centralized in `core/localization` and mirrored in ARB files. The
selected locale is persisted in Hive so language choice survives restart.

## Testing Strategy

Tests do not call the real CoinGecko API. Coverage includes:

- model parsing from CoinGecko JSON;
- coin detail parsing for `total_volume.usd`, `ath.usd`,
  `ath_change_percentage.usd`, `atl.usd`, `atl_change_percentage.usd`,
  `circulating_supply`, and `max_supply`;
- remote datasource success/error parsing with mocked Dio adapter;
- 429 rate-limit and 500 server mapping;
- repository cache fallback and cache metadata;
- Hive cache/favorite persistence;
- list/detail ViewModel states;
- detail retry from first-load failure;
- localization fallback;
- architecture boundary rules.

Test names use BDD-style `Given ..., when ..., then ...` phrasing where
practical.

## CI/CD

GitHub Actions runs on pushes and pull requests to `main`:

```sh
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Setup

```sh
flutter pub get
flutter run
```

## Local Verification

```sh
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## AI-Assisted Development Note

AI assistance was used as a technical reviewer and implementation aid. Final
architecture decisions, code changes, and verification were validated through
the analyzer and automated tests.
