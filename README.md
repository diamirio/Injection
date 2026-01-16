# Injection
Swift Dependency Injection Framework

A lightweight, thread-safe dependency injection container for Swift applications with property wrapper support.

## Features

- 🔒 Thread-safe registration and resolution with `@MainActor` isolation
- 📦 Simple registration and resolution
- 🏷️ Property wrapper for automatic injection
- 🧪 Testing support with container reset
- ⚡ Lightweight and fast

## Installation

Add this package to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/diamirio/Injection", from: "1.1.0")
]
```

## Usage

```swift
import Injection
```

### Registering Dependencies

Register dependencies during app initialization:

```swift
// Register concrete types
DependencyInjector.register(MyService())
DependencyInjector.register(UserRepository())

// Register protocol implementations  
DependencyInjector.register(NetworkService(), as: NetworkServiceProtocol.self)
```

### Resolving Dependencies

#### Manual Resolution

```swift
// Resolve (crashes if not found)
let service: MyService = DependencyInjector.resolve()

// Safe resolve (returns nil if not found)
if let service: MyService = DependencyInjector.safeResolve() {
    // Use service safely
}
```

#### Property Wrapper Injection

```swift
class MyViewModel {
    @Inject private var service: MyService
    @Inject private var repository: UserRepository
}
```

### Managing Dependencies

Remove specific dependencies without clearing the entire container:

```swift
// Register dependencies
DependencyInjector.register(MyService())
DependencyInjector.register(UserRepository())

// Option 1: Remove by type
DependencyInjector.remove(MyService.self)

// Option 2: Remove by instance (when you have a reference)
let service = MyService()
DependencyInjector.register(service)
DependencyInjector.remove(service)

// UserRepository is still available
let repo: UserRepository = DependencyInjector.resolve() // Works
let removed: MyService = DependencyInjector.resolve() // Fatal error - removed
```

This is useful when you need to swap out specific dependencies during testing or when cleaning up individual dependencies that are no longer needed.

### Testing Support

Clear all dependencies between tests:

```swift
func tearDown() {
    DependencyInjector.reset()
}
```

Or remove specific dependencies for testing:

```swift
func testWithMockService() {
    // Remove the real service
    DependencyInjector.remove(MyService.self)

    // Register a mock
    DependencyInjector.register(MockService())
}
```

## API Reference

### DependencyInjector

- `register<T>(_ dependency: T)` - Register a dependency instance
- `register<T>(_ dependency: T, as type: T.Type)` - Register a dependency instance with explicit type
- `resolve<T>() -> T` - Resolve a dependency (crashes if not found)
- `safeResolve<T>() -> T?` - Safely resolve a dependency (returns nil if not found)
- `remove<T>(_ type: T.Type)` - Remove a specific registered dependency by type
- `remove<T>(_ dependency: T)` - Remove a specific registered dependency by instance
- `reset()` - Clear all registered dependencies

### @Inject Property Wrapper

Automatically injects dependencies using the property wrapper syntax. The dependency must be registered before the property is accessed.

## Thread Safety

All operations are performed on the main thread due to `@MainActor` isolation, ensuring thread safety throughout your application. 
