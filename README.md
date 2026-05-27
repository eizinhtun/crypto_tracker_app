# Crypto Tracker App

Flutter take-home assignment for a cryptocurrency market tracker using
CoinGecko, Clean Architecture, MVVM, offline cache, favorites, and CI.

## Architecture

The app uses Clean Architecture with MVVM in the presentation layer:

```text
View       = pages and widgets
ViewModel  = BLoC-backed classes, events, and states
Model      = domain entities, use cases, repositories, and data sources
```

The presentation layer intentionally uses
`lib/features/crypto/presentation/viewmodels` instead of `presentation/bloc`.
`CoinListViewModel`, `CoinDetailViewModel`, and `FavoriteViewModel` extend
`Bloc` because BLoC is the state-management implementation, but their
architectural role is ViewModel.

Views render state and dispatch events. They do not call Dio, Hive,
repositories, or data sources directly.

See [ARCHITECTURE.md](ARCHITECTURE.md) for dependency direction, offline
strategy, typed Hive persistence, and reviewer notes.

## REST API Strategy

CoinGecko access is isolated in the remote data source behind `DioClient`.
`DioClient` owns base URL, timeouts, API-key headers, debug logging,
retry/backoff for safe GET requests, and HTTP status mapping. The repository
converts app exceptions into failures and decides whether cached data can be
returned.

Handled error cases include bad requests, auth failures, not found, timeouts,
rate limits with `Retry-After`, server failures, and connection errors. Raw
`DioException` messages are not exposed to UI state.

## Dependency Injection

`get_it` is used as the dependency container in `core/di`. App routes compose
ViewModels with `BlocProvider`; pages read ViewModels from `BuildContext`.
Tests can call `resetDependencies()` before registering fakes or mocks.

## Theme Support

The app uses `ThemeMode.system` with warm cream light colors and near-black
dark colors. List/detail cards, labels, price text, badges, and icon buttons use
theme-aware `AppColors` values.

## CI

GitHub Actions runs:

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test --coverage`
- coverage threshold validation
- `flutter build apk --debug`

## Test Coverage

The test suite covers:

- model parsing and explicit DTO-to-entity mapping
- remote data source requests with mocked Dio responses
- local Hive cache records, TTL expiry, schema invalidation, and favorites
- repository offline fallback, cache-source metadata, rate limits, and favorites
- ViewModel search debounce, pagination, offline state, and favorite updates
- architecture boundary rules that prevent presentation/domain layers from
  importing API, persistence, service locator, or data-layer implementations

## API Key

The CoinGecko API key is optional and can be provided with `--dart-define`:

```sh
flutter run \
  --dart-define=COINGECKO_API_KEY=your_key \
  --dart-define=COINGECKO_API_KEY_HEADER=x-cg-demo-api-key
```

## Local Verification

```sh
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter build apk --debug
```
