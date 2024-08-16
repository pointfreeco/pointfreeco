Today we are releasing version [1.13][tca-1.13-release] of the 
[Composable Architecture][tca-gh] that brings a new suite of UIKit tools to the library. You can
now observe changes in a `Store` using the simple `observe` function, and you can drive navigation
(sheets, popovers, stacks, and more!) from state.

Join us for a quick preview of the tools, and be sure to update your projects to 1.13 to be able
to take advantage of these tools today!

## A preview of the tools

The first tool provided by the library is `observe`, which allows you to minimally observe 
changes to any state in your feature's store:

```swift
let store: StoreOf<Feature>

func viewDidLoad() {
  super.viewDidLoad()

  observe { [weak self] in
    guard let self else { return }

    countLabel.text = "Count: \(store.count)"
    if let fact = store.fact {
      factLabel.text = fact
    }
    activityIndicator.isHidden = !store.isLoadingFact
  }
}
```

Any state accessed in the trailing closure of `observe` will automatically be observed, and when
that state changes the closure will be invoked again, allowing you to update the UI with the 
freshest state.

Further, there is an all new `present(item:)` method defined on `UIViewController`s that allows 
you to present sheets, popovers, alerts and more in a state-driven manner. For example, suppose 
you had a feature that can navigate to a child feature modeled like so:

```swift
@Reducer
struct Feature {
  @ObservableState
  struct State {
    @Presents var child: Child.State?
    …
  }
  enum Action {
    case child(PresentationAction<Child.Action>)
    …
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      // Core logic for 'Feature' 
    }
    .ifLet(\.child, action: \.child) {
      Child()
    }
  }
}
```

Then you can present the child feature in a sheet whenever the state flips to a non-`nil` value
like so:

```swift
@UIBindable var store: StoreOf<Feature>

func viewDidLoad() {
  super.viewDidLoad()
  …
  present(
    item: $store.scope(state: \.child, action: \.child)
  ) { store in
    ChildViewController(store: store)
  }
}
```

This style of navigation also works when modeling the destinations a feature can navigate to as
an enum of possibilities, as described in our [tree-based navigation][tree-based-nav] article.

Further, the library also comes with a tool for powering features with
[stack-based navigation][stack-based-nav] using a special `NavigationStackController` class.
For example, if your app-level features has a stack of features that can be presented in a 
navigation stack like so:

```swift
@Reducer
struct AppFeature {
  struct State {
    var path = StackState<Path.State>()
    …
  }

  @Reducer
  enum Path {
    case addItem(AddFeature)
    case detailItem(DetailFeature)
    case editItem(EditFeature)
  }
  …
}
```

Then you can subclass `NavigationStackController` and call the initializer that allows you to 
provide a binding to the stack that drives navigation, a view controller for the root, and a 
trailing closure that describes how to transform a child feature in a view controller: 

```swift
class AppController: NavigationStackController {
  private var store: StoreOf<AppFeature>!

  convenience init(store: StoreOf<AppFeature>) {
    @UIBindable var store = store

    self.init(path: $store.scope(state: \.path, action: \.path)) {
      RootViewController(store: store)
    } destination: { store in
      switch store.case {
      case .addItem(let store):
        AddViewController(store: store)
      case .detailItem(let store):
        DetailViewController(store: store)
      case .editItem(let store):
        EditViewController(store: store)
      }
    }

    self.model = model
  }
}
```

This looks very similar to how one constructs a `NavigationStack` in SwiftUI when using the tools
of the Composable Architecture.

## Get started today

Be sure to update your dependency on the Composable Architecture to 1.13 today, and if you have
any questions please open a [discussion][tca-discussion] on the repo!

[tree-based-nav]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/stackbasednavigation
[tree-based-nav]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/treebasednavigation
[tca-1.13-release]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.13.0
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture/
[tca-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions
