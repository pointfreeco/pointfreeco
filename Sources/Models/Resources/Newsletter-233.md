Type inference is one of the most idiomatic patterns in the Swift language. It's what allows us to define a variable like this:

```swift
let createdAt = Date()
```

…instead of like this:

```swift
let createdAt: Date = Date()
```

Most people who write Swift code want to elide types where possible, and would be put off if they were forced to add types to code that otherwise would not need them. But that is exactly what happens when using macros. A missing type annotation often means the macro cannot write correct code, and so will lead to cryptic compile time errors burried in the guts of the expanded macro code.

Well, it doesn't have to be that way. Join us for an advanced technique in Swift macros that allows your macros to get access to static type information even when the type is completely omitted. 

# The problem

Consider a theoretical `@Memberwise` macro that wants to generate a public memberwise initializer for the following type:

```swift:1
@Memberwise
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()
}
```

This macro cannot propertly do its job. The macro only only gets access to the stringy parts of the syntax, in this case "public var createdAt = Date()", and so it cannot possibly generate a valid initializer:

```swift:11:fail
@Memberwise
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()
  
  // Macro expands
  public init(
    id: Int, 
    name: String,
    createdAt: <#???#> = Date()
  ) {
    self.id = id
    self.name = name 
    self.createdAt = createdAt
  }
}
```

The fix is to force the user to specify the types for all variables explicitly:

```swift:5
@Memberwise
public struct User {
  public let id: Int
  public var name: String
  public var createdAt: Date = Date()
}
```

Well, what if we told you that it is possible to implement `@Memberwise` in a way that still allows your users to take advantage of type inference? They can continue writing idiomatic Swift code, and your macro can employ a few novel tricks to sneakily extract static type information from the raw syntax. And this trick works well beyond just `@Memberwise`. We also employ this trick in our [`@Table` macro][sq] and [`@DebugSnapshot` macro][ds].

[sq]: https://github.com/pointfreeco/swift-structured-queries
[ds]: https://github.com/pointfreeco/swift-debug-snapshots

# Inferring types in macros

We would like to implement a `@Memberwise` macro that will generate a public initializer for a type, even when that type is leveraging type inference for its fields:

```swift
@Memberwise
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()
}
```

If done naively, such a macro seems to have no choice but to generate invalid syntax since the type of `createdAt` is not statically known:

```swift:11:fail
@Memberwise
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()
  
  // Macro expands
  public init(
    id: Int, 
    name: String,
    createdAt: <#???#> = Date()
  ) {
    self.id = id
    self.name = name 
    self.createdAt = createdAt
  }
}
```

The macro only gets access to the stringy syntax "public var createdAt = Date()", and so one approach to fix this would be to try to determine the type from the string. If you find something of the form "= ABC()" inside the syntax, you might be able to assume that "ABC" is the type for the field.

Not only is this precarious, but it will not work if the default is given by a static property:

```swift
public var createdAt = Date.now
```

…or a function:

```swift
public var createdAt = now()

…

private func now() -> Date { Date() }
```

It's even possible to reference a constant that lives in an unrelated type:

```swift
public var createdAt = Constants.epoch
```

These examples show that mere string matching is not going to work, and whatever technique we employ should be able to handle these situations, and more.

Now there is one way to get a type from a value, and that is using Swift's [`type(of:)`][type-of] function. So perhaps we can use that to specify the type of `createdAt` in the initializer?

[type-of]: https://developer.apple.com/documentation/swift/type(of:)

```swift:5:fail
// Macro expands
public init(
  id: Int, 
  name: String,
  createdAt: type(of: Date()) = Date()
) {
  self.id = id
  self.name = name 
  self.createdAt = createdAt
}
```

Unfortunately, no. The `type(of:)` function merely returns the [_metatype_][metatype] of the value, which is the type of the type, but not the type itself.

[metatype]: https://docs.swift.org/latest/documentation/the-swift-programming-language/types/#Metatype-Type

However, there is a trick we can employ to upgrade a mere runtime value into a full blown static type, known at compile time. And it's all thanks to Swift's ability to infer associated types in protocols, a feature that was once proposed to be [removed][se-0108], as well as the ability to nest protocols in types (introduced in [SE-0404][se-0404]).

[se-0108]: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0108-remove-assoctype-inference.md
[se-0404]: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0404-nested-protocols.md

Before even thinking about generating the `public init` for `User` from the macro, let's think about other code that the macro can generate that will help us with the initializer. The macro can expand a nested protocol that ties together the static type of `createdAt` with its default value:

```swift:6-10
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()

  // Macro expands
  public protocol _$FieldTypes {
    associatedtype createdAt
    static var createdAtDefault: createdAt { get }
  }
}
```

