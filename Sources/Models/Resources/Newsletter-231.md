Swift macros are one of the most powerful features added to the language in recent years. They make it possible for libraries to generate boilerplate automatically and unlock capabilities that once required direct support from the compiler. We use them throughout the Point-Free ecosystem: [`@Table`][sq] for type-safe SQL queries, [`@CasePathable`][cp] for generating key paths to cases of enums, [`@DependencyClient`][dc] for designing controllable dependencies, [`@DebugSnapshot`][ds] for debugging changes to reference types and exhaustively testing them, and much, much more.

[cp]: https://github.com/pointfreeco/swift-case-paths
[dc]: https://github.com/pointfreeco/swift-dependencies
[sq]: https://github.com/pointfreeco/swift-structured-queries
[ds]: https://github.com/pointfreeco/swift-debug-snapshots

But anyone who has written a macro has quickly run into a fundamental limitation: macros only have access to the _syntax_ of the code they are attached to. They do not have access to the compiler's type checker, and they cannot directly ask seemingly simple questions, such as: "does this type conform to `Equatable`?" Or, "what type did the compiler infer for this expression?" 

This means that most macros are stumbling through syntax in the dark, and it is very easy for a macro to generate code that is syntactically valid but will not compile due to other static errors. And these errors are buried in the guts of the generated macro code, far from the true source of the problem, and so they can be difficult to understand and diagnose.

**These are the limitations of Swift macros, and they are undisputed.**

---

Or are they?

Over the years we have developed a collection of techniques that allow macros to coax the Swift compiler into revealing more information than one may think is possible. None of these techniques gives a macro general access to the type checker. Instead, they take advantage of the work the compiler performs _around_ macro expansion: overload resolution, isolation inference, associated type inference, source-location directives, and more.

In a new 2-part blog series we will explore some of our favorite advanced macro techniques, each motivated by a real problem we encountered in our open source libraries. Below is a short recap of each technique we will be covering, and be on the look out for the full blog post on each technique in the coming days.

## Part 1: Accessing static type information

We will begin with what is perhaps the most surprising claim of the series: macros can access a small amount of static type information. For example, suppose we were creating a `@DeriveEquatable` macro to synthesize `Equatable` conformances for structs (ignore for a moment that the Swift compiler does this for us automatically):

```swift:13:fail
struct Address {
  var street = ""
}

@DeriveEquatable
struct User {
  let id: UUID
  var address: Address
  var name = ""
  
  // Macro expands:
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.address == rhs.address && lhs.name == rhs.name
  }
}
```

Because `@DerivateEquatable` only sees the raw syntax of `User`, and cannot see that `Address` is not `Equatable`, it has no choice but to generate an `==` implementation that is incorrect. That causes an unhelpful compiler error:

> 🛑 Binary operator '\=\=' cannot be applied to two 'Address' operands

The message says that `==` can't be applied, but it doesn't say _why_ it can't be applied. And the error is hidden inside the macro generated code, which takes time to uncover:

<div style="position: relative; padding-top: 66.88907422852377%;">
  <iframe
    src="https://customer-1wj3kl26hvlz1r1i.cloudflarestream.com/539124498104560fe490a57ad6fac771/iframe?muted=true&preload=true&poster=https%3A%2F%2Fcustomer-1wj3kl26hvlz1r1i.cloudflarestream.com%2F539124498104560fe490a57ad6fac771%2Fthumbnails%2Fthumbnail.jpg%3Ftime%3D%26height%3D600"
    style="border: none; position: absolute; top: 0; left: 0; height: 100%; width: 100%;"
    allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;"
    allowfullscreen="true"
  ></iframe>
</div>

We will show how one can leverage a few macro tricks to greatly improve the developer experience of this macro by surfacing the error directly on the line of the struct that caused the issue, and correctly describe exactly what went wrong:

```swift:4:fail
@DeriveEquatable
struct User {
  let id: UUID
  var address: Address
  var name = ""
}
```

> 🛑 'Address' is not 'Equatable'

It may seem impossible to do, given the fact that macros cannot possible see `Address`'s definition, let alone see what protocols it conforms to, but it is indeed possible!

## Part 2: Improving type inference

In part 2 we will tackle another problem that sounds impossible: how can a macro generate type-safe code involving a type annotation the user has entirely omitted?

For example, a `@Memberwise` macro that wants to generate a memberwise initializer for public types cannot do so unless all types are provided:

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

