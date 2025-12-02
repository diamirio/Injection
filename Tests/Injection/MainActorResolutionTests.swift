import Testing
@testable import Injection

@MainActor
struct MainActorResolutionTests {
    
    init() {
        
    }
    
    @Test func testDependencyProviderInline() async throws {
        final class MyTestDependency: Sendable {}
        final class MySecondDependency: Sendable {}
        
        // Register dependencies
        let providedDependency = MyTestDependency()
        DependencyInjector.register(providedDependency)
        DependencyInjector.register(MySecondDependency())
        
        // Resolve dependencies
        let dependency: MyTestDependency = DependencyInjector.resolve()
        
        #expect(dependency === providedDependency)
    }
    
    @Test func testDependencyProviderPropertyWrapper() async throws {
        final class MyTestDependency: Sendable {}
        final class MySecondDependency: Sendable {}
        
        // Register dependencies
        let providedDependency = MyTestDependency()
        DependencyInjector.register(providedDependency)
        DependencyInjector.register(MySecondDependency())
        
        // Resolve dependencies
        @Inject
        var dependency: MyTestDependency
        
        #expect(dependency === providedDependency)
    }
    
    @Test func expectNilForResolveWithoutRegistration() async throws {
        final class MyTestDependency: Sendable {}
        final class MySecondDependency: Sendable {}
        
        let dependency: MyTestDependency? = DependencyInjector.safeResolve()
        #expect(dependency == nil)
        
        let providedDependency = MyTestDependency()
        DependencyInjector.register(providedDependency)
        
        let resolvedDependency: MyTestDependency? = DependencyInjector.safeResolve()
        
        #expect(resolvedDependency === providedDependency)
    }
}
