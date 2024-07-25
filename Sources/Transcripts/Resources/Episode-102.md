## Introduction

@T(00:00:05)
Alright, we've added a new feature, but something isn’t quite right with our reducer. We are currently plucking a random `UUID` out of thin air by calling its initializer.  To see why this is problematic, let’s try writing some tests.

@T(00:00:17)
We first discussed testing the Composable Architecture many months ago, and we discussed a few different facets. [First](/episodes/ep82-testable-state-management-reducers), we discussed how to test the reducers in isolation. This is a natural place to start because one of the primary responsibilities of the reducer is to mutate the state when an action comes in. So to test that functionality we just need to construct a piece of state to start with, and feed that state and an action into the reducer, and then assert on the changes made to the state. And although our reducers are quite simple right now, in practice they can get quite complicated and have quite a bit of logic in them. So this kind of testing can be super powerful because it is so lightweight and allows you to easily probe all of the strange edge cases of your code.

@T(00:00:58)
But [then we kicked things up a notch](/episodes/ep83-testable-state-management-effects) and showed how to test the second responsibility of the reducers: the side effects. We showed that after running the reducer, which returned a side effect publisher, we could then actually run the effect and capture the data it produced and then make an assertion that it produced the data we expected. This was incredibly powerful because we started getting test coverage on effects, which is typically off limits, and we could even get stronger guarantees about our business logic.

@T(00:01:27)
But [then we took things even further](/episodes/ep84-testable-state-management-ergonomics). We showed how to marry the reducer testing and the effect testing into one cohesive, ergonomic package. We built an assertion helper that allowed us to describe a series of steps that the user takes in the application, and each step of the way had to describe exactly how the state was mutated and describe what events were fed back into the system from effects. We could even make exhaustive assertions about effects, such as they must all complete by the end of the assertion so that we know definitively that no other data was fed into the application that we might be missing.

@T(00:02:01)
And so we are now going to use that to write some really nice tests for our application. We have refined the API for the assertion helper a bit for the library, but it’s still quite similar to what we covered in episodes.

## Writing our first test

@T(00:02:18)
Let’s get our feet wet by first writing a test for the functionality of marking a todo as completed. You start by creating a test store that holds onto the domain that you want to test, which looks almost identical to how you create a normal store:

```swift
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
```

> Correction: Since this episode was recorded, the `ComposableArchitectureTestSupport` module has merged into `ComposableArchitecture`. You can now import `ComposableArchitecture` in your test targets to access the test store.

@T(00:03:05)
However, the `TestStore` requires both the state and the actions of our domain to be equatable so that we can properly assert on how the system evolves. `AppState`  is already equatable, so we just need to make `AppAction` equatable:

```swift
enum TodoAction: Equatable {
  …
}

struct AppState: Equatable {
  …
}
```

@T(00:03:29)
Now tests are building, but in order to test completing a todo, we should have one defined in state:

```swift
func testCompletingTodo() {
  let store = TestStore(
    initialState: AppState(
      todos: [
        Todo(
          description: "Milk",
          id: UUID(
            uuidString: "00000000-0000-0000-0000-000000000000"
          )!,
          isComplete: false
        )
      ]
    ),
    reducer: appReducer,
    environment: AppEnvironment()
  )
}
```

@T(00:03:42)
Now we’re ready to write our assertion. We do this by calling the `assert` method on the store, which allows us to feed a series of user actions in so that we can then assert on how the system evolved:

```swift
store.assert(
)
```

@T(00:03:58)
Technically this test is passing because we haven’t sent any actions and therefore the system hasn’t changed at all!

@T(00:04:09)
So, let’s send an action to simulate the idea of the user tapping on the checkbox on the first todo item:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped))
)
```

@T(00:04:24)
Sending the action is only half the story for making this assertion. We also need to describe how the state changed after this action was sent to the store. The way we do that is open up a trailing closure on this `.send` command, and make the mutations we expect to happen to the value passed to the closure.

@T(00:04:40)
In particular, we expect the first todo’s `isComplete` field to switch to `true`:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  }
)
```

@T(00:04:53)
And if we run the tests they pass.

