## Introduction

@T(00:00:05)
So impressively enough, we now have the functionality we sought out to have, and we were able to do so by leveraging Combine and some very simple helpers that come with the Composable Architecture.

@T(00:00:23)
Since we’ve now implemented some new functionality into our application, we should probably write some tests to prove that it works the way we expect.

## Writing tests

@T(00:00:44)
Let’s start by running our existing test suite and see what goes wrong:

> Failed: Some effects are still running. All effects must complete by the end of the assertion.

> Failed: State change does not match expectation: …
>
> ```
>   AppState(
>     todos: [
>       Todo(
> −       isComplete: false,
> −       description: "Eggs",
> −       id: 00000000-0000-0000-0000-000000000001
> −     ),
> −     Todo(
>         isComplete: true,
>         description: "Milk",
>         id: 00000000-0000-0000-0000-000000000000
>       ),
> +     Todo(
> +       isComplete: false,
> +       description: "Eggs",
> +       id: 00000000-0000-0000-0000-000000000001
> +     ),
>     ]
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:00:49)
We get two failures in this test. One is telling us that there is still an effect inflight that has not yet completed. This is an extremely important error to have because it is forcing us to exhaustively prove that we handled all of the effects in the system. Without this failure we could be firing off effects that later change our system’s state and we wouldn’t be getting any test coverage on that.

@T(00:01:09)
The other failure is telling us that the changes we made to the state in the assertion does not match what actually happened. We are currently saying that the first item of the todos is the “Eggs” item, but in actuality that item is at the end of the list. And this is because the sort hasn’t happened yet, it happens after a delay of 1 second.

@T(00:01:38)
The second failure is the easiest to fix, because after the `checkboxTapped` action is sent the only thing that changes in the state is that the first item’s `isComplete` flag flips to `true`:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  }
)
```

@T(00:01:51)
We are now down to one failure in this test, the failure that says we have an inflight effect to deal with:

> Failed: 1 effect still running. All effects must complete by the end of the assertion.

@T(00:01:56)
The effect that is inflight is the delayed effect which will deliver the `todoDelayCompleted` action once a second passes. The only way to make that happen is to literally have the test suite wait for a second. The `assert` method supports inserting little imperative tasks like that in between steps, and it’s called a `do` block:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
     // Do any imperative work
  }
)
```

@T(00:02:24)
This `do` block will be executed before going onto the next step, and so in here we can wait for a second. The way to do this is using `self.expectation`s:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    _ = XCTWaiter.wait(
      for: [self.expectation(description: "wait")], timeout: 1
    )
  }
)
```

It’s a bit messy, but gets the job done.

@T(00:03:01)
Now if we run tests we get a new failure:

> Failed: failed - Received 1 unexpected action: …
>
> ```
> Unhandled actions: [
>   AppAction.todoDelayCompleted,
> ]
> ```

@T(00:03:16)
This is telling us that the system received an action from an effect, but we didn’t properly account for it in our assertion. And indeed, after the 1 second passed the `.todoDelayCompleted` was finally delivered. And again, this is a really powerful. It is forcing us to consider everything that is happening in the system. We can’t just allow effects to run and deliver their payloads back to the system without us explicitly declaring that happened. In the future this can even catch when accidental new effects creep into the system that we did not expect. So it’s very important for us to be getting these kinds of exhaustive checks in our test.

@T(00:03:38)
So, to prove that we expected to receive this action we need to add an additional step to our assertion:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    _ = XCTWaiter.wait(
      for: [self.expectation(description: "wait")], timeout: 1
    )
  },
  .receive(.todoDelayCompleted)
)
```

@T(00:03:53)
But that’s not enough to get things passing because we have further describe how the state changed after receiving this action from the effect. If we don’t we get the following failure:

> Failed: State change does not match expectation: …
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

@T(00:04:04)
This is telling us that the sorting logic has now run, but we haven’t accounted for it in our assertion. We can do this by swapping the element at index 0 with the element at index 1:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    _ = XCTWaiter.wait(
      for: [self.expectation(description: "wait")], timeout: 1
    )
  },
  .receive(.todoDelayCompleted) {
    $0.swap(0, 1)
  }
)
```

