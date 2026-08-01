Swift macros are one of the most powerful features added to the language in recent years, allowing libraries to generate boilerplate automatically to unlock capabilities that were previously impossible without direct support in the compiler. We use them heavily in our ecosystem: a `@Table` macro for type-safe SQL queries, `@CasePathable` for key path syntax on enums, `@DebugSnapshot` for debugging and testing tools on reference types, and more.

But macros have a major limitation. They can only see the underlying syntax of Swift code but do not get access to the static type information. Macros essentially only see the stringy parts of the code.

However, some amount of type checking does occur before macros are expanded, and it's just enough for us to exploit and get access to a small amount of static type information in our macros. It may sound surprising, but it's totally possible and we now employ this technique in our `@Table` and `@DebugSnapshot` macros (and more) to provide better type inference and diagnostics.

Join us for a quick overview of this technique!

## The problem

One of the prototypical use cases of macros is that of deriving `Equatable` conformances for types. Swift has compiler magic for automatically synthesizing such conformances for structs when every field in the type is `Equatable`, and has done so for the last 8 years. But wouldn't it be nicer if a macro could implement that functionality outside of the compiler?

It is easy to imagine a kind of `@DeriveEquatable` macro that when applied to a struct:

```swift
@DeriveEquatable
struct User {
  let id: UUID 
  var name = ""
} 
```

…automatically expands to the following code:

```diff
 struct User {
   let id: UUID 
   var name = ""
 } 
+extension User: Equatable {
+  static func == (lhs: Self, rhs: Self) -> Bool {
+    lhs.id == rhs.id && lhs.name == rhs.name
+  }
+}
```

Such a macro is straightforward to write, but giving it a good developer experience is surprisingly tricky.

If your type includes another type that is not yet `Equatable`:

```diff
 @DeriveEquatable
 struct User {
   let id: UUID 
+  var address: Address
   var name = ""
 }
+struct Address {
+  var street: String
+  var city: String
+}
```

…then the generated `==` function is no longer correct. But the error for this is hidden inside the generated macro code, and it does not explain exactly what is wrong:

<div style="position: relative; padding-top: 43.54215003866976%;">
  <iframe
    src="https://customer-1wj3kl26hvlz1r1i.cloudflarestream.com/795757acd5cb2886bfeb9c03069b38e2/iframe?muted=true&preload=true&loop=true&autoplay=true&poster=https%3A%2F%2Fcustomer-1wj3kl26hvlz1r1i.cloudflarestream.com%2F795757acd5cb2886bfeb9c03069b38e2%2Fthumbnails%2Fthumbnail.jpg%3Ftime%3D%26height%3D600"
    loading="lazy"
    style="border: none; position: absolute; top: 0; left: 0; height: 100%; width: 100%;"
    allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;"
    allowfullscreen="true"
  ></iframe>
</div>

It tells you that `==` cannot be applied, but why? It's because `Address` is not yet `Equatable`.

Wouldn't it be better if the macro could emit a warning directly inline, right on the field that is causing the problem:

<div style="position: relative; padding-top: 43.54215003866976%;">
  <iframe
    src="https://customer-1wj3kl26hvlz1r1i.cloudflarestream.com/db9dd04f075fb98adefc3f798d1cd6b3/iframe?muted=true&preload=true&loop=true&autoplay=true&poster=https%3A%2F%2Fcustomer-1wj3kl26hvlz1r1i.cloudflarestream.com%2Fdb9dd04f075fb98adefc3f798d1cd6b3%2Fthumbnails%2Fthumbnail.jpg%3Ftime%3D%26height%3D600"
    loading="lazy"
    style="border: none; position: absolute; top: 0; left: 0; height: 100%; width: 100%;"
    allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;"
    allowfullscreen="true"
  ></iframe>
</div>

This would be a much better experience for users of our macro, but unfortunately the macro does not get access to this kind of type information. When `@DeriveEquatable` expands it does not get to check if `Address` conforms to `Equatable`.

Well, what if we were to tell you it is possible to employ some clever tricks with macros that do give us access to static type information before expanding the macros?

## The solution

Let's start with the first problem. We want to localize the diagnostics for `@DeriveEquatable` to call out the non-`Equatable` fields rather than hide the error message deep in the expanded macro code:

```swift:4:fail
@DeriveEquatable
struct User {
  let id: UUID 
  var address: Address
  var name: String
}
```

> Failed: 'Address' is not Equatable

It is true that we cannot do this with `@DeriveEquatable` alone because it does not see any static type information on `address`. It only literally sees a type annotation of the string "Address".

However, the extension macro `@DeriveEquatable` can apply an attached macro to the `var address: Address` declaration, and attached macros _do_ get some type information. In the [proposal] for attached macros the following is stated:

[proposal]: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0389-attached-macros.md#proposed-solution

