import Foundation

/// Use to inject a already provided dependency
@MainActor
@propertyWrapper public struct Inject<T> {
    public var wrappedValue: T
    
    public init() {
        self.wrappedValue = DependencyInjector.shared.resolve()
    }
}
