# Architecture

This project follows Clean Architecture with MVVM in the presentation layer.
The implementation uses BLoC for state management, Dio for REST API access,
Hive for local persistence, and get_it for dependency injection.

## MVVM Mapping

Flutter's architecture guide describes a ViewModel as the layer that exposes
state to the View and handles user interaction by coordinating application
logic. In this project, each BLoC-backed class in
`lib/features/crypto/presentation/viewmodels` is the ViewModel.

```text
View       = pages and widgets
ViewModel  = BLoC + Event + State
Model      = domain entities, use cases, repositories, and data sources
```

- View: `lib/features/crypto/presentation/pages` and
  `lib/features/crypto/presentation/widgets`.
- ViewModel: `CoinListViewModel`, `CoinDetailViewModel`, and
  `FavoriteViewModel`.
- Model: domain entities, repository contracts, repository implementations,
  remote data sources, local data sources, and DTOs.

The source tree intentionally uses `presentation/viewmodels` instead of
`presentation/bloc`, and the classes are named `*ViewModel` rather than
`*Bloc`. They still extend `Bloc` because BLoC is the chosen state-management
mechanism for the ViewModel layer.

The BLoC package is an implementation detail of the ViewModel layer. ViewModels:

- expose immutable UI state;
- receive UI events from pages and widgets;
- call domain use cases;
- translate domain results into renderable state;
- own UI orchestration such as search debounce, pagination decisions, loading
  state, error state, and offline indicators.

Pages and widgets do not call repositories, Dio, Hive, or data sources directly.
They render state and dispatch events.

## Dependency Direction

Dependencies point inward toward the domain layer:

```text
View/Page
  -> ViewModel
    -> UseCase
      -> Repository abstraction
        <- Repository implementation
          -> Remote/Local data source
            -> Dio/Hive
```

The important boundary is the repository contract in the domain layer:

- `CryptoRepository` lives in `domain/repositories`.
- Use cases depend only on `CryptoRepository`.
- `CryptoRepositoryImpl` lives in `data/repositories` and implements the domain
  contract.
- Data sources are implementation details of the data layer.
- DTOs are kept separate from domain entities and mapped explicitly with
  `toEntity()` methods.

The domain layer does not import Flutter widgets, BLoC, Dio, Hive, or concrete
data sources. The presentation layer depends on use cases, not on data sources.

## Dependency Injection

`lib/core/di/injection_container.dart` wires concrete implementations to their
abstractions. `lib/router/app_router.dart` is the route-level composition
boundary for ViewModels:

- routes create ViewModels through get_it;
- routes provide ViewModels to pages with `BlocProvider`;
- pages and widgets read ViewModels from `BuildContext`;
- pages and widgets do not resolve dependencies from the service locator.

This keeps UI classes easier to test because construction details are outside
the View.

## REST Integration

CoinGecko access is isolated behind `CryptoRemoteDataSource` and `DioClient`.
The UI and domain layers do not know about Dio, headers, API keys, or HTTP
status codes.

API configuration is provided through compile-time environment values:

```sh
flutter run \
  --dart-define=COINGECKO_API_KEY=your_key \
  --dart-define=COINGECKO_API_KEY_HEADER=x-cg-demo-api-key
```

`COINGECKO_API_KEY_HEADER` defaults to `x-cg-demo-api-key`. `COINGECKO_BASE_URL`
can also be overridden for different CoinGecko environments.

`DioClient` installs interceptors for:

- API-key header injection;
- common JSON accept headers;
- HTTP/Dio error mapping.

HTTP failures are mapped at the network boundary into typed application
exceptions, including unauthorized, forbidden, not found, server, network, and
rate-limit exceptions. `429` responses preserve `Retry-After` metadata when the
header is available.

Search uses a two-step CoinGecko flow so list rows keep complete market data:

1. `/search` resolves matching coin ids.
2. `/coins/markets?ids=...` fetches price, market cap, image, and 24h change
   for those ids.

The remote data source returns market `CoinModel` objects from the second call,
so the list UI does not render sparse search-only records with missing prices.

## Offline Strategy