@T(00:04:57)
Before moving on, let’s show off a wonderful bit of testing ergonomics that we added to the library that wasn’t covered in the episodes. When a test fails we print a nice message showing exactly what piece of state does not match. So let’s purposely change this test to fail:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = false
  }
)
```

@T(00:05:15)
And if we run this test we will get a failure, and the failure message will show us exactly what went wrong:

> Failed: Unexpected state mutation: …
> 
> ```
>   AppState(
>     todos: [
>       Todo(
> −       isComplete: false,
> +       isComplete: true,
>         description: "Milk",
>         id: 00000000-0000-0000-0000-000000000000
>       ),
>     ]
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:05:27)
This is specifically showing that I expected `isComplete` to be `false` but it was actually `true`. This makes it so easy to focus in on exactly what failed and is a huge boon to productivity, and it’s quite similar to the debug helper that we demonstrated earlier.

@T(00:05:38)
Let’s flip the boolean back to `true` so that we can get things passing again:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  }
)
```

@T(00:05:46)
Now let’s try to write a test for the only other piece of functionality in our reducer: adding a todo. For this test we can start with a test store that has no todos in its initial state:

```swift
func testAddTodo() {
  let store = TestStore(
    initialState: AppState(),
    reducer: appReducer,
    environment: AppEnvironment()
  )

  store.assert(
  )
}
```

@T(00:06:11)
We want to assert that when the `addTodoButtonTapped` action is sent that the state changes by adding a todo to the array of todos in our app state:

```swift
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
```

@T(00:06:40)
I’m not really sure what to use for the `id` of the todo, but the reducer used this initializer so maybe that’s the right thing to do. If we run this we already get a failure:

> Failed: Unexpected state mutation: …
> 
> ```
>    AppState(
>      todos: [
>        Todo(
>          isComplete: false,
>          description: "",
>  −       id: 6FAAB3DB-B4E9-4D47-BD43-6987A7E730AE
>  +       id: 0D3C5587-3F2D-4625-8DAC-3475E957673A
>        ),
>      ]
>    )
> ```
>
> (Expected: −, Actual: +)

@T(00:07:07)
Well that’s a bummer. We see here that the ids of the todos don’t match. And in fact, they will never match. If we run the test again we will see the error message changes because an entirely different `UUID` was created. Creating `UUID`s like this means we will always get a random `UUID` each time this code runs. There will be no way to predict what it gives us so that we can write a test that passes.

## Controlling a dependency

@T(00:07:35)
So, what are we to do? Should we just not test this functionality? Should we try to find a way to write these assertions so that it ignores the id?

@T(00:07:43)
Well, the answer is no to both of these! We should absolutely be writing tests for this, and we should not be jumping through hoops just to make the library ignore this one field on the state.

@T(00:07:52)
The true problem here is that we have a dependency on `UUID` in our reducer that is not properly controlled. By invoking the `UUID` initializer directly we are reaching out into the real world to compute a random UUID, and we have no way to control that. This is precisely what the third generic of the `Reducer` type is for, and it’s called the environment.

@T(00:08:11)
The environment is the place to put all of the dependencies that our reducer needs to do its job. That can include API clients, analytics clients, date initializers and yes even `UUID` initializers. If you do this then your reducers become much easier to test, and you start to get a lot more test coverage on your feature.

@T(00:08:30)
So to do this we are going put our dependency on `UUID` in our `AppEnvironment`.

@T(00:08:43)
The dependency has the same shape as the `UUID.init` initializer, which is just a function from void to `UUID`:

```swift
struct AppEnvironment {
  var uuid: () -> UUID
}
```

@T(00:09:03)
Then we can make our `appReducer` work with the `AppEnvironment`, which means the closure is now handed an instance of the environment:

```swift
let appReducer: Reducer<
  AppState, AppAction, AppEnvironment
> = .combine(
  …,
  Reducer { state, action, environment in
    …
  }
}
```

@T(00:09:04)
And we can now use this environment to property create our todo rather than reaching out into the vast unknowable world to ask for a `UUID`:

```swift
case .addButtonTapped:
  state.todos.insert(Todo(id: environment.uuid()), at: 0)
  return .none
```

@T(00:09:16)
Then when we create our store in both the SwiftUI preview and scene delegate we just have to provide an environment. For these stores we will use the live dependency that actually does call the `UUID` initializer because we have no need to control it in these parts:

```swift
    environment: AppEnvironment(
      uuid: UUID.init
    )
