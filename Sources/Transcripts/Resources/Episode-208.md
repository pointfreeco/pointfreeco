## Introduction

@T(00:00:05)
We have spent the past 7 episodes completely reinventing the manner in which one creates features in the Composable Architecture. Something as seemingly innocent as putting a protocol in front of the fundamental reducer type completely changed the way we think about implementing reducers, composing reducers, providing dependencies to reducers, and even testing them.

@T(00:00:25)
And this week we are finally releasing an update to the library that brings all of those tools to the public, and there’s even a whole bunch of other tools and features shipping that we didn’t have time to cover in the past episodes. We’d like to celebrate the release by highlighting a couple of places where this new style of reducer has greatly simplified how we approach problems with the library. We will take a look at a few case studies and demo applications that ship with the library, as well as look at our open-source word game, [isowords](https://www.isowords.xyz), to see what the reducer protocol can do in a large, real-world application.

@T(00:00:57)
Let’s dig in!

## Recursive case study

@T(00:01:00)
Let’s start by looking at a few case studies where the protocol-style of reducers has greatly simplified things.

@T(00:01:05)
There’s a case study that demonstrates how one can deal with recursive state. In this demo you can add rows to a list, and then each row is capable of drilling down to a new list where you can add rows, and on and on and on.

@T(00:01:40)
Right now we have the git repo of the library pointed to a commit just before the reducer protocol was merged, which was [`a27a7a5`](https://github.com/pointfreeco/swift-composable-architecture/tree/a27a7a57bc776dfa6371bcdad5e62cad2a582512). Let’s see how this kind of feature was built in the previous version of the Composable Architecture.

@T(00:01:58)
It starts out just as any other kind of feature, where we model the domain. For example, the state just holds onto an identified array of state so that we can show it in a list, but interestingly it is a recursive data type:

```swift
struct NestedState: Equatable, Identifiable {
  let id: UUID
  var name: String = ""
  var rows: IdentifiedArrayOf<NestedState> = []
}
```

@T(00:02:14)
The `NestedState` type holds onto a collection of itself. This is how we can allow drilling down any number of levels.

@T(00:02:18)
The action enum is similar, where it contains a case that references itself so that we can expression actions that happen any number of layers deep:

```swift
enum NestedAction: Equatable {
  case addRowButtonTapped
  case nameTextFieldChanged(String)
  case onDelete(IndexSet)
  indirect case row(
    id: NestedState.ID, action: NestedAction
  )
}
```

@T(00:02:30)
One thing to note is that we had to mark the enum as `indirect` in order to allow it to be recursive.

@T(00:02:38)
And then there’s an environment for the demo’s features, of which there is only one, a UUID generator:

```swift
struct NestedEnvironment {
  var uuid: () -> UUID
}
```

@T(00:02:44)
With the domain defined we can then define the reducer that implements the logic for the feature. This is a little tricky though. It would be easy enough to implement the logic for just a single list of rows. But we also need to implement the logic for a drill down from a list to a new list, and then another drill down, and on and on and on. Somehow the reducer itself needs to be recursive just as the state and actions were.

@T(00:03:12)
To aid in this, the demo comes with a little reducer helper called `recurse`. It allows you to implement a reducer like normal by being handed state, action and environment, but it also hands you a reference to `self` that can be used to perform recursive logic:

```swift
extension Reducer {
  static func recurse(
    _ reducer:
      @escaping (Self, inout State, Action, Environment)
        -> Effect<Action, Never>
  ) -> Self {

    var `self`: Self!
    self = Self { state, action, environment in
      reducer(self, &state, action, environment)
    }
    return self
  }
}
```

@T(00:03:30)
The implementation is simple enough. You just upfront define an implicitly unwrapped optional reducer, create a new reducer that captures that value, and then assign the value. That little dance allows you to tie the loop of recursion.

@T(00:03:49)
With that helper defined you can now define the demo’s logic in the standard way with the one small addition that we will invoke the `self` reducer inside the recursive `row` action:

```swift
let nestedReducer = Reducer<
  NestedState, NestedAction, NestedEnvironment
>.recurse { `self`, state, action, environment in
  switch action {
  case .addRowButtonTapped:
    state.rows.append(
      NestedState(id: environment.uuid())
    )
    return .none

  case let .nameTextFieldChanged(name):
    state.name = name
    return .none

  case let .onDelete(indexSet):
    state.rows.remove(atOffsets: indexSet)
    return .none

  case .row:
    return self.forEach(
      state: \.rows,
      action: /NestedAction.row(id:action:),
      environment: { $0 }
    )
    .run(&state, action, environment)
  }
}
```

@T(00:04:03)
This reducer is a little bit mind-bendy, but it gets the job done. Needing to `.forEach` on the `self` in order to run the reducer on the collection of children is wild, but once that is done you get something really powerful out of it.

@T(00:04:30)
Let’s see what this looks like when we port this over to the `ReducerProtocol`. I’ll switch over to [version 0.41](https://github.com/pointfreeco/swift-composable-architecture/tree/0.41.0), and we’ll see that the domain modeling looks basically the same, except we now use `@Dependency` in order to instantly get access to a fully controllably UUID generator:

```swift
struct Nested: ReducerProtocol {
  struct State: Equatable, Identifiable {
    let id: UUID
    var name: String = ""
    var rows: IdentifiedArrayOf<State> = []
  }

  enum Action: Equatable {
    case addRowButtonTapped
    case nameTextFieldChanged(String)
    case onDelete(IndexSet)
    indirect case row(id: State.ID, action: Action)
  }

  @Dependency(\.uuid) var uuid

  …
}
```

@T(00:05:10)
Where things start to really differ is how the actual logic of the reducer is implemented. Rather than having a closure that takes state and action, we implement a property called `body`:

```swift
var body: some ReducerProtocol<State, Action> {
  …
}
```

@T(00:05:21)
This is the way to compose reducers in the Composable Architecture, and it may not seem like we are composing anything, but we really are. We not only need to run the logic for a particular list of rows, but also the logic for the drill downs of those rows, and the drill downs of the drill downs, etc.

@T(00:05:41)
So, we implement the logic for just a single list of rows by constructing a `Reduce` value that is handed some state and an action so that we can mutate the state and return any effects necessary.

@T(00:05:59)
Then the real magic happens. We invoke the `.forEach` operator on that reducer in order to run another reducer on each row of the collection of child states. But, which reducer do we want to run? We want to recursively run the same reducer on each row.

@T(00:06:13)
Previously that required some tricks to get a recursive handle on the reducer so that we could invoke it for each row, but now that isn’t necessary at all. The reducers constructed in the `body` property are already lazy since to run the reducer the library first invokes the `body` property to construct a reducer, and then hits the `reduce` method.

This means we can recursively use `Self` inside the `body` property:

```swift
var body: some ReducerProtocol<State, Action> {
  Reduce { state, action in
    switch action {
    case .addRowButtonTapped:
      state.rows.append(State(id: self.uuid()))
      return .none

    case let .nameTextFieldChanged(name):
      state.name = name
      return .none

    case let .onDelete(indexSet):
      state.rows.remove(atOffsets: indexSet)
      return .none

    case .row:
      return .none
    }
  }
  .forEach(\.rows, action: /Action.row(id:action:)) {
    Self()
  }
}
```

This will run the `Self` reducer on each row of the collection as actions come into the system. This is so much simpler and clearer than the contortions we had to put ourselves through previously.

@T(00:06:43)
But the benefits go beyond what we are seeing here. Because reducers are now expressed as types that expose a `reduce` method or a `body` property, Swift can do a much better job at optimizing and inlining code. That causes stack traces to become much slimmer, which can lead to performance improvements and decrease memory usage.

@T(00:07:01)
To see this in concrete terms, let’s stub some data in this recursion case study so that we can drill down 20 levels deep, and we’ll put a breakpoint in the action that is sent when the add button is tapped. We will also switch the build configuration to “Release” so that we get a realistic picture of how the app behaves when running production.

@T(00:07:52)
If we run in the simulator, drill down all 20 times, and then add a row, the breakpoint will trigger and we will see a pretty sizable stack trace. Let’s copy and paste it into [a text document](https://gist.githubusercontent.com/mbrandonw/500f51eaf0a0e4fb4ae3497e82278ece/raw/24f1e9f5b7c40671b4373afc268868d78f5649b0/0.41.0).

@T(00:08:28)
There’s 165 stack frames, but really the first stack frame with our code is at #129. So 36 of these frames are just things that iOS and SwiftUI are doing and we have no control over. Further, 98 of these stack frames have the label “[inlined]”, which means that aren’t actual stack frames. They get optimized away.

@T(00:08:58)
This means that 165 minus 98 is the true number of stack frames, which is 66, and of those 66 stack frames, 36 of them are out of our control. So our code constitutes only 31 stack frames even though we have a highly composed features spanning 20 layers of functionality.

@T(00:09:17)
We can even quickly delete all lines that contain “[inlined]” to see how just short and succinct this stack trace is.

@T(00:09:26)
We can see that a little helper method in the `_ForEachReducer` isn’t getting inlined for some reason. Perhaps it’s a little too heavyweight and so Swift decided not to inline it. That’s ok, we don’t need to inline everything.

@T(00:09:39)
Let’s quickly compare this to how things used to be before the reducer protocol. We aren’t going to run the older version to get the stack trace. Instead, we’ve already done all of that work, and I have the stack trace I can paste [right here](https://gist.githubusercontent.com/mbrandonw/500f51eaf0a0e4fb4ae3497e82278ece/raw/24f1e9f5b7c40671b4373afc268868d78f5649b0/0.40.2).

@T(00:10:03)
This is the stack trace from drilling down 20 levels deep and then tapping the add button. It has 191 stack frames, but the first stack frame from our code happens at #155. So again, about 36 stack frames are due to just iOS and SwiftUI right out of the gate.

@T(00:10:16)
However, if we search for “[inlined]” in this stack trace we will see that only 42 frames were inlined, as opposed to 98 stack frames when using the reducer protocol. This means that our application code constitutes a whopping 113 stack frames once you remove all of the inlined frames and the frames that are out of our control. That’s more than 3 times the number of frames than in the protocol version of this feature.

@T(00:10:36)
To see something even more shocking, let’s take a look at the stack trace back in version 0.39 of the library. This was a few releases ago, and it was before we made a series of sweeping performance improvements to the library a few weeks ago. I’ll paste in [the stack trace](https://gist.githubusercontent.com/mbrandonw/500f51eaf0a0e4fb4ae3497e82278ece/raw/24f1e9f5b7c40671b4373afc268868d78f5649b0/0.39.1) of running the exact same case study, drilling down 20 levels, and then tapping the add button.

@T(00:11:00)
There are now a whopping 347 stack frames, of which only 42 have been inlined. Removing those stack frames and the ones that are out of our control we will find that our application contributes 269 stack frames, which is nearly 10 times more than when using the reducer protocol. This is absolutely massive, and should come with some performance benefits and decrease in memory usage.

## Preview dependencies

@T(00:11:22)
While performance improvements to the library are certainly welcome, by far the biggest improvement made to the library thanks to the reducer protocol is the new, shiny dependency management system. We are going to show how this new system completely changes the way we deal with dependencies by looking at isowords in a moment, but before then we can show off an improvement we made in the final release of the library that was not covered in an episode. And it was all thanks to [a suggestion from a community member](https://github.com/pointfreeco/swift-composable-architecture/discussions/1282#discussioncomment-3449849) that participated in the public beta.

@T(00:11:51)
As we covered in the episodes, when you register a dependency with the library you must always specify a “live” value that is used when the application runs in the simulator or on device. It’s the version of the dependency that can actually interact with the outside world, including making network requests, accessing location managers, or who knows what else.

@T(00:12:11)
You can also provide a “test” value, and that will be used when testing your feature with the `TestStore`, and typically we like to construct an instance of the dependency that performs an `XCTFail` if any of its endpoints are invoked. This gives us the nice behavior of forcing us to account for how dependencies are used in tests.

@T(00:12:30)
For the final release of the library we added one more type of dependency you can provide: a “preview” value. This is the version of the dependency that will be used when running your feature in an Xcode preview. This gives you a chance to provide a baseline of data and functionality without using an actual, live dependency. You of course don’t have to provide a preview value, and if you don’t it will default to the live value.

@T(00:12:57)
Let’s take a look at the speech recognition demo application to see how this works. Recall that this demo shows off how to use Apple’s Speech framework to live transcribe audio into a text transcript on the screen. Let’s quickly demo that in the simulator.

@T(00:13:32)
The way this works is that we have defined a `SpeechClient` dependency that represents the interface to how one interacts with the Speech framework in iOS:

```swift
struct SpeechClient {
  var finishTask: @Sendable () async -> Void
  var requestAuthorization: @Sendable
    () async ->
      SFSpeechRecognizerAuthorizationStatus
  var startTask: @Sendable
    (SFSpeechAudioBufferRecognitionRequest) async ->
      AsyncThrowingStream<
        SpeechRecognitionResult, Error
      >
}
```

@T(00:13:41)
It has 3 simple endpoints. One for asking for authorization to recognize speech, one for starting a speech recognition task, and then one for stopping the task.

@T(00:13:48)
We provide a number of implementations of this interface. The most important one is the “live” client, which actually calls out to Apple’s APIs under the hood.

@T(00:14:08)
We even use an actor under the hood in order to serialize access to Apple’s framework. That’s a technique we will discuss on Point-Free sometime in the future.

@T(00:14:19)
There’s also the “unimplemented” `testValue` that simply causes a test failure if any of its endpoints are called.

@T(00:14:30)
There’s also this super interesting `previewValue`.

@T(00:14:35)
It’s an implementation of the `SpeechClient` that emulates how the speech APIs works without actually calling out to any of Apple’s APIs. When you start a speech recognition task with this client it will just send back a stream of transcripts that spell out a bunch of “lorem ipsum” text. It even dynamically changes the cadence of the words to emulate longer words taking longer to say. This allows you to see how the client’s behavior flows through your feature’s logic without needing to call Apple’s APIs.

@T(00:15:07)
And the reason you would want to do that is because many times it is not possible to use Apple’s APIs. In particular, in SwiftUI previews. It is just not possible to use the Speech framework in SwiftUI previews. Same goes for core location, core motion, and a lot more. If you want to run features that use those technologies in a preview, you have to go the extra mile to control those dependencies so you can supply stubbed out data and behavior. Otherwise your feature will just be broken in the preview and you won’t be able to iterate on its logic or styling quickly.

@T(00:15:39)
If we hop to SpeechRecognition.swift and go to the bottom of the file we will see that a preview is provided, and it’s quite simple:

```swift
struct SpeechRecognitionView_Previews: PreviewProvider {
  static var previews: some View {
    SpeechRecognitionView(
      store: Store(
        initialState: SpeechRecognition.State(
          transcribedText: "Test test 123"
        ),
        reducer: SpeechRecognition()
      )
    )
  }
}
```

@T(00:15:46)
There’s no mention of dependencies at all.

Based on how we developed the dependency story in our past episodes we would be using the live speech client in this preview, which means accessing the Speech framework’s APIs, which means we would just have a broken preview. Nothing would actually work.

@T(00:15:51)
But, if we run the preview and hit the record button, we will see that the feature emulates what happens in practice when running the app. A stream of words slowly animate onto the screen, as if we were speaking those words and having the app live transcribe it.

@T(00:16:08)
This is happening because when registering dependencies with the library you get to specify a version of the dependency to use only in previews, allowing you to provide some stubbed data and logic. Had the preview been using the live implementation we would have a completely non-functional preview, as can be seen by overriding the dependency to be the `liveValue`:

```swift
struct SpeechRecognitionView_Previews: PreviewProvider {
  static var previews: some View {
    SpeechRecognitionView(
      store: Store(
        initialState: SpeechRecognition.State(
          transcribedText: "Test test 123"
        ),
        reducer: SpeechRecognition()
          .dependency(\.speechClient, .liveValue)
      )
    )
  }
}
```

@T(00:16:29)
The preview is completely broken now, which means you lose the ability to iterate on how text flows onto the screen. Maybe you want to play with styling or animations. With the live dependency that actually interacts with the Speech framework that would be impossible, but thanks to our “lorem” client it’s very easy.

@T(00:16:59)
And this all works because we have provided a `previewValue` in our conformance to the `TestDependencyKey` protocol:

```swift
extension SpeechClient: TestDependencyKey {
  static let previewValue = {
    …
  }()
  …
}
```

@T(00:17:05)
Remember, it’s not necessary to provide this. We don’t want to make things harder for you to adopt this dependency system. If you choose not to provide a `previewValue` it will take the `liveValue` in previews. And you can always override dependencies directly on the reducer when constructing your preview.

## `ifCaseLet`

@T(00:17:19)
There’s one last thing we want to show off in the demo applications that come with the library before we hop over to isowords. In the episodes discussing the reducer protocol we showed how dealing with optional and array state in the library used to be fraught. It was on you to wield the APIs correctly, in particular you needed to combine the child and parent reducers in a very particular order.

@T(00:17:40)
We re-imagined what these operations could look like by making them into methods defined on the reducer protocol so that we could enforce the order under the hood, thus baking more correctness into the API.

@T(00:17:54)
We showed off how this looked in the voice memos demo application, where the root feature needs to conditionally run a reducer on some optional state and be able to run a reducer on each element of a collection. It looked something like this:

```swift
var body: some ReducerProtocol<State, Action> {
  Reduce { state, action in
    …
  }
  .ifLet(
    \.recordingMemo, action: /Action.recordingMemo
  ) {
    RecordingMemo()
  }
  .forEach(
    \.voiceMemos, action: /Action.voiceMemo(id:action:)
  ) {
    VoiceMemo()
  }
}
```

@T(00:18:10)
To use `ifLet` you first identify the optional state you want to operate on, as well as the actions the child domain uses, and then specify the reducer you want to run on that optional state. And similarly for `forEach`.

@T(00:18:31)
Well, those operators work great for optional and collection state, but there’s another kind of state that is important to be able to handle: enums. For that reason we have also added an `ifCaseLet` operator to the library.

@T(00:18:44)
We have an example of this in the Tic-Tac-Toe demo application, which models its root state as an enum for whether or not the user is logged in:

```swift
public enum State: Equatable {
  case login(Login.State)
  case newGame(NewGame.State)

  public init() { self = .login(Login.State()) }
}
```

@T(00:19:27)
Then we can compose a reducer together that runs a reducer on each case of the enum in addition to a reducer that handles the root level logic of the application:

```swift
public var body: some ReducerProtocol<State, Action> {
  Reduce { state, action in
    …
  }
  .ifCaseLet(/State.login, action: /Action.login) {
    Login()
  }
  .ifCaseLet(/State.newGame, action: /Action.newGame) {
    NewGame()
  }
}
```

@T(00:19:38)
This operator bakes in the same safety features as `ifLet` and `forEach`, making it easier to use correctly.

## isowords

@T(00:20:03)
So, this new release is looking pretty great for simplifying features built in the Composable Architecture. The new protocol is capable of expressing recursive features in a simple, natural way, and we’ve even added new powerful features to the dependency system that we didn’t get a chance to talk about in episodes.

@T(00:20:19)
Let’s now turn our attention to isowords, our open source word game built entirely in SwiftUI and the Composable Architecture. It’s a highly modularized code base, with each core feature of the application put into its own module, and it’s a pretty complex application, needing to deal with lots of effects, including network requests, Game Center, randomness, audio players, haptics and more.

@T(00:20:44)
We also have an extensive test suite, both unit tests and snapshot tests, for all major parts of the application, which means we heavily lean on needing to control our dependencies. By embracing the `ReducerProtocol` we are able to delete a massive amount of unnecessary code, and we could simplify some of our most complicated reducers.

@T(00:21:03)
Let’s take a look.

@T(00:21:06)
If you recall, we kicked off our reducer protocol series of episodes by showing all the problems with the library that we think could be solved with the protocol. The boilerplate associated with explicit environments of dependencies was a huge problem. We showed this by adding a dependency to a leaf node feature in isowords, the settings screen:

```swift
struct SettingsEnvironment {
  var someValue: Int
  …
}
```

@T(00:21:38)
…and saw how that seemingly innocent change reverberated throughout the entire application. We had to update every feature that touched the settings feature by adding this dependency to their environments, then updating their initializers to handle that new dependency since the features are modularized, and then pass that new dependency down to settings. And then we had to do it all over again for every feature that touched a feature that touched the settings feature. And on, and on, and on until we got to the entry point of the application. And if that wasn’t bad enough, the tests were also broken and needed to be updated, but we didn’t even attempt to do that in the episode.

@T(00:22:09)
All in all, it took us 8 minutes to accomplish this in the episode, and that’s with movie magic editing to try to make the experience less painful for our viewers, while still trying to communicate just how painful it is to do in real life.

@T(00:22:19)
Let’s see what this looks like with reducer protocols. We’ve already got the settings feature converted to the new `ReducerProtocol`, and it uses the `@Dependency` property wrapper to specify which dependencies it needs:

```swift
public struct Settings: ReducerProtocol {
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.applicationClient) var applicationClient
  @Dependency(\.audioPlayer) var audioPlayer
  @Dependency(\.build) var build
  @Dependency(\.fileClient) var fileClient
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.remoteNotifications.register)
  var registerForRemoteNotifications
  @Dependency(\.serverConfig.config) var serverConfig
  @Dependency(\.storeKit) var storeKit
  @Dependency(\.userNotifications) var userNotifications

  …
}
```

@T(00:22:49)
If the dependency we want to add to this feature happens to already exist, whether it’s a dependency that ships with the library or a first-party dependency that you defined, then we can just add it directly. For example, suppose the settings feature all the sudden needs access to the current date. That’s as simple as this:

```swift
@Dependency(\.date) var date
```

@T(00:23:12)
Miraculously everything still compiles, even tests. There is no step 2. In less than 10 seconds we can add a new dependency without changing any feature that needs to interact with the settings feature. Settings will be automatically provided a live date dependency when run in the simulator or on a device, and in tests it will be provided an “unimplemented” version that causes a test failure if it is ever used, forcing you to think about how this dependency might affect your feature’s logic.

@T(00:23:44)
For example, if we run the settings tests right now we will find that all tests pass because nothing in the reducer is actually using the date dependency. If we start using it somewhere, like say just computing the current date inside an effect:

```swift
case .binding(\.$developer.currentBaseUrl):
  return .fireAndForget {
    [url = state.developer.currentBaseUrl.url] in

    await self.apiClient.setBaseUrl(url)
    await self.apiClient.logout()
    _ = self.date.now
  }
```

@T(00:24:05)
We now get a test failure because an unimplemented dependency is being used:

> Failed: testSetApiBaseUrl(): Unimplemented: @Dependency(\.date)

@T(00:24:21)
This is incredible. The test suite is letting us know that something tricky is happening in our feature that we aren’t yet asserting against, and so we should do something about that.

@T(00:24:30)
To get the test passing we need to stub out the date dependency with something we control, like a constant date:

```swift
store.dependencies.date.now =
  Date(timeIntervalSinceReferenceDate: 1234567890)
```

@T(00:24:48)
And now the test passes. Of course, we didn’t add a new assertion, but that’s also because we didn’t actually use the date in any meaningful way. If we had then there would actually be some more work to do here.

@T(00:25:00)
So, it takes less than 10 seconds to add a dependency to a feature if that dependency so happens to already be available. What about if you need to register a whole new dependency with the library?

@T(00:25:09)
For example, in the past episode demonstrating the problem of environments, we added an integer to the environment to show how things go wrong. Let’s do the same here. It starts by creating a new type that represents a key that can be used to find a dependency in the global, nebulous blob of dependencies:

```swift
private enum SomeValueKey: DependencyKey {
}
```

@T(00:25:42)
The bare minimum you need to provide this conformance is a `liveValue`, which is the value used when running your application on a device or simulator. Right now we’ll just use an integer:

```swift
private enum SomeValueKey: DependencyKey {
  static let liveValue = 42
}
```

@T(00:25:52)
…but more generally this is where you would construct an implementation of some dependency client that interacts with the real world, such as making network requests, interacting with databases, file systems and more.

@T(00:26:03)
With the key defined, we now need to provide a computed property on `DependencyValues` for accessing and setting the dependency:

```swift
extension DependencyValues {
  var someValue: Int {
    get { self[SomeValueKey.self] }
    set { self[SomeValueKey.self] = newValue }
  }
}
```

@T(00:26:52)
`DependencyValues` is the global, nebulous blob of dependencies, and so this computed property “registers” the dependency with the library so that it can be instantly used from any reducer.

@T(00:27:03)
And this little dance to register the dependency might seem a little weird, but really it’s no different than what one has to do to register an environment value with SwiftUI, which allows you to implicitly push values deep into a view hierarchy. In fact, we modeled our dependency system heavily off of how environment values work in SwiftUI.

@T(00:27:19)
With that little bit of work done, we instantly get the ability to fetch this dependency from the global `DependencyValues` store:

```swift
// @Dependency(\.date) var date
@Dependency(\.someValue) var someValue
```

@T(00:27:38)
And we can start using it right in the reducer:

```swift
// _ = self.date.now
_ = self.someValue
```

@T(00:27:45)
This was incredibly easy to do. If I hadn't been blabbering the whole time I could have added this dependency in under a minute, and the whole application still builds as do all tests.

@T(00:27:57)
Speaking of tests, how does registering new dependencies with the library affect tests? Let’s run them and find out.

@T(00:28:04)
Well, looks like we got a failure:

> Failed: testSetApiBaseUrl(): @Dependency(\.someValue) has no test implementation, but was accessed from a test context:
>
>     Location:
>       SettingsFeature/Settings.swift:204
>     Key:
>       SomeValueKey
>     Value:
>       Int
>
> Dependencies registered with the library are not allowed to use their default, live implementations when run in a 'TestStore'.
>
> To fix, override 'someValue' with a mock value in your test by mutating  the 'dependencies' property on your 'TestStore'. Or, if you'd like to provide a default test value, implement the 'testValue' requirement of the 'DependencyKey'  protocol.

@T(00:28:18)
This helpfully lets us know that we haven’t provided a test implementation of our dependency. It even tells exactly which dependency it is and where we used the dependency.

@T(00:28:31)
And it’s pretty clear we don’t have a test value for this dependency by look at its conformance to `DependencyKey`:

```swift
private enum SomeValueKey: DependencyKey {
  static let liveValue = 42
}
```

@T(00:28:40)
The library is taking a stance on how live dependencies are allowed to be used in tests.

@T(00:28:44)
On the one hand, we want to make it easy for you to get started with the dependency system by not forcing you to provide a live value and a test value just to get something up on the screen. So, we require only a `liveValue` at the bare minimum, and then the `testValue` will be derived from that `liveValue`.

@T(00:29:00)
However, we do not think it’s ever appropriate to use live dependencies in tests. This could lead you to making network requests, accidentally tracking analytics events that don’t represent true user behavior, or trampling on the global, shared user defaults in your application. None of that is ideal, so the library forces its opinion on users.

@T(00:29:18)
Luckily, the fix is easy. You just need to supply a version of the dependency that is appropriate for using tests. You can do this on a test-by-test basis by overriding the dependency on the test store:

```swift
store.dependencies.someValue = 42
```

@T(00:29:35)
Now the test passes, and so if we were using this value in some real way we could make an assertion on that logic.

@T(00:29:43)
Or you can drop that line from the test, and instead provide all tests with a default test value by augmenting the dependency key:

```swift
private enum SomeValueKey: DependencyKey {
  static let liveValue = 42
  static let testValue = 0
}
```

@T(00:29:57)
Now tests still pass.

@T(00:30:00)
Now, for some very simple dependencies it may be fine to stub in a test value for all tests to use without failure, but as we mentioned a moment ago it can be very powerful to know when features are using dependencies that you didn’t account for so that you can strengthen your assertions.

@T(00:30:15)
So, most of the time we recommend leaving out the `testValue` in your dependencies so that you can get that instant feedback when something starts using the dependency.

@T(00:30:23)
If your dependency is very complicated, having a whole bunch of endpoints you can interact with, like say a file system client that can create, read, update and delete files, then you may want to provide an “unimplemented” version of the dependency that invokes `XCTFail` whenever any of its endpoints are accessed.

@T(00:30:41)
For example, the audio player dependency that allows us to play sound effects and music in the game has 8 different endpoints:

```swift
public struct AudioPlayerClient {
  public var load: @Sendable ([Sound]) async -> Void
  public var loop: @Sendable (Sound) async -> Void
  public var play: @Sendable (Sound) async -> Void
  public var secondaryAudioShouldBeSilencedHint:
    @Sendable () async -> Bool
  public var setGlobalVolumeForMusic:
    @Sendable (Float) async -> Void
  public var setGlobalVolumeForSoundEffects:
    @Sendable (Float) async -> Void
  public var setVolume:
    @Sendable (Sound, Float) async -> Void
  public var stop: @Sendable (Sound) async -> Void

  …
}
```

@T(00:30:50)
If one of these endpoints is used in a test where we didn’t explicitly override it, we want a failure to let us know exactly which endpoint was accessed. And for that reason we perform a little bit of upfront work to provide an unimplemented version of the client that causes a test failure if the endpoint is ever accessed:

```swift
extension AudioPlayerClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    load: XCTUnimplemented("\(Self.self).load"),
    loop: XCTUnimplemented("\(Self.self).loop"),
    play: XCTUnimplemented("\(Self.self).play"),
    secondaryAudioShouldBeSilencedHint: XCTUnimplemented(
      "\(Self.self).secondaryAudioShouldBeSilencedHint",
      placeholder: false
    ),
    setGlobalVolumeForMusic: XCTUnimplemented(
      "\(Self.self).setGlobalVolumeForMusic"
    ),
    setGlobalVolumeForSoundEffects: XCTUnimplemented(
      "\(Self.self).setGlobalVolumeForSoundEffects"
    ),
    setVolume: XCTUnimplemented(
      "\(Self.self).setVolume"
    ),
    stop: XCTUnimplemented("\(Self.self).stop")
  )
}
```

@T(00:31:26)
These `XCTUnimplemented` functions are provided by our [XCTestDynamicOverlay](https://github.com/pointfreeco/xctest-dynamic-overlay) library, which automatically comes with the Composable Architecture:

```swift
import XCTestDynamicOverlay
```

@T(00:31:36)
And it allows you to define test helpers in application code, which is usually not possible because the XCTest framework is not available.

@T(00:31:42)
This forces us to override each individual endpoint we expect to be used in the user flow we are testing.

@T(00:31:50)
So, things are looking pretty incredible. It’s so easy to add new dependencies, and by default the library guides you to do so in the safest way possible when it comes to testing. There’s one other thing we want to show, which is something we discussed in past episodes.

@T(00:32:01)
Sometimes dependencies can be quite heavy weight or difficult to build, especially if they depend on a 3rd party framework, like Firebase, FFmpeg, or a web socket library, or who knows what else. In those times we like to separate the interface of the dependency, which is usually super lightweight and builds very quickly, from the implementation of the live dependency, which actually needs access to the heavy weight stuff.

@T(00:32:23)
We’ve got one example of needing to do this. Our API client separates interface from implementation because the interface only needs access to a few basic things that build quite fast:

```swift
.target(
  name: "ApiClient",
  dependencies: [
    "SharedModels",
    "XCTestDebugSupport",
    .product(
      name: "CasePaths", package: "swift-case-paths"
    ),
    .product(
      name: "Dependencies",
      package: "swift-composable-architecture"
    ),
    .product(
      name: "XCTestDynamicOverlay",
      package: "xctest-dynamic-overlay"
    ),
  ]
),
```

@T(00:32:54)
The live implementation, however, needs access to the ServerRouter library:

```swift
.target(
  name: "ApiClientLive",
  dependencies: [
    "ApiClient",
    "ServerRouter",
    "SharedModels",
    "TcaHelpers",
    .product(
      name: "Dependencies",
      package: "swift-composable-architecture"
    ),
  ],
  exclude: ["Secrets.swift.example"]
),
```

@T(00:33:05)
…which is the thing that actually constructs the router that powers both the API client for the iOS app and the router for the server. It uses our parsing library to do that, which incurs a small compilation cost:

```swift
.target(
  name: "ServerRouter",
  dependencies: [
    "SharedModels",
    .product(
      name: "Tagged", package: "swift-tagged"
    ),
    .product(
      name: "Parsing", package: "swift-parsing"
    ),
    .product(
      name: "URLRouting", package: "swift-url-routing"
    ),
    .product(
      name: "XCTestDynamicOverlay",
      package: "xctest-dynamic-overlay"
    ),
  ]
),
```

@T(00:33:26)
We can see this in concrete terms by building each library. If we build the ApiClient library we will see it takes about 3 seconds, so quite fast. And if we build the ApiClientLive library we will see it takes about 8 seconds. Still pretty fast, but it is definitely slower. And in the future the live library could get slower and slower to build.

@T(00:34:00)
But the cool thing is that any feature that needs the API client never has to incur the cost of the live API client, and hence the cost of the parsing library and router. Features that need the API client only need the interface, and so they just need to incur the 3 second compilation cost. That means it will be faster to iterate on, and as we’ve mentioned a bunch of times on Point-Free, beyond just raw compilation times, the less you build in features the more stable certain tools will be such, such as SwiftUI previews. We’ve seen cases were previews were completely broken for a feature module, but by eliminating access to a few live dependencies, especially certain Apple frameworks, we were able to restore preview functionality.

@T(00:34:40)
We can see how the dependency registration process works when interfaces and implementations are separated. In the ApiClient library we register a dependency key that only conforms to `TestDependencyKey`, which means you only have to provide a `testValue`. No `liveValue` is necessary at this point.

We can see how the dependency registration process works when interfaces and implementations are separated. In the ApiClient library we register the `ApiClient` type as a dependency value by defining a `TestDependencyKey`, which only requires that we provide a `testValue`, and optionally a `previewValue`. No `liveValue` is necessary at this point:

```swift
extension DependencyValues {
  public var apiClient: ApiClient {
    get { self[ApiClient.self] }
    set { self[ApiClient.self] = newValue }
  }
}
extension ApiClient: TestDependencyKey {
  public static let previewValue = Self.noop
  public static let testValue = Self(…)
}
```

@T(00:35:17)
Also note here that we didn’t introduce a whole new type to conform to `TestDependencyKey`. Often it is possible to conform a dependency’s interface directly to the dependency key protocols, and this can save us from the boilerplate and ceremony of defining yet another type just to register the dependency.

@T(00:35:39)
And then in the ApiClientLive library we can fully conform to the `DependencyKey` protocol by providing the live value:

```swift
extension ApiClient: DependencyKey {
  public static let liveValue = Self.live(
    sha256: { Data(SHA256.hash(data: $0)) }
  )
  …
}
```

@T(00:35:50)
So that’s pretty cool.

@T(00:35:51)
So, we’ve seen how to add a new dependency to a feature, but the entire application has already been converted to the new dependency system, and so what did that look like? Well, there was a ton of code we were able to delete.

@T(00:36:02)
The environment for the root app feature was so big that we had to put it in its own file even though we typically like to create all domain-related types together. The file was 140 lines, consisting of an `import` for every dependency the entire application uses, a struct with fields for every single dependency, and initializer that takes every dependency and assigns it, and then at the bottom we define some useful instances of the environment, such as an unimplemented one for tests and a “no-op” one handy for previews.

@T(00:36:59)
This 140 lines code squashes down to just 9 in the `AppReducer` struct:

```swift
@Dependency(\.fileClient) var fileClient
@Dependency(\.gameCenter.turnBasedMatch.load)
var loadTurnBasedMatch
@Dependency(\.database.migrate) var migrate
@Dependency(\.mainRunLoop.now.date) var now
@Dependency(\.dictionary.randomCubes) var randomCubes
@Dependency(\.remoteNotifications)
var remoteNotifications
@Dependency(\.serverConfig.refresh)
var refreshServerConfig
@Dependency(\.userDefaults) var userDefaults
@Dependency(\.userNotifications) var userNotifications
```

@T(00:37:15)
This is less than half the number of dependencies the full application uses. The app reducer doesn’t need things like an API client, or the haptic feedback generator, or store kit, or most of it really.

@T(00:37:26)
Further, not only did we get to whittle down the dependencies to just the 9 this feature needs, but we further whittled some dependencies down to just the one single endpoint the feature needs. For example, the only thing we need from the Game Center dependency is the ability to load turn based matches:

```swift
@Dependency(\.gameCenter.turnBasedMatch.load)
var loadTurnBasedMatch
```

@T(00:37:41)
The Game Center client has 15 other endpoints besides this `load` one, and we are making it very visible to any one looking at this code that we do not need any of that. We just need the one endpoint.

@T(00:37:52)
Same goes for the database client:

```swift
@Dependency(\.database.migrate) var migrate
```

@T(00:37:57)
…the dictionary client:

```swift
@Dependency(\.dictionary.randomCubes) var randomCubes
```

@T(00:38:01)
…the server config client:

```swift
@Dependency(\.serverConfig.refresh)
var refreshServerConfig
```

@T(00:38:04)
…and even the main run loop:

```swift
@Dependency(\.mainRunLoop.now.date) var now
```

@T(00:38:08)
This makes it clear we’re not even doing any time-based asynchrony in this feature. We just need a way of getting the current date.

@T(00:38:14)
So this is a huge win for the root level app feature, but the wins multiplied with every single feature module in the entire application. We were able to delete 26 environment structs, which means deleting 26 public initializers, and even delete even more places where we had to transform a parent environment into a child environment. It’s hard to measure exactly, but we certainly deleted close to if not over a 1,000 lines of code.

@T(00:38:40)
There’s a couple of other fun things in the isowords code base. We have a reducer operator defined that can enhance any existing reducer with on that performs haptic feedback when certain events happen. At the call site it looks like this:

```swift
.haptics(
  isEnabled: \.isHapticsEnabled,
  triggerOnChangeOf: \.selectedCubeFaces
)
```

@T(00:39:00)
The operator first takes an argument that allows us to specify whether or not the haptics is even enabled, which can be determined by reading a boolean from the feature’s state. The second argument is used to determine when a haptic feedback should be triggered. We can specify a piece of equatable state, and when that state changes the feedback will be triggered.

@T(00:39:18)
The cool part about this is that the `haptics` operator gets to hide some details from us that we don’t have to care about at the call site. In particular, the haptics functionality is implemented via a private type that conforms to the `ReducerProtocol`, and it depends on the `feedbackGenerator` dependency:

```swift
private struct Haptics<
  Base: ReducerProtocol, Trigger: Equatable
>: ReducerProtocol {
  let base: Base
  let isEnabled: (Base.State) -> Bool
  let trigger: (Base.State) -> Trigger

  @Dependency(\.feedbackGenerator) var feedbackGenerator

  var body: some ReducerProtocol<
    Base.State, Base.Action
  > {
    self.base
      .onChange(of: self.trigger) { _, _, state, _ in
        guard self.isEnabled(state)
        else { return .none }

        return .fireAndForget {
          await self.feedbackGenerator
            .selectionChanged()
        }
      }
  }
}
```

@T(00:39:37)
The feature invoking this functionality doesn’t need to know where it gets its dependencies from. That can be completely hidden.

@T(00:39:42)
The only time we will actually care is when writing tests, in which case we will get some failing tests if the feedback generator is invoked without being properly stubbed. But as soon as that happens we can just stub the dependency, either by putting in a no-op if we just want to quiet the error, or with something that tracks some state so that we can confirm the generator was invoked the way we expect.

@T(00:40:02)
There’s another example of this in a `sounds` reducer operator. It layers complex sound effect logic on top of the game without having to muddy the game reducer, which is already extremely complex. This is done with a private `GameSounds` reducer, which also needs some dependencies but the parent doesn’t need to know anything about that:

```swift
private struct GameSounds<
  Base: ReducerProtocol<Game.State, Game.Action>
>: ReducerProtocol {
  @Dependency(\.audioPlayer) var audioPlayer
  @Dependency(\.date) var date
  @Dependency(\.dictionary.contains)
  var dictionaryContains
  @Dependency(\.mainQueue) var mainQueue

  …
}
```

@T(00:40:28)
And then inside the `body` we have a very complex reducer, because the logic guiding sound effects is quite complex, but amazingly this can be kept fully separate from the game reducer. We don’t need to litter the game logic code with all of this gnarly sound effect logic, which makes it easier to edit each reducer in isolation.

@T(00:40:57)
There’s one last example we want to look at in isowords that is quite advanced, and this is something that was quite awkward to accomplish before the reducer protocol. The feature that handles all of the logic for leaderboards is called `LeaderboardResults`. The file that has this logic has a preview that shows all the different variations it handles.

@T(00:41:23)
It’s quite generic. This one reducer handles the logic for game leaderboards, word leaderboards and daily challenge leaderboards. That is 3 pretty significantly different use cases to package up into a single feature.

@T(00:41:42)
The thing is, though, that they all basically work the same, they just need to be customized in the way they filter their results. To handle this we make the entire feature generic over the type of time scope that can be used:

```swift
public struct LeaderboardResults<TimeScope>:
ReducerProtocol {
  …
}
```

@T(00:41:54)
This allows us to use a time scope of past day/week/all time for game and word leaderboards, and for daily challenges we use the date that represents which day we are fetching results for.

@T(00:42:03)
This allows us to consolidate a massive amount of code which otherwise would need to be duplicated. And the best part is that the type we define to conform to the `ReducerProtocol` provides a natural place for us to define the generic:

```swift
LeaderboardResults<TimeScope>
```

@T(00:42:18)
Previously this was quite awkward with the `Reducer` struct. There’s no way to make a value generic. We can’t do something like this:

```swift
let leaderboardResultsReducer<TimeScope> = Reducer { … }
```

@T(00:42:35)
Instead, we had to define a function that takes no arguments just so that we could get access to a generic:

```swift
func leaderboardResultsReducer<TimeScope>() -> Reducer<
  LeaderboardResultsState<TimeScope>,
  LeaderboardResultsAction<TimeScope>,
  LeaderboardResultsEnvironment<TimeScope>
> { … }
```

@T(00:42:49)
This makes it much nicer to create these kinds of super generic, reusable components that can be mixed into other features.

@T(00:42:58)
Also, interestingly, these kinds of super generic components don’t necessary need to leverage the dependency system. For example, the `LeaderboardResults` has only one dependency, an async endpoint for loading results from a game mode and time scope, and it specifies it as a regular property:

```swift
public struct LeaderboardResults<TimeScope>:
ReducerProtocol {
  …
  public let loadResults: @Sendable
    (GameMode, TimeScope) async throws -> ResultEnvelope
  …
}
```

@T(00:43:24)
It’s not appropriate to use `@Dependency` for this because this needs to be customized at the point of creating the `LeaderboardResults` reducer. Dependency values are perfect for statically-known, global dependencies, but this dependency is super generic.

@T(00:43:45)
Instead, the feature that mixes `LeaderboardResults` into its functionality can lean on an `@Dependency` dependency in order to grab the endpoint it wants to pass along:

```swift
Scope(state: \.solo, action: /Action.solo) {
  LeaderboardResults(
    loadResults: self.apiClient.loadSoloResults
  )
}
Scope(state: \.vocab, action: /Action.vocab) {
  LeaderboardResults(
    loadResults: self.apiClient.loadVocabResults
  )
}
```

@T(00:44:05)
In this case we grab the `loadSoloResults` and `loadVocabResults` endpoints from the API client, and configure `LeaderboardResults` with those functions.

## Conclusion

@T(00:44:42)
That concludes our quick overview of the latest release of the Composable Architecture, which introduces the reducer protocol and a whole new dependency management system. It’s worth noting that this update is 100% backwards compatible with the previous version of the library. If you already have a large application built with the library, there is no reason to stop everything and update everything right now. You can do it slowly, on your own time, piece by piece, and we even have some [upgrade guides](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingtothereducerprotocol) that give pointers on how to do that.

@T(00:45:09)
We have even made these changes compatible for people who can’t yet upgrade to Xcode 14 and Swift 5.7. The features that require Swift 5.7 tools will gracefully degrade to Swift 5.6 friendly code, making it even easier for you to incremental adopt the new reducer protocol when you are ready.

@T(00:45:27)
So, that’s it for this week, and next week we start a completely different topic.

@T(00:45:32)
Until next time!