> Note: Prior to Swift 5.10 nested protocols were not allowed and so this trick would not have worked!

It may seem strange to prefix the protocol name with `_$` and to not use titlecase for the associated type, but remember that this is just macro generated code, and users will rarely need to look at it.

Next, the macro will generate a type that conforms to `_$FieldTypes` that uses the default value provided by the user to satisfy the conformance:

```swift:6-14
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()

  // Macro expands
  public protocol _$FieldTypes {
    associatedtype createdAt
    static var createdAtDefault: createdAt { get }
  }
  
  public enum _$FieldWitness: _$FieldTypes {
    public static let createdAtDefault = Date()
  }
}
```

The only reason such a simple conformance satisfies the `_$FieldTypes` protocol is precisely because Swift is able to infer that the `associatedtype createdAt` is `Date` thanks to the `createdAtDefault` static.

And now for the wonderful trick! The `_$FieldWitness` is a bonafide static type, and it has an associated type `_$FieldWitness.createdAt`  that is also a bonafide static type, and can be used just as any other type (such as `Date`):

```swift:19
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()

  // Macro expands
  public init(
    id: Int, 
    name: String,
    createdAt: _$FieldWitness.createdAt = Date()
  ) {
    self.id = id
    self.name = name 
    self.createdAt = createdAt
  }
  
  public protocol _$FieldTypes {
    associatedtype createdAt
    static var createdAtDefault: createdAt { get }
  }
  
  public enum _$FieldWitness: _$FieldTypes {
    public static let createdAtDefault = Date()
  }
}
```

This code may look strange, but it's also code the user will never directly see. We've had to ping pong through a few layers, first a protocol with an associated type, to a concrete conformance, and finally to accessing the concrete type's associated type. But this is now 100% valid Swift code that fully compiles, and this is the kind of code a macro can easily expand without directly knowing about any of the static type information of the code it is attached to.

And this trick works no matter how complex the default value is for a field. Take for example a default that is determined by an immediately invoked closure that references environment values:

```swift:5-7
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()
  public var isDebugging = {
    ProcessInfo.processInfo.environment["DEBUGGING"] != nil
  }()
}
```

The macro code can follow the same pattern as for `createdAt`. A new associated type and static requirement is added to `_$FieldTypes`, a new static property is added to `_$FieldWitness`, and then the initializer can use that associated type for the type:

```swift:5-7,14-16,21,27-28,33-35
public struct User {
  public let id: Int
  public var name: String
  public var createdAt = Date()
  public var isDebugging = {
    ProcessInfo.processInfo.environment["DEBUGGING"] != nil
  }()

  // Macro expands
  public init(
    id: Int, 
    name: String,
    createdAt: _$FieldWitness.createdAt = Date(),
    isDebugging: _$FieldWitness.isDebugging = {
      ProcessInfo.processInfo.environment["DEBUGGING"] != nil
    }()
  ) {
    self.id = id
    self.name = name 
    self.createdAt = createdAt
    self.isDebugging = isDebugging
  }
  
  public protocol _$FieldTypes {
    associatedtype createdAt
    static var createdAtDefault: createdAt { get }
    associatedtype isDebugging
    static var isDebuggingDefault: isDebugging { get }
  }
  
  public enum _$FieldWitness: _$FieldTypes {
    public static let createdAtDefault = Date()
    public static let isDebuggingDefault = {
      ProcessInfo.processInfo.environment["DEBUGGING"] != nil
    }()
  }
}
```

This technique can also be combined with the technique described in [yesterday's post](/blog/posts/232-advanced-macro-technique-1-static-type-information) to not only allow for type inference but also to determine the static types for better diagnostics and custom macro logic.

# Improve your macros today

If you have any macros that generate new types, initializers or functions (e.g. builders) from a user's existing type, then you need to use this technique to improve the developer experience of using your macro. We use this technique in our `@Table` macro for building type-safe SQLite queries (see an example of an expansion [here][sq-example]). And we use this technique in our `@DebugSnapshot` macro for making reference types more testable, and we've even extended inference to work with property wrapper inference (example [here][ds-example]).

[sq-example]: https://github.com/pointfreeco/swift-structured-queries/blob/a834ac7849d51df9d52f5699a2c94716c7a30933/Tests/StructuredQueriesMacrosTests/TableMacroTests.swift#L2113-L2136
[ds-example]: https://github.com/pointfreeco/swift-debug-snapshots/blob/083c2aa4d1edf6e98bb20670cfddc04ac45ad8a4/Tests/DebugSnapshotsMacrosTests/DebugSnapshotMacroTests.swift#L2210-L2226