@T(00:04:29)
And now tests pass!

@T(00:04:35)
We have one more failure to deal with, which is our existing `testCompletingTodo` test needs to also account for this delayed action, but in its case we don't expect any changes to state because we only have a single todo, and sorting it won't do a thing.

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    _ = XCTWaiter.wait(
      for: [self.expectation(description: "wait")], timeout: 1
    )
  },
  .receive(.todoDelayCompleted)
)
```

@T(00:05:18)
We can even test a deeper aspect of our logic to make sure that effect cancellation is actually occurring. We can write a test that completes a todo, waits half a second, then un-completes the same todo, and prove that no sorting occurs.

@T(00:05:31)
We can start by getting some of the test set up in place by copying and pasting the contents of our existing sorting test:

```swift
func testTodoSorting_Cancellation() {
  let todos = [
    Todo(
      isComplete: false,
      description: "Milk",
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    ),
    Todo(
      isComplete: false,
      description: "Eggs",
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    )
  ]

  let store = TestStore(
    initialState: AppState(todos: todos),
    reducer: appReducer,
    environment: AppEnvironment(
      uuid: UUID.incrementing
    )
  )

  store.assert(
    .send(.todo(index: 0, action: .checkboxTapped)) {
      $0.todos[0].isComplete = true
    },
    .do {
      _ = XCTWaiter.wait(
        for: [self.expectation(description: "wait")], timeout: 1
      )
    },
    .receive(.todoDelayCompleted) {
      $0.swap(0, 1)
    }
  )
}
```

@T(00:05:45)
But this time, we will only wait half a second before sending another `checkboxTapped`, which means the delay has not yet finished, and then send another action to tap the checkbox again, which will flip the `isComplete` flag back to `false`:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    _ = XCTWaiter.wait(
      for: [self.expectation(description: "wait")], timeout: 0.5
    )
  },
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = false
  },
```

@T(00:06:02)
And then finally we can wait the full second for the next delayed effect to complete, which will send the `.todoDelayCompleted` action back into the system, but will _not_ mutate state in any way:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    _ = XCTWaiter.wait(
      for: [self.expectation(description: "wait")], timeout: 0.5
    )
  },
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = false
  },
  .do {
    _ = XCTWaiter.wait(
      for: [self.expectation(description: "wait")], timeout: 1
    )
  },
  .receive(.todoDelayCompleted)
)
```

@T(00:06:15)
And this test passes. This is proving that the todos do not sort at any point throughout this entire user script. And we really do mean that. It is exhaustively proving that property because if any other actions were received during this script then the test would have failed.

@T(00:06:32)
For example, if we had waited a full second instead of a half second:

```swift
.do {
  _ = XCTWaiter.wait(
    for: [self.expectation(description: "wait")], timeout: 1
  )
},
.send(.todo(index: 0, action: .checkboxTapped)) {
  $0.todos[0].isComplete = false
},
```

@T(00:06:40)
We will get a few failures:

> Failed: Must handle 1 received action before sending an action: …
> 
> ```
> Unhandled actions: [
>   AppAction.todoDelayCompleted,
> ]
> ```

> Failed: Must handle 1 received action before performing this work: …
>
> ```
> Unhandled actions: [
>   AppAction.todoDelayCompleted,
> ]
> ```

> Failed:  Received 1 unexpected action: …
>
> ```
> Unhandled actions: [
>   AppAction.todoDelayCompleted,
> ]
> ```

@T(00:06:42)
The first failure is saying that we must account for all of the actions received from effects before we are allowed to send new actions. This is showing that our delayed effect really was canceled when it was inflight, and so its work was never delivered to the system. This is truly power. Exhaustive assertions on effects executed in our applications.

@T(00:07:17)
Before moving on we want to mention one more tiny simplification we can make. The combination of delaying an effect and cancelling inflight effects when starting a new one has a name that is well-known in the reactive programming communities: it’s called debounce. Probably the most prototypical example of this operation is when a user types into a search field. We may naively want to execute an API request with each key stroke, but that would both flood our API with many more requests than are necessary, and the responses from those requests may come back in unpredictable order. A better approach would be to debounce the key stroke events so that we only execute an API request if the user stops typing for a brief moment.

@T(00:07:55)
The Composable Architecture comes with a debounce operator on effects specifically for this kind of functionality:

```swift
return Effect(value: .todoDelayCompleted)
  .debounce(
    id: CancelDelayId(), for: 1, scheduler: DispatchQueue.main
  )
  // .delay(for: 1, scheduler: DispatchQueue.main)
  // .eraseToEffect()
  // .cancellable(id: CancelDelayId(), cancelInFlight: true)
