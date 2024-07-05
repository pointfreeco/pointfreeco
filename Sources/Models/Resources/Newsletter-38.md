> Announcement: Today we are open sourcing CasePaths, a library that introduces the power and
> ergonomics of key paths to enums!

We are excited to announce the 0.1.0 release of
[CasePaths](https://github.com/pointfreeco/swift-case-paths), a new API that brings key path-like
functionality and ergonomics to enums and unlocks the potential to write code that is generic over
enums.

## Motivation

Swift endows every struct and class property with a
[key path](https://developer.apple.com/documentation/swift/swift_standard_library/key-path_expressions).

```swift
struct User {
  var id: Int
  var name: String
}

\User.id    // WritableKeyPath<User, Int>
\User.name  // WritableKeyPath<User, String>
```

This is compiler-generated code that can be used to abstractly zoom in on part of a structure,
inspect and even change it, while propagating these changes to the structure's whole. They unlock
the ability to do many things, like
[key-value observing](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift) 
and
[reactive bindings](https://developer.apple.com/documentation/combine/receiving_and_handling_events_with_combine), 
[dynamic member lookup](https://github.com/apple/swift-evolution/blob/master/proposals/0252-keypath-dynamic-member-lookup.md),
and scoping changes to the SwiftUI
[environment](https://developer.apple.com/documentation/swiftui/environment).

Unfortunately, no such structure exists for enum cases!

```swift:6:fail
enum Authentication {
  case authenticated(accessToken: String)
  case unauthenticated
}

\Authentication.authenticated
```

> Error: Key path cannot refer to enum case 'authenticated'

And so it's impossible to write similar generic algorithms that can zoom in on a particular enum case.

## Introducing: case paths

[CasePaths](https://github.com/pointfreeco/swift-case-paths) intends to bridge this gap by
introducing what we call "case paths." Case paths can be constructed simply by prepending the enum
type and case name with a _forward_ slash:

```swift
import CasePaths

/Authentication.authenticated  // CasePath<Authentication, String>
```

### Case paths vs. key paths

While key paths package up the functionality of getting and setting a value on a root structure,
case paths package up the functionality of extracting and embedding a value on a root enumeration.

```swift
user[keyPath: \User.id] = 42
user[keyPath: \User.id]  // 42

let authentication = (/Authentication.authenticated)
  .embed("cafebeef")
(/Authentication.authenticated).extract(from: authentication)
// Optional("cafebeef")
```

Case path extraction can fail and return `nil` because the cases may not match up.

```swift
(/Authentication.authenticated).extract(from: .unauthenticated)
// nil
```

Case paths, like key paths, compose. Where key paths use dot-syntax to dive deeper into a structure,
case paths use a double-dot syntax:

```swift
\HighScore.user.name
// WritableKeyPath<HighScore, String>

/Result<Authentication, Error>..Authentication.authenticated
// CasePath<Result<Authentication, Error>, String>
```

Case paths, also like key paths, provide an
"[identity](https://github.com/apple/swift-evolution/blob/master/proposals/0227-identity-keypath.md)"
path, which is useful for interacting with APIs that use key paths and case paths but you want to
work with entire structure.

```swift
\User.self            // WritableKeyPath<User, User>
/Authentication.self  // CasePath<Authentication, Authentication>
```

Key paths are created for every property, even computed ones, so what is the equivalent for case
paths? "Computed" case paths can be created by providing custom `embed` and `extract` functions:

```swift
CasePath<Authentication, String>(
  embed: { decryptedToken in
    Authentication.authenticated(token: encrypt(decryptedToken))
  },
  extract: { authentication in
    guard
      case let .authenticated(encryptedToken) = authentication,
      let decryptedToken = decrypt(token)
      else { return nil }
    return decryptedToken
  }
)
```

Since Swift 5.2, key path expressions can be passed directly to methods like `map`. The same is true
of case path expressions, which can be passed to methods like `compactMap`:

```swift
users.map(\User.name)
authentications.compactMap(/Authentication.authenticated)
```

## Ergonomic associated value access

CasePaths uses Swift reflection to automatically and extract associated values from _any_ enum in a
single, short expression. This helpful utility is made available as a public module function that
can be used in your own libraries and apps:

```swift
extract(
  case: Authentication.authenticated,
  from: .authenticated("cafebeef")
)
// Optional("cafebeef")
```

## Try it out today!

The official 0.1.0 release of [CasePaths](http://github.com/pointfreeco/swift-case-paths) is on
GitHub now, and we have more improvements and refinements coming soon. We hope that case paths will
unlock all new kinds of interesting, expressive code!
[Try it today](https://github.com/pointfreeco/swift-case-paths)!
