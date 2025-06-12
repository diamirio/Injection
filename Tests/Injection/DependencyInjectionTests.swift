import Testing
@testable import Injection

@Suite struct DependencyInjectionTests {
    
    @Test func testDependencyProviderInline() async throws {
        // Register dependencies
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        await DependencyInjector.register(MySecondDependency())
        
        // Resolve dependencies
        let dependency: MyTestDependency = await DependencyInjector.resolve()
        
        #expect(dependency === providedDependency)
    }
    
    @Test func testDependencyProviderPropertyWrapper() async throws {
        // Register dependencies
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        await DependencyInjector.register(MySecondDependency())
        
        // Resolve dependencies
        @Inject
        var dependency: MyTestDependency
        
        #expect(dependency === providedDependency)
    }
}

/// Dependency just for testing purposes
final class MyTestDependency: Sendable {
    
}

/// Dependency just for testing purposes
final class MySecondDependency: Sendable {
    
}