```

@T(00:08:37)
And everything will still work the same, and even better all of our tests will pass. We wrote some intricate tests around how the timing and cancellation worked, and the fact that those tests are still passing even though we changed the operators gives us some confidence that we didn’t break anything.

@T(00:08:44)
We must warn that Combine also defines a `debounce` operator on the `Publisher` protocol that does _not_ take a cancellation id:

```swift
.debounce(for: 1, scheduler: DispatchQueue.main)
```

@T(00:08:57)
However, this does not give us the behavior we want. This operator is debouncing the emissions of `Effect(value: .todoDelayCompleted)`, but it will only emit a single time, and so debouncing does nothing. We instead need a version of debounce that understands how the Composable Architecture works, and knows that effects are returned from actions being sent to the store.

## Controlling time

@T(00:09:23)
So this is really incredible. We not only layered on a pretty complex piece of functionality in just a single line of code, the debouncing of tapping the checkbox, but we also wrote exhaustive tests to prove very subtle properties of how that functionality works. And we were able to do it with very little work. It all happens in this nice little concise test store helper.

@T(00:09:46)
But this can be made even better. Right now it’s a bit of a bummer that we are literally waiting for time to go by in order to test debouncing.

@T(00:10:00)
Already in just these two tests we are spending a total of 3.5 seconds on waiting, and the entire test suite only takes 3.51 seconds to run!

```txt
Executed 3 tests, with 0 failures (0 unexpected) in 3.510 (3.514) seconds
```

@T(00:10:13)
That means 99.5% of the test suite time is spent waiting. Worse, if we have dozens or hundreds of these tests that time could easily add up to minutes of wasted time. Some day we may even have a feature that wants to wait minutes or hours before it executes, and testing in this way would force our test suite to wait that long in order to do its assertions.

@T(00:10:53)
And even if you are ok with waiting a bit of extra time for your tests to run, there is another reason why it’s not great to write tests like this: it completely destroys debuggability. Say you have a weird failing test that you are trying to debug. If you put a breakpoint somewhere in the code to debug, then when the code stops at that breakpoint the passage of time does not also stop. By the time you continue code execution, many seconds will have passed and you may have missed the window to understand what the heck happened in your code. However, if you control time with a scheduler you get to slowly move time forward while you debug in order to understand what exactly is happening.

@T(00:11:34)
Luckily, the Composable Architecture comes with a tool to control the flow of time so that we can instantly advance time to any moment in the future. Let’s take another look at the debounce effect in our reducer:

```swift
case .todo(index: _, action: .checkboxTapped):
  struct CancelDelayId: Hashable {}

  return Effect(value: .todoDelayCompleted)
    .debounce(
      id: CancelDelayId(), for: 1, scheduler: DispatchQueue.main
    )
