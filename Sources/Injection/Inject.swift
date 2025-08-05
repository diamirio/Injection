import Foundation

/// A property wrapper that automatically injects dependencies.
///
/// `Inject` provides a convenient way to automatically resolve and inject dependencies
/// into your types using Swift's property wrapper syntax. The dependency must be
/// previously registered with `DependencyInjector` before use.
///
/// ## Usage
///
/// Use the `@Inject` property wrapper to automatically inject dependencies:
/// ```swift
/// class MyViewController {
///     @Inject private var service: MyService
///     @Inject private var repository: MyRepository
/// }
/// ```
///
/// ## Requirements
/// - The dependency type `T` must be previously registered with `DependencyInjector.register(_:)` or `DependencyInjector.register(_:as:)`
/// - This property wrapper uses `DependencyInjector.resolve()` internally, so it will
///   crash if the dependency is not found
///
/// ## Thread Safety
/// This property wrapper is marked with `@MainActor` to ensure dependency resolution
/// happens on the main thread, maintaining thread safety.
///
/// - Important: Make sure to register your dependencies before creating instances
///             that use this property wrapper, typically during app initialization.
@MainActor
@propertyWrapper public struct Inject<T> {
    /// The injected dependency instance.
    public var wrappedValue: T
    
    /// Initializes the property wrapper and resolves the dependency.
    ///
    /// This initializer automatically resolves the dependency of type `T`
    /// from the `DependencyInjector`. The dependency must have been previously
    /// registered or this will result in a fatal error.
    ///
    /// - Precondition: A dependency of type `T` must be registered with `DependencyInjector`.
    public init() {
        self.wrappedValue = DependencyInjector.resolve()
    }
}
