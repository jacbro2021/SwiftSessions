# Swift Sessions

**Swift Sessions** is a Swift package that implements binary [session types](https://en.wikipedia.org/wiki/Session_type), providing a robust framework for ensuring safe and structured communication in concurrent systems.

The library currently supports the following features:
- session type inference (only with closures)
- session types with binary branches
- dynamic linearity checking
- duality constraints on session types
- session initialization with client/server architecture

## Authors and Acknowledgments

This library was developed as part of a Bachelor’s degree thesis project at the University of Camerino. The project was completed by [Alessio Rubicini](https://github.com/alessiorubicini) under the supervision of professor [Luca Padovani](https://github.com/boystrange).

## Overview

### Programming Styles
This library offers two distinct styles for managing session types:
- **Continuation with closures**: protocol continuations are passed as closures. This approach makes the flow of logic explicit and easy to follow within the closure context. It's particularly useful for straightforward communication sequences.
    
    ```swift
    await Session.create { e in
        // One side of the communication channel
        await Session.recv(from: e) { num, e in
            await Session.send(num % 2 == 0, on: e) { e in
                await Session.close(e)
            }
        }
    } _: { c in
        // Another side of the communication channel
        await Session.send(42, on: e) { e in
            await Session.recv(from: e) { isEven, e in
                await Session.close(e)
            }
        }   
    }
    ```
    
    - Pros: Complete type inference of the communication protocol.
	- Cons: Nested code structure.
    
- **Continuations with endpoint passing**: this style involves returning continuation endpoints from communication primitives. It offers greater flexibility, enabling more modular and reusable code, particularly for complex communication sequences.

    ```swift
    typealias Protocol = Endpoint<Empty, (Int, Endpoint<(Bool, Endpoint<Empty, Empty>), Empty>)>
    
    // One side of the communication channel
    let e = await Session.create { (e: Protocol) in
        let (num, e1) = await Session.recv(from: e)
        let e2 = await Session.send(num % 2 == 0, on: e1)
        await Session.close(e2)
    }
        
    // Another side of the communication channel
    let e1 = await Session.send(42, on: e)
    let (isEven, e2) = await Session.recv(from: e1)
    await Session.close(e2)
    ```
    
    - Pros: Simplicity, particularly for avoiding deep indentation.
	- Cons: Incomplete type inference support.

Each style provides a unique approach to handling session-based binary communication and comes with its own pros and cons. By supporting both styles, SwiftSessions allows you to choose the best approach (or use both in a hybrid way!) according to your needs and coding preferences.

For additional examples, see the [Tests](Tests) folder.


### Client/Server Architecture

Instead of creating disposable sessions as seen in the previous examples, you can also initialize sessions using a client/server architectural style.

A **server** is responsible for creating and managing multiple sessions that can handle a specific protocol. Many **clients** can be spawned and used with the same server to interact dually according to that defined protocol. This allows to define a protocol's side only once, and use it as many times as we want.

```swift
// Server side
let server = await Server { e in
    await Session.recv(from: e) { num, e in
        await Session.send(num % 2 == 0, on: e) { e in
            await Session.close(e)
        }
    }
}

// Client side
let c1 = await Client(for: server) { e in
    await Session.send(42, on: e) { e in
        await Session.recv(from: e) { isEven, e in
            await Session.close(e)
        }
    }
}

// You can spawn more clients here...
```
    
This architecture is useful for scenarios where multiple clients need to interact with a single server. It's also useful to implement complex protocols that involve loops and recursion.

## Future directions

In upcoming versions of Swift, new features such as [non-copyable generics](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0427-noncopyable-generics.md#conformance-to-copyable) are expected to be introduced, which will significantly enhance the capabilities of this library allowing static linearity checking.

## Installation

To integrate SwiftSessions into your project, use Swift Package Manager. 

1. Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/alessiorubicini/SwiftSessions.git", .upToNextMajor(from: "1.0.0"))
]
```

2. Then, add `SwiftSessions` to your target dependencies:

```swift
.target(
    name: "YourTargetName",
    dependencies: [
        .product(name: "SwiftSessions", package: "SwiftSessions")
    ]
)

```

## Requirements

- Swift 5.5+
- Xcode 13+
- Compatible with iOS 14.0+ / macOS 10.15+ / tvOS 14.0+ / watchOS 6.0+

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
