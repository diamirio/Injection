import Testing
@testable import Injection

@MainActor
struct ProtocolResolvementTests {
    @Test func testProtocolResolve() async throws {
        protocol MyProtocol: AnyObject {}
        final class MyProtocolImplementation: MyProtocol {}
        
        let providedDependency = MyProtocolImplementation()
        DependencyInjector.register(providedDependency, as: MyProtocol.self)
        
        let resolvedDependency: MyProtocol = DependencyInjector.resolve()
        
        #expect(resolvedDependency === providedDependency)
    }
}
