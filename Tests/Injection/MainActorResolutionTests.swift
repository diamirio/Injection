import Testing
@testable import Injection

@MainActor
class MainActorResolutionTests {
    
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
        DependencyInjector.register(providedDependency)
        DependencyInjector.register(MySecondDependency())
        
        // Resolve dependencies
        let dependency: MyTestDependency = DependencyInjector.resolve()
        
        #expect(dependency === providedDependency)
    }
    
    @Test func testDependencyProviderPropertyWrapper() async throws {
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
        let dependency: MyTestDependency? = DependencyInjector.safeResolve()
        #expect(dependency == nil)
        
        let providedDependency = MyTestDependency()
        DependencyInjector.register(providedDependency)
        
        let resolvedDependency: MyTestDependency? = DependencyInjector.safeResolve()
        
        #expect(resolvedDependency === providedDependency)
    }
}

/// Dependency just for testing purposes
fileprivate final class MyTestDependency {
    
}

/// Dependency just for testing purposes
fileprivate final class MySecondDependency {
    
}
