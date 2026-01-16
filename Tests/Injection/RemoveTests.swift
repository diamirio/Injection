import Testing
@testable import Injection

@MainActor
struct RemoveTests {
    @Test func testRemoveExistingDependency() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}

        // Register a dependency
        let service = ConcreteService()
        DependencyInjector.register(service)

        // Verify it exists
        let resolved: ConcreteService = DependencyInjector.resolve()
        #expect(resolved === service)

        // Remove it
        DependencyInjector.remove(ConcreteService.self)

        // Verify it's gone (safeResolve should return nil)
        let afterRemove: ConcreteService? = DependencyInjector.safeResolve()
        #expect(afterRemove == nil)
    }

    @Test func testRemoveNonExistentDependency() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}

        // Removing a non-existent dependency should not crash
        DependencyInjector.remove(ConcreteService.self)

        // Should still return nil when trying to resolve
        let resolved: ConcreteService? = DependencyInjector.safeResolve()
        #expect(resolved == nil)
    }

    @Test func testRemoveOneOfMultiple() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}

        // Register multiple dependencies
        let service = ConcreteService()
        let repository = ConcreteRepository()
        DependencyInjector.register(service)
        DependencyInjector.register(repository)

        // Remove only the service
        DependencyInjector.remove(ConcreteService.self)

        // Verify service is gone
        let resolvedService: ConcreteService? = DependencyInjector.safeResolve()
        #expect(resolvedService == nil)

        // Verify repository is still available
        let resolvedRepository: ConcreteRepository = DependencyInjector.resolve()
        #expect(resolvedRepository === repository)
    }

    @Test func testRemoveAndReregister() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}

        // Register a dependency
        let originalService = ConcreteService()
        DependencyInjector.register(originalService)

        // Remove it
        DependencyInjector.remove(ConcreteService.self)

        // Register a new instance
        let newService = ConcreteService()
        DependencyInjector.register(newService)

        // Verify the new instance is resolved
        let resolved: ConcreteService = DependencyInjector.resolve()
        #expect(resolved === newService)
        #expect(resolved !== originalService)
    }

    @Test func testRemoveProtocolRegistration() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}

        // Register a protocol implementation
        let implementation = ServiceImplementation()
        DependencyInjector.register(implementation, as: ServiceProtocol.self)

        // Verify it exists
        let resolved: ServiceProtocol = DependencyInjector.resolve()
        #expect(resolved === implementation)

        // Remove it by protocol type
        DependencyInjector.remove(ServiceProtocol.self)

        // Verify it's gone
        let afterRemove: ServiceProtocol? = DependencyInjector.safeResolve()
        #expect(afterRemove == nil)
    }

    @Test func testRemoveByInstance() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}

        // Register a dependency
        let service = ConcreteService()
        DependencyInjector.register(service)

        // Verify it exists
        let resolved: ConcreteService = DependencyInjector.resolve()
        #expect(resolved === service)

        // Remove it by passing the instance
        DependencyInjector.remove(service)

        // Verify it's gone
        let afterRemove: ConcreteService? = DependencyInjector.safeResolve()
        #expect(afterRemove == nil)
    }

    @Test func testRemoveByInstanceVsType() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}

        // Register two separate instances for testing
        let service1 = ConcreteService()
        let service2 = ConcreteService()

        // Test 1: Remove by instance
        DependencyInjector.register(service1)
        DependencyInjector.remove(service1)
        let afterRemoveByInstance: ConcreteService? = DependencyInjector.safeResolve()
        #expect(afterRemoveByInstance == nil)

        // Test 2: Remove by type - should have same effect
        DependencyInjector.register(service2)
        DependencyInjector.remove(ConcreteService.self)
        let afterRemoveByType: ConcreteService? = DependencyInjector.safeResolve()
        #expect(afterRemoveByType == nil)
    }

    @Test func testRemoveByInstanceWithMultiple() async throws {
        final class ConcreteService {}
        final class ConcreteRepository {}
        protocol ServiceProtocol: AnyObject {}
        final class ServiceImplementation: ServiceProtocol {}
        
        // Register multiple dependencies
        let service = ConcreteService()
        let repository = ConcreteRepository()
        DependencyInjector.register(service)
        DependencyInjector.register(repository)

        // Remove only the service by instance
        DependencyInjector.remove(service)

        // Verify service is gone
        let resolvedService: ConcreteService? = DependencyInjector.safeResolve()
        #expect(resolvedService == nil)

        // Verify repository is still available
        let resolvedRepository: ConcreteRepository = DependencyInjector.resolve()
        #expect(resolvedRepository === repository)
    }
}
