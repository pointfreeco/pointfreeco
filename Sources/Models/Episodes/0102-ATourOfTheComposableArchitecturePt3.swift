import Foundation

extension Episode {
  public static let ep102_ATourOfTheComposableArchitecture_pt3 = Episode(
    blurb: """
It's time to start proving that our business logic works the way we expect. We are going to show how easy it is to write tests with the Composable Architecture, which will give us the confidence to add more functionality and explore some advanced effect capabilities of the library.
""",
    codeSampleDirectory: "0102-swift-composable-architecture-tour-pt3",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 372_928_086,
      vimeoId: 416344329,
      vimeoSecret: "41600b1214a102b688fc46c171b71787c2ef667c"

    ),
    id: 102,
    image: "https://i.vimeocdn.com/video/890437028-06963dc647493b70d085d81934329065a3397f0a895c7ee276df8bab996a279e-d",
    length: 32*60 + 28,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1589778001),
    references: [
      .theComposableArchitecture,
      .elmHomepage,
      .reduxHomepage,
    ],
    sequence: 102,
    subtitle: "Part 3",
    title: "A Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 61_680_473,
      vimeoId: 416533116,
      vimeoSecret: "581cf5a583c942899aaf1aa06d143ecdc7e012c3"
    ),
    transcriptBlocks: _transcriptBlocks
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