```

@T(00:09:35)
And now the app should build and run just as it did before.

@T(00:09:37)
But, the place we do want to control the dependency is in our tests. In each of our tests we create a test store, and in order to do that we need to construct an environment. Right now it’s using the empty `AppEnvironment`, but that is no longer correct.

@T(00:09:45)
In order to construct an `AppEnvironment` we have to provide a function `() -> UUID`:

```swift
environment: AppEnvironment(
  uuid: <#() -> UUID#>
)
```

@T(00:09:56)
And it’s this function we want to control. We would like to provide an implementation of this function that generates deterministic UUIDs. In fact, for the purpose of this test, we could even just have this function return a single, pre-determined `UUID`:

```swift
environment: AppEnvironment(
  uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
)
```

@T(00:10:31)
It’s also possible to come up with a more robust, deterministic `UUID` function for the situations your reducer needs to be able to generate many `UUID`s. We have an exercise exploring this very thing, so you may want to check that out.

@T(00:11:02)
Now when we run our tests we still get a failure, but it’s something a lot more interesting:

> Failed: Unexpected state mutation: …
>
> ```
>   AppState(
>     todos: [
>       Todo(
>         isComplete: false,
>         description: "",
> −       id: 0676432F-834B-402E-B9B2-14121E3F6BAD
> +       id: DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF
>       ),
>     ]
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:11:07)
We now see that the actual `UUID` produced is far more predictable. In fact, it’s precisely the `UUID` we stubbed in, so we clearly see that our reducer is now working with the controlled environment. And if we update our test to construct this `UUID` in the assertion we should get a passing test:

```swift
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
```

@T(00:11:27)
And it passes!

@T(00:11:29)
This is incredibly cool. We accidentally introduced a side effect into our reducer code that made it untestable. So, we took advantage of the extra `Environment` generic that all reducers have in order to properly pass down dependencies to the reducer, and this made it very easy to control the `UUID` function and write tests.

@T(00:11:46)
And this is how the story will play out repeatedly when it comes to effects and dependencies. You can of course always reach out to global dependencies and functions in your reducer, but if you want things to be testable you should throw those dependencies in the environment and then you get a shot at controlling them later.

## Todo sorting

@T(00:12:02)
Now that we have the basics of the todo app in place, let’s start layering on some advanced functionality. What if we wanted completed items to automatically sort to the bottom of the list?

@T(00:12:26)
In order to do this we would need to know the moment a todo is completed or un-completed, which happens in the `todoReducer`:

```swift
case .checkboxTapped:
  state.isComplete.toggle()
  return .none
```

@T(00:12:40)
However, in this reducer we don’t have any access to the full list of todos, we only have the one todo that we are operating on.

@T(00:12:51)
Never fear, because in the main `appReducer` we have access to all of the actions in the app, including each action that happens in every row of the list. Currently we are ignoring all of those actions with this line:

```swift
case .todo(index: let index, action: let action):
  return .none
```

@T(00:13:11)
But, just before doing that we can handle any action in the `todo` case that we want. In particular, we want to know when a `.checkboxTapped` action is sent, so we can destructure that one event and this is where we will do our sorting logic:

```swift
case .todo(index: _, action: .checkboxTapped):
  return .none
```

@T(00:13:28)
A naive way to do the sort is to use the `sort` method and say that the first todo comes before the second todo if it the first is incomplete and the second is completed:

```swift
case .todo(index: _, action: .checkboxTapped):
  state.todos.sort { !$0.isComplete && $1.isComplete }
  return .none
```

@T(00:14:00)
This technically works, but it isn’t right. The standard library sort method is not what is known as a “stable” sort. This means that two todos for which this condition returns `false` are not guaranteed to stay in the same order relative to each other. In particular, after this sort all the completed todos could be shuffled around, and all the incomplete todos could be shuffled. It doesn’t necessarily happen, but it isn’t guaranteed to not happen so we should assume that eventually it will.

@T(00:14:31)
Luckily there’s a small thing we can do to emulate a stable sort. If we keep track of the integer offset of each element, then when the `isComplete` condition above is `false` we can fallback to checking their offsets:

```swift
case .todo(index: _, action: .checkboxTapped):
  state.todos = state.todos
    .enumerated()
    .sorted(by: { lhs, rhs in
      (rhs.element.isComplete && !lhs.element.isComplete)
        || lhs.offset < rhs.offset
    })
    .map(\.element)
  return .none
```

@T(00:15:43)
And this is the more technically correct solution for sorting, and if we run the app we will see that as soon as we check off a todo it magically floats down to the bottom of the todos.

