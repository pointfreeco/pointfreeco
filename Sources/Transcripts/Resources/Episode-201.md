## Introduction

@T(00:00:05)
For the past many weeks we have gone deep into Swift’s concurrency tools, and then brought many of those tools into the Composable Architecture. This greatly improved the ergonomics for constructing complex effects, allowed us to tie the lifetime of effects to the lifetime of views, and amazingly everything remained 100% testable. In fact, we think that the Composable Architecture offers one of the most cohesive testing solutions for integrated asynchronous code in the entire Swift ecosystem.

@T(00:00:31)
While we greatly improved the ergonomics of constructing complex effects, the ergonomics of constructing complex reducers hasn’t changed much since the library was first released over 2 years ago. It’s now time to focus on that, and we think it’s maybe an even bigger update to the library than the concurrency tools were.

@T(00:00:47)
We are going to improve the ergonomics of nearly every facet of creating a feature with the library, and make all new patterns possible that were previously impossible. We have uncovered many far reaching applications of these ideas, and we believe that there is still a lot more out there to be discovered.

@T(00:01:02)
Today we are going to start exploring what it means to put a protocol in front of our reducers. This will mean that instead of constructing a reducer by providing a closure that takes some state so that you can mutate it, you will instead create a type that conforms to the reducer protocol. And operators defined on reducers will return a whole new type rather than constructing a closure that calls out to other reducers under the hood.

@T(00:01:25)
This idea was first brought up by Composable Architecture community members over a year ago, and we have actively researched the idea since then, but it took some new features of Swift 5.7 to make this style of reducer ergonomic and performant.

@T(00:01:38)
This change will help with a variety of things. Some of the things changing may seem like simple aesthetics, such as giving us a dedicated namespace to house state and action types. But then others help us completely reimagine the way we compose reducers, and how to push information deep throughout a reducer hierarchy, with applications to how we structure our dependencies and even navigation.

@T(00:02:00)
Now we want to stress that all the changes we discuss in this series of episodes, as well as everything in the final release of the library, is 100% backwards compatible with all of your existing Composable Architecture code. Once you upgrade to the newest version of the library, you will not need to make a single change to your code, and then later you can incrementally adopt these newer tools as you see fit. A few things will be soft-deprecated, which means it’s technically deprecated but we aren’t going to loudly warn about it yet, and then someday in the future we will fully deprecate, and then some day further into the future we will have an officially breaking change to remove some old cruft.

@T(00:02:35)
We are going to kick off this series to highlight a few things about the current library that are not quite ideal. This will set the stage for seeing what can be improved in the library, and then we can start tackling some of those things.

## Structure

@T(00:02:50)
Let’s start with something that seems like merely an aesthetic issue, but does affect many people, and that’s how to structure a feature written in the Composable Architecture.

@T(00:02:59)
We have released quite a bit of public code using the Composable Architecture, including the case studies and demos in this repo as well as our open-source word game, isowords. In all of those examples we mostly follow the pattern of defining the domain at the top of the file, which includes the state, action and environment. Abstractly, the domain looks like this:

```swift
import ComposableArchitecture

struct FeatureState {
}
enum FeatureAction {
}
struct FeatureEnvironment {
}
```

@T(00:03:47)
Followed by a file-scope variable for defining the reducer that implements the feature’s logic:

```swift
let featureReducer = Reducer<FeatureState, FeatureAction, FeatureEnvironment> { state, action, environment in
  .none
}
```

@T(00:03:51)
This line gets a little long, so sometimes you may need to add some newlines to get it all on the screen at once:

```swift
let featureReducer = Reducer<
  FeatureState,
  FeatureAction,
  FeatureEnvironment
> { state, action, environment in
    .none
}
```

@T(00:04:02)
This style can make some people a little uncomfortable. First, some people see state, action and environment as making up one single unit, and so like to group them into some kind of namespace:

```swift
enum Feature {
  struct State {
  }
  enum Action {
  }
  struct Environment {
  }
}
```

@T(00:04:28)
We personally prefer to use modules to group features in a “namespace”, and think it solves most of the problems this enum is trying to solve, but we also understand it’s not always possible or reasonable to organize things into modules.

@T(00:04:42)
Although this empty enum does act as a namespace, it is a little cumbersome. Because `Feature` is not used as a real type anywhere in the application, you often do not get the opportunity to elide it by using type inference. You usually have to fully qualify it with:

```swift
Feature.State
```

@T(00:05:00)
So, that’s a pattern that some people employ to ease their discomfort with not having the domain grouped into a single type, but even more people are bothered by the file-scope defined reducer variable:

```swift
let featureReducer = Reducer<
  FeatureState,
  FeatureAction,
  FeatureEnvironment
> { state, action, environment in
  .none
}
```

