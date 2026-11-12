---
name: injection
description: Integrate and use the diamirio/Injection Swift dependency injection library (DependencyInjector, @Inject). Use when adding the Injection package to an iOS/macOS/watchOS/visionOS project, registering or resolving dependencies, using the @Inject property wrapper, registering a protocol implementation, swapping in mocks, removing dependencies, or writing tests (Swift Testing / XCTest) for code that uses DependencyInjector. Triggers on "import Injection", "DependencyInjector", "@Inject", "safeResolve", or questions about dependency injection in a project that depends on github.com/diamirio/Injection.
---

# Injection — Swift dependency injection

`Injection` is a tiny, `@MainActor`-isolated service locator: one global container that stores **one instance per type**, plus an `@Inject` property wrapper that pulls from it. Source: `Sources/Injection/DependencyInjector.swift`, `Sources/Injection/Inject.swift`.

## 1. Add the package

Requirements: Swift tools 6.1, iOS 16 / macOS 13 / watchOS 9 / visionOS 1.

`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/diamirio/Injection", from: "1.2.0")
],
targets: [
    .target(name: "MyFeature", dependencies: [
        .product(name: "Injection", package: "Injection")
    ])
]
```

Xcode project: File › Add Package Dependencies… › `https://github.com/diamirio/Injection`, rule "Up to Next Major" from `1.2.0`, add the `Injection` product to the app target.

Use `1.2.0` or later if you need `remove(_:)`; earlier releases only have `register`, `resolve`, `safeResolve`, `reset`.

## 2. API at a glance

All members are `static` and `@MainActor`.

| Call | Behaviour |
|---|---|
| `DependencyInjector.register(x)` | Stores `x` under its **static** type. Replaces any existing entry for that type. |
| `DependencyInjector.register(x, as: P.self)` | Stores `x` under `P` (use for protocols / abstractions). |
| `let s: S = DependencyInjector.resolve()` | Returns the instance; **`fatalError`** if missing. |
| `let s: S? = DependencyInjector.safeResolve()` | Returns `nil` if missing. |
| `DependencyInjector.remove(S.self)` | Removes the entry for `S`; no-op if absent. |
| `DependencyInjector.remove(x)` | Removes the entry for `x`'s **static** type (not by identity). |
| `DependencyInjector.reset()` | Clears the whole container. |
| `@Inject var s: S` | Resolves `S` via `resolve()` when the owning instance is initialised. |

`resolve`/`safeResolve` infer `T` from the declared type, so always annotate: `let api: APIClient = DependencyInjector.resolve()`.

## 3. Integration recipe

### Register once, at the composition root, before anything injects

SwiftUI:

```swift
import SwiftUI
import Injection

@main
struct MyApp: App {
    init() {
        DependencyContainer.registerAll()
    }
    var body: some Scene { WindowGroup { RootView() } }
}

@MainActor
enum DependencyContainer {
    static func registerAll() {
        let http = URLSessionHTTPClient()
        DependencyInjector.register(http, as: HTTPClient.self)
        DependencyInjector.register(UserRepository(http: http), as: UserRepositoryProtocol.self)
        DependencyInjector.register(AnalyticsService())
    }
}
```

UIKit: call the same function at the top of `application(_:didFinishLaunchingWithOptions:)`.

Register in dependency order: if a dependency itself uses `@Inject`, everything it injects must already be registered when you construct it.

### Consume

```swift
import Injection

@MainActor
final class ProfileViewModel: ObservableObject {
    @Inject private var users: UserRepositoryProtocol
    @Inject private var analytics: AnalyticsService
}
```

Or explicitly, e.g. for an optional feature:

```swift
if let flags: FeatureFlags = DependencyInjector.safeResolve() { ... }
```

From non-main-actor code, hop to the main actor: `let repo: UserRepositoryProtocol = await DependencyInjector.resolve()`.

## 4. Gotchas — read before writing code

