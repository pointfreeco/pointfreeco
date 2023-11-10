To celebrate the release of Swift macros we are releasing updates to 4 of our popular libraries to 
greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
[SwiftUINavigation][sui-nav-gh], [ComposableArchitecture][tca-gh], and 
[Dependencies][dependencies-gh]. Each day this week we will detail how macros have allowed us to 
massively simplify one of these libraries, and increase their powers.

And today we are discussing our [SwiftUINavigation][sui-nav-gh] library, which brings tools to 
SwiftUI that allow you to better drive navigation from optionals and enums.

[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies

## Better domain modeling tools

The SwiftUINavigation library provides tools that allow you to drive navigation in your features
using a single enum. This makes it possible to prove at compile time that only a single 
destination can be active at a time, and helping to reduce the complexity of your features.

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

  // ...
}
```

The single piece of optional `destination` state determines whether or not we are currently 
navigated to a particular feature.

This can be powerful, but unfortunately vanilla SwiftUI does not provide the tools to drive 
navigation off of such a domain. It's tools, such as the `sheet`, `alert` and 
`navigationDestination` view modifiers, are tuned for bindings of booleans, and sometimes bindings 
of optionals.

Well, our [SwiftUINavigation][sui-nav-gh] library tries to fill the gap, with the help of our
[CasePaths][case-paths-gh] library, by providing view modifiers that allow you to drive navigation
from the `Destination` enum:

```swift
.alert(
  unwrapping: self.$model.destination,
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
) { $editModel in
  EditMeetingView(model: editModel)
}
```

This works incredibly well, but it also a bit verbose.

## Navigation with @CasePathable

Thanks to the new `@CasePathable` macro provided by our CasePaths library, we can greatly simplify
the above view modifiers. We can start by annotating the `Destination` enum with the macro:

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
that can be handed to the SwiftUI view modifiers:

```swift
.alert(unwrapping: self.$model.destination.alert) { action in
  await self.model.alertButtonTapped(action)
}
.navigationDestination(item: self.$model.destination.record) { model in
  RecordMeetingView(model: model)
}
.sheet(item: self.$model.destination.edit) { editModel in
  EditMeetingView(model: editModel)
}
``` 

There's no need to deal with explicit case paths, or the `/` prefix operator for constructing case
paths. It's simpler and more fluent Swift code.

<!-- 
TODO: can discuss this if we want: form bindings: self.$model.status.inStock
-->

## Get started today

Update your dependency on SwiftUINavigation to [1.1][sui-nav-1.1] today to start taking advantage of
the new `@CasePathable` macro, and more. Tomorrow we will discuss how these new case path tools have
massively improved our [Composable Architecture][tca-gh] library. 

[sui-nav-1.1]: todo