@T(00:05:10)
People in the Swift community generally have some discomfort with file-scope variables and functions, especially non-private ones. They look like globals, but they aren’t really globals because Swift doesn’t have true globals. At the end of the day these kinds of variables are always at least scoped to the module, but still, the discomfort remains for many.

@T(00:05:26)
So, one thing we could do is move the reducer to the `Feature` enum “namespace”, but then we have to make it a static:

```swift
enum Feature {
  …

  static let reducer = Reducer<
    State,
    Action,
    Environment
  > { state, action, environment in
    .none
  }
}
```

@T(00:05:41)
Another structure-related annoyance people encounter, especially with large, complex reducers, is where to put helpers that can be used in the reducer. For example, we may have two button tap actions in the UI that have some overlapping logic:

```swift
enum Action {
  case buttonTapped
  case otherButtonTapped
}
```

@T(00:06:03)
Perhaps there’s a specific piece of state that gets mutated in the same way and a complex effect that is returned from both actions.

@T(00:06:12)
Well, one way to accomplish this is to have a little private helper function. If the helper needs to both mutate state and return an effect, it means you need to pass some `inout` state and the environment to it:

```swift
enum Feature {
  …

  private static func sharedButtonTapLogic(
    state: inout State,
    environment: Environment
  ) -> Effect<Action, Never> {
    .none
  }
}
```

@T(00:06:46)
…and then call that from the actions, in addition to whatever non-shared logic needs to be executed:

```swift
switch action {
case .buttonTapped:
  // additional button tap logic
  return sharedButtonTapLogic(
    state: &state, environment: environment
  )
case .otherButtonTapped:

  // additional other button tap logic
  return sharedButtonTapLogic(
    state: &state, environment: environment
  )
}
```

@T(00:07:11)
This gets the job done, and is what we recommend in the Composable Architecture today, but it isn’t without its annoyances. We have to pass the state and environment to any helpers that do anything moderately interesting.

@T(00:07:24)
Another approach would be to define these helpers as mutating functions on the state:

```swift
extension Feature.State {
  fileprivate mutating func doSomething(
    environment: Feature.Environment
  ) -> Effect<Feature.Action, Never> {
    .none
  }
}
```

@T(00:07:56)
Then you could do this:

```swift
switch action {
case .buttonTapped:
  // additional button tap logic
  return state.sharedButtonTapLogic(
    environment: environment
  )
case .otherButtonTapped:
  // additional other button tap logic
  return state.sharedButtonTapLogic(
    environment: environment
  )
}
```

@T(00:08:05)
This works, but is perhaps weird to throw such significant, behavioral logic on the value type representing the state. There is technically nothing technically wrong with it, but this style will probably make some people unconformable, and also, at the end of the day you still have to pass the environment to it if you want to return any effects.

@T(00:08:23)
Something else we see people doing often is to share pieces of logic in a reducer by sending synchronous actions from effects. So, instead of having a `sharedButtonTapLogic` function, you would have a `sharedButtonTapLogic` action that houses the shared logic, and you would send that action from other actions:

```swift
enum Action {
  case buttonTapped
  case otherButtonTapped
  case sharedButtonTapLogic
}
…
static let reducer = Reducer<
  State,
  Action,
  Environment
> { state, action, environment in
  switch action {
  case .buttonTapped:
    return Effect(value: .sharedButtonTapLogic)

  case .otherButtonTapped:
    return Effect(value: .sharedButtonTapLogic)

  case .sharedButtonTapLogic:
    // Shared logic
    return .none
  }
}
```

@T(00:09:14)
We highly recommend against this pattern. First of all this pattern isn’t as flexible as the other two styles we described. With the shared function or method we are able to call it before or after the additional logic we want to layer on, and we can even take just the state mutation or discard the effects, or take only the effects and discard the state mutation. We can even tweak the environment before calling the shared helper. In general, it’s just very flexible. Also, in the method and function style we could make those helpers private, yet with the synchronous action we are making it completely public to every parent layer above this feature.

@T(00:09:52)
But also, sending synchronous actions from effects like this is inefficient and indirect for something that should be quite simple. In general, sending actions into the system can be heavy weight considering that every layer of the entire composed application can listen for those actions.

@T(00:10:07)
So, sending synchronous actions just to share logic can make the system less performant. Also, it seems strange to enlarge your domain just to share logic, and can even make your tests read strangely since you need to assert on all of these synchronous communication actions being sent all over the place.

## Compiler strain

@T(00:10:22)
So, that’s a couple of somewhat superficial examples of how the current style of developing features in the Composable Architecture is maybe not quite as nice as we would hope.