@T(00:16:05)
Before moving on, let’s get some test coverage on this. Right now our test for completing a todo only has a single todo, so that’s not exercising any of our sorting logic. Let's copy this test over and add another todos to state so we can.

```swift
func testTodoSorting() {
  let store = TestStore(
    initialState: AppState(
      todos: [
        Todo(
          description: "Milk",
          id: UUID(
            uuidString: "00000000-0000-0000-0000-000000000000"
          )!,
          isComplete: false
        ),
        Todo(
          description: "Eggs",
          id: UUID(
            uuidString: "00000000-0000-0000-0000-000000000001"
          )!,
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
```

@T(00:17:05)
And when we run it we get the failure:

> Failed: Unexpected state mutation: …
>
> ```
>   AppState(
>     todos: [
>       Todo(
> −       isComplete: true,
> −       description: "Milk",
> −       id: 00000000-0000-0000-0000-000000000000
> −     ),
> −     Todo(
>         isComplete: false,
>         description: "Eggs",
>         id: 00000000-0000-0000-0000-000000000001
>       ),
> +     Todo(
> +       isComplete: true,
> +       description: "Milk",
> +       id: 00000000-0000-0000-0000-000000000000
> +     ),
>     ]
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:17:36)
This is pretty clearly showing us that we are not properly asserting that the todos sorted. We are claiming that the first todo is “Milk” which has been completed, but in actuality that todo should be at the bottom of the list.

@T(00:17:40)
The easiest way to fix this is to fully reconstruct the todos from scratch in the assertion so that we can truly demonstrate that we know what state the todos should be in:

```swift
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
```

@T(00:18:10)
This may be verbose, but it’s how we can make this test as strong as possible. If we were to try to take a shortcut by just doing the sorting right in the assertion, like this:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
    $0.todos = $0.todos
      .enumerated()
      .sorted(by: { lhs, rhs in
        (rhs.element.isComplete && !lhs.element.isComplete)
          || lhs.offset < rhs.offset
      })
      .map(\.element)
  }
)
```

@T(00:18:23)
Well, that still passes but we’ve now recreated a bunch of logic, and worse if there’s a failure it is not clear why it failed. There’s a pretty big distance between the expected and actual value. Did it fail because the logic inside this assertion is wrong, or because the logic in the application is wrong?

@T(00:18:51)
So it’s much better to be as explicit as possible when making your assertions. If you really do think this is too verbose, then one small step we could take is to re-arrange the todos right in the assert closure:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
    $0.todos = [
      $0.todos[1],
      $0.todos[0],
    ]
  }
)
```

@T(00:19:31)
Or we can even use the `swap` method on arrays:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
    $0.swapAt(0, 1)
  }
)
```

@T(00:19:44)
You are free to use any of these styles depending on your appetite for explicitness and verbosity. We still think it’s may be worth just embracing the verbosity so that it is very clear what went wrong when there is a failure.

## Delaying the sort

@T(00:20:02)
Our todo app is now getting pretty functional, and we have test coverage on all the logic that powers it. There are a lot of features we could move on to next to beef up the app, and we have a bunch of exercises to explore those, but we want to demonstrate something very specific.

@T(00:20:17)
One thing that is a little annoying with ticking a todo complete is that it immediately moves down to the bottom. What if we wanted to rapid fire complete some todos. With things shifting around so much it can be a little disorienting and you run the risk of accidentally tapping on the wrong todo.

@T(00:20:34)
What if we could add a little delay so that when you complete a todo you have a wait a second before the sorting is done. Since we are involving time here and want to do something outside the lifetime of our reducer being called, we definitely need to use effects. So far we haven’t had to use the `Effect` type at all because everything could just be done right in the reducer. But now we need to speak to the outside world, and then have the outside world speak back to us, and therefore effects are necessary.

@T(00:21:02)
Effects are modeled in the Composable Architecture as Combine publishers that are returned from the reducer. After a reducer finishes its state mutation logic, it can return an effect publisher that will later be run by the store, and any data those effects produce will be fed back into the store so that we can react to it.

@T(00:21:20)
We can’t return just any type of publisher, it has to be the `Effect` type that the library provides. We can still use all of the publishers and operators that Combine gives us, but at the end of the day we gotta convert that publisher to an effect, which is easy to do.

@T(00:21:45)
If we approach this naively we may be tempted to create an effect that encapsulates the sorting work, and then delay that effect by a second. There’s even an effect that is specifically tuned for performing work in the outside world that doesn’t need to feed another action back into the system, and it’s called `fireAndForget`:

