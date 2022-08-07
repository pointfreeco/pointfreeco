import Foundation

extension Episode {
  public static let ep195_tcaConcurrency = Episode(
    blurb: """
      The Composable Architecture's fundamental unit of effect is modeled on Combine publishers because it was the simplest and most modern asynchrony tool available at the time. Now Swift has native concurrency tools, and so we want to make use of those tools in the library. But first, let's see what can go wrong if we try to naively use async/await in an existing application.
      """,
    codeSampleDirectory: "0195-tca-concurrency-pt1",
    exercises: _exercises,
    fullVideo: .ep195_tcaConcurrency,
    id: 195,
    length: 40 * 60 + 40,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_656_910_800),
    references: [
      reference(
        forCollection: .concurrency,
        additionalBlurb: "",
        collectionUrl: "http://pointfree.co/collections/concurrency"
      )
    ],
    sequence: 195,
    subtitle: "The Problem",
    title: "Async Composable Architecture",
    trailerVideo: .init(
      bytesLength: 75_900_000,
      downloadUrls: .s3(
        hd1080: "0195-trailer-1080p-ffad0c87c51448018313bc66e146e106",
        hd720: "0195-trailer-720p-a457f5a6becc4d85978883eb03fad7b4",
        sd540: "0195-trailer-540p-512c522b100c41c1ad7da8abd650f9ea"
      ),
      vimeoId: 726_095_967
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Episode.Video {
  public static let ep195_tcaConcurrency = Self(
    bytesLength: 399_300_000,
    downloadUrls: .s3(
      hd1080: "0195-1080p-55916e2ebde441f2b0eb84bd4032ac94",
      hd720: "0195-720p-c0cad256734040feb82d4fb5f4f126e6",
      sd540: "0195-540p-f3063a73e05d43819c615860a5012daa"
    ),
    vimeoId: 726_096_095
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep195_tcaConcurrency: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Currently, in the Composable Architecture, the fundamental unit of asynchrony is the `Effect` type, which conforms to Combine’s `Publisher` protocol. We do this because at the time of developing the Composable Architecture, Combine was the most modern asynchrony tool that Apple offered, but sadly Combine is closed source and not a part of the open source Swift project. This means that the Composable Architecture can really only be used on Apple platforms.
        """#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Ideally we could completely disentangle Combine from the Composable Architecture and instead use only Swift’s native concurrency tools. This would mean we could use the library on non-Apple platforms, such as Windows, Linux, Raspberry Pi, and even SwiftWASM for running Swift in the browser. It would also have the added benefit of being able to write complex asynchronous code in a very familiar style. After all, WHY use Combine operators like `map`, `flatMap` and `zip` to compose publishers when you can use things like `await`, `async let` and task groups?
        """#,
      timestamp: 28,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Unfortunately we cannot replace all of Combine with async/await today, and that’s because it would be a huge breaking change. Instead, we want to slowly layer on changes that are completely backwards compatible that allow us to use async/await in more and more places. Then someday we may eventually have a breaking change to get rid of Combine entirely, but by that point hopefully it will be a straightforward migration.
        """#,
      timestamp: 56,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Already in past episodes we have introduced some very basic concurrency tools to the library, such as an initializer on `Effect` that allows you to use async/await code, as well as an async version of `viewStore.send` that allows you to await until state changes to a particular value.
        """#,
      timestamp: (1 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Those tools allowed us to do a few cool things, such as interface with SwiftUI’s `refreshable` API, but they were quite superficial and even have some drawbacks. We’d like a deeper integration of concurrency into the library, but we also have to be careful in how we accomplish that.
        """#,
      timestamp: (1 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This week we are beginning a new series of episodes that brings some of Swift’s new concurrency tools into the library at a deeper level, but still in a completely backwards compatible manner. These tools will help you simplify how you construct effects, make tying effects to view lifecycles simpler, and even make testing a little nicer.
        """#,
      timestamp: (1 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"A effectful demo"#,
      timestamp: (2 * 60 + 12),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s start by taking a look at a few places we’d like to be able to make use of Swift’s concurrency tools in a Composable Architecture application, see why we can’t just naively adopt concurrency today, and then see what can be done to fix the situation.
        """#,
      timestamp: (2 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To explore this we are going to take a look at an existing case study in the Composable Architecture repo. It’s important to note that for this episode we are running version [0.38.2](https://github.com/pointfreeco/swift-composable-architecture/releases/0.38.2) of the library, so if you are watching this episode in the future you will know which version to pull down in order to follow along.
        """#,
      timestamp: (2 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If you didn’t know already, the library comes with dozens of case studies and demo applications that show how to solve everyday problems.
        """#,
      timestamp: (2 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The case study we are interested is titled “Effect Basics”. Like all great demos, it begins with a counter for incrementing and decrementing an integer on the screen. Once you count to a number you can ask for a fact about that number, which actually makes a request to an external API service for the fact.
        """#,
      timestamp: (2 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, if count up to the number 4 and ask for a fact we will find that:

        > 4 is the number of movements in a symphony.
        """#,
      timestamp: (3 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        You’ll also notice that while the number fact is loading we show a progress view, and then hide it once the request finishes.
        """#,
      timestamp: (3 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now, of course this app is not super complicated. It just makes a simple network request and manages a little bit of state, and so if the scope of your entire application is just this one screen, then you wouldn’t need anything like the Composable Architecture. It would probably be sufficient to use plain, vanilla SwiftUI with some `@State` variables and putting all the side effects directly in the view.
        """#,
      timestamp: (3 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, if after time you start adding more and more features to this screen, and the interactions on the screen become more complex and more subtle, you are eventually going to want to write some tests. And if even later down the road we decide to add more screens to our application, we may need all of our screens to be able to interact with each other in complex ways. Doing either of these things in vanilla SwiftUI can be quite tricky to get right.
        """#,
      timestamp: (3 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is where the Composable Architecture really starts to shine. It allows you to build features in a consistent manner, gives you a story of how to manage state, effects, and dependencies, gives you a story of how to plug multiple features together, and finally gives a really nice story on how to test the entire package.
        """#,
      timestamp: (4 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s see how this demo is built using the Composable Architecture, including its tests, and then see how we might improve it using Swift’s new concurrency tools.
        """#,
      timestamp: (4 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The demo’s code begins with its domain. This consists of 3 parts:
        """#,
      timestamp: (4 * 60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        First the state that drives the UI, which consists of a simple struct holding the current count, a boolean indicating whether or not the fact request is in flight, which is used for showing the progress view, as well as an optional string for the current fact being shown in the UI:
        """#,
      timestamp: (4 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct EffectsBasicsState: Equatable {
          var count = 0
          var isNumberFactRequestInFlight = false
          var numberFact: String?
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Second there are the actions that can occur in the UI, such as tapping on the increment, decrement or fact buttons:
        """#,
      timestamp: (4 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum EffectsBasicsAction: Equatable {
          case decrementButtonTapped
          case numberFactButtonTapped
          case incrementButtonTapped
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        But there’s also an action that occurs as the result of some work being down in the outside world, which is that network request made to fetch a number fact. That is another action that the system must account for:
        """#,
      timestamp: (5 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case numberFactResponse(Result<String, FactClient.Failure>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then third, there’s the environment of dependencies that the feature needs to do its job. These are the things that talk to the outside world, such as the number fact service:
        """#,
      timestamp: (5 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct EffectsBasicsEnvironment {
          var fact: FactClient
          var mainQueue: AnySchedulerOf<DispatchQueue>
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `FactClient` is a simple little struct that gives us an interface for fetching a fact for a number:
        """#,
      timestamp: (5 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct FactClient {
          var fetch: (Int) -> Effect<String, Failure>

          struct Failure: Error, Equatable {}
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `Effect` type ships with our library, and as we mentioned before is a Combine publisher whose emissions are automatically fed back into the system as actions.
        """#,
      timestamp: (5 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Down below we have two implementations of this interface. One is a “live” implementation that actually makes a real network request to an external server for fetching the fact:
        """#,
      timestamp: (5 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension FactClient {
          static let live = Self(
            fetch: { number in
              Effect.task {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                let (data, _) = try await URLSession.shared
                  .data(from: URL(string: "http://numbersapi.com/\(number)/trivia")!)
                return String(decoding: data, as: UTF8.self)
              }
              .mapError { _ in Failure() }
              .eraseToEffect()
            }
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And the other is an “unimplemented” version of the dependency, which will actually fail the test suite if its endpoints are ever used:
        """#,
      timestamp: (6 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension FactClient {
          static let unimplemented = Self(
            fetch: { _ in .unimplemented("\(Self.self).fact is unimplemented.") }
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We will get into more of why we would want this soon.
        """#,
      timestamp: (6 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Back in the `EffectBasicsEnvironment`  we have one more dependency: the `mainQueue`. This may seem a little strange. How is that a dependency on the outside world?
        """#,
      timestamp: (6 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Well, anytime that we need to schedule work to be done on a specific queue or thread, which is common in SwiftUI since state must be mutated on the main thread, we are implicitly depending on a scheduling system that we do not control. If we carelessly use the real life, main dispatch queue in our code, then we will complicate our tests because we will need to use expectations to wait for small amounts of time so that tiny thread hops can happen, and just hope we waited enough time.
        """#,
      timestamp: (6 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        By making the main queue an explicit dependency as a type erased Combine scheduler, we can use a live dispatch queue when running our app on the simulator or device, and use an immediate or test scheduler in tests so that we control the flow of time. This allows you to write nuanced tests that prove what happens as time flows through your feature in a 100% deterministic manner. Our open source [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) library gives you all the tools to accomplish this, and we will be getting more into this more soon.
        """#,
      timestamp: (7 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we have the reducer, which is the thing that glues all the domain together to implement the feature’s logic. At its core it is a function that takes the current state of the feature, an action that came into the system, such as a button being tapped, and the environment of dependencies:
        """#,
      timestamp: (7 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let effectsBasicsReducer = Reducer<
          EffectsBasicsState,
          EffectsBasicsAction,
          EffectsBasicsEnvironment
        > { state, action, environment in
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Its job is to mutate the `inout` state to the next state given an action and return any effects that should be executed by the runtime so that their outputs can be fed back into the system.
        """#,
      timestamp: (7 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This means most reducers start with a `switch` at the very top in order to decide what logic to execute for each kind of action:
        """#,
      timestamp: (8 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        switch action {
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The logic for some of these actions is quite straightforward. For example, when the increment or decrement buttons are tapped we just need to update the `count` state and don’t need to perform any effects:
        """#,
      timestamp: (8 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .decrementButtonTapped:
          state.count -= 1
          state.numberFact = nil
          return .none

        case .incrementButtonTapped:
          state.count += 1
          state.numberFact = nil
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We are also preemptively clearing out the `numberFact` string state because the fact is no longer representative of the current count on the screen.
        """#,
      timestamp: (8 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        When the number fact button is tapped we want to first update some state to track that the request is inflight and clear any existing fact:
        """#,
      timestamp: (8 * 60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .numberFactButtonTapped:
          state.isNumberFactRequestInFlight = true
          state.numberFact = nil
          …
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then we want to return an effect that fetches a fact for the current count, which can be done by invoking the `fetch` endpoint on the fact client in the environment, then forcing its output onto the main queue, and finally using the `catchToEffect` operator to bundle the output or failure of the request into an action that can be sent back into the system:
        """#,
      timestamp: (8 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return environment.fact.fetch(state.count)
          .receive(on: environment.mainQueue)
          .catchToEffect(EffectsBasicsAction.numberFactResponse)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Recall that this `EffectsBasicsAction.numberFactResponse` action is precisely what we specified in our action enum above:
        """#,
      timestamp: (9 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum EffectsBasicsAction: Equatable {
          …
          case numberFactResponse(Result<String, FactClient.Failure>)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And finally we can react to receiving a success or failure from the network request by destructuring those actions and implementing their logic:
        """#,
      timestamp: (9 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .numberFactResponse(.success(response)):
          state.isNumberFactRequestInFlight = false
          state.numberFact = response
          return .none

        case .numberFactResponse(.failure):
          // NB: This is where we could handle the error is some way, such as showing an alert.
          state.isNumberFactRequestInFlight = false
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next, we have the view. It holds onto an object called a `Store` that is generic over the type of state that we want to read from in order to populate the UI, and the type of actions we want to send when the user does something:
        """#,
      timestamp: (9 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct EffectsBasicsView: View {
          let store: Store<EffectsBasicsState, EffectsBasicsAction>

          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Note that we do not hold onto the store as an `@ObservedObject`. There is a separate type in the Composable Architecture for observing state changes, and we do this because very often we do not want to observe all of the state in our domain. Many times there is additional state in the domain that is for internal logic only, and changes to it should not trigger view updates. This is especially common when decomposing an application into many features in which we would not want every little change in a child feature to cause the parent feature to update its view.
        """#,
      timestamp: (10 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The way to observe state is with something called a `ViewStore`, which you can construct directly and add to your view as an `@ObservedObject`, but our SwiftUI integration tools come with a more ergonomic tool called `WithViewStore`:
        """#,
      timestamp: (10 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var body: some View {
          WithViewStore(self.store) { viewStore in
            …
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This sets up observation of the state in the store, hands you a view store, and takes care of refreshing the view when any state changes.
        """#,
      timestamp: (11 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Currently we are observing all of the state in the store, but in the future if the feature becomes more complex and we do not need to observe everything, we can whittle away at the state to its bare essentials using the `scope` operator to transform the state into something smaller:
        """#,
      timestamp: (11 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        WithViewStore(self.store.scope(state: <#(State) -> LocalState>)) { viewStore in
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        But we don’t need this power right now, so we won’t use it.
        """#,
      timestamp: (11 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Inside the `WithViewStore` scope everything looks mostly like vanilla SwiftUI. We construct views just as we would normally, and we can access any piece of state on the view store by using regular dot syntax:
        """#,
      timestamp: (11 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Text("\(viewStore.count)")
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        In any action closure, such as a button’s action, we can send an action to the view store by using the `send` method:
        """#,
      timestamp: (11 * 60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Button("−") { viewStore.send(.decrementButtonTapped) }
        …
        Button("+") { viewStore.send(.incrementButtonTapped) }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Finally, we have a preview down at the bottom of the file which shows off how to create a view by supplying a `Store`:
        """#,
      timestamp: (12 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct EffectsBasicsView_Previews: PreviewProvider {
          static var previews: some View {
            NavigationView {
              EffectsBasicsView(
                store: Store(
                  initialState: EffectsBasicsState(),
                  reducer: effectsBasicsReducer,
                  environment: EffectsBasicsEnvironment(
                    fact: .live,
                    mainQueue: .main
                  )
                )
              )
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To build a `Store` you must supply the initial state of your feature, the reducer that runs the logic of your feature, and the environment of dependencies that your feature we will use.
        """#,
      timestamp: (12 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This gives us an opportunity to supply custom state to preview how it renders in the view:
        """#,
      timestamp: (12 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        EffectsBasicsState(
          count: 1_000_000,
          numberFact: "1,000,000 is a big number"
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We are currently using the real, live dependencies for the preview, which means we are actually making network requests to fetch the fact. If we wanted to work in a more controlled environment, one that did not make any network requests, we could simply provide a new fetch client that returns its data synchronously and immediately:
        """#,
      timestamp: (12 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment: EffectsBasicsEnvironment(
          fact: FactClient(fetch: { n in Effect(value: "\(n) is a good number!") }),
          mainQueue: .main
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now the preview runs in a more controlled environment, but it is still fully functional.
        """#,
      timestamp: (13 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Testing effects"#,
      timestamp: (14 * 60 + 0),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        And that’s all it takes to build a simple feature in the Composable Architecture.
        """#,
      timestamp: (14 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We want to reiterate that such a simple feature may not really even need the full power of our library. The main reason you would want to use the Composable Architecture is if this logic starts to get a lot more complicated, or if we wanted to add additional separate features that need to be integrated in complex ways, or if you want to write some tests.
        """#,
      timestamp: (14 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We will actually be adding some more features to this demo a bit later to show off some of those powers, but right now let’s look at tests. Every single case study and demo application in the library comes with an extensive test suite. The logic in this feature may be simple, but we are still doing some state management around setting and unsetting a boolean for the loading status, so it would be nice to get some test coverage on that.
        """#,
      timestamp: (14 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s hop over to the tests file and run the test suite just to make sure everything is passing.
        """#,
      timestamp: (14 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And it is.
        """#,
      timestamp: (14 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The first test we have just exercises the most basic functionality, which is what happens when you send an increment action the count goes up by one, and when you send a decrement action the count goes down by one:
        """#,
      timestamp: (14 * 60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        func testCountUpAndDown() {
          let store = TestStore(
            initialState: EffectsBasicsState(),
            reducer: effectsBasicsReducer,
            environment: .unimplemented
          )

          store.send(.incrementButtonTapped) {
            $0.count = 1
          }
          store.send(.decrementButtonTapped) {
            $0.count = 0
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, even in this simple test there is already quite a few powerful things happening.
        """#,
      timestamp: (15 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        First, the way in which you test Composable Architecture features is by constructing a `TestStore` rather than a `Store`. This is an object that under the hood makes use of a `Store`, but it monitors everything that is happening in the system so that it can force you to exhaustively prove that you know how the system evolves over time.
        """#,
      timestamp: (15 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        You construct a `TestStore` in the same way as a `Store`, by supplying the initial state, a reducer whose logic you want to test, as well as an environment of dependencies. However, since we are in a test, we do not want to use live dependencies. We don’t want to be making network requests, which would leave us to the whims of the outside world, and we don’t want to use a live dispatch queue, which would require us to wait little bits of time for thread hops to happen.
        """#,
      timestamp: (15 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Typically we provide better controlled dependencies, such as a fact client that immediately returns some mock data, or an immediate scheduler or test scheduler that controls the flow of time.
        """#,
      timestamp: (15 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But things are even simpler in this test. We don’t actually expect these dependencies to be used at all. The act of tapping the increment or decrement buttons doesn’t actually execute any effects, and so we don’t expect the fact client or main queue to be used.
        """#,
      timestamp: (16 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This gives us an opportunity to greatly strengthen our tests. We can supply “unimplemented” versions of our dependencies, which are implementations of the dependency interface that simply perform an `XCTFail` if you access any of its endpoints:
        """#,
      timestamp: (16 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension EffectBasicsEnvironment {
          static let unimplemented = Self(
            fact: .unimplemented,
            mainQueue: .unimplemented
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So the fact that this test passes proves that our feature does not even touch these dependencies. This greatly increases the strength of this test, and if in the future we add more features to this demo that do start using dependencies, we will get a failure in this test letting us know that there is new logic that must be covered in the test.
        """#,
      timestamp: (16 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The other powerful feature of this test is in the following lines:
        """#,
      timestamp: (16 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.send(.incrementButtonTapped) {
          $0.count = 1
        }
        store.send(.decrementButtonTapped) {
          $0.count = 0
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `send` method on test stores acts a little different from `send` on regular stores. You specify what action to send, but immediately after you provide a trailing closure to describe what state changes you expect to happen when the action is sent.
        """#,
      timestamp: (16 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If for whatever reason we decide that the increment button should actually increment by 2 over in our feature reducer:
        """#,
      timestamp: (17 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .incrementButtonTapped:
          state.count += 2
          …
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then when we run tests we immediately get two failures with nice error messages:

        > ❌ testCountUpAndDown(): A state change does not match expectation: …
        >
        >       EffectsBasicsState(
        >     −   count: 1,
        >     +   count: 2,
        >         isNumberFactRequestInFlight: false,
        >         numberFact: nil
        >       )
        >
        > (Expected: −, Actual: +)
        >
        > ❌ testCountUpAndDown(): A state change does not match expectation: …
        >
        >       EffectsBasicsState(
        >     −   count: 0,
        >     +   count: 1,
        >         isNumberFactRequestInFlight: false,
        >         numberFact: nil
        >       )
        >
        > (Expected: −, Actual: +)
        """#,
      timestamp: (17 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This let’s us know that the way we mutated the state in the test does not match what the reducer did, and it helpfully prints a diff representation of exactly what is different between the two states.
        """#,
      timestamp: (17 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s revert that change to the reducer so that we can get passing tests again.
        """#,
      timestamp: (17 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The next test exercises more interesting logic in our feature. It tests the happy path of trying to fetch a fact about a number and getting a successful response.
        """#,
      timestamp: (17 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        It starts by constructing a test store, again with a fully unimplemented environment:
        """#,
      timestamp: (18 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        func testNumberFact_HappyPath() {
          let store = TestStore(
            initialState: EffectsBasicsState(),
            reducer: effectsBasicsReducer,
            environment: .unimplemented
          )

          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This time, however, we do actually need implementations of these dependencies. By fetching the fact we will be using the `fetch` endpoint of the fact client, and we will use the main queue to dispatch back to the main thread. So, what we do is reach into the test store to update its environment to implement only the bare essentials of the dependencies we expect to use:
        """#,
      timestamp: (18 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.environment.fact.fetch = { Effect(value: "\($0) is a good number Brent") }
        store.environment.mainQueue = .immediate
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can reach all the way into the fact client’s `fetch` endpoint to replace it with a closure that immediately and synchronous returns a response when asking for a fact. If there were other endpoints on the fact client then we would be leaving them as unimplemented. We also provide a main queue by using an immediate scheduler, which is a scheduler that simply invokes any work item enqueued on it immediately. It just ignores any arguments for delaying work.
        """#,
      timestamp: (18 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        With our dependencies set up we can play a script of what the user does in the UI, such as incrementing the count by one, and then tapping the fact button:
        """#,
      timestamp: (19 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.send(.incrementButtonTapped) {
          $0.count = 1
        }
        store.send(.numberFactButtonTapped) {
          $0.isNumberFactRequestInFlight = true
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This looks similar to what we did before, but then we have this additional assertion after sending the actions:
        """#,
      timestamp: (19 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.numberFactResponse(.success("1 is a good number Brent"))) {
          $0.isNumberFactRequestInFlight = false
          $0.numberFact = "1 is a good number Brent"
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `receive` method on test store is how we assert on what actions are fed back into the store from effects, and how state changes when those actions are sent. If we comment out these `receive` lines we will get a test failure:

        > ❌ testNumberFact_HappyPath(): The store received 1 unexpected action after this one: …
        >
        > Unhandled actions: [
        >   [0]: EffectsBasicsAction.numberFactResponse(
        >     Result.success("1 is a good number Brent")
        >   )
        > ]
        """#,
      timestamp: (19 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This happens because we haven’t exhaustively proven how the state evolves. If this didn’t fail then there would be later state changes to the feature that we are not asserting on, and there could be bugs in the logic that makes those changes. We definitely want to get test coverage on that logic.
        """#,
      timestamp: (19 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, to write this assertion we use `store.receive` to explicitly say exactly what action we expect to receive from the effect, and further how state changes after receiving that action.
        """#,
      timestamp: (19 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, if we didn’t fully express all changes to state in the trailing closure, perhaps we forgot to flip the boolean back to false, we get a failure:
        """#,
      timestamp: (20 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.numberFactResponse(.success("1 is a good number Brent"))) {
          // $0.isNumberFactRequestInFlight = false
          $0.numberFact = "1 is a good number Brent"
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ testNumberFact_HappyPath(): A state change does not match expectation: …
        >
        >       EffectsBasicsState(
        >         count: 1,
        >     −   isNumberFactRequestInFlight: true,
        >     +   isNumberFactRequestInFlight: false,
        >         numberFact: "1 is a good number Brent"
        >       )
        >
        > (Expected: −, Actual: +)
        """#,
      timestamp: (20 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And finally we have a test for the “unhappy” path, that is when the fact request fails. It looks quite similar to the happy path, except we substitute in a `fetch` endpoint that returns an error:
        """#,
      timestamp: (20 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        func testNumberFact_UnhappyPath() {
          let store = TestStore(
            initialState: EffectsBasicsState(),
            reducer: effectsBasicsReducer,
            environment: .unimplemented
          )

          store.environment.fact.fetch = { _ in Effect(error: FactClient.Failure()) }
          store.environment.mainQueue = .immediate

          store.send(.incrementButtonTapped) {
            $0.count = 1
          }
          store.send(.numberFactButtonTapped) {
            $0.isNumberFactRequestInFlight = true
          }
          store.receive(.numberFactResponse(.failure(FactClient.Failure()))) {
            $0.isNumberFactRequestInFlight = false
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        If later we implement error handling logic, such as showing an alert or something, we would do more work in this `receive` closure to capture that.
        """#,
      timestamp: (20 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"The problem with Effect.task"#,
      timestamp: (20 * 60 + 50),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, that’s a quick tour of a simple feature built with the Composable Architecture as well as what it takes to test the feature. But there are a few rough edges that would be nice to smooth over, and it all has to do with using Combine for effects.
        """#,
      timestamp: (20 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Using Combine is really convenient because it’s a first class library provided by Apple that expresses the emission of values over time, and that’s exactly what we need to model side effects that can talk with the outside world and send us back information.
        """#,
      timestamp: (21 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, as we saw in our previous [episodes on Swift’s new concurrency tools](TODO), Combine can be a lot clunkier than the equivalent code using async/await. Let’s see why that is, and see how we can use async/await in our effects.
        """#,
      timestamp: (21 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Suppose we wanted to do something silly like add exclamation to the end of the fact fetched from the fact service to really give it some pop. If we wanted to do this in the effect we would need to `map` on the publisher so that we could transform the string before sending it on its way:
        """#,
      timestamp: (21 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return environment.fact.fetch(state.count)
          .map { fact in fact + "!!!" }
          .receive(on: environment.mainQueue)
          .catchToEffect(EffectsBasicsAction.numberFactResponse)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        That’s really verbose and cryptic for something so simple. With async/await we would have just be able to concat an exclamation point to the end of the string returned from the `fetch` endpoint.
        """#,
      timestamp: (22 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s see what it takes to use async/await for this effect. To begin with, let’s update our `FactClient` to have a version of the fetch endpoint that is async/await friendly:
        """#,
      timestamp: (22 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct FactClient {
          var fetch: (Int) -> Effect<String, Failure>
          var fetchAsync: @Sendable (Int) async throws -> String

          struct Failure: Error, Equatable {}
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Note that we are leaving the Combine-based `fetch` endpoint to keep everything backwards compatible so that we don’t have to update a bunch of code throughout the case studies app. Ultimately we will be able to get rid of the Combine-based endpoint entirely, and we will rename `fetchAsync` to just `fetch`.
        """#,
      timestamp: (22 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We also made the `fetchAsync` endpoint `@Sendable` because we know it is going to be used from asynchronous contexts, such as in a task. Because of this we want to restrict the types of closures that can be used to construct a `FactClient`. In particular, they can’t capture non-isolated, mutable data. Technically it isn’t necessary to do this right now because Swift won’t complain if we use this closure incorrectly, but seen there will be more visible warnings for these kinds of things, and in Swift 6 it will even be a compiler error.
        """#,
      timestamp: (23 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We went [really deep](https://www.pointfree.co/collections/concurrency/concurrency/ep193-concurrency-s-future-sendable-and-actors) into the concepts of “sendable” in our [previous series of episodes](https://www.pointfree.co/collections/concurrency) discussing concurrency, so we highly recommend you watch those episodes if you are unfamiliar with these terms.
        """#,
      timestamp: (23 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Also note that we are using `throws`, which can only use untyped errors, whereas previously we used a separate type for the error, though it didn’t actually hold any useful information. We will soon see that using untyped errors brings up some new complications, but it’s actually not all bad, and in fact may even be a little better.
        """#,
      timestamp: (23 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now that we have added a new endpoint to our dependency we have a some errors because there are a few spots we are explicitly constructing instances of the client. For example, in the live implementation of the client we can now implement the fetch endpoint much more simply because we immediately have access to an asynchronous context:
        """#,
      timestamp: (24 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        static let live = Self(
          fetch: { number in
            …
          },
          fetchAsync: { number in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            let (data, _) = try await URLSession.shared
              .data(from: URL(string: "http://numbersapi.com/\(number)/trivia")!)
            return String(decoding: data, as: UTF8.self)
          }
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is much simpler than what we had to do with the Combine-style endpoint.
        """#,
      timestamp: (24 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s also the `unimplemented` fact client, which makes use of `Effect.unimplemented` to construct an effect that immediately causes a test failure if anyone subscribes to it. We can use a helper the library ships with to instantly stub in a closure that will trigger a test failure if it is ever invoked:
        """#,
      timestamp: (25 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension FactClient {
          static let unimplemented = Self(
            fetch: { _ in … },
            fetchAsync: XCTUnimplemented("\(Self.self).fetchAsync")
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Here we are using the [`XCTUnimplemented`](https://www.pointfree.co/blog/posts/77-introducing-xctunimplemented) function that comes with our [XCTest Dynamic Overlay](https://github.com/pointfreeco/xctest-dynamic-overlay) library. The library ships a version of `XCTFail` that doesn’t require being able to import `XCTest`, which means you can put test helpers right alongside application code. This `XCTUnimplemented` function can be used to satisfy any function endpoint with a stub of a function that simply immediately fails if it is invoked.
        """#,
      timestamp: (26 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And with those changes things are building again, but of course we aren’t actually using the new `asyncFetch` method, so let’s do that.
        """#,
      timestamp: (27 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Over in our reducer we can comment out the code that constructs the effect via Combine operators.
        """#,
      timestamp: (27 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And instead we can return an effect that is represented by a single asynchronous closure using the `Effect.task` helper:
        """#,
      timestamp: (27 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return Effect.task {
          // Do async work
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can do any asynchronous work in here we want, but ultimately we need to return an action so that it can be fed back into the system:
        """#,
      timestamp: (27 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .task {
          .numberFactResponse(<#Result<String, FactClient.Failure>#>)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And to do that we need to construct a result of a string. The `fetchAsync` endpoint can fetch a string, and it does it’s work async which is fine since we have an async context:
        """#,
      timestamp: (27 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .task {
          .numberFactResponse(
            .success(try await environment.fact.fetchAsync(state.count))
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Oh, and I guess if we want to recapture that behavior of exclaiming the fact then we should also concatenate an exclamation mark:
        """#,
      timestamp: (28 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .task {
          .numberFactResponse(
            .success(try await environment.fact.fetchAsync(state.count) + "!!!")
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However we still have a problem because we are performing throwing work in `.task { }` and that’s not allowed:

        > 🛑 Invalid conversion from throwing function of type '@Sendable () async throws -> EffectsBasicsAction' to non-throwing function type '@Sendable () async -> EffectsBasicsAction'
        """#,
      timestamp: (28 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We don’t allow errors to be thrown in `Effect.task` because who would handle them? Ultimately your reducer is the only place that performs application logic, and the only way to invoke the reducer is by sending an action into the system.
        """#,
      timestamp: (28 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, we require you to massage your effect errors into an action so that it can be fed back into the system, and then you can implement your logic there for handling the error, such as showing an alert or anything else.
        """#,
      timestamp: (28 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s open up a do/catch block so that we can catch any error thrown by the `fetchAsync` endpoint:
        """#,
      timestamp: (29 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .task {
          do {
            return .numberFactResponse(
              .success(try await environment.fact.fetchAsync(state.count) + "!!!")
            )
          } catch {
            // ???
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Although this still does not compile:

        > 🛑 Mutable capture of 'inout' parameter 'state' is not allowed in concurrently-executing code
        """#,
      timestamp: (29 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is because we are accessing `state` inside a `@Sendable` closure, which as we saw from our episodes on concurrency is a big no-no. We just need to capture the data we care about as an immutable value:
        """#,
      timestamp: (29 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .task { [count = state.count] in
          do {
            return .numberFactResponse(.success(try await environment.fact.fetchAsync(count)))
          } catch {
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we are finally down to the last error:

        > 🛑 Missing return in closure expected to return 'EffectsBasicsAction’
        """#,
      timestamp: (29 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s really only one reasonable thing we can return here, and that is a `numberFactResponse` with an failure that holds the fact client’s error:
        """#,
      timestamp: (30 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .numberFactResponse(.failure(FactClient.Failure()))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Things are now compiling, and the preview is working exactly as it did before, but we now have some async/await code directly in our reducer!
        """#,
      timestamp: (30 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now technically this code is a little bit longer than the Combine-based version. In fact, it’s 11 lines compared to 4 lines for the Combine code.
        """#,
      timestamp: (30 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But, at the same time, it also has fewer parts to understand. We didn’t need the `map` operator just to exclaim the fact, we don’t need `catchToEffect` to further massage the output and failure into an action, and we’re not even using a scheduler anymore. `Effect.task` automatically delivers its output on the main thread via the main actor, and so there is no extra work we have to do there. This means we could even remove the `mainQueue` dependency from our environment. We won’t do that now because we’ll need it later for some later explorations, but suffice it to say that you will no longer need to put schedulers in your environment unless you you are doing time-based operations.
        """#,
      timestamp: (30 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Further, we will soon see that we can get rid of the weird empty `FactClient.Failure` type and even squash the 11 lines to construct the effect into just 3, so it will be even shorter than the Combine code.
        """#,
      timestamp: (31 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And this style of effect will really start to shine as the effect gets more and more complicated. For example, what if we didn’t want to fetch a fact from the current count, but instead we used another asynchronous dependency to procure a random number and then used that number to fetch the fact. In the Combine operator we would have to use `flatMap` in order to sequence these two effects together, but in async/await we get to just run them together on one line:
        """#,
      timestamp: (31 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .task { [count = state.count] in
          do {
            return .numberFactResponse(
              .success(try await environment.fact.fetchAsync(environment.random(0...count)))
            )
          } catch {
            return .numberFactResponse(.failure(FactClient.Failure()))
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Or, what if after procuring that random number we wanted to fetch two facts and join them with a newline:
        """#,
      timestamp: (33 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .task { [count = state.count] in
          do {
            async let fact1 = environment.fact.fetchAsync(count)
            async let fact2 = environment.fact.fetchAsync(count)
            return try await .numberFactResponse(
              .success(fact1 + "\n" + fact2 + "!!!")
            )
          } catch {
            return .numberFactResponse(.failure(FactClient.Failure()))
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Or, what if we wanted to dynamically fetch the a number of facts using the current count, and then join them with newlines using a task group:
        """#,
      timestamp: (33 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return Effect.task { [count = state.count] in
          do {
            let facts = try await withThrowingTaskGroup(of: String.self, returning: String.self) { group in
              for _ in 1...count {
                group.addTask {
                  try await environment.fact.fetchAsync(count)
                }
              }
              return try await group
                .reduce(into: []) { $0.append("• " + $1) }
                .joined(separator: "\n")
            }
            return .numberFactResponse(.success(facts))
          } catch {
            return .numberFactResponse(.failure(FactClient.Failure()))
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Writing these kinds of effects using Combine is really annoying, requiring expert knowledge of the `map`, `zip` and `flatMap` operators and how to use them in unison. But here, we get just use `await` or `async let` or task groups, and it reads linearly from top-to-bottom, almost exactly like regular, synchronous code.
        """#,
      timestamp: (34 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s quickly back out of these experimental explorations.
        """#,
      timestamp: (34 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This all seeming pretty great, and so you may be surprised to learn that we actually recommend people to not use `Effect.task` in their reducers. We even have this in the documentation:

        > Note that due to the lack of tools to control the execution of asynchronous work in Swift,
        > it is not recommended to use this function in reducers directly. Doing so will introduce
        > thread hops into your effects that will make testing difficult. You will be responsible
        > for adding explicit expectations to wait for small amounts of time so that effects can
        > deliver their output.
        >
        > Instead, this function is most helpful for calling `async`/`await` functions from the live
        > implementation of dependencies, such as `URLSession.data`, `MKLocalSearch.start` and more.
        """#,
      timestamp: (35 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is why the fact client interface still uses the `Effect` publisher, and the only time we use async/await is in the live implementation.
        """#,
      timestamp: (35 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To see the problems we are warning about in this documentation concretely, let’s run our tests. Before we do that let’s remove the exclamation mark from our reducer since our tests were not written for that behavior.
        """#,
      timestamp: (35 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we run tests we get a failure.
        """#,
      timestamp: (36 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is because our reducer is using `fetchAsync` but our tests have only mocked out the `fetch` endpoint.
        """#,
      timestamp: (36 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s switch our test to use `fetchAsync` instead of `fetch`.
        """#,
      timestamp: (36 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // store.environment.fact.fetch = { Effect(value: "\($0) is a good number Brent") }
        store.environment.fact.fetchAsync = { "\($0) is a good number Brent" }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Also notice how much simpler it is to mock an async endpoint rather than an `Effect`-based endpoint. We can just return the data immediately, no need to package it up in an effect.
        """#,
      timestamp: (36 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We also need to do the same for the test for the unhappy path, where we can also simplify by throwing an error directly:
        """#,
      timestamp: (36 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // store.environment.fact.fetch = { _ in Effect(error: FactClient.Failure()) }
        store.environment.fact.fetchAsync = { _ in throw FactClient.Failure() }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we run tests now, both of the ones that exercise the effects of the feature fail:

        > ❌ testNumberFact_HappyPath(): An effect returned for this action is still running. It must complete before the end of the test. …
        >
        > ❌ testNumberFact_HappyPath(): Expected to receive an action, but received none.
        """#,
      timestamp: (37 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is happening because the effect is performing asynchronous work, which means it takes a little bit of time for it to execute and send its data back to the main thread. While that work is executing on some non-main thread, our main thread breezes right past and the test ends without the effect having ever finished.
        """#,
      timestamp: (37 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To fix this we need to wait a minuscule amount of time to give the effect enough time to execute its work:
        """#,
      timestamp: (37 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        store.receive(.numberFactResponse(.success("1 is a good number Brent"))) {
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And this now passes, but also our choice of 0.1 seconds was arbitrary. Could we get away with 0.01 seconds?
        """#,
      timestamp: (38 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.01)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        But now this fails. Looks like 0.01 seconds is too little time. Can we do 0.02?
        """#,
      timestamp: (38 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.02)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This works for us, but who knows how reliable it is on slower machines or CI, which means we have a very fragile test in front of us.
        """#,
      timestamp: (38 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Next time: the solution"#,
      timestamp: (39 * 60 + 0),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So we are seeing this is really precarious, and we are just needlessly slowing down our test suite to wait for these little thread hops.
        """#,
      timestamp: (39 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, this is a pretty big missing part of the ergonomics story for the Composable Architecture. We need to figure out a way to use `Effect.task` in our reducers because there are a ton of benefits:
        """#,
      timestamp: (39 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - It makes for simpler dependency clients that can just use `async` instead of returning `Effect` values, which means that our dependencies don’t even need to depend on the Composable Architecture.
        """#,
      timestamp: (39 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - It makes for simpler live and mock instances of dependencies
        """#,
      timestamp: (39 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - It makes for simpler construction of effects in reducers, and we can chain multiple asynchronous tasks together by just awaiting one after another.
        """#,
      timestamp: (39 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And finally it means we can even sometimes remove schedulers from our environment, especially if we don’t need to schedule time-based work.
        """#,
      timestamp: (39 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But most importantly, we want to allow usage of `Effect.task` in our reducers in a way that does not affect tests. Testing is by far the most important feature of the Composable Architecture, and we try our hardest to never add a feature to the library that hurts testability. We should strive to be able to write fully deterministic tests that run immediately.
        """#,
      timestamp: (39 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And `Effect.task` is really just the tip of the iceberg. There are a lot more ways we’d like to more deeply integrate the library with Swift’s concurrency tools, but let’s start with the problem of `Effect.task` not being usable in reducers.
        """#,
      timestamp: (40 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The main problem with using async/await directly in the reducer is that all new asynchronous contexts are spun up when effects execute in tests, and we are forced to wait for small amounts of times for those tasks to finish and feed their data back into the system.
        """#,
      timestamp: (40 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let's see how we can fix this...next time!
        """#,
      timestamp: (40 * 60 + 35),
      type: .paragraph
    ),
  ]
}