@T(00:10:30)
But there are some concrete ways we can see that the current style actually negatively impacts our ability to build features with the library. It turns out that file-scope variables and closures can put quite a bit of strain on the compiler. In the worst case scenario that can cause the compiler to throw up its hands and just fail to compile for complex reducers, although that happens less and less these days.

@T(00:10:51)
And in the “not-so-worst” case scenario, but still really annoying, complex reducers can cause the compiler just to give up sometimes. Autocomplete can stop working, compiler errors become inscrutable or point to the wrong lines, and warnings can even stop appearing, making you miss out on potential problems in your code.

@T(00:11:07)
Let’s take a look at that.

@T(00:11:11)
We actually don’t have to look very far to start to see problems. We can hop over to the case studies project in the repository, bring up any case study that has effects, and put an unused variable in the effect to see that there’s no warning:

```swift
case .rainbowButtonTapped:
  return .run { send in
    let x = 1
    …
  }
```

@T(00:11:39)
Typically this would be a warning:

```swift
func f() {
  let x = 1
}
```

> Warning: Initialization of variable 'x' was never used; consider replacing with assignment to '_' or removing it

@T(00:11:50)
And the warning is useful to let you know that something is maybe not quite right. The fact that this variable is unused could mean that you aren’t doing exactly what you think you are doing, and so it should be looked at eventually.

@T(00:12:01)
Reducers strain the compiler in other ways besides just losing out on some warnings. It can also break Xcode’s ability to autocomplete code for you.

@T(00:12:07)
For example, in the animations case study we have an effect that cycles through some colors with a 1 second delay in order to change the color of something on the screen:

```swift
case .rainbowButtonTapped:
  return .run { send in
    for color in [Color.red, .blue, .green, …] {
      await send(.setColor(color), animation: .linear)
      try await environment.mainQueue.sleep(for: 1)
    }
  }
  .cancellable(id: CancelID.self)
```

@T(00:12:10)
Even something as simple as typing `environment` inside this effect closure shows that for some reason Xcode’s autocomplete can’t figure out that this value is available to us and what its type is:

```swift
environment<#⎋#>
```

@T(00:12:23)
If we try to use dot to then discover what all the environment holds we are met with an empty list letting us know there are “No Completions”:

```swift
environment.<#⎋#>
```

We know that the environment has a `mainQueue` property so we can try to type a few characters:

```swift
environment.mainqu<#⎋#>
```

@T(00:12:39)
And not only is this not properly autocompleting, but it’s even showing us a warning that it found the property elsewhere in the code base (a test no less!) but it can’t figure out that this property is available here even though it’s defined in the same file:

> Error: This property is defined in defined on PresentAndLoadEnvironment, and may not be available in this context.

@T(00:12:48)
And even if we type of `mainQueue` in full, from memory, we still can’t autocomplete anything on the main queue, such as the signature of the `sleep` method:

```swift
environment.mainQueue.slee<#⎋#>
```

@T(00:12:56)
Even the `send` value that is given to us by the `.run` effect isn’t auto-completable. We cannot autocomplete any of the actions that we are allowed to send back into the system:

```swift
send(.<#⎋#>
```

@T(00:13:11)
This greatly dampens the experience of using the library. Autocomplete can remove a lot of mental burden at a time when you when you are already knee deep in the complexities of your feature’s logic. Especially when trying to create asynchronous effects.

## Readability, composition and correctness

@T(00:13:23)
There’s another annoyance with the current library that comes up as your reducers get more and more complicated.

@T(00:13:30)
Currently the library comes with a variety of interesting operators that allow you to break large, complex units of logic into small units that can be pieced together. This includes the `pullback` operator for embedding a child feature into a parent feature, the `optional` operator for lifting a reducer on non-optional state to optional state, which can be great for driving navigation off of state, and the `forEach` operator for running a reducer on an entire collection of data, which is great for lists where each row has behavior of its own.

@T(00:14:00)
All of these operators work well enough, and you can do some powerful things with them, but that doesn’t mean there isn’t room for improvement. Some of these operators must be used in a very specific way to work correctly, but we don’t enforce that in the API and instead rely on runtime warnings and documentation in order to teach users of the library how to properly wield the API.

@T(00:14:21)
The interesting thing about moving to a protocol for reducers is that we can explore what result builders have to say about composing reducers. SwiftUI is the most prototypical use case of result builders because it allows you to define a view hierarchy in a very natural way, but behind the scenes its building up a complex, nested type that encodes the view. We saw the same thing play out earlier this year where we turned to result builders to compose together lots of parsers to build up one big parser.

@T(00:14:47)
In short, result builders are a fantastic tool for re-imaging how one composes things together, and we think it can it work really well with reducers.

