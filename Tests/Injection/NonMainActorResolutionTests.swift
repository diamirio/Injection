import Testing
@testable import Injection

struct NonMainActorResolutionTests {
    @Test func testDependencyProviderInline() async throws {
        final class MyTestDependency: Sendable {}
        final class MySecondDependency: Sendable {}
        
        // Register dependencies
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        await DependencyInjector.register(MySecondDependency())
        
        // Resolve dependencies
        let dependency: MyTestDependency = await DependencyInjector.resolve()
        
        #expect(dependency === providedDependency)
    }
    
    @Test func testDependencyProviderPropertyWrapper() async throws {
        final class MyTestDependency: Sendable {}
        final class MySecondDependency: Sendable {}
        
        // Register dependencies
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        await DependencyInjector.register(MySecondDependency())
        
        // Resolve dependencies
        @Inject
        var dependency: MyTestDependency
        
        #expect(dependency === providedDependency)
    }
    
    @Test func expectNilForResolveWithoutRegistration() async throws {
        final class MyTestDependency: Sendable {}
        final class MySecondDependency: Sendable {}
        
        let dependency: MyTestDependency? = await DependencyInjector.safeResolve()
        #expect(dependency == nil)
        
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        
        let resolvedDependency: MyTestDependency? = await DependencyInjector.safeResolve()
        
        #expect(resolvedDependency === providedDependency)
    }
}