The repository is the offline coordination point. It decides whether to use the
network or local cache and returns `DataResult<T>` for read operations so cache
provenance travels with the data.

### Read Flow

1. `NetworkInfo` checks connectivity.
2. If online, the repository requests fresh data from the remote data source.
3. Successful remote responses are cached through the local data source.
4. If the remote request fails, the repository falls back to cached data.
5. If offline, the repository reads cached data directly.
6. If no cached data exists, the repository returns a `CacheFailure`.

This applies to:

- paginated market coins;
- coin detail;
- trending coins;
- global market data;
- search fallback using cached coins.

### Data Result Metadata

Read operations return `Result<DataResult<T>>`:

```dart
class DataResult<T> {
  final T data;
  final ResultSource source;

  bool get isFromCache => source == ResultSource.cache;
}
```

`Result<T>` still represents success or failure. `DataResult<T>` represents the
successful payload and where that payload came from:

```text
remote = fresh API response
cache  = Hive fallback or offline cached response
local  = local-only operation, such as favorites
```

ViewModels use this metadata to set offline UI state. For example,
`CoinListViewModel` and `CoinDetailViewModel` set `isOffline` from
`DataResult.isFromCache`, which allows the UI to show the offline banner while
still rendering cached content.

### Local Persistence

Hive stores cached API responses in concrete typed boxes:

- `Box<CoinsCacheRecord>` for cached coin pages;
- `Box<CoinDetailCacheRecord>` for cached coin detail responses;
- `Box<TrendingCoinsCacheRecord>` for cached trending coins;
- `Box<GlobalMarketCacheRecord>` for cached global market data;
- `Box<bool>` for favorite coin ids.

`Box<dynamic>` is only used transiently during startup migration to inspect and
delete legacy raw values before reopening the same stores with typed Hive boxes.

Each cache record contains:

- `schemaVersion`: cache record format version;
- typed cache DTO payloads such as `CoinCacheDto`, `CoinDetailCacheDto`,
  `TrendingCoinCacheDto`, and `GlobalMarketCacheDto`;
- `cachedAt`: UTC timestamp for when the response was cached;
- `ttl`: cache lifetime for that record.

Favorites use a separate typed boolean box keyed by coin id.

Cache TTLs are defined in `AppConstants`:

- coin pages: 5 minutes;
- trending coins: 10 minutes;
- global market: 10 minutes;
- coin detail: 1 hour.

The local data source invalidates expired records and stale schema-version
records automatically when they are read. It also exposes
`invalidateExpiredCache()` for explicit cache cleanup. Startup migration deletes
legacy raw values and old cache schemas before reopening boxes with typed Hive
box APIs.

Favorites are local-first. Toggling a favorite does not require network access,
and list/detail ViewModels merge favorite status into the renderable state.

## Layer Responsibilities

- Presentation: pages, widgets, ViewModels, events, and states.
- Domain: entities, repository contracts, and use cases.
- Data: DTOs, remote/local data sources, and repository implementations.
- Core: shared infrastructure such as networking, database initialization,
  error/result types, dependency injection, theme, and utilities.

## Architecture Tests

The test suite includes executable architecture boundary checks in
`test/architecture/architecture_boundary_test.dart`:

- presentation files cannot import Dio, Hive, get_it, core network/database
  infrastructure, or data-layer implementations;
- domain files cannot import Flutter, BLoC, Dio, Hive, presentation, data, core
  network, or core database infrastructure.

These tests make the "no UI-direct-to-API" and dependency-direction rules
reviewable in CI.

## Reviewer Notes

- BLoC is intentionally used as the ViewModel implementation, not as a separate
  architecture layer.
- UI-to-API calls are not allowed. API access is isolated behind the remote data
  source and repository implementation.
- REST concerns such as API keys, interceptors, rate limits, and HTTP status
  mapping are handled in `core/network`, not in widgets or ViewModels.
- DTO inheritance from domain entities is avoided. Data models map into domain
  entities explicitly.
- Offline behavior is explicit through `DataResult.isFromCache`, not inferred
  from errors or UI state alone.
- Hive cache entries are typed records with timestamps, TTLs, and invalidation
  behavior instead of long-lived raw dynamic values.
