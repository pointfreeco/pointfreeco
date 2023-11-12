!> [preamble]: To celebrate the release of Swift macros we releasing updates to 4 of our popular 
> libraries to greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
> [ComposableArchitecture][tca-gh], [SwiftUINavigation][sui-nav-gh], and 
> [Dependencies][dependencies-gh]. Each day this week we will detail how macros have allowed us to 
> massively simplify one of these libraries, and increase their powers.
> * [Macro Bonanza: CasePaths](/blog/posts/117-macro-bonanza-case-paths)
> * [Macro Bonanza: Composable Architecture](/blog/posts/118-macro-bonanza-composable-architecture)
> * [**Macro Bonanza: SwiftUINavigation**](/blog/posts/119-macro-bonanza-swiftui-navigation)
> * _Macro Bonanza: Dependencies (tomorrow!)_
> 
> [case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
> [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
> [sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
> [dependencies-gh]: http://github.com/pointfreeco/swift-dependencies

Today we are releasing [version 1.1][sui-nav-1.1] of our popular library, 
[SwiftUINavigation][sui-nav-gh], which is a collection of tools that help you better model 
navigation using enums. This release does not introduce a macro to the library itself, but it
does heavily make use of the new `@CasePathable` macro that we discussed [earlier this 
week](/blog/posts/117-macro-bonanza-case-paths). We can now greatly simplify how you interact with
SwiftUI navigation view modifiers while still modeling your domains as concisely as possible
with enums.

Join us for a quick overview of the new tools, and be sure to update to [version 1.1][sui-nav-1.1]
of the library to take advantage of these tools.

[sui-nav-1.1]: https://github.com/pointfreeco/swiftui-navigation/releases/tag/1.1.0
[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies

## Better domain modeling tools

The [SwiftUINavigation][sui-nav-gh] library provides tools that allow you to drive navigation in 
your features using a single enum. This makes it possible to prove at compile time that only a 
single destination can be active at a time, helping reduce the complexity of your features.

For example, if you have an observable model for a meeting that is capable of showing an edit
feature in a sheet, drilling down to a record meeting feature, or showing an alert, then an optimal
way to design this domain is the following: 

```swift
@Observable
class MeetingDetailModel {
  var destination: Destination?

  enum Destination {
    case alert(AlertState<AlertAction>)
    case edit(EditMeetingModel)
    case record(RecordMeetingModel)
  }

  …
}
```

The single piece of optional `destination` state determines whether or not we are currently 
navigated to a particular feature.

This can be powerful, but unfortunately vanilla SwiftUI does not provide the tools to drive 
navigation off of such a domain. Its tools, such as the `sheet`, `alert` and `navigationDestination`
view modifiers, are tuned for bindings of booleans, and sometimes bindings of optionals.

Well, our [SwiftUINavigation][sui-nav-gh] library tries to fill the gap, with the help of our
[CasePaths][case-paths-gh] library, by providing view modifiers that allow you to drive navigation
from the `Destination` enum:

```swift
.alert(
  self.$model.destination,
  case: /MeetingDetailModel.Destination.alert
) { action in
  await self.model.alertButtonTapped(action)
}
.navigationDestination(
  unwrapping: self.$model.destination,
  case: /MeetingDetailModel.Destination.record
) { $model in
  RecordMeetingView(model: model)
}
.sheet(
  unwrapping: self.$model.destination,
  case: /MeetingDetailModel.Destination.edit
) { $model in
  EditMeetingView(model: model)
}
```

These are custom view modifiers that ship with the [SwiftUINavigation][sui-nav-gh] library that
allow you to drive navigation from an optional enum value. You first specify a binding to the 
optional enum value, and then you specify a case path to isolate the case you care about for the
navigation.

This works incredibly well, but it also a bit verbose.

## Navigation with dynamic case lookup

Thanks to [the new `@CasePathable` macro][case-path-bonanza-blog] provided by our CasePaths library,
we can greatly simplify the above view modifiers. We can start by annotating the `Destination` enum
with the macro:

[case-paths-bonanza-blog]: /blog/posts/117-macro-bonanza-case-paths

```swift
@CasePathable
enum Destination {
  case alert(AlertState<AlertAction>)
  case edit(EditMeetingModel)
  case record(RecordMeetingModel)
}
```

Just that one line of additional code gives us the ability to perform dot-chaining syntax onto
the `$model.destination` binding for each case of the enum. This allows us to derive bindings
that can be handed to the SwiftUI view modifiers, which massively simplifies the code we saw above:

```diff
-.alert(
-  self.$model.destination,
-  case: /MeetingDetailModel.Destination.alert
-) { action in
+.alert(self.$model.destination.alert) { action in
   await self.model.alertButtonTapped(action)
 }
-.navigationDestination(
-  unwrapping: self.$model.destination,
-  case: /MeetingDetailModel.Destination.record
-) { $model in
+.navigationDestination(item: self.$model.destination.record) { model in
   RecordMeetingView(model: model)
 }
-.sheet(
-  unwrapping: self.$model.destination,
-  case: /MeetingDetailModel.Destination.edit
-) { $model in
+.sheet(item: self.$model.destination.edit) { model in  
   EditMeetingView(model: model)
 }
```

There's no need to deal with explicit case paths or the `/` prefix operator for constructing case
paths. It's simpler and more fluent Swift code. We are even now using the vanilla SwiftUI view
modifiers `navigationDestination(item:)` and `sheet(item:)`. There is no need for a custom view
modifier anymore.

<!-- 
## Form bindings with dynamic case lookup

TODO: can discuss this if we want: form bindings: self.$model.status.inStock
-->

## Get started today

Update your dependency on SwiftUINavigation to [version 1.1][sui-nav-1.1] today to start taking 
advantage of the new `@CasePathable` macro, and more. Tomorrow we will discuss how these new case 
path tools have massively improved our [Composable Architecture][tca-gh] library. 

[sui-nav-1.1]: https://github.com/pointfreeco/swiftui-navigation/releases/tag/1.1.0