```

@T(00:11:51)
Notice that we are using `DispatchQueue.main` as a scheduler. This is another one of those sneaky dependencies, much like the `UUID`  initializer. It seems innocent at first, but it wreaks havoc on our ability to test and control code. It turns out we can replace this scheduler with something that we control, but sadly the Combine framework does not come with this out of the box, so we have provided it in the Composable Architecture.

@T(00:12:19)
In order to understand the tool we need to give a little background on schedulers. If we look at the types that `.debounce` expects we see a few interesting things:

```swift
.debounce(
  id: <#AnyHashable#>,
  for: <#SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>,
  scheduler: <#Scheduler#>
)
```

@T(00:12:43)
The `for` duration has to conform to a whole bunch of protocols, and the scheduler is of type `Scheduler`. `Scheduler` is a protocol in the Combine framework, and it represents a type that can describe when and how to execute a closure. Many types that ship with Foundation conform to this protocol because they can also schedule work, for example `DispatchQueue`, `RunLoop` and `OperationQueue`.

@T(00:13:13)
For example, because `DispatchQueue` conforms to `Scheduler` you can schedule some work on a dispatch queue like so:

```swift
DispatchQueue.main.schedule {
  print("DispatchQueue")
}
```

```txt
DispatchQueue
```

@T(00:13:48)
If you want schedule some work after a second you can do the following:

```swift
DispatchQueue.main.schedule(after: .init(.now() + 1)) {
  print("DispatchQueue", "delayed")
}
```

```txt
DispatchQueue
DispatchQueue delayed
```

@T(00:14:26)
The extra `.init` is needed because the conformance of `DispatchQueue` to the `Scheduler` protocol defines a new wrapper type around `DispatchTime` in order to satisfy an associated type.

@T(00:14:38)
At this point you may be asking why would we ever use this since this is already more verbose than what we could do with `DispatchQueue` directly. Well, firstly the scheduler abstraction provides more utility than just scheduling a single unit of work. You can also schedule work to be done repeatedly on an interval:

```swift
DispatchQueue.main.schedule(after: .init(.now()), interval: 1) {
  print("DispatchQueue", "timer")
}
```

@T(00:15:39)
In order for the timer to keep going we have to hold onto the cancellable it returns.

```swift
var cancellables: Set<AnyCancellable> = []

