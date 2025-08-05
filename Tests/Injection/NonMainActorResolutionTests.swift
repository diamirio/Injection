import Testing
@testable import Injection

class NonMainActorResolutionTests {
    
    init() {
        
    }

    deinit {
        Task { @MainActor in
            DependencyInjector.reset()
        }
    }
    
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
    
    @Test func expectNilForResolveWithoutRegistration() async throws {
        let dependency: MyTestDependency? = await DependencyInjector.safeResolve()
        #expect(dependency == nil)
        
        let providedDependency = MyTestDependency()
        await DependencyInjector.register(providedDependency)
        
        let resolvedDependency: MyTestDependency? = await DependencyInjector.safeResolve()
        
        #expect(resolvedDependency === providedDependency)
    }
}

/// Dependency just for testing purposes
fileprivate final class MyTestDependency: Sendable{
    
}

/// Dependency just for testing purposes
fileprivate final class MySecondDependency: Sendable {
    
}