> SE-0389 Excerpt: As with expression macros, attached declaration macros are declared with `macro`, and have [type-checked macro arguments](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0382-expression-macros.md#type-checked-macro-arguments-and-results) that allow their behavior to be customized.

And this comment links to the proposal for expression macros, in particular the section "Type-checked macro arguments and results", and it has the following to say:

> SE-0382 Excerpt: Macro arguments are type-checked against the parameter types of the macro prior to instantiating the macro.

This clearly states that Swift does perform a bit of type checking before macros are expanded, and that type checking can influence the macros' behavior.

To see this concretely, suppose we had an attached peer macro called `@EquatableCheck` that took a generic type as an argument:

```swift
@attached(peer) 
public macro EquatableCheck<T>(_: T.Type) = 
  #externalMacro(…)
```

Then when the `@DeriveEquatable` macro expands it will apply the `@EquatableCheck` macro to each stored property, and pass the type of the field to the macro:

```diff
 @DeriveEquatable
 struct User {
+  @EquatableCheck(UUID.self)
   let id: UUID 
+  @EquatableCheck(Address.self)
   var address: Address
+  @EquatableCheck(String.self)
   var name: String
 }
```

And now for a fun little trick! Just like functions and methods in Swift, macros are capable of being overloaded. We can define an overload of `@EquatableCheck` that works with `Equatable` types:

```swift
@attached(peer) 
public macro EquatableCheck<T: Equatable>(_: T.Type) =
  #externalMacro(…)
```

Swift will correctly choose between these two versions of the macro depending on whether the argument is `Equatable` or not. This means that although the macro does not get access to static type information we can _choose_ between two macros based on static type information.

So, if we implement the fully generic `@EquatableCheck` macro by having it expand a diagnostic failure:

```swift
enum EquatableCheckFailMacro: PeerMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    context.diagnose(
      Diagnostic(
        node: Syntax(declaration),
        message: MacroExpansionErrorMessage(
          "Type is not Equatable"
        ),
      )
    )
    return []
  }
}
```

And if we implement the `Equatable` constrained macro by having it expand nothing at all:

```swift
enum EquatableCheckPassMacro: PeerMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    []
  }
}
```

Then we will have the desired behavior:

```swift:6:fail
@DeriveEquatable
struct User {
  @EquatableCheck(UUID.self)
  let id: UUID 
  @EquatableCheck(Address.self)
  var address: Address
  @EquatableCheck(String.self)
  var name: String
}
```

> Failed: Type is not Equatable

And best of all, this failure appears directly inline on the type instead of hidden away in the expanded `==` implementation from the macro:

![[Daily/attachments/derive-equatable-good.mov]]

We can improve this a bit more too. Right now `@EquatableCheck` takes only a type as an argument, which means if you elide the type and provide a default:

```swift:4-5
@DeriveEquatable
struct User {
  let id: UUID 
  var address = Address()
  var name = ""
}
```

…then we don't know what type to pass to `@EquatableCheck`. The Swift compiler can infer the types of the fields to be `Address` and `String`, but that information is not available to the macro.

Well, this is nothing that another overload can't fix. We can provide two more overloads that take generic values and `Equatable` values as arguments:

```swift
@attached(peer) 
public macro EquatableCheck<T>(_: T) =
  #externalMacro(…)

@attached(peer) 
public macro EquatableCheck<T: Equatable>(_: T) =
  #externalMacro(…)
```

These macros differ from the previous macros in that they take values, not types, as arguments. And again, the generic macro will expand with a diagnostic failure whereas the `Equatable` constrained macro will expand nothing at all.

This allows the `name` field to type check as `Equatable`, while the `address` field gets caught as not being `Equatable`:

```swift:4:fail
@DeriveEquatable
struct User {
  let id: UUID 
  var address = Address()
  var name = ""
}
```

> Failed: Type is not Equatable

So we have now been able to access a modest amount of type information in our macros via overloading!

## A more advanced example

Suppose we wanted to build some extra smarts into this `@DeriveEquatable` macro. As we discussed in our [Equatable & Hashable] series, `Equatable` classes are fraught. 99% of the time classes should use their object identity for `==` and `hash(into:)`, and they should almost never use the data they hold.

[Equatable & Hashable]: https://www.pointfree.co/collections/back-to-basics/equatable-and-hashable

What if we wanted `@DeriveEquatable` to allow types to hold onto non-`Equatable` objects and it would use object identity `===` for such objects? The canonical example of this is a SwiftUI view that holds onto an observable model:

```swift
struct SearchView: View {
  let sort: Sort
  let model: SearchModel
  …
}
```

Giving `SearchView` an `Equatable` conformance allows SwiftUI to [skip unnecessary re-computations] of the `body` of the view. So, this sounds like a good use case for the `@DeriveEquatable` macro:

[skip unnecessary re-computations]: https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896

```swift:4:fail
@DeriveEquatable
struct SearchView: View {
  let sort: Sort
  let model: SearchModel
  …
}
```

> Failed: 'SearchModel' is not Equatable

…however the `SearchModel` class is not `Equatable`. We could take the time to conform it using object identity (or a bit of [library code] makes it a one liner), but wouldn't it be nicer if `@DeriveEquatable` could see that `SearchModel` is a non-`Equatable` class and decide to implement equality with `===` on its own?

[library code]: https://github.com/pointfreeco/swift-navigation/blob/2.10.3/Sources/SwiftNavigation/HashableObject.swift

Well, again `@DeriveEquatable` cannot do this because it only sees syntax. It is not able to see that `SearchModel` is a class, nor can it see what protocols it conforms to. But there is another trick we can employ to make this possible.

We can start with the previous trick by defining a new `@EquatableCheck` overload that is constrained to `AnyObject`:

```swift
@attached(peer) 
public macro EquatableCheck<T: AnyObject>(_: T.Type) =
  #externalMacro(…)
```

…and its implementation will expand nothing. That will prevent non-`Equatable` objects from being flagged by the `@EquatableCheck` macro.

Next, the `@DeriveEquatable` macro will expand two private static methods inside the type it is attached to. A method for checking the equality of `Equatable` types, and a method for checking the equality of object types:

```swift
private static func _$isEqual<T: Equatable>(_ lhs: T, _ rhs: T) -> Bool {
  lhs == rhs
}
private static func _$isEqual<T: AnyObject>(_ lhs: T, _ rhs: T) -> Bool {
  lhs === rhs
}
```

And finally, these methods will be used by `@DeriveEquatable` when implementing `==` instead of using `==` directly:

```swift
extension SearchView: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    _$isEqual(lhs.sort, rhs.sort) 
      && _$isEqual(lhs.model, rhs.model)
  }
}
```

This allows regular `Equatable` types to check for equality using `==`, and objects will use `===`.

## How we are using these techniques in the Point-Free ecosystem

We are using this trick in a number of places in the Point-Free ecosystem to improve the developer experience when using our tools.

### @Table macro

The `@Table` macro in [StructuredQueries] is responsible for generating enough static information about a type to make it possible to construct type-safe and schema-safe SQL queries. By default, one can only store simple data types in a table that are recognized by SQLite, such as strings, integers, doubles, and data blobs. But often one needs to store more complex types (raw representables, JSON, nested columns, etc.), and to do so one must take a few extra steps.

[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries

And now the `@Table` macro can guide you to do this correctly! For example, if you try to hold onto a type in a table that is not compatible with SQLite, you get a clear error message letting you know that you need to add a representation for converting the value back-and-forth to a SQLite-compatible type:

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/30813f8b-eed0-480b-bfef-cdef768b9600/public)

If the `@Table` macro detects that `location` is `Codable`, then it can suggest you store the value as JSON text or JSONB binary:

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/05875b66-5bc2-4962-9b19-d4d6c2a11300/public)

