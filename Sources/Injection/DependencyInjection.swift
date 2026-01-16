import Foundation

/// A dependency injection container that manages application dependencies.
///
/// `DependencyInjector` provides a centralized way to register and resolve dependencies
/// throughout your application. It is thread-safe because of `@MainActor` isolation.
///
/// ## Usage
///
/// Register dependencies during app initialization:
/// ```swift
/// DependencyInjector.register(MyService())
/// DependencyInjector.register(MyImplementation(), as: MyProtocol.self)
/// ```
///
/// Resolve dependencies when needed:
/// ```swift
/// let service: MyService = DependencyInjector.resolve()
/// let optionalService: MyService? = DependencyInjector.safeResolve()
/// ```
///
/// ## Thread Safety
/// This struct is marked with `@MainActor` to ensure all operations are performed
/// on the main thread, providing thread safety for dependency registration and resolution.´
@MainActor
public struct DependencyInjector {
    private var dependencyList: [ObjectIdentifier : Any] = [:]

    /// Registers a dependency instance for later injection.
    ///
    /// This method stores the provided dependency instance in the container,
    /// making it available for resolution by type. If a dependency of the same
    /// type is already registered, it will be replaced.
    ///
    /// - Parameter dependency: The dependency instance to register.
    ///
    /// ## Example
    /// ```swift
    /// DependencyInjector.register(MyService())
    /// ```
    public static func register<T>(_ dependency : T) {
        DependencyInjector.shared.register(dependency)
    }
    
    /// Registers a dependency instance for later injection with explicit type specification.
    ///
    /// This method stores the provided dependency instance in the container under
    /// the specified type, making it available for resolution by that type. This is
    /// useful when you want to register a concrete implementation as a protocol type.
    ///
    /// - Parameters:
    ///   - dependency: The dependency instance to register.
    ///   - type: The type to register the dependency as.
    ///
    /// ## Example
    /// ```swift
    /// DependencyInjector.register(MyImplementation(), as: MyProtocol.self)
    /// ```
    public static func register<T>(_ dependency: T, as type: T.Type) {
        DependencyInjector.shared.register(dependency)
    }
    
    /// Resolves a dependency instance by type.
    ///
    /// This method retrieves a previously registered dependency instance of the
    /// specified type from the container. If no dependency of the requested type
    /// has been registered, this method will trigger a fatal error.
    ///
    /// - Returns: The registered dependency instance of type `T`.
    /// - Precondition: A dependency of type `T` must have been previously registered.
    ///
    /// ## Example
    /// ```swift
    /// let service: MyService = DependencyInjector.resolve()
    /// ```
    ///
    /// - Important: This method will crash the app if the dependency is not found.
    ///             Use `safeResolve()` if you need optional resolution.
    public static func resolve<T>() -> T {
        return DependencyInjector.shared.resolve()
    }
    
    /// Safely resolves a dependency instance by type, returning nil if not found.
    ///
    /// This method retrieves a previously registered dependency instance of the
    /// specified type from the container. Unlike `resolve()`, this method returns
    /// `nil` instead of crashing if no dependency of the requested type has been registered.
    ///
    /// - Returns: The registered dependency instance of type `T`, or `nil` if not found.
    ///
    /// ## Example
    /// ```swift
    /// if let service: MyService = DependencyInjector.safeResolve() {
    ///     // Use the service
    /// } else {
    ///     // Handle missing dependency gracefully
    /// }
    /// ```
    ///
    /// - Note: This is the safer alternative to `resolve()` when you're unsure
    ///         if a dependency has been registered.
    public static func safeResolve<T>() -> T? {
        return DependencyInjector.shared.safeResolve()
    }
    
    /// Resets the dependency injection container, clearing all registered dependencies.
    ///
    /// This method creates a new instance of the dependency injector, effectively
    /// removing all previously registered dependencies. This is particularly useful
    /// for testing scenarios where you need a clean slate between test cases.
    ///
    /// ## Example
    /// ```swift
    /// // Register some dependencies
    /// DependencyInjector.register(MyService())
    /// DependencyInjector.register(MyRepository())
    ///
    /// // Clear all dependencies
    /// DependencyInjector.reset()
    ///
    /// // Container is now empty - resolving will fail until dependencies are re-registered
    /// ```
    ///
    /// - Warning: After calling this method, all previously registered dependencies
    ///           will be lost. Any subsequent calls to `resolve()` or `safeResolve()`
    ///           will fail until dependencies are re-registered.
    ///
    /// - Note: This method is commonly used in unit tests to ensure test isolation
    ///         and prevent dependencies from one test affecting another.
    public static func reset() {
        shared = DependencyInjector()
    }

    /// Removes a registered dependency of the specified type from the container.
    ///
    /// This method removes a previously registered dependency instance of the
    /// specified type from the container. If no dependency of the requested type
    /// has been registered, this method silently succeeds without any effect.
    ///
    /// - Parameter type: The type of dependency to remove.
    ///
    /// ## Example
    /// ```swift
    /// // Register a dependency
    /// DependencyInjector.register(MyService())
    ///
    /// // Remove it
    /// DependencyInjector.remove(MyService.self)
    ///
    /// // Subsequent resolve will fail
    /// let service: MyService = DependencyInjector.resolve() // Fatal error
    /// ```
    ///
    /// - Note: This is useful for testing scenarios where you need to swap out
    ///         specific dependencies without clearing the entire container with `reset()`.
    public static func remove<T>(_ type: T.Type) {
        DependencyInjector.shared.remove(type)
    }

    /// Removes a registered dependency by its instance from the container.
    ///
    /// This method removes a previously registered dependency instance from the
    /// container by extracting the type from the provided instance. If no dependency
    /// of the inferred type has been registered, this method silently succeeds
    /// without any effect.
    ///
    /// - Parameter dependency: The dependency instance to remove (type is inferred).
    ///
    /// ## Example
    /// ```swift
    /// // Register a dependency
    /// let service = MyService()
    /// DependencyInjector.register(service)
    ///
    /// // Remove it by passing the instance
    /// DependencyInjector.remove(service)
    ///
    /// // Subsequent resolve will fail
    /// let resolved: MyService = DependencyInjector.resolve() // Fatal error
    /// ```
    ///
    /// - Note: This overload provides convenience when you have a reference to the
    ///         dependency instance and want to remove it without explicitly specifying the type.
    public static func remove<T>(_ dependency: T) {
        DependencyInjector.shared.remove(dependency)
    }

    private func resolve<T>() -> T {
        guard let t = dependencyList[ObjectIdentifier(T.self)] as? T else {
            fatalError("No provider registered for type \(T.self)")
        }
        return t
    }
    
    private func safeResolve<T>() -> T? {
        guard let t = dependencyList[ObjectIdentifier(T.self)] as? T else {
            return nil
        }
        return t
    }
    
    private mutating func register<T>(_ dependency : T) {
        dependencyList[ObjectIdentifier(T.self)] = dependency
    }

    private mutating func remove<T>(_ type: T.Type) {
        dependencyList.removeValue(forKey: ObjectIdentifier(type))
    }

    private mutating func remove<T>(_ dependency: T) {
        dependencyList.removeValue(forKey: ObjectIdentifier(T.self))
    }

    /// Singleton instance of the DependencyInjector.
    internal static var shared = DependencyInjector()
    private init() { }
}