private let _transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: #"Introduction"#,
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
Alright, we've added a new feature, but something isn’t quite right with our reducer. We are currently plucking a random `UUID` out of thin air by calling its initializer.  To see why this is problematic, let’s try writing some tests.
"""#,
    timestamp: 5,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We first discussed testing the Composable Architecture many months ago, and we discussed a few different facets. [First](/episodes/ep82-testable-state-management-reducers), we discussed how to test the reducers in isolation. This is a natural place to start because one of the primary responsibilities of the reducer is to mutate the state when an action comes in. So to test that functionality we just need to construct a piece of state to start with, and feed that state and an action into the reducer, and then assert on the changes made to the state. And although our reducers are quite simple right now, in practice they can get quite complicated and have quite a bit of logic in them. So this kind of testing can be super powerful because it is so lightweight and allows you to easily probe all of the strange edge cases of your code.
"""#,
    timestamp: (0*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But [then we kicked things up a notch](/episodes/ep83-testable-state-management-effects) and showed how to test the second responsibility of the reducers: the side effects. We showed that after running the reducer, which returned a side effect publisher, we could then actually run the effect and capture the data it produced and then make an assertion that it produced the data we expected. This was incredibly powerful because we started getting test coverage on effects, which is typically off limits, and we could even get stronger guarantees about our business logic.
"""#,
    timestamp: (0*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But [then we took things even further](/episodes/ep84-testable-state-management-ergonomics). We showed how to marry the reducer testing and the effect testing into one cohesive, ergonomic package. We built an assertion helper that allowed us to describe a series of steps that the user takes in the application, and each step of the way had to describe exactly how the state was mutated and describe what events were fed back into the system from effects. We could even make exhaustive assertions about effects, such as they must all complete by the end of the assertion so that we know definitively that no other data was fed into the application that we might be missing.
"""#,
    timestamp: (1*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
And so we are now going to use that to write some really nice tests for our application. We have refined the API for the assertion helper a bit for the library, but it’s still quite similar to what we covered in episodes.
"""#,
    timestamp: (2*60 + 1),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Writing our first test"#,
    timestamp: (2*60 + 18),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
Let’s get our feet wet by first writing a test for the functionality of marking a todo as completed. You start by creating a test store that holds onto the domain that you want to test, which looks almost identical to how you create a normal store:
"""#,
    timestamp: (2*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
import ComposableArchitectureTestSupport
import XCTest
@testable import Todos

class TodosTests: XCTestCase {
  func testCompletingTodo() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment()
    )
  }
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Since this episode was recorded, the `ComposableArchitectureTestSupport` module has merged into `ComposableArchitecture`. You can now import `ComposableArchitecture` in your test targets to access the test store.
"""#,
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: #"""
However, the `TestStore` requires both the state and the actions of our domain to be equatable so that we can properly assert on how the system evolves. `AppState`  is already equatable, so we just need to make `AppAction` equatable:
"""#,
    timestamp: (3*60 + 5),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
enum TodoAction: Equatable {
  ...
}

struct AppState: Equatable {
  ...
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Now tests are building, but in order to test completing a todo, we should have one defined in state:
"""#,
    timestamp: (3*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
func testCompletingTodo() {
  let store = TestStore(
    initialState: AppState(
      todos: [
        Todo(
          description: "Milk",
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          isComplete: false
        )
      ]
    ),
    reducer: appReducer,
    environment: AppEnvironment()
  )
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Now we’re ready to write our assertion. We do this by calling the `assert` method on the store, which allows us to feed a series of user actions in so that we can then assert on how the system evolved:
"""#,
    timestamp: (3*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Technically this test is passing because we haven’t sent any actions and therefore the system hasn’t changed at all!
"""#,
    timestamp: (3*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
So, let’s send an action to simulate the idea of the user tapping on the checkbox on the first todo item:
"""#,
    timestamp: (4*60 + 9),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped))
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Sending the action is only half the story for making this assertion. We also need to describe how the state changed after this action was sent to the store. The way we do that is open up a trailing closure on this `.send` command, and make the mutations we expect to happen to the value passed to the closure.
"""#,
    timestamp: (4*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
In particular, we expect the first todo’s `isComplete` field to switch to `true`:
"""#,
    timestamp: (4*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And if we run the tests they pass.
"""#,
    timestamp: (4*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Before moving on, let’s show off a wonderful bit of testing ergonomics that we added to the library that wasn’t covered in the episodes. When a test fails we print a nice message showing exactly what piece of state does not match. So let’s purposely change this test to fail:
"""#,
    timestamp: (4*60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = false
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And if we run this test we will get a failure, and the failure message will show us exactly what went wrong:
"""#,
    timestamp: (5*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
🛑 failed - Unexpected state mutation: …

      AppState(
        todos: [
          Todo(
    −       isComplete: false,
    +       isComplete: true,
            description: "Milk",
            id: 00000000-0000-0000-0000-000000000000
          ),
        ]
      )

(Expected: −, Actual: +)
"""#,
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: #"""
This is specifically showing that I expected `isComplete` to be `false` but it was actually `true`. This makes it so easy to focus in on exactly what failed and is a huge boon to productivity, and it’s quite similar to the debug helper that we demonstrated earlier.
"""#,
    timestamp: (5*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Let’s flip the boolean back to `true` so that we can get things passing again:
"""#,
    timestamp: (5*60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Now let’s try to write a test for the only other piece of functionality in our reducer: adding a todo. For this test we can start with a test store that has no todos in its initial state:
"""#,
    timestamp: (5*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
func testAddTodo() {
  let store = TestStore(
    initialState: AppState(),
    reducer: appReducer,
    environment: AppEnvironment()
  )

  store.assert(
  )
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
We want to assert that when the `addTodoButtonTapped` action is sent that the state changes by adding a todo to the array of todos in our app state:
"""#,
    timestamp: (6*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.addButtonTapped) {
    $0.todos = [
      Todo(
        description: "",
        id: UUID(),
        isComplete: false
      )
    ]
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
I’m not really sure what to use for the `id` of the todo, but the reducer used this initializer so maybe that’s the right thing to do. If we run this we already get a failure:
"""#,
    timestamp: (6*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
🛑 failed - Unexpected state mutation: …

      AppState(
        todos: [
          Todo(
            isComplete: false,
            description: "",
    −       id: 6FAAB3DB-B4E9-4D47-BD43-6987A7E730AE
    +       id: 0D3C5587-3F2D-4625-8DAC-3475E957673A
          ),
        ]
      )

(Expected: −, Actual: +)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Well that’s a bummer. We see here that the ids of the todos don’t match. And in fact, they will never match. If we run the test again we will see the error message changes because an entirely different `UUID` was created. Creating `UUID`s like this means we will always get a random `UUID` each time this code runs. There will be no way to predict what it gives us so that we can write a test that passes.
"""#,
    timestamp: (7*60 + 7),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Controlling a dependency"#,
    timestamp: (7*60 + 35),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
So, what are we to do? Should we just not test this functionality? Should we try to find a way to write these assertions so that it ignores the id?
"""#,
    timestamp: (7*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Well, the answer is no to both of these! We should absolutely be writing tests for this, and we should not be jumping through hoops just to make the library ignore this one field on the state.
"""#,
    timestamp: (7*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
The true problem here is that we have a dependency on `UUID` in our reducer that is not properly controlled. By invoking the `UUID` initializer directly we are reaching out into the real world to compute a random UUID, and we have no way to control that. This is precisely what the third generic of the `Reducer` type is for, and it’s called the environment.
"""#,
    timestamp: (7*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
The environment is the place to put all of the dependencies that our reducer needs to do its job. That can include API clients, analytics clients, date initializers and yes even `UUID` initializers. If you do this then your reducers become much easier to test, and you start to get a lot more test coverage on your feature.
"""#,
    timestamp: (8*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
So to do this we are going put our dependency on `UUID` in our `AppEnvironment`.
"""#,
    timestamp: (8*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
The dependency has the same shape as the `UUID.init` initializer, which is just a function from void to `UUID`:
"""#,
    timestamp: (8*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
struct AppEnvironment {
  var uuid: () -> UUID
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Then we can make our `appReducer` work with the `AppEnvironment`, which means the closure is now handed an instance of the environment:
"""#,
    timestamp: (9*60 + 3),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
  ...,
  Reducer { state, action, environment in
    ...
  }
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And we can now use this environment to property create our todo rather than reaching out into the vast unknowable world to ask for a `UUID`:
"""#,
    timestamp: (9*60 + 4),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .addButtonTapped:
  state.todos.insert(Todo(id: environment.uuid()), at: 0)
  return .none
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Then when we create our store in both the SwiftUI preview and scene delegate we just have to provide an environment. For these stores we will use the live dependency that actually does call the `UUID` initializer because we have no need to control it in these parts:
"""#,
    timestamp: (9*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
    environment: AppEnvironment(
      uuid: UUID.init
    )
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And now the app should build and run just as it did before.
"""#,
    timestamp: (9*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But, the place we do want to control the dependency is in our tests. In each of our tests we create a test store, and in order to do that we need to construct an environment. Right now it’s using the empty `AppEnvironment`, but that is no longer correct.
"""#,
    timestamp: (9*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
In order to construct an `AppEnvironment` we have to provide a function `() -> UUID`:
"""#,
    timestamp: (9*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
environment: AppEnvironment(
  uuid: <#T##() -> UUID#>
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And it’s this function we want to control. We would like to provide an implementation of this function that generates deterministic UUIDs. In fact, for the purpose of this test, we could even just have this function return a single, pre-determined `UUID`:
"""#,
    timestamp: (9*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
environment: AppEnvironment(
  uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
It’s also possible to come up with a more robust, deterministic `UUID` function for the situations your reducer needs to be able to generate many `UUID`s. We have an exercise exploring this very thing, so you may want to check that out.
"""#,
    timestamp: (10*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Now when we run our tests we still get a failure, but it’s something a lot more interesting:
"""#,
    timestamp: (11*60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
🛑 failed - Unexpected state mutation: …

      AppState(
        todos: [
          Todo(
            isComplete: false,
            description: "",
    −       id: 0676432F-834B-402E-B9B2-14121E3F6BAD
    +       id: DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF
          ),
        ]
      )

(Expected: −, Actual: +)
"""#,
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: #"""
We now see that the actual `UUID` produced is far more predictable. In fact, it’s precisely the `UUID` we stubbed in, so we clearly see that our reducer is now working with the controlled environment. And if we update our test to construct this `UUID` in the assertion we should get a passing test:
"""#,
    timestamp: (11*60 + 7),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.addButtonTapped) {
    $0.todos = [
      Todo(
        description: "",
        id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!,
        isComplete: false
      )
    ]
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And it passes!
"""#,
    timestamp: (11*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
This is incredibly cool. We accidentally introduced a side effect into our reducer code that made it untestable. So, we took advantage of the extra `Environment` generic that all reducers have in order to properly pass down dependencies to the reducer, and this made it very easy to control the `UUID` function and write tests.
"""#,
    timestamp: (11*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
And this is how the story will play out repeatedly when it comes to effects and dependencies. You can of course always reach out to global dependencies and functions in your reducer, but if you want things to be testable you should throw those dependencies in the environment and then you get a shot at controlling them later.
"""#,
    timestamp: (11*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Todo sorting"#,
    timestamp: (12*60 + 2),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
Now that we have the basics of the todo app in place, let’s start layering on some advanced functionality. What if we wanted completed items to automatically sort to the bottom of the list?
"""#,
    timestamp: (12*60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
In order to do this we would need to know the moment a todo is completed or un-completed, which happens in the `todoReducer`:
"""#,
    timestamp: (12*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .checkboxTapped:
  state.isComplete.toggle()
  return .none
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
However, in this reducer we don’t have any access to the full list of todos, we only have the one todo that we are operating on.
"""#,
    timestamp: (12*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Never fear, because in the main `appReducer` we have access to all of the actions in the app, including each action that happens in every row of the list. Currently we are ignoring all of those actions with this line:
"""#,
    timestamp: (12*60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: let index, action: let action):
  return .none
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
But, just before doing that we can handle any action in the `todo` case that we want. In particular, we want to know when a `.checkboxTapped` action is sent, so we can destructure that one event and this is where we will do our sorting logic:
"""#,
    timestamp: (13*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: _, action: .checkboxTapped):
  return .none
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
A naive way to do the sort is to use the `sort` method and say that the first todo comes before the second todo if it the first is incomplete and the second is completed:
"""#,
    timestamp: (13*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: _, action: .checkboxTapped):
  state.todos.sort { !$0.isComplete && $1.isComplete }
  return .none
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This technically works, but it isn’t right. The standard library sort method is not what is known as a “stable” sort. This means that two todos for which this condition returns `false` are not guaranteed to stay in the same order relative to each other. In particular, after this sort all the completed todos could be shuffled around, and all the incomplete todos could be shuffled. It doesn’t necessarily happen, but it isn’t guaranteed to not happen so we should assume that eventually it will.
"""#,
    timestamp: (14*60 + 0),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Luckily there’s a small thing we can do to emulate a stable sort. If we keep track of the integer offset of each element, then when the `isComplete` condition above is `false` we can fallback to checking their offsets:
"""#,
    timestamp: (14*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: _, action: .checkboxTapped):
  state.todos = state.todos
    .enumerated()
    .sorted(by: { lhs, rhs in
      (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
    })
    .map(\.element)
  return .none
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And this is the more technically correct solution for sorting, and if we run the app we will see that as soon as we check off a todo it magically floats down to the bottom of the todos.
"""#,
    timestamp: (15*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Before moving on, let’s get some test coverage on this. Right now our test for completing a todo only has a single todo, so that’s not exercising any of our sorting logic. Let's copy this test over and add another todos to state so we can.
"""#,
    timestamp: (16*60 + 5),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
func testTodoSorting() {
  let store = TestStore(
    initialState: AppState(
      todos: [
        Todo(
          description: "Milk",
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          isComplete: false
        ),
        Todo(
          description: "Eggs",
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
          isComplete: false
        )
      ]
    ),
    reducer: appReducer,
    environment: AppEnvironment(
      uuid: { fatalError("unimplemented") }
    )
  )

  store.assert(
    .send(.todo(index: 0, action: .checkboxTapped)) {
      $0.todos[0].isComplete = true
    }
  )
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And when we run it we get the failure:
"""#,
    timestamp: (17*60 + 5),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
🛑 failed - Unexpected state mutation: …

      AppState(
        todos: [
          Todo(
    −       isComplete: true,
    −       description: "Milk",
    −       id: 00000000-0000-0000-0000-000000000000
    −     ),
    −     Todo(
            isComplete: false,
            description: "Eggs",
            id: 00000000-0000-0000-0000-000000000001
          ),
    +     Todo(
    +       isComplete: true,
    +       description: "Milk",
    +       id: 00000000-0000-0000-0000-000000000000
    +     ),
        ]
      )

(Expected: −, Actual: +)
"""#,
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: #"""
This is pretty clearly showing us that we are not properly asserting that the todos sorted. We are claiming that the first todo is “Milk” which has been completed, but in actuality that todo should be at the bottom of the list.
"""#,
    timestamp: (17*60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
The easiest way to fix this is to fully reconstruct the todos from scratch in the assertion so that we can truly demonstrate that we know what state the todos should be in:
"""#,
    timestamp: (17*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos = [
      Todo(
        description: "Eggs",
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        isComplete: false
      ),
      Todo(
        description: "Milk",
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        isComplete: true
      )
    ]
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This may be verbose, but it’s how we can make this test as strong as possible. If we were to try to take a shortcut by just doing the sorting right in the assertion, like this:
"""#,
    timestamp: (18*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
    $0.todos = $0.todos
      .enumerated()
      .sorted(by: { lhs, rhs in
        (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
      })
      .map(\.element)
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Well, that still passes but we’ve now recreated a bunch of logic, and worse if there’s a failure it is not clear why it failed. There’s a pretty big distance between the expected and actual value. Did it fail because the logic inside this assertion is wrong, or because the logic in the application is wrong?
"""#,
    timestamp: (18*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
So it’s much better to be as explicit as possible when making your assertions. If you really do think this is too verbose, then one small step we could take is to re-arrange the todos right in the assert closure:
"""#,
    timestamp: (18*60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
    $0.todos = [
      $0.todos[1],
      $0.todos[0],
    ]
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Or we can even use the `swap` method on arrays:
"""#,
    timestamp: (19*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
    $0.swapAt(0, 1)
  }
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
You are free to use any of these styles depending on your appetite for explicitness and verbosity. We still think it’s may be worth just embracing the verbosity so that it is very clear what went wrong when there is a failure.
"""#,
    timestamp: (19*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Delaying the sort"#,
    timestamp: (20*60 + 2),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
Our todo app is now getting pretty functional, and we have test coverage on all the logic that powers it. There are a lot of features we could move on to next to beef up the app, and we have a bunch of exercises to explore those, but we want to demonstrate something very specific.
"""#,
    timestamp: (20*60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
One thing that is a little annoying with ticking a todo complete is that it immediately moves down to the bottom. What if we wanted to rapid fire complete some todos. With things shifting around so much it can be a little disorienting and you run the risk of accidentally tapping on the wrong todo.
"""#,
    timestamp: (20*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
What if we could add a little delay so that when you complete a todo you have a wait a second before the sorting is done. Since we are involving time here and want to do something outside the lifetime of our reducer being called, we definitely need to use effects. So far we haven’t had to use the `Effect` type at all because everything could just be done right in the reducer. But now we need to speak to the outside world, and then have the outside world speak back to us, and therefore effects are necessary.
"""#,
    timestamp: (20*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Effects are modeled in the Composable Architecture as Combine publishers that are returned from the reducer. After a reducer finishes its state mutation logic, it can return an effect publisher that will later be run by the store, and any data those effects produce will be fed back into the store so that we can react to it.
"""#,
    timestamp: (21*60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We can’t return just any type of publisher, it has to be the `Effect` type that the library provides. We can still use all of the publishers and operators that Combine gives us, but at the end of the day we gotta convert that publisher to an effect, which is easy to do.
"""#,
    timestamp: (21*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
If we approach this naively we may be tempted to create an effect that encapsulates the sorting work, and then delay that effect by a second. There’s even an effect that is specifically tuned for performing work in the outside world that doesn’t need to feed another action back into the system, and it’s called `fireAndForget`:
"""#,
    timestamp: (21*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: _, action: .checkboxTapped):
  return Effect.fireAndForget {

  }
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And since `Effect` conforms to the `Publisher` protocol we get all of its operators for free, in particular we can delay the execution of this effect by tacking on the `delay` operator:
"""#,
    timestamp: (22*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
return Effect.fireAndForget {

}
.delay(for: 1, scheduler: DispatchQueue.main)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
But as soon we use the `delay` operator we change our type to something that isn’t an `Effect`:

> 🛑 Cannot convert return expression of type 'Publishers.Delay<Effect<Output>, DispatchQueue>' to return type 'Effect<AppAction>’

And so we have to erase that detail:
"""#,
    timestamp: (0*60 + 0),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
return Effect.fireAndForget {

}
.delay(for: 1, scheduler: DispatchQueue.main)
.eraseToEffect()
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
With this in place we would hope that maybe we can do the sorting logic inside this effect:
"""#,
    timestamp: (22*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
return Effect.fireAndForget {
  state.todos = state.todos
  .enumerated()
  .sorted(by: { lhs, rhs in
    (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
  })
  .map(\.element)
}
.delay(for: 1, scheduler: DispatchQueue.main)
.eraseToEffect()
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This would ideally represent the idea that we want to execute this sorting logic after a 1 second delay.
"""#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But this is not correct, we get the following compiler error:
"""#,
    timestamp: (23*60 + 7),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
> 🛑 Escaping closure captures 'inout' parameter 'state'

And this is a good compiler error to get. It’s saying that we are not allowed to access the `inout` parameter of `state` inside a closure that escapes. This is a strong guarantee that Swift is making. It says that when you hand a mutable value to a function via `inout` that it must make all of its mutations to the value in the scope of that function. It cannot run off to do some work at a later time and magically mutate this local value. This makes value types so much simpler than reference types, because reference types are allowed to venture far away and be mutated without us knowing who or what did the mutation.
"""#,
    timestamp: (23*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
And not only is this impossible from Swift’s perspective, but we don’t want to even allow this in the Composable Architecture. The architecture demands that the only way for changes to be made to state is that an action is sent into the system. This is a good thing because it means there are only a few places to look for how our state evolves over time. If we could do something like this effect then we’d also have to be aware of all of the state mutations that could be happening all over the place.
"""#,
    timestamp: (24*60 + 1),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
So let’s back out of this and do something else. Let’s create an effect to send an action back into the store, and then we will do our sorting logic in that action. We need to create a new action for this, and we will call it `todoDelayCompleted` to be super explicit about what exactly triggered this action:
"""#,
    timestamp: (24*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
enum AppAction: Equatable {
  case addButtonTapped
  case todo(index: Int, action: TodoAction)
  case todoDelayCompleted
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
If we wanted to immediately send this action back into the store when the toggle button was tapped we could just do:
"""#,
    timestamp: (25*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: _, action: .checkboxTapped):
  return Effect(value: .todoDelayCompleted)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This is returning an effect that emits the action immediately.
"""#,
    timestamp: (25*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Before doing any delay logic let’s get things compiling by handling this new action in the reducer. We want to put the sorting logic in there:
"""#,
    timestamp: (25*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todoDelayCompleted:
  state.todos = state.todos
    .enumerated()
    .sorted(by: { lhs, rhs in
      (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
    })
    .map(\.element)
  return .none
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And if we were to run the app now it should behave exactly as it did before.
"""#,
    timestamp: (25*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Let’s mix back in the delaying logic. We can take our effect that holds `.todoDelayCompleted` action, and we can delay its delivery to the store by a second, and finish it off by erasing to the `Effect` type:
"""#,
    timestamp: (26*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: _, action: .checkboxTapped):
  return Effect(value: .todoDelayCompleted)
    .delay(for: 1, scheduler: DispatchQueue.main)
    .eraseToEffect()
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
If we run the app it seems to work as we expect. We complete a todo, and then a second later it’s sorted to the bottom. Looks good!
"""#,
    timestamp: (26*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But there’s a caveat. If I add a bunch of todos, and then slowly check them off, we see that eventually the sorting happens right in the middle of me trying to complete a task. This is because as I am checking off todos we are not reseting the 1 second delay. Once a second has passed from the first completion action it will trigger a sort of the todos, even if you are still tapping around.
"""#,
    timestamp: (26*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
The problem is that when we tap a checkbox we should cancel any effects for todo completion that might be inflight. That would help us reset the clock each time we complete a todo.
"""#,
    timestamp: (27*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Lucky for us the Composable Architecture comes with an effect operator that allows us to do this quite easily. We can enhance an effect to be capable of cancelling by using the `cancellable` method:
"""#,
    timestamp: (27*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
return Effect(value: .todoDelayCompleted)
  .delay(for: 1, scheduler: DispatchQueue.main)
  .eraseToEffect()
  .cancellable(id: <#AnyHashable#>)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Using this operator gives us the chance to cancel its execution at a later time. In order to track the effect so that we can find it later to cancel, we have to give it an identifier. The identifier can be any hashable value, so we could just use a string if we want:
"""#,
    timestamp: (27*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
return Effect(value: .todoDelayCompleted)
  .delay(for: 1, scheduler: DispatchQueue.main)
  .eraseToEffect()
  .cancellable(id: "completion effect")
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And then later if we want to cancel this effect from any action we can use the special `cancel` effect function:
"""#,
    timestamp: (28*60 + 3),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Effect.cancel(id: "todo completion effect")
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
So what we want to do here is first cancel our todo completion effect, and then fire off a new, delayed completion effect. We can do this with another effect operator called `concatenate`, which just runs a list of effects in order:
"""#,
    timestamp: (28*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
return .concatenate(
  Effect.cancel(id: "todo completion effect"),
  Effect(value: .todoDelayCompleted)
    .delay(for: 1, scheduler: DispatchQueue.main)
    .eraseToEffect()
    .cancellable(id: "todo completion effect")
)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
We can even use some type inference to make this a little shorter:
"""#,
    timestamp: (28*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
.cancel(id: "todo completion effect"),
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Now when we run the app we see that it behaves exactly as we want. We can check off todos as quickly as we want and the sorting will be delayed until we stop for a second.
"""#,
    timestamp: (29*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
It’s pretty amazing how easy it was to get this feature working in the Composable Architecture. We can very succinctly describe exactly what we want to happen. When a todo is completed we want to first cancel any inflight requests we may have, and then we want to schedule another effect to happen after one second.
"""#,
    timestamp: (29*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
And there are even ways to improve this a bit. First, the `cancellable` operator comes with an optional argument that makes it automatically cancel any inflight effects so that we don’t have to do this `concatenate` and `cancel` dance ourselves:
"""#,
    timestamp: (29*60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
return Effect(value: .todoDelayCompleted)
  .delay(for: 1, scheduler: DispatchQueue.main)
  .eraseToEffect()
  .cancellable(id: "todo completion effect", cancelInFlight: true)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And now this still behaves exactly as we want, but is even more succinct.
"""#,
    timestamp: (30*60 + 5),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Another improvement that can be made is the id used for this cancellation. By using a string we are opening ourselves up to a few potential problems. For example, if we needed to use this identifier in a few spots of our reducer we would be susceptible to typos, and that could cause subtle bugs. But, even if we extracted this string to a constant to be shared we could accidentally use the same identifier in this reducer that we were using in another reducer. Then we accidentally cancel an effect from another reducer if we happen to use the same identifier.
"""#,
    timestamp: (30*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We can very easily fix both of these problems by creating a dedicated type for the cancellation identifier. All it takes is a new struct that conforms to `Hashable`:
"""#,
    timestamp: (31*60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
case .todo(index: _, action: .checkboxTapped):
  struct CancelDelayId: Hashable {}

  return Effect(value: .todoDelayCompleted)
    .delay(for: 1, scheduler: environment.mainQueue)
    .eraseToEffect()
    .cancellable(id: CancelDelayId(), cancelInFlight: true)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Not only can we define the struct locally inside the action case, which means it isn’t visible to anyone outside this local scope, but it also makes it completely unique so it is impossible for anyone else to trample over this identifier. And because it’s a type it is impossible to accidentally misspell, and so we have solved all the problems with using stringy identifiers, and this makes cancellation of effects a super understandable and safe thing to do.
"""#,
    timestamp: (31*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Next time: controlling complex dependencies"#,
    timestamp: (31*60 + 47),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
So impressively enough, we now have the functionality we sought out to have, and we were able to do so by leveraging Combine and some very simple helpers that come with the Composable Architecture.
"""#,
    timestamp: (31*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Since we’ve now implemented some new functionality into our application, we should probably write some tests to prove that it works the way we expect…next time!
"""#,
    timestamp: (32*60 + 10),
    type: .paragraph
  ),
]