1. **Key = the static type at the call site.** `register(UserRepositoryStub())` stores it under `UserRepositoryStub`, so `resolve()` as `UserRepositoryProtocol` still fails or returns the old one. When the consumer asks for a protocol or base class, always use `register(x, as: TheProtocol.self)` (or `register(x as TheProtocol)`).
2. **Concrete and protocol registrations are separate entries.** `register(impl)` does not make `impl` resolvable as its protocol, and `remove(impl)` does not remove a registration made with `as: Protocol.self` — use `remove(Protocol.self)`.
3. **Instances only, no factories / scopes.** Every resolve returns the same stored value. Classes are effectively singletons; structs are copied on every resolve, so mutations are not shared. Register reference types for shared state.
4. **`@Inject` resolves eagerly at init and caches.** It crashes immediately if the type isn't registered yet, and later `register`/`remove` calls do not affect objects that were already created. Register before creating consumers; recreate consumers (or resolve lazily with `DependencyInjector.resolve()` at use time) if you need to observe swaps.
5. **Missing registration = crash.** Prefer `safeResolve()` for genuinely optional dependencies.
6. **Main actor.** Everything is `@MainActor`. Put `@Inject` in `@MainActor` types (views, view models, coordinators); from other isolation domains use `await DependencyInjector.resolve()` and keep the resolved value `Sendable`.
7. **One global container.** No child containers or named registrations — one instance per type. If you need two instances of the same type, wrap them in distinct types or protocols.

## 5. Testing

The container is global and shared by all tests in the process. Swift Testing runs tests in parallel, but on the main actor they only interleave at `await` points; code between two `await`s runs without interruption.

### Default: `makeSUT()` (works with parallel tests)

Register **every** dependency the SUT injects and create the SUT in one synchronous function, with no `await` in between. `@Inject` resolves at init (gotcha 4), so the SUT captures exactly these stubs; registrations made later by other tests can't change it. No `reset()` needed.

```swift
import Injection
import Testing
@testable import MyApp

@MainActor
struct ProfileViewModelTests {
    let users = UserRepositoryStub()
    let analytics = AnalyticsServiceSpy()

    func makeSUT() -> ProfileViewModel {
        DependencyInjector.register(users, as: UserRepositoryProtocol.self)   // `as:` is required
        DependencyInjector.register(analytics, as: AnalyticsServiceProtocol.self)
        return ProfileViewModel()                                            // @Inject resolves here
    }

    @Test("Load shows the user")
    func loadsUser() async {
        // Given
        users.user = .fixture(name: "Ann")
        let sut = makeSUT()

        // When
        await sut.load()

        // Then
        #expect(sut.user == .fixture(name: "Ann"))
    }
}
```

- Missing a registration crashes the test at `makeSUT()`, so a new `@Inject` in the SUT shows up immediately.
- Doubles: `…Stub` returns configured values, `…Spy` records calls.

### When the SUT resolves lazily

If the SUT calls `DependencyInjector.resolve()` at use time (or creates objects with `@Inject` after an `await`), another test can replace the registration in between. Prefer `@Inject` or constructor injection in code under test. If lazy resolution has to stay, run every suite that touches those types serialized, under one parent suite:

```swift
@Suite(.serialized) @MainActor
struct DependencyInjectorTests {
    @Suite struct Profile { /* … */ }
    @Suite struct Settings { /* … */ }
}
```

`@Suite(.serialized)` serializes only the tests inside that suite; other suites keep running in parallel.

### Rules

- Never call `reset()` in a suite that runs in parallel with others: it removes registrations other tests are using. If you need it, use it only inside the serialized parent suite.
- To swap one dependency, `register` again (registration replaces) or `remove(T.self)` first.
- XCTest (UI/performance tests, existing suites) runs serially per class: `DependencyInjector.reset()` in `tearDown()` is fine (mark it `@MainActor` or wrap in `MainActor.assumeIsolated`).

## 6. Checklist when integrating

- [ ] Package added, `Injection` product linked to every target that imports it.
- [ ] Single registration function called at app launch, before any view/view model is created.
- [ ] Protocol-typed dependencies registered with `as: Protocol.self`.
- [ ] `@Inject` only used in `@MainActor` types; async contexts use `await DependencyInjector.resolve()`.
- [ ] Optional dependencies resolved with `safeResolve()`.
- [ ] Tests register stubs with `as:` in a synchronous `makeSUT()` that creates the SUT afterwards; parallel suites don't call `reset()`.