The `@Memberwise` macro does not know the type of `createdAt`, and so cannot properly write the `init`.

Similarly, a "builder" kind of macro that wants to unlock Kotlin-like syntax for making a copy of an existing value with some fields updated:

```swift:10:fail
@Builder
struct User {
  let id: Int
  var name: String
  var createdAt = Date()
  
  // Macro expands
  func copy(
    name: String? = nil, 
    createdAt: <#???#> = nil
  ) -> User {
    var result = self
    if let name { result.name = name }
    if let createdAt { result.createdAt = createdAt }
    return result
  }
}

let newUser = existingUser.copy(createdAt: Date())
```

…again cannot properly implement `copy` because the type of `createdAt` is not known.

Even in our own libraries we have come across this problem, such as in [StructuredQueries], where the `@Table` macro wants to generate a "draft" type that is the same as the user's type, except where all fields are optionalized:

[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries

```swift:11:fail
@Table
struct User {
  let id: Int
  var name: String
  var createdAt = Date()
  
  // Macro expands
  struct Draft {
    let id: Int?
    var name: String?
    var createdAt: <#???#> = Date()
  }
}
```

Again this cannot be done without knowing the type of `createdAt`.

In all of these situations the macro author must provide an unpleasant developer experience to their users by forcing them to explicitly annotate all fields with a type:

```diff
 @Table
 struct User {
   let id: Int
   var name: String
-  var createdAt = Date()
+  var createdAt: Date = Date()
 }
```

Well, luckily this does not have to be the case. Thanks to a novel use of protocols with associated types, it is possible for the macro to generate macro code that has access to the type that Swift infers for each field. Sounds too good to be true, but we promise it is not!

<!--
## Part 3: Detecting default main actor isolation

Swift's default isolation setting allows an entire target to implicitly isolate its declarations to `@MainActor`. This setting has far-reaching consequences on how one writes code in such targets, and it can make it very difficult to write macros that work just as well in `@MainActor` modules as they do in nonisolated modules. 

For example, when using the macros from our [Dependencies] library in a `@MainActor` module, it is necessary to mark certain things as nonisolated. This is due to the fact that Dependencies requires sendable key paths and key paths derived from main actor types are _not_ sendable.

This causes an unfortunate situation where naive use of the macro seems to work at first:

```swift
@DependencyClient
struct APIClient {
  var fetchUser: @Sendable (Int) async throws -> User
}
```

This compiles with no errors. But the moment you go to register this dependency:

```swift
extension DependencyValues {
  @DependencyEntry
  var apiClient = APIClient()
}
```

…you get two error messages hidden in the macro generated code:

> Failed: Main actor-isolated default value in a nonisolated context

> Failed: Call to main actor-isolated initializer 'init()' in a synchronous nonisolated context

The fix is to make the `APIClient` type and `apiClient` property nonisolated, so that the generated key path is sendable:

```diff
 @DependencyClient
-struct APIClient {
+nonisolated struct APIClient {
   var fetchUser: @Sendable (Int) async throws -> User
 }
 extension DependencyValues {
   @DependencyEntry
-  var apiClient = APIClient()
+  nonisolated var apiClient = APIClient()
 }
```

But of course there is no way for our users (or AI agents) to know that this is what needs to done. Whether or not a module is built with main actor isolation is not something made available to macros, and so you may assume we just have to live with this subpar developer experience.

Well, that's not the case! In the second post in this series we will demonstrate a technique to detect `@MainActor` isolation from macros so that proper diagnostics can be emitted directly on the lines that are causing the problem:

```swift:1,5:fail
@DependencyClient struct APIClient {
  var fetchUser: @Sendable (Int) async throws -> User
}
extension DependencyValues {
  @DependencyEntry var apiClient = APIClient()
}
```

> Failed: Client must be 'nonisolated struct' when default isolation is '@MainActor'

> Failed: Entry must be 'nonisolated var' when default isolation is '@MainActor'

Now it is obvious what the problem is, and how to fix it.

[Dependencies]: https://github.com/pointfreeco/swift-dependencies
-->

## Tomorrow the fun begins…

Macros may only get access to the syntax of user code, but macro expansions are able to participate in more of the compilation process. With a little bit of creativity we can recover type information, detect compiler settings, and preserve type inference.

And we use each and every one of these tricks in production libraries that improve diagnostics, unlock concise APIs, and make code written by both humans and AI agents easier to get right.

Be sure to catch the first post tomorrow!