```swift
case .todo(index: _, action: .checkboxTapped):
  return Effect.fireAndForget {

  }
```

@T(00:22:24)
And since `Effect` conforms to the `Publisher` protocol we get all of its operators for free, in particular we can delay the execution of this effect by tacking on the `delay` operator:

```swift
return Effect.fireAndForget {

}
.delay(for: 1, scheduler: DispatchQueue.main)
```

@T(00:00:00)
But as soon we use the `delay` operator we change our type to something that isn’t an `Effect`:

> Error: Cannot convert return expression of type 'Publishers.Delay&lt;Effect&lt;Output>, DispatchQueue>' to return type 'Effect&lt;AppAction>’

And so we have to erase that detail:

```swift
return Effect.fireAndForget {

}
.delay(for: 1, scheduler: DispatchQueue.main)
.eraseToEffect()
```

@T(00:22:55)
With this in place we would hope that maybe we can do the sorting logic inside this effect:

```swift
return Effect.fireAndForget {
  state.todos = state.todos
  .enumerated()
  .sorted(by: { lhs, rhs in
    (rhs.element.isComplete && !lhs.element.isComplete)
      || lhs.offset < rhs.offset
  })
  .map(\.element)
}
.delay(for: 1, scheduler: DispatchQueue.main)
.eraseToEffect()
```

This would ideally represent the idea that we want to execute this sorting logic after a 1 second delay.

@T(00:23:07)
But this is not correct, we get the following compiler error:

> Error: Escaping closure captures 'inout' parameter 'state'

@T(00:23:15)
And this is a good compiler error to get. It’s saying that we are not allowed to access the `inout` parameter of `state` inside a closure that escapes. This is a strong guarantee that Swift is making. It says that when you hand a mutable value to a function via `inout` that it must make all of its mutations to the value in the scope of that function. It cannot run off to do some work at a later time and magically mutate this local value. This makes value types so much simpler than reference types, because reference types are allowed to venture far away and be mutated without us knowing who or what did the mutation.

@T(00:24:01)
And not only is this impossible from Swift’s perspective, but we don’t want to even allow this in the Composable Architecture. The architecture demands that the only way for changes to be made to state is that an action is sent into the system. This is a good thing because it means there are only a few places to look for how our state evolves over time. If we could do something like this effect then we’d also have to be aware of all of the state mutations that could be happening all over the place.

@T(00:24:49)
So let’s back out of this and do something else. Let’s create an effect to send an action back into the store, and then we will do our sorting logic in that action. We need to create a new action for this, and we will call it `todoDelayCompleted` to be super explicit about what exactly triggered this action:

```swift
enum AppAction: Equatable {
  case addButtonTapped
  case todo(index: Int, action: TodoAction)
  case todoDelayCompleted
}
```

@T(00:25:27)
If we wanted to immediately send this action back into the store when the toggle button was tapped we could just do:

```swift
case .todo(index: _, action: .checkboxTapped):
  return Effect(value: .todoDelayCompleted)
```

@T(00:25:31)
This is returning an effect that emits the action immediately.

@T(00:25:49)
Before doing any delay logic let’s get things compiling by handling this new action in the reducer. We want to put the sorting logic in there:

```swift
case .todoDelayCompleted:
  state.todos = state.todos
    .enumerated()
    .sorted(by: { lhs, rhs in
      (rhs.element.isComplete && !lhs.element.isComplete)
        || lhs.offset < rhs.offset
    })
    .map(\.element)
  return .none
```

@T(00:25:55)
And if we were to run the app now it should behave exactly as it did before.

@T(00:26:15)
Let’s mix back in the delaying logic. We can take our effect that holds `.todoDelayCompleted` action, and we can delay its delivery to the store by a second, and finish it off by erasing to the `Effect` type:

```swift
case .todo(index: _, action: .checkboxTapped):
  return Effect(value: .todoDelayCompleted)
    .delay(for: 1, scheduler: DispatchQueue.main)
    .eraseToEffect()
```

@T(00:26:35)
If we run the app it seems to work as we expect. We complete a todo, and then a second later it’s sorted to the bottom. Looks good!

@T(00:26:47)
But there’s a caveat. If I add a bunch of todos, and then slowly check them off, we see that eventually the sorting happens right in the middle of me trying to complete a task. This is because as I am checking off todos we are not reseting the 1 second delay. Once a second has passed from the first completion action it will trigger a sort of the todos, even if you are still tapping around.

