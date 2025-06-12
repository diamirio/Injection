import Foundation

/// DependencyInjector handles your app dependencies
@MainActor
public struct DependencyInjector {
    private var dependencyList: [ObjectIdentifier : Any] = [:]
    static var shared = DependencyInjector()
    
    private init() { }
    
    /// Provide a dependency for injection
    public static func register<T>(_ dependency : T) {
        DependencyInjector.shared.register(dependency)
    }
    
    /// Resolve a provided dependency
    public static func resolve<T>() -> T {
        return DependencyInjector.shared.resolve()
    }
    
    func resolve<T>() -> T {
        guard let t = dependencyList[ObjectIdentifier(T.self)] as? T else {
            fatalError("No provider registered for type \(T.self)")
        }
        return t
    }
    
    mutating func register<T>(_ dependency : T) {
        dependencyList[ObjectIdentifier(T.self)] = dependency
    }
}
