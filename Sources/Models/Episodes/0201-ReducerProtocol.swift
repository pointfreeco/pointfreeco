import Foundation

extension Episode {
  public static let ep201_reducerProtocol = Episode(
    blurb: """
      The Composable Architecture was first released over two years ago, and the core ergonomics haven't changed much since then. It's time to change that: we are going to improve the ergonomics of nearly every facet of creating a feature with the library, and make all new patterns possible.
      """,
    codeSampleDirectory: "0201-reducer-protocol-pt1",
    exercises: _exercises,
    id: 201,
    length: 39 * 60 + 53,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_661_144_400),
    references: [
      // TODO
    ],
    sequence: 201,
    subtitle: "The Problem",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 101_300_000,
      downloadUrls: .s3(
        hd1080: "0201-trailer-1080p-1d183f8801624cc8a5b6eef34802f030",
        hd720: "0201-trailer-720p-0f909c5fb9494f8493694f7569b401bb",
        sd540: "0201-trailer-540p-459b52d3fbe0464e95b5d8d7a2dfb9d0"
      ),
      vimeoId: 740_853_246
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Episode.Video {
  public static let ep201_reducerProtocol = Self(
    bytesLength: 503_500_000,
    downloadUrls: .s3(
      hd1080: "0201-1080p-6b25542568b94969877d1ab818b83fa9",
      hd720: "0201-720p-7f0085c2954d43808ca6b7dbd5185355",
      sd540: "0201-540p-c8307966c81b41ddb4f210fb32bfbf7e"
    ),
    vimeoId: 740853322
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep201_reducerProtocol: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
For the past many weeks we have gone deep into Swift’s concurrency tools, and then brought many of those tools into the Composable Architecture. This greatly improved the ergonomics for constructing complex effects, allowed us to tie the lifetime of effects to the lifetime of views, and amazingly everything remained 100% testable. In fact, we think that the Composable Architecture offers one of the most cohesive testing solutions for integrated asynchronous code in the entire Swift ecosystem.
"""#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
While we greatly improved the ergonomics of constructing complex effects, the ergonomics of constructing complex reducers hasn’t changed much since the library was first released over 2 years ago. It’s now time to focus on that, and we think it’s maybe an even bigger update to the library than the concurrency tools were.
"""#,
      timestamp: 31,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We are going to improve the ergonomics of nearly every facet of creating a feature with the library, and make all new patterns possible that were previously impossible. We have uncovered many far reaching applications of these ideas, and we believe that there is still a lot more out there to be discovered.
"""#,
      timestamp: 47,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Today we are going to start exploring what it means to put a protocol in front of our reducers. This will mean that instead of constructing a reducer by providing a closure that takes some state so that you can mutate it, you will instead create a type that conforms to the reducer protocol. And operators defined on reducers will return a whole new type rather than constructing a closure that calls out to other reducers under the hood.
"""#,
      timestamp: (1*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This idea was first brought up by Composable Architecture community members over a year ago, and we have actively researched the idea since then, but it took some new features of Swift 5.7 to make this style of reducer ergonomic and performant.
"""#,
      timestamp: (1*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This change will help with a variety of things. Some of the things changing may seem like simple aesthetics, such as giving us a dedicated namespace to house state and action types. But then others help us completely reimagine the way we compose reducers, and how to push information deep throughout a reducer hierarchy, with applications to how we structure our dependencies and even navigation.
"""#,
      timestamp: (1*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now we want to stress that all the changes we discuss in this series of episodes, as well as everything in the final release of the library, is 100% backwards compatible with all of your existing Composable Architecture code. Once you upgrade to the newest version of the library, you will not need to make a single change to your code, and then later you can incrementally adopt these newer tools as you see fit. A few things will be soft-deprecated, which means it’s technically deprecated but we aren’t going to loudly warn about it yet, and then someday in the future we will fully deprecate, and then some day further into the future we will have an officially breaking change to remove some old cruft.
"""#,
      timestamp: (2*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We are going to kick off this series to highlight a few things about the current library that are not quite ideal. This will set the stage for seeing what can be improved in the library, and then we can start tackling some of those things.
"""#,
      timestamp: (2*60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Structure"#,
      timestamp: (2*60 + 50),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s start with something that seems like merely an aesthetic issue, but does affect many people, and that’s how to structure a feature written in the Composable Architecture.
"""#,
      timestamp: (2*60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We have released quite a bit of public code using the Composable Architecture, including the case studies and demos in this repo as well as our open-source word game, isowords. In all of those examples we mostly follow the pattern of defining the domain at the top of the file, which includes the state, action and environment. Abstractly, the domain looks like this:
"""#,
      timestamp: (2*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import ComposableArchitecture

struct FeatureState {
}
enum FeatureAction {
}
struct FeatureEnvironment {
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Followed by a file-scope variable for defining the reducer that implements the feature’s logic:
"""#,
      timestamp: (3*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let featureReducer = Reducer<FeatureState, FeatureAction, FeatureEnvironment> { state, action, environment in
  .none
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This line gets a little long, so sometimes you may need to add some newlines to get it all on the screen at once:
"""#,
      timestamp: (3*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let featureReducer = Reducer<
  FeatureState,
  FeatureAction,
  FeatureEnvironment
> { state, action, environment in
    .none
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This style can make some people a little uncomfortable. First, some people see state, action and environment as making up one single unit, and so like to group them into some kind of namespace:
"""#,
      timestamp: (4*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum Feature {
  struct State {
  }
  enum Action {
  }
  struct Environment {
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We personally prefer to use modules to group features in a “namespace”, and think it solves most of the problems this enum is trying to solve, but we also understand it’s not always possible or reasonable to organize things into modules.
"""#,
      timestamp: (4*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Although this empty enum does act as a namespace, it is a little cumbersome. Because `Feature` is not used as a real type anywhere in the application, you often do not get the opportunity to elide it by using type inference. You usually have to fully qualify it with:
"""#,
      timestamp: (4*60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Feature.State
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that’s a pattern that some people employ to ease their discomfort with not having the domain grouped into a single type, but even more people are bothered by the file-scope defined reducer variable:
"""#,
      timestamp: (5*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let featureReducer = Reducer<
  FeatureState,
  FeatureAction,
  FeatureEnvironment
> { state, action, environment in
  .none
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
People in the Swift community generally have some discomfort with file-scope variables and functions, especially non-private ones. They look like globals, but they aren’t really globals because Swift doesn’t have true globals. At the end of the day these kinds of variables are always at least scoped to the module, but still, the discomfort remains for many.
"""#,
      timestamp: (5*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, one thing we could do is move the reducer to the `Feature` enum “namespace”, but then we have to make it a static:
"""#,
      timestamp: (5*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Another structure-related annoyance people encounter, especially with large, complex reducers, is where to put helpers that can be used in the reducer. For example, we may have two button tap actions in the UI that have some overlapping logic:
"""#,
      timestamp: (5*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum Action {
  case buttonTapped
  case otherButtonTapped
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Perhaps there’s a specific piece of state that gets mutated in the same way and a complex effect that is returned from both actions.
"""#,
      timestamp: (6*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Well, one way to accomplish this is to have a little private helper function. If the helper needs to both mutate state and return an effect, it means you need to pass some `inout` state and the environment to it:
"""#,
      timestamp: (6*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum Feature {
  …

  private static func sharedButtonTapLogic(
    state: inout State,
    environment: Environment
  ) -> Effect<Action, Never> {
    .none
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
…and then call that from the actions, in addition to whatever non-shared logic needs to be executed:
"""#,
      timestamp: (6*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This gets the job done, and is what we recommend in the Composable Architecture today, but it isn’t without its annoyances. We have to pass the state and environment to any helpers that do anything moderately interesting.
"""#,
      timestamp: (7*60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Another approach would be to define these helpers as mutating functions on the state:
"""#,
      timestamp: (7*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
extension Feature.State {
  fileprivate mutating func doSomething(
    environment: Feature.Environment
  ) -> Effect<Feature.Action, Never> {
    .none
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then you could do this:
"""#,
      timestamp: (7*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This works, but is perhaps weird to throw such significant, behavioral logic on the value type representing the state. There is technically nothing technically wrong with it, but this style will probably make some people unconformable, and also, at the end of the day you still have to pass the environment to it if you want to return any effects.
"""#,
      timestamp: (8*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Something else we see people doing often is to share pieces of logic in a reducer by sending synchronous actions from effects. So, instead of having a `sharedButtonTapLogic` function, you would have a `sharedButtonTapLogic` action that houses the shared logic, and you would send that action from other actions:
"""#,
      timestamp: (8*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We highly recommend against this pattern. First of all this pattern isn’t as flexible as the other two styles we described. With the shared function or method we are able to call it before or after the additional logic we want to layer on, and we can even take just the state mutation or discard the effects, or take only the effects and discard the state mutation. We can even tweak the environment before calling the shared helper. In general, it’s just very flexible. Also, in the method and function style we could make those helpers private, yet with the synchronous action we are making it completely public to every parent layer above this feature.
"""#,
      timestamp: (9*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But also, sending synchronous actions from effects like this is inefficient and indirect for something that should be quite simple. In general, sending actions into the system can be heavy weight considering that every layer of the entire composed application can listen for those actions.
"""#,
      timestamp: (9*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, sending synchronous actions just to share logic can make the system less performant. Also, it seems strange to enlarge your domain just to share logic, and can even make your tests read strangely since you need to assert on all of these synchronous communication actions being sent all over the place.
"""#,
      timestamp: (10*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Compiler strain"#,
      timestamp: (10*60 + 22),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that’s a couple of somewhat superficial examples of how the current style of developing features in the Composable Architecture is maybe not quite as nice as we would hope.
"""#,
      timestamp: (10*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But there are some concrete ways we can see that the current style actually negatively impacts our ability to build features with the library. It turns out that file-scope variables and closures can put quite a bit of strain on the compiler. In the worst case scenario that can cause the compiler to throw up its hands and just fail to compile for complex reducers, although that happens less and less these days.
"""#,
      timestamp: (10*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And in the “not-so-worst” case scenario, but still really annoying, complex reducers can cause the compiler just to give up sometimes. Autocomplete can stop working, compiler errors become inscrutable or point to the wrong lines, and warnings can even stop appearing, making you miss out on potential problems in your code.
"""#,
      timestamp: (10*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s take a look at that.
"""#,
      timestamp: (11*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We actually don’t have to look very far to start to see problems. We can hop over to the case studies project in the repository, bring up any case study that has effects, and put an unused variable in the effect to see that there’s no warning:
"""#,
      timestamp: (11*60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .rainbowButtonTapped:
  return .run { send in
    let x = 1
    …
  }
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Typically this would be a warning:
"""#,
      timestamp: (11*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func f() {
  let x = 1
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> ⚠️ Initialization of variable 'x' was never used; consider replacing with assignment to '_' or removing it

And the warning is useful to let you know that something is maybe not quite right. The fact that this variable is unused could mean that you aren’t doing exactly what you think you are doing, and so it should be looked at eventually.
"""#,
      timestamp: (11*60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Reducers strain the compiler in other ways besides just losing out on some warnings. It can also break Xcode’s ability to autocomplete code for you.
"""#,
      timestamp: (12*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
For example, in the animations case study we have an effect that cycles through some colors with a 1 second delay in order to change the color of something on the screen:
"""#,
      timestamp: (12*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .rainbowButtonTapped:
  return .run { send in
    for color in [Color.red, .blue, .green, …] {
      await send(.setColor(color), animation: .linear)
      try await environment.mainQueue.sleep(for: 1)
    }
  }
  .cancellable(id: CancelID.self)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Even something as simple as typing `environment` inside this effect closure shows that for some reason Xcode’s autocomplete can’t figure out that this value is available to us and what its type is:
"""#,
      timestamp: (12*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
environment<#⎋#>
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If we try to use dot to then discover what all the environment holds we are met with an empty list letting us know there are “No Completions”:
"""#,
      timestamp: (12*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
environment.<#⎋#>
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> No Completions

We know that the environment has a `mainQueue` property so we can try to type a few characters:
"""#,
      timestamp: (12*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
environment.mainqu<#⎋#>
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And not only is this not properly autocompleting, but it’s even showing us a warning that it found the property elsewhere in the code base (a test no less!) but it can’t figure out that this property is available here even though it’s defined in the same file:

> 🛑 This property is defined in defined on PresentAndLoadEnvironment, and may not be available in this context.
"""#,
      timestamp: (12*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And even if we type of `mainQueue` in full, from memory, we still can’t autocomplete anything on the main queue, such as the signature of the `sleep` method:
"""#,
      timestamp: (12*60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
environment.mainQueue.slee<#⎋#>
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> No Completions

Even the `send` value that is given to us by the `.run` effect isn’t auto-completable. We cannot autocomplete any of the actions that we are allowed to send back into the system:
"""#,
      timestamp: (12*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
send(.<#⎋#>
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> No Completions

This greatly dampens the experience of using the library. Autocomplete can remove a lot of mental burden at a time when you when you are already knee deep in the complexities of your feature’s logic. Especially when trying to create asynchronous effects.
"""#,
      timestamp: (13*60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Readability, composition and correctness"#,
      timestamp: (13*60 + 23),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
There’s another annoyance with the current library that comes up as your reducers get more and more complicated.
"""#,
      timestamp: (13*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Currently the library comes with a variety of interesting operators that allow you to break large, complex units of logic into small units that can be pieced together. This includes the `pullback` operator for embedding a child feature into a parent feature, the `optional` operator for lifting a reducer on non-optional state to optional state, which can be great for driving navigation off of state, and the `forEach` operator for running a reducer on an entire collection of data, which is great for lists where each row has behavior of its own.
"""#,
      timestamp: (13*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
All of these operators work well enough, and you can do some powerful things with them, but that doesn’t mean there isn’t room for improvement. Some of these operators must be used in a very specific way to work correctly, but we don’t enforce that in the API and instead rely on runtime warnings and documentation in order to teach users of the library how to properly wield the API.
"""#,
      timestamp: (14*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The interesting thing about moving to a protocol for reducers is that we can explore what result builders have to say about composing reducers. SwiftUI is the most prototypical use case of result builders because it allows you to define a view hierarchy in a very natural way, but behind the scenes its building up a complex, nested type that encodes the view. We saw the same thing play out earlier this year where we turned to result builders to compose together lots of parsers to build up one big parser.
"""#,
      timestamp: (14*60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In short, result builders are a fantastic tool for re-imaging how one composes things together, and we think it can it work really well with reducers.
"""#,
      timestamp: (14*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s take a look at a common pattern for combining three child reducers into a single parent reducer. Say we have a tab-based application with 3 tabs. We can model the domain and reducer of each tab like so:
"""#,
      timestamp: nil, // 59,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then we can merge all of the child domains into one single root application domain:
"""#,
      timestamp: (15*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And finally, by making use of the `combine` and `pullback` operators we can create one big reducer that encapsulates the logic of all 3 tab reducers:
"""#,
      timestamp: (15*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We can even open up an additional reducer before or after all the tab reducers in order to layer on more logic:
"""#,
      timestamp: (15*60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This is all really nice and can be powerful, but let’s see how result builders might simplify things.
"""#,
      timestamp: (16*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
First of all, what if the result builder context defaulted to simply combining reducers? That means, if you just list some reducers in a builder context:
"""#,
      timestamp: (16*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Reducer1()
Reducer2()
Reducer3()
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
…under the hood this is just combining the reducers into one by running one after the other and merging their effects. This would mean you don’t really have to think about the `combine` operator. It would just happen automatically for you behind the scenes, as long as you are in a builder context.
"""#,
      timestamp: (16*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, our tab application root reducer would just list out all the reducers:
"""#,
      timestamp: (16*60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
…and we could drop the commas. That will clean up a lot of noise and annoyance with managing commas.
"""#,
      timestamp: (16*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Further, rather than thinking of the `pullback` operator as acting on a child reducer in order to cram the child domain into the parent domain, we can change our point-of-view to think of a `Scope` reducer that carves out the child domain from the parent domain in order to provide a new builder context for us to run the child reducer:
"""#,
      timestamp: (17*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So already this is looking quite nice, but this little flip of a reducer operator into a reducer builder comes with another benefit.
"""#,
      timestamp: (17*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In the old style, if we didn’t specify the generics on `Reducer.combine`, then we would be forced to provide the explicit root type for the state key path because otherwise Swift has no idea what parent domain you are pulling back to, as well as the parent environment:
"""#,
      timestamp: (17*60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let appReducer = Reducer.combine(
  tabAReducer.pullback(
    state: \<#???#>.tabA,
    action: /AppAction.tabA,
    environment: { (_: <#???#>) in .init() })
  ),
  …
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We can provide explicit types to get things to compile, but it's not grounded in any specific place.
"""#,
      timestamp: (18*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, in the builder style, the context of the parent domain is already known to the compiler and so there is no need to specify the types:
"""#,
      timestamp: (18*60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Scope(
  state: \.tabA,
  action: /AppAction.tabA,
  environment: { _ in .init() }
) {
  TabA()
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So this style will help improve the compiler’s ability to infer types for us, meaning we get better autocomplete results and can remove noisy, explicit types.
"""#,
      timestamp: (18*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, already we are seeing that result builders will help improve the readability, composition and inference of complex reducers. But it gets better.
"""#,
      timestamp: (19*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Certain operators must be used in a very specific manner in order to guarantee correctness. For example, suppose you have a feature that can show a modal view that has its own behavior, and you want that modal to be driven off of optional state. Ideally you should be able to modal a domain and reducer just for the modal, so that you could develop and test it in isolation, as well as a domain and reducer for the parent feature, and then have some way to plug those pieces together.
"""#,
      timestamp: (19*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we would sit down and do a domain modeling exercise to figure out the state, actions and environment of the modal feature, and implement a reducer for its logic:
"""#,
      timestamp: (19*60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct ModalState {}
enum ModalAction {}
struct ModalEnvironment {}
let modalReducer = Reducer<
  ModalState, ModalAction, ModalEnvironment
> { _, _, _ in
  .none
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we would do a domain modeling exercise for the feature that has the modal, and so in addition to whatever state, actions and environment the feature needs we would also add the modal’s domain as an optional:
"""#,
      timestamp: (19*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And finally we could implement the feature reducer by combining a reducer that handles the core feature logic along with the modal reducer. However, to fit the modal reducer’s domain into the feature reducer’s domain we need to apply the `optional` operator in order to lift it from non-optional state to optional state, and then pull it back to the feature’s domain:
"""#,
      timestamp: (20*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
There’s a lot going on here, but it’s super powerful. As soon as we get all the types matching up and the compiler is ok with everything, we have created a single reducer that encapsulates all of the logic for both the parent feature and the modal. The feature reducer and even observe all the actions happening inside the reducer so that it can react accordingly.
"""#,
      timestamp: (21*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, there’s a problem, and you wouldn’t know it until you encounter a runtime warning while running the app in the simulator or on a device, or if you have read all the documentation for the `optional` operator.
"""#,
      timestamp: (21*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It turns out that the order of combing reducers when dealing with the `optional` operator matters quite a bit. With the current order we have the possibility that a modal action comes into the system, the core feature reducer sees it and decides to `nil` out the modal state, which in turn means the modal reducer doesn’t get a chance to react to it. That can cause subtle bugs that are hard to catch, and that’s why we display loud, runtime warnings when an action is sent to an optional reducer while the state is `nil`.
"""#,
      timestamp: (21*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The fix is to flip the order:
"""#,
      timestamp: (22*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This makes it so that the modal reducer always has a chance to react to the action, even if the core feature reducer decides to `nil` out the state.
"""#,
      timestamp: (22*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now, we do have this behavior [documented](https://github.com/pointfreeco/swift-composable-architecture/blob/d41f36c707206625ca310ff4f929e3a350445733/Sources/ComposableArchitecture/Reducer.swift#L463-L580) and the [runtime warnings](https://github.com/pointfreeco/swift-composable-architecture/blob/d41f36c707206625ca310ff4f929e3a350445733/Sources/ComposableArchitecture/Reducer.swift#L597-L628) that show also let you know that you should combine optional reducers before parent reducers but even so, it would be far better if the API could be designed in such a way that makes these kinds of mistakes impossible.
"""#,
      timestamp: (22*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And luckily for us result builders give us an opportunity to explore that. Rather than knowing that you must combine reducers in a specific order, what if instead there was an `ifLet` operator on the parent reducer that accepted transformations of where to find the optional state you want to operate on, and then a trailing builder for the child reducer you want to run on that optional state when it is non-`nil`:
"""#,
      timestamp: (23*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Reducer { _, _, _ in
  // Core feature logic
  .none
}
.ifLet(state: \.modal, action: /Action.modal, …) {
  Modal()
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This will operate the same as before, but because it simultaneously knows about the parent and child reducers it can enforce the order. And because the trailing closure is a builder context, which is essentially a reducer `combine` operator under the hood, you can also easily mix in additional reducers to be run in that modal domain:
"""#,
      timestamp: (23*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Reducer { _, _, _ in
  // Core feature logic
  .none
}
.ifLet(state: \.modal, action: /FeatureAction.modal, …) {
  BeforeModal()
  Modal()
  AfterModal()
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
While nothing prevented us from flipping this operator in the past, without the builder context available it would have been a much noisier experience.
"""#,
      timestamp: (24*60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.ifLet(state: \.modal, action: /FeatureAction.modal, …) {
  .combine(
    beforeModalReducer,
    modalReducer,
    afterModalReducer
  )
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
The `optional` operator isn’t the only one that requires special handling. The `forEach` reducer must also be run in a specific order.
"""#,
      timestamp: (24*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Suppose that our feature also has a list of rows, and each row has its own complex behavior. We would of course hope that we could develop the domain and reducer of the row in isolation so that we could test it full isolation:
"""#,
      timestamp: (24*60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then we would want to plug this domain into the feature’s domain:
"""#,
      timestamp: (25*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct State {
  // …
  var rows: IdentifiedArrayOf<RowState>
}
enum Action {
  // …
  case row(id: RowState.ID, RowAction)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And finally we would want to plug the row’s reducer into the feature’s reducer. In order to do this we make use of the `forEach` operator that allows us to take a reducer that operates on just a single element, and lift it up to a reducer that operates on an entire collection of elements:
"""#,
      timestamp: (25*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
The reducer is getting more and more complex, but also becoming more and more powerful.
"""#,
      timestamp: (25*60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We now have a single package that handles all of the core logic of the feature, but also embeds the logic for the modal, when it’s presented, and the logic for each individual row of the list. The core feature can listen for anything happening on the inside of the modal and each row, and react accordingly, if it wants to.
"""#,
      timestamp: (25*60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, like the `optional` operator, the `forEach` operator also must be used in a specific way. The way it is combined with the core reducer right now can lead to subtle bugs. Right now it is possible for a row action to be sent into the system, the core reducer observes it and decides to remove that row, which will mean the row reducer never gets a chance to see that action. This is bad for all the same reasons it was bad for the `optional` operator, and we similarly show runtime warnings when we detect this happening and have documentation trying to steer you in the right direction to use this API.
"""#,
      timestamp: (26*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But we can do better. Just has we had an `ifLet` operator that transforms a parent reducer by identifying a piece of optional state and running a reducer on that state when it is non-`nil`, we can also define a `forEach` operator on the parent that identifies a collection of data inside the parent domain and runs a row reducer on each element:
"""#,
      timestamp: (27*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And of course we can also easily mix in additional reducers before and after the row if we want:
"""#,
      timestamp: (27*60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This looks a lot tidier and less intimidating than the previous style. We have removed a lot of noise and made the APIs more correct to use by default.
"""#,
      timestamp: (27*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Dependencies"#,
      timestamp: (28*60 + 1),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we’ve now seen that there are a few things we’d definitely like to improve in the library. Some of them are more stylistic, such as wanting better ways to group together and compose feature code, but other things are just downright annoyances, such as straining the compiler, and composing reducers in ways that preserve correctness.
"""#,
      timestamp: (28*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But there’s more. One of the best features of the Composable Architecture is its testability. Right out of the box you get the ability to instantly test all state mutations in an ergonomic and exhaustive manner.
"""#,
      timestamp: (28*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If you also take a bit of time to properly model your dependencies in a way that makes them controllable, and thread those dependencies through your feature’s domain, then you also get the ability to test how effects execute and send their data back into the system. This is also done in an exhaustive manner, forcing you to prove that you know exactly how the effects execute and proving that they all complete by the end of the test. This makes it impossible for for things to happen in the feature that are not being asserted on, which would leave you open to having bugs with no way to catch them in tests.
"""#,
      timestamp: (28*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that is all great, but the only problem is that threading dependencies through a large application can be a pain. If a leaf feature of your application needs a dependency, then every feature leading up to that feature must also have this dependency. This means if the leaf is 5 layers deep, the act of adding a single dependency to it forces us to update 4 other features to add the dependency. This can be a real pain, so let’s take a quick look at this problem.
"""#,
      timestamp: (28*60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
To demonstrate the problem let’s take a look at our open source word game, [isowords](https://github.com/pointfreeco/isowords), which is built 100% in SwiftUI and the Composable Architecture. Let’s take a feature that is used in a few spots, some of them quite deep in the feature hierarchy, such as settings.
"""#,
      timestamp: (29*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The settings environment holds all of the dependencies the settings feature needs to do its job:
"""#,
      timestamp: (29*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public struct SettingsEnvironment {
  …
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s see what happens if we decide to add another dependency to the environment:
"""#,
      timestamp: (30*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public struct SettingsEnvironment {
  public var dependency: Int
  …
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
One nice thing is that our application is highly modularized so it’s possible for us to build the settings feature in isolation so that we can fix its errors without getting bogged down by the entire application.
"""#,
      timestamp: (30*60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The first error we get is in the initializer of `SettingsEnvironment` because we haven’t assigned `dependency` yet.
"""#,
      timestamp: (30*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Unfortunately this is the annoying part to modularizing. Because Swift auto-synthesizes only an internal initializer for structs we are forced to define our own public initializer so that it can be constructed from other modules. It would be great if Swift allowed making the synthesized initializer public, but it just isn’t possible right now.
"""#,
      timestamp: (30*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we now have to thread the dependency through the initializer:
"""#,
      timestamp: (30*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public init(
  dependency: Int,
  …
) {
  self.dependency = dependency
  …
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But, now that the initializer signature is changed we get compiler errors in the places we try constructing a settings environment. This includes some useful instances that can be used in tests or previews.
"""#,
      timestamp: (31*60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, let’s update those initializers:
"""#,
      timestamp: (31*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now things compile.
"""#,
      timestamp: (31*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, already this is annoying. The act of adding a new dependency to the feature has caused 3 compiler errors that had to be fixed. And there are more compiler errors waiting for us in the feature's tests, but let's focus on the application for now, where things are about to get worse.
"""#,
      timestamp: (31*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If we back up to a feature that uses the settings feature, like the game feature, we will find more compiler errors. First we see that where we are constructing a settings environment from a game environment in order to embed the settings domain and logic into the game:
"""#,
      timestamp: (31*60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
environment: {
  SettingsEnvironment(
    …
  )
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 Missing argument  for parameter 'dependencies'

This no longer compiles because we aren’t passing along the new dependency. In order to do that we need to add the dependency to the game environment:
"""#,
      timestamp: (32*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public struct GameEnvironment {
  public var dependency: Int
  …
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then that forces us to add the dependency to the initializer:
"""#,
      timestamp: (32*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public init(
  dependency: Int,
  …
) {
  self.dependency = dependency
  …
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This now allows us to thread the game’s dependency on to the settings dependency:
"""#,
      timestamp: (32*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
environment: {
  SettingsEnvironment(
    dependency: $0.dependency,
    …
  )
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now the only compiler errors are specifying a dependency to use for the failing and noop instances of the game environment, which are useful for tests and previews:
"""#,
      timestamp: (32*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And apparently this feature creates a custom environment for a specific preview so we now have to update that:
"""#,
      timestamp: (32*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
environment: .init(
  dependency: 0,
  …
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We are finally in building order. For this feature module at least.
"""#,
      timestamp: (33*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If we now back up all the way to the root app feature module we will see it does not build. Looks like the home feature makes use of settings too. We now have to repeat everything all over again.
"""#,
      timestamp: (33*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We need to add the dependency to the home environment and initializer:
"""#,
      timestamp: (33*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We need to update any place we construct the home environment:
"""#,
      timestamp: (33*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And finally the app feature module builds. Believe it or not there are still more spots that need to be updated, such as the entry point for the app and app clip, as well as tests.
"""#,
      timestamp: (35*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But we aren’t going to put you through watching us update all of that. The main point we want to get across is that this is an absolute pain, and the library should do something to make this easier.
"""#,
      timestamp: (35*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It should be possible to add a dependency to a leaf feature without having to update every single feature that depends on it. And we should even be able to bake in some of the best practices for constructing dependencies, such as using “unimplemented” dependencies that simply fail if you ever invoke their endpoints. Such dependencies are great for proving that certain execution flows use only the dependencies you think they should, and in the future being notified when features start using new dependencies.
"""#,
      timestamp: (36*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Even more amazing, by trying to address this problem, we will come up with a tool that allows us to solve other problems that look quite different. For example, we have found that we can use this tool to improve how navigation is modeled in Composable Architecture applications, and we believe there are even more uses out there that we haven’t even discovered yet.
"""#,
      timestamp: (36*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Performance and stack size"#,
      timestamp: (36*60 + 46),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
There’s one last problem with how reducers are currently set up in the library, but it isn’t immediately obvious like some of the other things we’ve discussed. It has to do with performance and memory usage.
"""#,
      timestamp: (36*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Currently reducers are created by passing an escaping closure to a struct initializer. Swift does not inline and optimize escaping closures like it does for methods. We’ve seen this in very concrete terms in past episodes when we converted a `Parser` struct to a `Parser` protocol. We saw that by constructing deeply nested parser types representing complex parsers, Swift could optimize away most of the nesting, giving us a compact set of stack frames. On the other hand, nesting escaping closures could not be optimized. Each nested parser resulted in a few additional stack frames, and it resulted in a measurable performance hit.
"""#,
      timestamp: (36*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We would expect the same with reducers. To see this concretely, let’s quickly put a breakpoint in an action in the settings feature:
"""#,
      timestamp: (37*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case let .tappedProduct(product):
  state.isPurchasing = true
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And let’s run the application, start a game, go into settings, and then tap the product button.
"""#,
      timestamp: (37*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
When the breakpoint triggers we see that there are about 100 stack frames in the debugger. But worse, the stack frame where we send the action in the view is #65, which means we incurred the cost of 65 stack frames just to send an action.
"""#,
      timestamp: (38*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Moving to protocols will help us flatten and inline a lot of these frames. But even better, by flattening the stack frames that occur when sending actions we will also reduce the amount of memory on the stack. This will help people who need to hold a lot of data directly on the stack in the features.
"""#,
      timestamp: (38*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Next time: the solution"#,
      timestamp: (38*60 + 38),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we have now seen there is still a ton of room for improvement in the library:
"""#,
      timestamp: (38*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- We can do a better job of providing a more natural space for housing the state, actions and logic of your features built in the Composable Architecture.
"""#,
      timestamp: (38*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- We can help out the compiler a bit so that it is not so strained, leading us to lose type inference, autocomplete and warnings.
"""#,
      timestamp: (38*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- There’s improvements we can make to readability of highly composed reducers, as well as the correctness of some of the more powerful operators in the library.
"""#,
      timestamp: (38*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- We definitely have to do something about the ergonomics of the environment, because right now it’s quite a pain to add new dependencies to a leaf node of an application and update every layer through to the root of the application.
"""#,
      timestamp: (39*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- And finally, there’s performance improvements we can make because highly modularized applications will lead to very deep call stacks.
"""#,
      timestamp: (39*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Well, luckily for us it’s possible to solve all of these problems, and more. By putting a protocol in front of reducers, and by constructing reducers as concrete types that conform to the protocol rather than deeply nested escaping closures, we will greatly improve the experience of developing large, complex features in the library.
"""#,
      timestamp: (39*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, let’s get to it...next time!
"""#,
      timestamp: (39*60 + 49),
      type: .paragraph
    ),
  ]
}
