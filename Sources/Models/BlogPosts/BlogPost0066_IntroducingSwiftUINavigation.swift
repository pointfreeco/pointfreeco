import Foundation

public let post0066_AnnouncingSwiftUINavigation = BlogPost(
  author: .pointfree,
  blurb: """
Today we are open sourcing SwiftUI Navigation, a collection of tools for making SwiftUI navigation simpler, more ergonomic and more precise.
""",
  contentBlocks: [
    .init(
      content: #"""
Over the past [9 weeks](/collections/swiftui/navigation) we have built up the concepts of SwiftUI navigation from the ground up. When we started the series we didn't think it would take us 6 hours of video to accomplish this, but along the way we discovered many tools for making working with SwiftUI navigation simpler, more ergnonomic and more precise.

We believe the tools we uncovered are highly applicable to everyone working with SwiftUI, and so today we are excited to release them in a new open source library.

## Motivation

SwiftUI comes with many forms of navigation (tabs, alerts, dialogs, modal sheets, popovers, navigation links, and more), and each comes with many ways to construct them. The ways of constructing roughly fall in two categories:

* "Fire-and-forget": Some initializers and methods do not take any bindings, which means SwiftUI fully manages navigation by itself. This means it is easy to get something on the screen quickly, but you also have no programmatic control over the navigation. Examples of this are the initializers on [`TabView`][TabView.init] and [`NavigationLink`][NavigationLink.init] that do not take a binding.

[NavigationLink.init]: https://developer.apple.com/documentation/swiftui/navigationlink/init(destination:label:)-27n7s
[TabView.init]: https://developer.apple.com/documentation/swiftui/tabview/init(content:)

* "State-driven": Most other initializers and methods do take a binding, which means you can mutate state in your domain to tell SwiftUI when it should activate or de-activate navigation. Using these APIs is more complicated than the "fire-and-forget" style, but doing so instantly gives you the ability to deep-link into any state of your application by just constructing a piece of data, handing it to a SwiftUI view, and letting SwiftUI handle the rest.

Navigation that is "state-driven" is the more powerful form of navigation, albeit slightly more complicated, but unfortunately SwiftUI does not ship with all the tools necessary to model our domains as concisely as possible and use SwiftUI's navigation APIs.

For example, to show a modal sheet in SwiftUI you can provide a binding of some optional state so that when the state flips to non-`nil` the modal is presented. However, the content of that model must be determined by a non-binding value:

```swift
struct ContentView: View {
  @State var draft: Post?

  var body: some View {
    Button("Edit") {
      self.draft = Post()
    }
    .sheet(item: self.$draft) { (draft: Post) in
      EditPostView(post: draft)
    }
  }
}
```

This means that whatever actions `EditPostView` performs will be disconnected from the source of truth, `draft`. Ideally we could derive a `Binding<Post>` for the draft so that any mutations `EditPostView` makes will be instantly visible in `ContentView`.

Another problem arises when trying to model multiple navigation destinations as multiple optional values. For example, suppose there are 3 different sheets that can be shown in a screen:

```swift
.sheet(item: self.$draft) { (draft: Post) in
  EditPostView(post: draft)
}
.sheet(item: self.$settings) { (settings: Settings) in
  SettingsView(settings: settings)
}
.sheet(item: self.$userProfile) { (userProfile: Profile) in
  UserProfile(profile: userProfile)
}
```

This forces us to hold 3 optional values in state, which has 2^3=8 different states, 4 of which are invalid. The only valid states is for all values to be `nil` or exactly one be non-`nil`. It makes no sense if two or more values are non-`nil`, for that would representing wanting to show two modal sheets at the same time.

Ideally we'd like to represent these navigation destinations as 3 mutually exclusive states so that we could guarantee at compile time that only one can be active at a time. Luckily for us Swift’s enums are perfect for this:

```swift
enum Route {
  case draft(Post)
  case settings(Settings)
  case userProfile(Profile)
}
```

And then we could hold an optional `Route` in state to represent that we are either navigating to a specific destination or we are not navigating anywhere:

```swift
@State var route: Route?
```

This would be the most optimal way to model our navigation domain, but unfortunately SwiftUI's tools do not make easy for us to drive navigation off of enums.

This library comes with a number of `Binding` transformations and navigation API overloads that allow you to model your domain as concisely as possible, using enums, while still allowing you to use SwiftUI's navigation tools.

For example, powering multiple modal sheets off a single `Route` enum looks like this with the tools in this library:

```swift
.sheet(unwrapping: self.$route, case: /Route.draft) { $draft in
  EditPostView(post: $draft)
}
.sheet(unwrapping: self.$route, case: /Route.settings) { $settings in
  SettingsView(settings: $settings)
}
.sheet(unwrapping: self.$route, case: /Route.userProfile) { $userProfile in
  UserProfile(profile: $userProfile)
}
```

## Tools

This library comes with many tools that allow you to model your domain as concisely as possible, using enums, while still allowing you to use SwiftUI's navigation APIs.

### Navigation overloads

This library provides additional overloads for all of SwiftUI's "state-driven" navigation APIs that allow you to activate navigation based on a particular case of an enum. Further, all overloads unify presentation in a single, consistent API:

* `NavigationLink.init(unwrapping:case:)`
* `View.alert(unwrapping:case:)`
* `View.confirmationDialog(unwrapping:case:)`
* `View.fullScreenCover(unwrapping:case:)`
* `View.popover(unwrapping:case:)`
* `View.sheet(unwrapping:case:)`

For example, here is how a navigation link, a modal sheet and an alert can all be driven off a single enum with 3 cases:

```swift
enum Route {
  case add(Post)
  case alert(Alert)
  case edit(Post)
}
struct ContentView {
  @State var posts: [Post]
  @State var route: Route?

  var body: some View {
    ForEach(self.posts) { post in
      NavigationLink(
        unwrapping: self.$route,
        case: /Route.edit,
        onNavigate: { isActive in self.route = isActive ? .edit(post) : nil },
        destination: EditPostView.init(post:)
      ) {
        Text(post.title)
      }
    }
    .sheet(unwrapping: self.$route, case: /Route.add) { $post in
      EditPostView(post: $post)
    }
    .alert(
      title: { Text("Delete \($0.title)?") },
      unwrapping: self.$route,
      case: /Route.alert
      actions: { post in
        Button("Delete") {
          self.posts.remove(post)
        }
      },
      message: { Text($0.summary) }
    )
  }
}

struct EditPostView: View {
  @Binding var post: Post

  var body: some View {
    ...
  }
}
```

### Navigation views

This library comes with additional SwiftUI views that transform and destructure bindings, allowing you to better handle optional and enum state:

  * `IfLet`
  * `IfCaseLet`
  * `Switch`

For example, suppose you were working on an inventory application that modeled in-stock and out-of-stock as an enum:

```swift
enum ItemStatus {
  case inStock(quantity: Int)
  case outOfStock(isOnBackorder: Bool)
}
```

If you want to conditionally show a stepper view for the quantity when in-stock and a toggle for the backorder when out-of-stock, you're out of luck when it comes to using SwiftUI's standard tools. However, the `Switch` view that comes with this library allows you to destructure a `Binding<ItemStatus>` in bindings of each case so that you can present different views:

```swift
struct InventoryItemView {
  @State var status: ItemStatus?

  var body: some View {
    Switch(self.$status) {
      CaseLet(/ItemStatus.inStock) { $quantity in
        HStack {
          Text("Quantity: \(quantity)")
          Stepper("Quantity", value: $quantity)
        }
        Button("Out of stock") { self.status = .outOfStock(isOnBackorder: false) }
      }

      CaseLet(/ItemStatus.outOfStock) { $isOnBackorder in
        Toggle("Is on back order?", isOn: $isOnBackorder)
        Button("In stock") { self.status = .inStock(quantity: 1) }
      }
    }
  }
}
```

### Binding transformations

This library comes with tools that transform and destructure bindings of optional and enum state, which allows you to build your own navigation views similar to the ones that ship in this library.

  * `Binding.init(unwrapping:)`
  * `Binding.case(_:)`
  * `Binding.isPresent()` and `Binding.isPresent(_:)`

For example, suppose you have built a `BottomSheet` view for presenting a modal-like view that only takes up the bottom half of the screen. You can build the entire view using the most simplistic domain modeling where navigation is driven off a single boolean binding:

```swift
struct BottomSheet<Content>: View where Content: View {
  @Binding var isActive: Bool
  let content: () -> Content

  var body: some View {
    ...
  }
}
```

Then, additional convenience initializers can be introduced that allow the bottom sheet to be created with a more concisely modeled domain.

For example, an initializer that allows the bottom sheet to be presented and dismissed with optional state, and further the content closure is provided a binding of the non-optional state. We can accomplish this using the `isPresent()` method and `Binding(unwrapping:)` initializer:

```swift
extension BottomSheet {
  init<Value, WrappedContent>(
    unwrapping value: Binding<Value?>,
    @ViewBuilder content: @escaping (Binding<Value>) -> WrappedContent
  )
  where Content == WrappedContent?
  {
    self.init(
      isActive: value.isPresent(),
      content: { Binding(unwrapping: value).map(content) }
    )
  }
}
```

An even more robust initializer can be provided by providing a binding to an optional enum _and_ a case path to specify which case of the enum triggers navigation. This can be accomplished using the `case(_:)` method on binding:

```swift
extension BottomSheet {
  init<Enum, Case, WrappedContent>(
    unwrapping enum: Binding<Enum?>,
    case casePath: CasePath<Enum, Case>,
    @ViewBuilder content: @escaping (Binding<Case>) -> WrappedContent
  )
  where Content == WrappedContent?
  {
    self.init(
      unwrapping: `enum`.case(casePath),
      content: content
    )
  }
}
```

Both of these more powerful initializers are just conveniences. If the user of `BottomSheet` does not want to worry about concise domain modeling they are free to continue using the `isActive` boolean binding. But the day they need the more powerful APIs they will be available.

## Learn More

SwiftUI Navigation's tools were motivated and designed over the course of many episodes on [Point-Free](https://www.pointfree.co), a video series exploring functional programming and the Swift language, hosted by [Brandon Williams](https://twitter.com/mbrandonw) and [Stephen Celis](https://twitter.com/stephencelis).

You can watch all of the episodes [here](https://www.pointfree.co/collections/swiftui/navigation).

<a href="https://www.pointfree.co/collections/swiftui/navigation">
  <img alt="video poster image" src="https://d3rccdn33rt8ze.cloudfront.net/episodes/0161.jpeg" width="600">
</a>

## Try it today

We've already started to get a lot of use out of [SwiftUI Navigation](https://github.com/pointfreeco/swiftui-navigation), but we think there is so much more than can be done. Give it a spin today to develop new, creative debugging and testing tools for your team and others today!
"""#,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 66,
  publishedAt: Date(timeIntervalSince1970: 1637042400),
  title: "Open Sourcing SwiftUI Navigation"
)