DispatchQueue.main.schedule(after: .init(.now()), interval: 1) {
  print("DispatchQueue", "timer")
}.store(in: &cancellables)
```

```txt
DispatchQueue
DispatchQueue timer
DispatchQueue delayed
DispatchQueue timer
DispatchQueue timer
DispatchQueue timer
…
```

@T(00:16:12)
This is much simpler than creating timers directly in Grand Central Dispatch, which requires a few more lines of boilerplate to get going.

@T(00:16:30)
And the reason this abstraction is powerful is that it consolidates a bunch of different ways of scheduling work, such as run loops. We can basically copy and paste the above code but replace dispatch queues with run loops:

```swift
RunLoop.main.schedule {
  print("RunLoop")
}
RunLoop.main.schedule(after: .init(Date() + 1)) {
  print("RunLoop", "delayed")
}
RunLoop.main.schedule(after: .init(Date()), interval: 1) {
  print("RunLoop", "timer")
}
.store(in: &cancellables)
```

```txt
RunLoop
DispatchQueue
DispatchQueue timer
RunLoop timer
DispatchQueue delayed
DispatchQueue timer
RunLoop delayed
DispatchQueue timer
RunLoop timer
…
```

@T(00:17:27)
And we can do the same with operation queues:

```swift
OperationQueue.main.schedule {
  print("OperationQueue")
}
OperationQueue.main.schedule(after: .init(Date() + 1)) {
  print("OperationQueue", "delayed")
}
OperationQueue.main.schedule(after: .init(Date()), interval: 1) {
  print("OperationQueue", "timer")
}
.store(in: &cancellables)
```

@T(00:17:41)
And the `Scheduler` protocol is the way Combine abstracts away the responsibility of when and how to execute a unit of work. Any Combine operator that involves time or threading takes a scheduler as an argument, including delaying, throttling, timeouts, debouncing, and more:

```swift
Just(1)
  .receive(on: <#Scheduler#>)
  .subscribe(on: <#Scheduler#>)
  .timeout(
    <#SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>,
    scheduler: <#Scheduler#>
  )
  .throttle(
    for: <#SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>,
    scheduler: <#Scheduler#>,
    latest: <#Bool#>
  )
  .debounce(
    for: <#SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>,
    scheduler: <#Scheduler#>
  )
  .delay(
    for: <#SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>,
    scheduler: <#Scheduler#>
  )
```

@T(00:18:23)
So, that’s what schedulers give us, but what they don’t give us is a way to control these things during tests. Anytime we use a `DispatchQueue`, `RunLoop` or `OperationQueue` we are hopelessly in the realm of the real world, with all of its complexities and vagaries, and we have no way to control the scheduler except for literally waiting for time to pass.

@T(00:18:48)
That’s why the Composable Architecture provides a special scheduler that can be used specifically for testing. It’s called a `TestScheduler`, and you create it based off an existing scheduler type. So if we want a test scheduler for dispatch queues we can just do:

```swift
let scheduler = DispatchQueue.testScheduler
```

@T(00:19:25)
And then we can use this scheduler just like any other scheduler, like schedule a unit of work:

```swift
scheduler.schedule {
  print("TestScheduler")
}
```

@T(00:19:40)
If we run this, nothing prints, and that's because the test scheduler does not perform any of its scheduled work unless we explicitly tell it to by calling `advance`, which will perform any work that has been scheduled for the moment.

```swift
scheduler.advance()
```

```txt
TestScheduler
```

@T(00:20:05)
And now we see things printed.

@T(00:20:17)
We can take things further by scheduling a unit of work after some delay.

```swift
scheduler.schedule(after: scheduler.now.advanced(by: 1)) {
  print("TestScheduler", "delayed")
}
```

```txt
TestScheduler
```

@T(00:20:05)
When we run this we only get `TestScheduler` printed to the console because we need to advance the scheduler again. If we pass no arguments to `advance` it will only perform work that is waiting to execute at the scheduler's exact moment, so instead we need to advance the scheduler into the future.

```swift
scheduler.advance(by: 1)
```

@T(00:21:22)
Which immediately causes two things to print:

```txt
TestScheduler
TestScheduler delayed
```

@T(00:21:30)
We can even schedule events at an interval.

```swift
scheduler.schedule(after: scheduler.now, interval: 1) {
  print("TestScheduler", "timer")
}
```

@T(00:21:55)
But nothing prints till we advance our scheduler.

```swift
scheduler.advance()
```

```txt
TestScheduler timer
```

@T(00:21:55)
This simply causes the scheduler to execute anything waiting to be executed, and in particular the timer first when it starts.

@T(00:22:02)
If we advance by a half second we will still only get one log:

```swift
scheduler.advance(by: 0.5)
```

```txt
TestScheduler timer
```

@T(00:22:09)
If we advance by a full second we will still two logs:

```swift
scheduler.advance(by: 1)
```

```txt
TestScheduler timer
TestScheduler timer
```

@T(00:22:12)
We get two. If we advance 5 seconds we will get 5 more logs:

```swift
scheduler.advance(by: 5)
```

```txt
TestScheduler timer
TestScheduler timer
TestScheduler timer
TestScheduler timer
TestScheduler timer
```

@T(00:22:16)
And if we advance time by 1,000 seconds and we’ll get a whole bunch of logs:

```swift
scheduler.advance(by: 1000)
```

```txt
…
TestScheduler timer
TestScheduler timer
TestScheduler timer
TestScheduler timer
TestScheduler timer
```

@T(00:22:24)
This is showing that we can instantly control the flow of time with this scheduler. The only way to get this many lines to print with the other timers would be to literally wait 1,000 seconds.

@T(00:22:36)
So this seems pretty promising, how do we take advantage of it in our todo app? Well, as we mentioned before, the use of `DispatchQueue.main` in our reducer is an unintended side-effect, and it must be controlled. This means we need to move it to be a dependency in our environment just like the `UUID` function.

@T(00:22:59)
We are going to call it `mainQueue` since it represents the main dispatch queue:

```swift
struct AppEnvironment {
  var mainQueue: <#???#>
  var uuid: () -> UUID
}
```

@T(00:23:07)
But what should its type be? We don’t want to use a `DispatchQueue` directly:

```swift
var mainQueue: DispatchQueue
```

@T(00:23:10)
Because then we couldn’t substitute in a test scheduler when we are in tests. We also can’t put in the `Scheduler` protocol:

```swift
var mainQueue: Scheduler
```

> Error: Protocol 'Scheduler' can only be used as a generic constraint because it has Self or associated type requirements

@T(00:23:31)
because the protocol has associated types. In the future Swift’s type system may be powerful enough to work around this limitation allowing us to do something like:

```swift
var mainQueue: Scheduler
where
  .ScheduleTimeType == DispatchQueue.SchedulerTimeType,
  .SchedulerOptions == DispatchQueue.SchedulerOptions
```

@T(00:24:13)
This would allow us to use any scheduler here, as long as its associated types match. This feature is known as existential types, and would open up a lot of possibilities.

@T(00:24:33)
However, this is not possible, so we have to turn to a more ad hoc solution. We need one of those “Any” type erasers for the `Scheduler` protocol. The standard library and various frameworks from Apple has multiple type erased wrappers, such as:

```swift
// AnyHashable
// AnyIterator
// AnyCollection
// AnySubscriber
// AnyCancellable
// AnyPublisher
// AnyView
```

@T(00:24:58)
Just to name a few. These wrappers are specifically made to deal with this existential type deficiency in the Swift type system. You use them in places where you’d like to be able to use the bare protocol.

@T(00:25:11)
So, perhaps we would hope that Combine ships with an `AnyScheduler`, because after all it has an `AnySubscriber`, `AnyPublisher` and `AnyCancellable`, but alas it does not for some reason. Fear not, the Composable Architecture ships with an `AnyScheduler` specifically for this purpose, so we can do:

```swift
var mainQueue: AnyScheduler<
  DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions
>
// var mainQueue: Scheduler
// where
//   .ScheduleTimeType == DispatchQueue.SchedulerTimeType,
//   .SchedulerOptions == DispatchQueue.SchedulerOptions
```

@T(00:25:44)
Note the similarity between what we wrote and what a theoretical Swift type feature could provide.

@T(00:25:47)
So this is saying we can stick any scheduler in for `mainQueue` as long as it has the same time type and options as `DispatchQueue`. In particular, we can use an actual, honest `DispatchQueue` or we can use a `TestScheduler`.

@T(00:26:15)
This code is a bit verbose right now, so that’s why we have also provided a convenience type alias that can hide these generics. It’s called `AnySchedulerOf`, and it’s generic over a single scheduler type, and then under the hood it takes the time and option associated types from the scheduler:

```swift
var mainQueue: AnySchedulerOf<DispatchQueue>
```

@T(00:26:31)
Then, in our reducer, we should stop reaching out to the global, uncontrollable main dispatch queue, and instead use the main queue scheduler that is in our environment:

```swift
case .todo(index: _, action: .checkboxTapped):
  struct CancelDelayId: Hashable {}

  return Effect(value: .todoDelayCompleted)
    .debounce(
      id: CancelDelayId(), for: 1, scheduler: environment.mainQueue
    )
```

@T(00:26:44)
Next we need to fix our SwiftUI preview by updating its environment to provide a main scheduler. For the purpose of a preview it is acceptable to use the live dispatch queue:

```swift
environment: AppEnvironment(
  mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
  uuid: UUID.init
)
```

@T(00:27:22)
And we need to do the same in the scene delegate:

```swift
environment: AppEnvironment(
  mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
  uuid: UUID.init
)
```

@T(00:27:40)
The app builds and it should run and behave exactly as before.

@T(00:27:46)
But the real fun is over in the tests. Tests aren’t building right now because their environments have not been provided with a scheduler. We could pass a test scheduler directly:

```swift
environment: AppEnvironment(
  mainQueue: DispatchQueue.testScheduler.eraseToAnyScheduler(),
  uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
)
```

@T(00:28:14)
But this isn't quite what we want to do. By immediately erasing the test scheduler we are preventing ourselves from accessing the methods that allow us to advance it.

@T(00:28:32)
Instead what we need to do is hold onto the test scheduler before erasing it on its way into the environment.

```swift
let scheduler = TestScheduler.dispatchQueue

let store = TestStore(
  initialState: AppState(todos: todos),
  reducer: appReducer,
  environment: AppEnvironment(
    mainQueue: scheduler.eraseToAnyScheduler(),
    uuid: {
      UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
    }
  )
)
```

@T(00:28:48)
We can even extract this scheduler to be a property of the test case and have access to it in every test.

```swift
class TodosTests: XCTestCase {
  let scheduler = TestScheduler.dispatchQueue
```

@T(00:29:08)
If we run our tests, any that depend on waiting will fail, because we're still waiting using `XCTWaiter` and _not_ by advancing our scheduler.

@T(00:29:22)
In our first test we waited for 1 second so that we could have the effect emit its value back into the system. We no longer need to literally wait for a second, instead we can tell the scheduler to advance a second, and we can do that work in a `.do` block:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    // _ = XCTWaiter.wait(
    //   for: [self.expectation(description: "wait")], timeout: 1
    // )
    self.scheduler.advance(by: 1)
  },
  .receive(.todoDelayCompleted)
)
```

@T(00:29:41)
In our second test we can make a similar change:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    // _ = XCTWaiter.wait(
    //   for: [self.expectation(description: "wait")], timeout: 1
    // )
    self.scheduler.advance(by: 1)
  },
  .receive(.todoDelayCompleted) {
    $0.todos.swap(0, 1)
  }
)
```

@T(00:29:46)
In the third test we were making sure that effects were actually debounced by cancelling a currently inflight effect. To do that we tapped the checkbox, waited half a second, and then tapped the checkbox again, and then waited another second.

Well, instead of literally waiting we can just advance the scheduler:

```swift
store.assert(
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = true
  },
  .do {
    // _ = XCTWaiter.wait(
    //   for: [self.expectation(description: "wait")], timeout: 0.5
    // )
    self.scheduler.advance(by: 0.5)
  },
  .send(.todo(index: 0, action: .checkboxTapped)) {
    $0.todos[0].isComplete = false
  },
  .do {
    // _ = XCTWaiter.wait(
    //   for: [self.expectation(description: "wait")], timeout: 1
    // )
    self.scheduler.advance(by: 1)
  },
  .receive(.todoDelayCompleted)
)
```

@T(00:29:55)
And now when we run tests they all still pass, but it takes only a fraction of a second to complete:

```
Executed 3 tests, with 0 failures (0 unexpected) in 0.007 (0.026) seconds
```

@T(00:30:00)
Remember that previously when we were doing actual waiting the test suite took over 3.5 seconds to run because we were waiting in real time. Now the tests are over 600 times faster. And if we needed to test an effect that wanted to wait an hour before executing we could simply advance the scheduler forward 3,600 seconds and be done with it.

## What’s the point?

@T(00:30:41)
So, that’s the Composable Architecture in a nutshell. We covered a ton of material in the past few episodes, including breaking down a complex feature into smaller parts, in particular using the `forEach` operator on reducers, using the environment to control dependencies to the outside work, using effects to communicate with the outside world, and then bringing it all together to write extensive tests of our feature.

@T(00:31:10)
But, would you believe there is even more? There is so much packed into the Composable Architecture repo, and so we’d love if everyone [checked it out](https://github.com/pointfreeco/swift-composable-architecture). There are even more tools for breaking down complex applications into smaller, more understandable units, and there are even more fancy effects tricks.

@T(00:31:26)
It’s right about now on Point-Free that we like to ask ourselves the all important question: “what’s the point?”, because usually we are talking about abstract things and we like to take a moment to bring things back down to earth and show why it’s worth knowing these things. But this time there’s really no need. We have shown how quickly we can build a demo application using the Composable Architecture, and showed that we could even start to layer on some pretty complex logic, all the while not sacrificing testability. In fact, testing remained easy, succinct and ergonomic the whole time.

@T(00:32:10)
There is still a ton more we could cover about the Composable Architecture, but we’re going to end the episode here, and next time we will cover some topics that not about architecture. It’s been awhile since we’ve covered topics not related to the Composable Architecture, and we’re really excited about it.

@T(00:32:32)
Until next time…