Let’s take a look at a common pattern for combining three child reducers into a single parent reducer. Say we have a tab-based application with 3 tabs. We can model the domain and reducer of each tab like so:

```swift
struct TabAState {}
enum TabAAction {}
struct TabAEnvironment {}
let tabAReducer = Reducer<
  TabAState, TabAAction, TabAEnvironment
> { _, _, _ in .none }

struct TabBState {}
enum TabBAction {}
struct TabBEnvironment {}
let tabBReducer = Reducer<
  TabBState, TabBAction, TabBEnvironment
> { _, _, _ in .none }

struct TabCState {}
enum TabCAction {}
struct TabCEnvironment {}
let tabCReducer = Reducer<
  TabCState, TabCAction, TabCEnvironment
> { _, _, _ in .none }
```

@T(00:15:17)
And then we can merge all of the child domains into one single root application domain:

```swift
struct AppState {
  var tabA: TabAState
  var tabB: TabBState
  var tabC: TabCState
}
enum AppAction {
  case tabA(TabAAction)
  case tabB(TabBAction)
  case tabC(TabCAction)
}
enum AppEnvironment {}
```

@T(00:15:25)
And finally, by making use of the `combine` and `pullback` operators we can create one big reducer that encapsulates the logic of all 3 tab reducers:

```swift
let appReducer = Reducer<
  AppState, AppAction, AppEnvironment
>.combine(
  tabAReducer.pullback(
    state: \.tabA,
    action: /AppAction.tabA,
    environment: { _ in .init() }
  ),
  tabBReducer.pullback(
    state: \.tabB,
    action: /AppAction.tabB,
    environment: { _ in .init() }
  ),
  tabCReducer.pullback(
    state: \.tabC,
    action: /AppAction.tabC,
    environment: { _ in .init() }
  )
)
```

@T(00:15:44)
We can even open up an additional reducer before or after all the tab reducers in order to layer on more logic:

```swift
let appReducer = Reducer<
  AppState, AppAction, AppEnvironment
>.combine(
  Reducer { state, action, environment in
    // Additional logic before the tabs
    .none
  },

  …

  Reducer { state, action, environment in
    // Additional logic after the tabs
    .none
  }
)
```

@T(00:16:02)
This is all really nice and can be powerful, but let’s see how result builders might simplify things.

@T(00:16:09)
First of all, what if the result builder context defaulted to simply combining reducers? That means, if you just list some reducers in a builder context:

```swift
Reducer1()
Reducer2()
Reducer3()
```

@T(00:16:27)
…under the hood this is just combining the reducers into one by running one after the other and merging their effects. This would mean you don’t really have to think about the `combine` operator. It would just happen automatically for you behind the scenes, as long as you are in a builder context.

@T(00:16:42)
So, our tab application root reducer would just list out all the reducers:

```swift
Reducer { state, action, environment in
  // Additional logic before the tabs
  .none
}

tabAReducer.pullback(
  state: \.tabA,
  action: /AppAction.tabA,
  environment: { _ in .init() }
)

tabBReducer.pullback(
  state: \.tabB,
  action: /AppAction.tabB,
  environment: { _ in .init() }
)

tabCReducer.pullback(
  state: \.tabC,
  action: /AppAction.tabC,
  environment: { _ in .init() }
)

Reducer { state, action, environment in
  // Additional logic after the tabs
  .none
}
```

@T(00:16:46)
…and we could drop the commas. That will clean up a lot of noise and annoyance with managing commas.

@T(00:17:04)
Further, rather than thinking of the `pullback` operator as acting on a child reducer in order to cram the child domain into the parent domain, we can change our point-of-view to think of a `Scope` reducer that carves out the child domain from the parent domain in order to provide a new builder context for us to run the child reducer:

```swift
Reducer { state, action, environment in
  // Additional logic before the tabs
  .none
}

Scope(
  state: \.tabA,
  action: /AppAction.tabA,
  environment: { _ in .init() }
) {
  TabA()
}

Scope(
  state: \.tabB,
  action: /AppAction.tabB,
  environment: { _ in .init() }
) {
  TabB()
}

Scope(
  state: \.tabC,
  action: /AppAction.tabC,
  environment: { _ in .init() }
) {
  TabC()
}

Reducer { state, action, environment in
  // Additional logic after the tabs
  .none
}
```

@T(00:17:39)
So already this is looking quite nice, but this little flip of a reducer operator into a reducer builder comes with another benefit.

@T(00:17:48)
In the old style, if we didn’t specify the generics on `Reducer.combine`, then we would be forced to provide the explicit root type for the state key path because otherwise Swift has no idea what parent domain you are pulling back to, as well as the parent environment:

