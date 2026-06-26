> Preamble: This week we are running a Point-Free blog bonanza to highlight new things happening
> across our ecosystem.
> * [DebugSnapshots now logs SwiftUI bindings](/blog/posts/214-debugsnapshots-now-logs-swiftui-bindings)
> * [**New macros for SwiftNavigation**](/blog/posts/215-new-macros-for-swiftnavigation)
> * [“Trait-ifying” our libraries to reduce transitive dependencies](/blog/posts/216-trait-ifying-our-libraries-to-reduce-transitive-dependencies)
> * [Proposing task-local test traits for Swift Testing](/blog/posts/217-proposing-task-local-test-traits-for-swift-testing)
> * [Xcode 27 support in the Point-Free ecosystem](/blog/posts/218-xcode-27-support-in-the-point-free-ecosystem)

Today we have a [big release] for our [SwiftNavigation] library that introduces two new macros that
unlock powerful techniques in all Swift applications, including SwiftUI and UIKit.

[big release]: https://github.com/pointfreeco/swift-navigation/releases/tag/2.9.0

## First, what is SwiftNavigation?

[SwiftNavigation] is a bit of a sleeper library in our ecosystem. It expands SwiftUI's toolkit
for navigation by providing additional tools that allow you to more precisely model your domains,
including using enums. But, that's only scratching the surface. It further brings a whole suite of
tools to UIKit that allow one to drive navigation from state in a manner similar to SwiftUI, 
including:

* Navigation APIs that are driven by state but mimic UIKit's native navigation APIs, such as 
[`present(item:)`][present-docs], as well as the ability to bind models to any `UIControl` (e.g. 
text fields, steppers, etc.). 
* Open source and platform independent `UIBinding` and `UITransaction` types for binding models
to UI components and attaching animations and other contextual data to state changes.
* An `observe` method for minimally observing changes to your models.

[present-docs]: https://swiftpackageindex.com/pointfreeco/swift-navigation/main/documentation/uikitnavigation/uikit/uiviewcontroller/present(item:ondismiss:content:)-4x5io

And best of all, most of these tools are back deployed all the way to iOS 13, so you can use them
today without waiting for your users to upgrade to the newest OS. It's a powerful library that we
think could use more attention, and so that's why we are excited to announce two new tools…

## `@CaseBindable`

This release brings new macros to the library, starting with `@CaseBindable`.

This macro allows you transform a binding of an enum into a binding of each case of the enum, in
an exhaustive manner. For example, a `Status` enum decorated with `@CaseBindable` like so:

```swift
@CaseBindable
enum Status {
  case inStock(quantity: Int)
  case outOfStock(isOnBackOrder: Bool)
}
```

…instantly gets the ability to switch on a `Binding<Status>` to derive a `Binding<Int>` and 
`Binding<Bool>` for each case. This means if you hold onto this status in SwiftUI state:

```swift
struct Item {
  var name = ""
  var status: Status
}

@State var item = Item()
```

…you can display a stepper for the quantity and a toggle for the back order in an exhaustive switch:

```swift
switch $item.status {
case .inStock(let $quantity):
  Stepper("\($quantity.wrappedValue)", value: $quantity)
case .outOfStock(let $isOnBackOrder):
  Toggle("Is on back order?", isOn: $isOnBackOrder)
}
``` 

> Note: The `$` syntax isn't real projection, so we do need to explicitly call to
> `$quantity.wrappedValue` when the underlying value is needed, but this just shows a real gap in the
> language for enums that will hopefully be addressed some day.

This makes it possible to model your domains as concisely as possible without giving up the ability
to derive bindings for SwiftUI controls.

## `@UITransactionEntry` for `UITransaction`s

There is also a smaller, but still useful, macro coming along for the ride: `@TransactionEntry`.

SwiftUI ships an `@Entry` macro that cuts down on the boilerplate needed to define custom
environment and transaction entries. We are doing the same for `UITransaction` values in the library,
which is our open source and platform independent port of SwiftUI's `Transaction`. A new entry can be
defined like so:

```swift
extension UITransaction {
  @UITransactionEntry var animateCount = false
}
```

With just those few lines you are now able to override a transaction value for a lexical scope:

```swift
withUITransaction(\.animateCount, true) {
  model.incrementButtonTapped()
}
```

…and retrieve the transaction value when observing changes to your model:

```swift
observe { [unowned self] transaction in
  if transaction.animateCount {
    UIView.transition(with: countLabel, options: .transitionCrossDissolve) {
      countLabel.text = "\(model.count)"
    }
  } else {
    countLabel.text = "\(model.count)"
  }
}
```

It's a small feature, but makes working with transaction values that much nicer.

## Try out SwiftNavigation today

If you need more powerful SwiftUI navigation APIs, or SwiftUI-like navigation APIs in UIKit,
then our [SwiftNavigation] library is worth a closer look. It's a tiny library that makes it easier
to model your domains correctly, and gets updates regularly rather than waiting for the year-long
release cycle of Apple. 

[case-bindable-pr]: https://github.com/pointfreeco/swift-navigation/pull/346
[swift-nav-gh]: https://github.com/pointfreeco/swift-navigation
[SwiftNavigation]: https://github.com/pointfreeco/swift-navigation