And if the `@Table` macro detects that the value you are storing is `RawRepresentable`, it can suggest that you conform that type to `QueryBindable`, or you can provide an explicit representation:

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/659bfb16-56b8-4f4a-1929-82fd96be8600/public)

Prior to the techniques discussed in this post, storing an unsupported type in a `@Table` type meant you would get a cryptic error message hidden deep in dozens of lines of macro generated code.
### @DebugSnapshot macro

The `@DebugSnapshot` macro in our [DebugSnapshots] library gives testing superpowers to reference types, which are typically quite difficult to test. It does this by performing a static snapshot of a type's data at various points in time so that one can exhaustively assert on how the state changes.

However, in order to snapshot deeply nested reference types, one must apply additional macros to determine how the snapshotting is performed. For example, if you have an observable model that can present a form for creating or editing a record (such as a reminder), then it could be modeled like so:

```swift
@DebugSnapshot
@Observable
class RemindersListModel {
  var reminders: [Reminder] = []
  var reminderForm: ReminderFormModel?
  …
}

@DebugSnapshot
@Observable
class ReminderFormModel {
  var reminder: Reminder.Draft
  …
}
```

In the first release of DebugSnapshots this code would compile without any warning even though technically changes to the `reminderForm` property could not be properly snapshotted. The fix is to apply the `@DebugSnapshotConvertible` macro:

```diff
 @DebugSnapshot
 @Observable
 class RemindersListModel {
   var reminders: [Reminder] = []
+  @DebugSnapshotConvertible
   var reminderForm: ReminderFormModel?
   …
 }
```

…but there is no reason for our users to know to do this.

Well, thanks to the type inference tricks described in this article, we can now detect when a property held in a `@DebugSnapshot` class is itself `@DebugSnapshot`, and prompt the user to apply the `@DebugSnapshotConvertible`:

[DebugSnapshots]: https://github.com/pointfreeco/swift-debug-snapshots

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/47ae5082-f3d1-40e1-56ad-56b2f48c7e00/public)

Let's let the user know that the code they have written is not quite right, and there's a bit more to do.

## Conclusion

We hope that you can see how much potential there is in this technique. It is not true that macros have zero visibility into the static types of the code they are attached to. Under certain circumstances you are able to detect what protocols a type conforms to, as well as the inferred type of a value. 

Further, the more you provide these kinds of diagnostics for your macros, the better AI agents will be able to write code using your library in the correct manner. Agents can easily consume these diagnostics and fix-its and determine the next best action to take. This technique can be incredibly powerful, and it's something we are using to great effect in our libraries and will continue using.