```swift
let appReducer = Reducer.combine(
  tabAReducer.pullback(
    state: \<#???#>.tabA,
    action: /AppAction.tabA,
    environment: { (_: <#???#>) in .init() })
  ),
  …
)
```

@T(00:18:12)
We can provide explicit types to get things to compile, but it's not grounded in any specific place.

@T(00:18:40)
However, in the builder style, the context of the parent domain is already known to the compiler and so there is no need to specify the types:

```swift
Scope(
  state: \.tabA,
  action: /AppAction.tabA,
  environment: { _ in .init() }
) {
  TabA()
}
```

@T(00:18:51)
So this style will help improve the compiler’s ability to infer types for us, meaning we get better autocomplete results and can remove noisy, explicit types.

@T(00:19:01)
So, already we are seeing that result builders will help improve the readability, composition and inference of complex reducers. But it gets better.

@T(00:19:10)
Certain operators must be used in a very specific manner in order to guarantee correctness. For example, suppose you have a feature that can show a modal view that has its own behavior, and you want that modal to be driven off of optional state. Ideally you should be able to modal a domain and reducer just for the modal, so that you could develop and test it in isolation, as well as a domain and reducer for the parent feature, and then have some way to plug those pieces together.

@T(00:19:43)
So, we would sit down and do a domain modeling exercise to figure out the state, actions and environment of the modal feature, and implement a reducer for its logic:

```swift
struct ModalState {}
enum ModalAction {}
struct ModalEnvironment {}
let modalReducer = Reducer<
  ModalState, ModalAction, ModalEnvironment
> { _, _, _ in
  .none
}
```

@T(00:19:51)
Then we would do a domain modeling exercise for the feature that has the modal, and so in addition to whatever state, actions and environment the feature needs we would also add the modal’s domain as an optional:

```swift
enum Feature {
  struct State {
    var modal: ModalState?
    …
  }
  enum Action {
    case modal(ModalAction)
    …
  }
  …
}
```

@T(00:20:12)
And finally we could implement the feature reducer by combining a reducer that handles the core feature logic along with the modal reducer. However, to fit the modal reducer’s domain into the feature reducer’s domain we need to apply the `optional` operator in order to lift it from non-optional state to optional state, and then pull it back to the feature’s domain:

```swift
static let reducer = Reducer<
  State, Action, Environment
>.combine(
  Reducer { state, action, environment in
    …
  },

  modalReducer
    .optional()
    .pullback(
      state: \.modal,
      action: /Action.modal,
      environment: { _ in .init() }
    )
)
```

@T(00:21:08)
There’s a lot going on here, but it’s super powerful. As soon as we get all the types matching up and the compiler is ok with everything, we have created a single reducer that encapsulates all of the logic for both the parent feature and the modal. The feature reducer and even observe all the actions happening inside the reducer so that it can react accordingly.

@T(00:21:37)
However, there’s a problem, and you wouldn’t know it until you encounter a runtime warning while running the app in the simulator or on a device, or if you have read all the documentation for the `optional` operator.

@T(00:21:47)
It turns out that the order of combing reducers when dealing with the `optional` operator matters quite a bit. With the current order we have the possibility that a modal action comes into the system, the core feature reducer sees it and decides to `nil` out the modal state, which in turn means the modal reducer doesn’t get a chance to react to it. That can cause subtle bugs that are hard to catch, and that’s why we display loud, runtime warnings when an action is sent to an optional reducer while the state is `nil`.

@T(00:22:30)
The fix is to flip the order:

```swift
static let reducer = Reducer<
  State, Action, Environment
>.combine(
  modalReducer
    .optional()
    .pullback(
      state: \.modal,
      action: /FeatureAction.modal,
      environment: { _ in .init() }
    ),

  Reducer { _, _, _ in
    // Core feature logic
    .none
  }
)
```

@T(00:22:39)
This makes it so that the modal reducer always has a chance to react to the action, even if the core feature reducer decides to `nil` out the state.

