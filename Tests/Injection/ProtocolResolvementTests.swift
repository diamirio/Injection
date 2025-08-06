import Testing
@testable import Injection

@MainActor
class ProtocolResolvementTests {
    
    init() {
        
    }

    deinit {
        Task { @MainActor in
            DependencyInjector.reset()
        }
    }
    
    @Test func testProtocolResolve() async throws {
        let providedDependency = MyProtocolImplementation()
        DependencyInjector.register(providedDependency, as: MyProtocol.self)
        
        let resolvedDependency: MyProtocol = DependencyInjector.resolve()
        
        #expect(resolvedDependency === providedDependency)
    }
}


fileprivate protocol MyProtocol: AnyObject {
    
}

fileprivate final class MyProtocolImplementation: MyProtocol {
    
}