@T(00:27:14)
The problem is that when we tap a checkbox we should cancel any effects for todo completion that might be inflight. That would help us reset the clock each time we complete a todo.

@T(00:27:30)
Lucky for us the Composable Architecture comes with an effect operator that allows us to do this quite easily. We can enhance an effect to be capable of cancelling by using the `cancellable` method:

```swift
return Effect(value: .todoDelayCompleted)
  .delay(for: 1, scheduler: DispatchQueue.main)
  .eraseToEffect()
  .cancellable(id: <#AnyHashable#>)
```

@T(00:27:44)
Using this operator gives us the chance to cancel its execution at a later time. In order to track the effect so that we can find it later to cancel, we have to give it an identifier. The identifier can be any hashable value, so we could just use a string if we want:

```swift
return Effect(value: .todoDelayCompleted)
  .delay(for: 1, scheduler: DispatchQueue.main)
  .eraseToEffect()
  .cancellable(id: "completion effect")
```

@T(00:28:03)
And then later if we want to cancel this effect from any action we can use the special `cancel` effect function:

```swift
Effect.cancel(id: "todo completion effect")
```

@T(00:28:22)
So what we want to do here is first cancel our todo completion effect, and then fire off a new, delayed completion effect. We can do this with another effect operator called `concatenate`, which just runs a list of effects in order:

```swift
return .concatenate(
  Effect.cancel(id: "todo completion effect"),
  Effect(value: .todoDelayCompleted)
    .delay(for: 1, scheduler: DispatchQueue.main)
    .eraseToEffect()
    .cancellable(id: "todo completion effect")
)
```

@T(00:28:49)
We can even use some type inference to make this a little shorter:

```swift
.cancel(id: "todo completion effect"),
```

@T(00:29:12)
Now when we run the app we see that it behaves exactly as we want. We can check off todos as quickly as we want and the sorting will be delayed until we stop for a second.

@T(00:29:33)
It’s pretty amazing how easy it was to get this feature working in the Composable Architecture. We can very succinctly describe exactly what we want to happen. When a todo is completed we want to first cancel any inflight requests we may have, and then we want to schedule another effect to happen after one second.

@T(00:29:50)
And there are even ways to improve this a bit. First, the `cancellable` operator comes with an optional argument that makes it automatically cancel any inflight effects so that we don’t have to do this `concatenate` and `cancel` dance ourselves:

```swift
return Effect(value: .todoDelayCompleted)
  .delay(for: 1, scheduler: DispatchQueue.main)
  .eraseToEffect()
  .cancellable(id: "todo completion effect", cancelInFlight: true)
```

@T(00:30:05)
And now this still behaves exactly as we want, but is even more succinct.

@T(00:30:16)
Another improvement that can be made is the id used for this cancellation. By using a string we are opening ourselves up to a few potential problems. For example, if we needed to use this identifier in a few spots of our reducer we would be susceptible to typos, and that could cause subtle bugs. But, even if we extracted this string to a constant to be shared we could accidentally use the same identifier in this reducer that we were using in another reducer. Then we accidentally cancel an effect from another reducer if we happen to use the same identifier.

@T(00:31:02)
We can very easily fix both of these problems by creating a dedicated type for the cancellation identifier. All it takes is a new struct that conforms to `Hashable`:

```swift
case .todo(index: _, action: .checkboxTapped):
  struct CancelDelayId: Hashable {}

  return Effect(value: .todoDelayCompleted)
    .delay(for: 1, scheduler: environment.mainQueue)
    .eraseToEffect()
    .cancellable(id: CancelDelayId(), cancelInFlight: true)
```

@T(00:31:21)
Not only can we define the struct locally inside the action case, which means it isn’t visible to anyone outside this local scope, but it also makes it completely unique so it is impossible for anyone else to trample over this identifier. And because it’s a type it is impossible to accidentally misspell, and so we have solved all the problems with using stringy identifiers, and this makes cancellation of effects a super understandable and safe thing to do.

## Next time: controlling complex dependencies

@T(00:31:47)
So impressively enough, we now have the functionality we sought out to have, and we were able to do so by leveraging Combine and some very simple helpers that come with the Composable Architecture.

@T(00:32:10)
Since we’ve now implemented some new functionality into our application, we should probably write some tests to prove that it works the way we expect…next time!