@T(00:22:49)
Now, we do have this behavior [documented](https://github.com/pointfreeco/swift-composable-architecture/blob/d41f36c707206625ca310ff4f929e3a350445733/Sources/ComposableArchitecture/Reducer.swift#L463-L580) and the [runtime warnings](https://github.com/pointfreeco/swift-composable-architecture/blob/d41f36c707206625ca310ff4f929e3a350445733/Sources/ComposableArchitecture/Reducer.swift#L597-L628) that show also let you know that you should combine optional reducers before parent reducers but even so, it would be far better if the API could be designed in such a way that makes these kinds of mistakes impossible.

@T(00:23:00)
And luckily for us result builders give us an opportunity to explore that. Rather than knowing that you must combine reducers in a specific order, what if instead there was an `ifLet` operator on the parent reducer that accepted transformations of where to find the optional state you want to operate on, and then a trailing builder for the child reducer you want to run on that optional state when it is non-`nil`:

```swift
Reducer { _, _, _ in
  // Core feature logic
  .none
}
.ifLet(state: \.modal, action: /Action.modal, …) {
  Modal()
}
```

@T(00:23:57)
This will operate the same as before, but because it simultaneously knows about the parent and child reducers it can enforce the order. And because the trailing closure is a builder context, which is essentially a reducer `combine` operator under the hood, you can also easily mix in additional reducers to be run in that modal domain:

```swift
Reducer { _, _, _ in
  // Core feature logic
  .none
}
.ifLet(state: \.modal, action: /FeatureAction.modal, …) {
  BeforeModal()
  Modal()
  AfterModal()
}
```

@T(00:24:21)
While nothing prevented us from flipping this operator in the past, without the builder context available it would have been a much noisier experience.

```swift
.ifLet(state: \.modal, action: /FeatureAction.modal, …) {
  .combine(
    beforeModalReducer,
    modalReducer,
    afterModalReducer
  )
}
```

@T(00:24:41)
The `optional` operator isn’t the only one that requires special handling. The `forEach` reducer must also be run in a specific order.

@T(00:24:48)
Suppose that our feature also has a list of rows, and each row has its own complex behavior. We would of course hope that we could develop the domain and reducer of the row in isolation so that we could test it full isolation:

```swift
struct RowState: Identifiable {
  let id = UUID()
}
enum RowAction {}
struct RowEnvironment {}
let rowReducer = Reducer<
  RowState,
  RowAction,
  RowEnvironment
> { _, _, _ in .none }
```

@T(00:25:02)
And then we would want to plug this domain into the feature’s domain:

```swift
struct State {
  // …
  var rows: IdentifiedArrayOf<RowState>
}
enum Action {
  // …
  case row(id: RowState.ID, RowAction)
}
```

@T(00:25:20)
And finally we would want to plug the row’s reducer into the feature’s reducer. In order to do this we make use of the `forEach` operator that allows us to take a reducer that operates on just a single element, and lift it up to a reducer that operates on an entire collection of elements:

```swift
static let reducer = Reducer<
  State, Action, Environment
>.combine(
  …
  rowReducer.forEach(
    state: \.rows,
    action: /FeatureAction.row,
    environment: { _ in .init() }
  )
)
```

@T(00:25:43)
The reducer is getting more and more complex, but also becoming more and more powerful.

@T(00:25:48)
We now have a single package that handles all of the core logic of the feature, but also embeds the logic for the modal, when it’s presented, and the logic for each individual row of the list. The core feature can listen for anything happening on the inside of the modal and each row, and react accordingly, if it wants to.

@T(00:26:08)
However, like the `optional` operator, the `forEach` operator also must be used in a specific way. The way it is combined with the core reducer right now can lead to subtle bugs. Right now it is possible for a row action to be sent into the system, the core reducer observes it and decides to remove that row, which will mean the row reducer never gets a chance to see that action. This is bad for all the same reasons it was bad for the `optional` operator, and we similarly show runtime warnings when we detect this happening and have documentation trying to steer you in the right direction to use this API.

@T(00:27:03)
But we can do better. Just has we had an `ifLet` operator that transforms a parent reducer by identifying a piece of optional state and running a reducer on that state when it is non-`nil`, we can also define a `forEach` operator on the parent that identifies a collection of data inside the parent domain and runs a row reducer on each element:

```swift
Reducer { _, _, _ in
  // Core feature logic
  .none
}
.ifLet(state: \.modal, action: /FeatureAction.modal, …) {
  BeforeModal()
  Modal()
  AfterModal()
}
.forEach(state: \.rows, action: /FeatureAction.row, …) {
  Row()
}
```

@T(00:27:36)
And of course we can also easily mix in additional reducers before and after the row if we want:

```swift
Reducer { _, _, _ in
  // Core feature logic
  .none
}
.ifLet(state: \.modal, action: /FeatureAction.modal, …) {
  BeforeModal()
  Modal()
  AfterModal()
}
.forEach(state: \.rows, action: /FeatureAction.row, …) {
  BeforeRow()
  Row()
  AfterRow()
}
```

@T(00:27:51)
This looks a lot tidier and less intimidating than the previous style. We have removed a lot of noise and made the APIs more correct to use by default.

## Dependencies

@T(00:28:01)
So, we’ve now seen that there are a few things we’d definitely like to improve in the library. Some of them are more stylistic, such as wanting better ways to group together and compose feature code, but other things are just downright annoyances, such as straining the compiler, and composing reducers in ways that preserve correctness.

@T(00:28:17)
But there’s more. One of the best features of the Composable Architecture is its testability. Right out of the box you get the ability to instantly test all state mutations in an ergonomic and exhaustive manner.

@T(00:28:28)
If you also take a bit of time to properly model your dependencies in a way that makes them controllable, and thread those dependencies through your feature’s domain, then you also get the ability to test how effects execute and send their data back into the system. This is also done in an exhaustive manner, forcing you to prove that you know exactly how the effects execute and proving that they all complete by the end of the test. This makes it impossible for for things to happen in the feature that are not being asserted on, which would leave you open to having bugs with no way to catch them in tests.

@T(00:28:58)
So, that is all great, but the only problem is that threading dependencies through a large application can be a pain. If a leaf feature of your application needs a dependency, then every feature leading up to that feature must also have this dependency. This means if the leaf is 5 layers deep, the act of adding a single dependency to it forces us to update 4 other features to add the dependency. This can be a real pain, so let’s take a quick look at this problem.

@T(00:29:27)
To demonstrate the problem let’s take a look at our open source word game, [isowords](https://github.com/pointfreeco/isowords), which is built 100% in SwiftUI and the Composable Architecture. Let’s take a feature that is used in a few spots, some of them quite deep in the feature hierarchy, such as settings.

@T(00:29:55)
The settings environment holds all of the dependencies the settings feature needs to do its job:

```swift
public struct SettingsEnvironment {
  …
}
```

@T(00:30:04)
Let’s see what happens if we decide to add another dependency to the environment:

```swift
public struct SettingsEnvironment {
  public var dependency: Int
  …
}
```

@T(00:30:15)
One nice thing is that our application is highly modularized so it’s possible for us to build the settings feature in isolation so that we can fix its errors without getting bogged down by the entire application.

@T(00:30:30)
The first error we get is in the initializer of `SettingsEnvironment` because we haven’t assigned `dependency` yet.

@T(00:30:41)
Unfortunately this is the annoying part to modularizing. Because Swift auto-synthesizes only an internal initializer for structs we are forced to define our own public initializer so that it can be constructed from other modules. It would be great if Swift allowed making the synthesized initializer public, but it just isn’t possible right now.

@T(00:30:57)
So, we now have to thread the dependency through the initializer:

```swift
public init(
  dependency: Int,
  …
) {
  self.dependency = dependency
  …
}
```

@T(00:31:06)
But, now that the initializer signature is changed we get compiler errors in the places we try constructing a settings environment. This includes some useful instances that can be used in tests or previews.

@T(00:31:14)
So, let’s update those initializers:

```swift
extension SettingsEnvironment {
  public static let failing = Self(
    dependency: 0,
    …
  )
  public static let noop = Self(
    dependency: 0,
    …
  )
}
```

@T(00:31:30)
And now things compile.

@T(00:31:34)
So, already this is annoying. The act of adding a new dependency to the feature has caused 3 compiler errors that had to be fixed. And there are more compiler errors waiting for us in the feature's tests, but let's focus on the application for now, where things are about to get worse.

@T(00:31:50)
If we back up to a feature that uses the settings feature, like the game feature, we will find more compiler errors. First we see that where we are constructing a settings environment from a game environment in order to embed the settings domain and logic into the game:

```swift
environment: {
  SettingsEnvironment(
    …
  )
}
```

> Error: Missing argument  for parameter 'dependencies'

@T(00:32:09)
This no longer compiles because we aren’t passing along the new dependency. In order to do that we need to add the dependency to the game environment:

```swift
public struct GameEnvironment {
  public var dependency: Int
  …
}
```

@T(00:32:23)
And then that forces us to add the dependency to the initializer:

```swift
public init(
  dependency: Int,
  …
) {
  self.dependency = dependency
  …
}
```

@T(00:32:29)
This now allows us to thread the game’s dependency on to the settings dependency:

```swift
environment: {
  SettingsEnvironment(
    dependency: $0.dependency,
    …
  )
}
```

@T(00:32:34)
And now the only compiler errors are specifying a dependency to use for the failing and noop instances of the game environment, which are useful for tests and previews:

```swift
extension GameEnvironment {
  public static let failing = Self(
    dependency: 0,
    …
  )
  public static let noop = Self(
    dependency: 0,
    …
  )
}
```

@T(00:32:52)
And apparently this feature creates a custom environment for a specific preview so we now have to update that:

```swift
environment: .init(
  dependency: 0,
  …
)
```

@T(00:33:00)
We are finally in building order. For this feature module at least.

@T(00:33:04)
If we now back up all the way to the root app feature module we will see it does not build. Looks like the home feature makes use of settings too. We now have to repeat everything all over again.

@T(00:33:19)
We need to add the dependency to the home environment and initializer:

```swift
public struct HomeEnvironment {
  public var dependency: Int
  …

  public init(
    dependency: Int,
    …
  ) {
    self.dependency = dependency
  }
}
```

@T(00:33:37)
We need to update any place we construct the home environment:

```swift
extension HomeEnvironment {
  public static let noop = Self(
    dependency: 0,
    …
  )
}
…
environment: {
  SettingsEnvironment(
    dependency: $0.dependency,
    …
  )
}
…
environment: HomeEnvironment(
  dependency: 0,
  …
)
…
public struct OnboardingEnvironment {
  …
  var gameEnvironment: GameEnvironment {
    GameEnvironment(
      dependency: 0,
      …
    )
  }
}
…
extension AppEnvironment {
  var game: GameEnvironment {
    .init(
      dependency: 0,
      …
    )
  }

  var home: HomeEnvironment {
    .init(
      dependency: 0,
      …
    )
  }
}
```

@T(00:35:31)
And finally the app feature module builds. Believe it or not there are still more spots that need to be updated, such as the entry point for the app and app clip, as well as tests.

@T(00:35:52)
But we aren’t going to put you through watching us update all of that. The main point we want to get across is that this is an absolute pain, and the library should do something to make this easier.

@T(00:36:02)
It should be possible to add a dependency to a leaf feature without having to update every single feature that depends on it. And we should even be able to bake in some of the best practices for constructing dependencies, such as using “unimplemented” dependencies that simply fail if you ever invoke their endpoints. Such dependencies are great for proving that certain execution flows use only the dependencies you think they should, and in the future being notified when features start using new dependencies.

@T(00:36:29)
Even more amazing, by trying to address this problem, we will come up with a tool that allows us to solve other problems that look quite different. For example, we have found that we can use this tool to improve how navigation is modeled in Composable Architecture applications, and we believe there are even more uses out there that we haven’t even discovered yet.

## Performance and stack size

@T(00:36:46)
There’s one last problem with how reducers are currently set up in the library, but it isn’t immediately obvious like some of the other things we’ve discussed. It has to do with performance and memory usage.

@T(00:36:56)
Currently reducers are created by passing an escaping closure to a struct initializer. Swift does not inline and optimize escaping closures like it does for methods. We’ve seen this in very concrete terms in past episodes when we converted a `Parser` struct to a `Parser` protocol. We saw that by constructing deeply nested parser types representing complex parsers, Swift could optimize away most of the nesting, giving us a compact set of stack frames. On the other hand, nesting escaping closures could not be optimized. Each nested parser resulted in a few additional stack frames, and it resulted in a measurable performance hit.

@T(00:37:31)
We would expect the same with reducers. To see this concretely, let’s quickly put a breakpoint in an action in the settings feature:

```swift
case let .tappedProduct(product):
  state.isPurchasing = true
```

@T(00:37:51)
And let’s run the application, start a game, go into settings, and then tap the product button.

@T(00:38:01)
When the breakpoint triggers we see that there are about 100 stack frames in the debugger. But worse, the stack frame where we send the action in the view is #65, which means we incurred the cost of 65 stack frames just to send an action.

@T(00:38:23)
Moving to protocols will help us flatten and inline a lot of these frames. But even better, by flattening the stack frames that occur when sending actions we will also reduce the amount of memory on the stack. This will help people who need to hold a lot of data directly on the stack in the features.

## Next time: the solution

@T(00:38:38)
So, we have now seen there is still a ton of room for improvement in the library:

@T(00:38:41)
- We can do a better job of providing a more natural space for housing the state, actions and logic of your features built in the Composable Architecture.

@T(00:38:49)
- We can help out the compiler a bit so that it is not so strained, leading us to lose type inference, autocomplete and warnings.

@T(00:38:59)
- There’s improvements we can make to readability of highly composed reducers, as well as the correctness of some of the more powerful operators in the library.

@T(00:39:08)
- We definitely have to do something about the ergonomics of the environment, because right now it’s quite a pain to add new dependencies to a leaf node of an application and update every layer through to the root of the application.

@T(00:39:22)
- And finally, there’s performance improvements we can make because highly modularized applications will lead to very deep call stacks.

@T(00:39:29)
Well, luckily for us it’s possible to solve all of these problems, and more. By putting a protocol in front of reducers, and by constructing reducers as concrete types that conform to the protocol rather than deeply nested escaping closures, we will greatly improve the experience of developing large, complex features in the library.

@T(00:39:49)
So, let’s get to it...next time!
