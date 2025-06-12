# Injection
Swift Dependency Injection Framework

## Usage

```swift
import Injection
```

### Provide Dependency

```swift
DependencyInjector.register(MyClass())
```

### Inject Dependency

```swift
let myClass: MyClass = DependencyInjector.resolve()
```

OR

```swift
class OtherClass {
    
    @Inject
    private var myClass: MyClass
}
``` 
