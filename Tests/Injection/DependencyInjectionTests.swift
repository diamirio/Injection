import Testing
@testable import Injection

@Suite struct DependencyInjectionTests {
    
    @Test func testDependencyProviderInline() async throws {
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        let dependency: MyTestDependency = await DependencyInjector.resolve()
        
        #expect(dependency === providedDependency)
    }
    
    @Test func testDependencyProviderPropertyWrapper() async throws {
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        
        @Inject
        var dependency: MyTestDependency
        
        #expect(dependency === providedDependency)
    }
}

/// Dependency just for testing purposes
final class MyTestDependency: Sendable {
    
}
