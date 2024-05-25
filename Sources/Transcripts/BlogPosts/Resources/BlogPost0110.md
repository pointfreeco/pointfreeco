Swift 5.5 brought first class support for concurrency to the language, including lightweight syntax
for describing when functions and methods need to perform async work, a new data type for
isolating mutable data, and all new APIs for performing non-blocking asynchronous work. This made it
far easier to write async code than ever before, but it also made testing asynchronous code quite
a bit more complicated.

Join us for a quick overview of what tools Swift gives us today for testing asynchronous code, as
well as examples of how these tools can fall short, and then how to fix them.

!> [note]: This blog post is a brief recap of a [series of episodes](https://www.pointfree.co/collections/concurrency/testing-async-code) on Point-Free that goes very deep into how to reliably test async code in Swift.  

## Async testing tools of today

The primary tool for testing async code today is XCTest's support for async test cases. Simply mark
your test method as `async` and then you are free to perform any async work you want:

```swift
class FeatureTests: XCTestCase {
  func testBasics() async {
    …
  }
}
```

This makes it easy to invoke an async function or method and then assert on what changed after
the work finished.

For example, suppose we had a very simple observable object for encapsulating a number that could
be incremented and decremented from the UI, as well as the ability to fetch a fact about the 
number. The mechanism for fetching the fact should be hidden behind some kind of interface, like
a protocol, but for now we will pass it as an explicit closure to the model.

Further, to make things interesting, we will also manage a piece of boolean state that tracks
whether or not the fact is currently loading so that we can display a progress indicator in the
view: 

```swift
@MainActor
class FeatureModel: ObservableObject {
  @Published var count = 0
  @Published var fact: String?
  @Published var isLoadingFact = false
  
  // Can hide this closure behind an interface and use some sort of dependency
  // injection to provide it.
  let numberFact: (Int) async throws -> String
  
  init(numberFact: @escaping (Int) async throws -> String) {
    self.numberFact = numberFact
  }
  
  func getFactButtonTapped() async {
    self.isLoadingFact = true 
    defer { self.isLoadingFact = false }
    do {
      self.fact = try await self.numberFact(self.count)
    } catch {
      // TODO: Handle error
    } 
  }
}
```

This model seems simple enough, yet it can be surprisingly tricky to test all aspects of it.

The easiest part of the model to test is that the `fact` state is populated eventually after the 
"Get fact" button is tapped. That can be done simply thanks to the support for async in tests, and 
by using some kind of "mock" version of the number fact closure that returns a response immediately
rather than making a network request:

```swift
@MainActor
func testGetFact() async {
  let model = FeatureModel(numberFact: { number in 
    "\(number) is a good number!" 
  })
  
  await model.getFactButtonTapped()
  XCAssertEqual(model.fact, "0 is a good number!")
}
```

This test will pass 100% of the time, and do so very quickly. And that's great!

What's not so great is that it's not really possible to test that the `isLoadingFact` state flips
from `false` to `true` and then back to `false`. At least when using the tools that Swift gives us
today for testing async code.

First of all, naively asserting on `isLoadingFact` right after invoking `getFactButtonTapped` can't
possibly work because the async work has already finished by that point:

```swift
await model.getFactButtonTapped()
XCTAssertEqual(model.isLoadingFact, true)  // ❌
XCAssertEqual(model.fact, "0 is a good number!")
XCTAssertEqual(model.isLoadingFact, false)
```

So what we need to do is run `getFactButtonTapped` in an unstructured `Task` so that it can run
in parallel with the rest of the test. That should allow us to wiggle ourselves in between the
moment the boolean state flips to `true` and then `false`:

```swift
let task = Task { await model.getFactButtonTapped() }
XCTAssertEqual(model.isLoadingFact, true)  // ❌
await task.value
XCAssertEqual(model.fact, "0 is a good number!")
XCTAssertEqual(model.isLoadingFact, false)
```

However this fails the vast majority of times. Over 99% of the time. It seems that _every_ once in
awhile the `Task` starts up fast enough to flip the boolean to `true`, but that is a rare exception
rather than the rule.

What we really need to do is wait a _little_ bit of time for the `Task` to start executing its code,
but not _too_ much time so that it finishes. Perhaps a single `Task.yield` will help:

```swift
let task = Task { await model.getFactButtonTapped() }
await Task.yield()
XCTAssertEqual(model.isLoadingFact, true)  // ❌
await task.value
XCAssertEqual(model.fact, "0 is a good number!")
XCTAssertEqual(model.isLoadingFact, false)
``` 

Unfortunately this fails too, and it does so the vast majority of the time.

And this is only one small example of async code that is difficult to test. If your async code
tries to implement cancellation, or makes use of time-based asynchrony (such as clocks), or
uses async sequences, or any number of things, then you will come across similar test failures that
are essentially impossible to fix. You may be able to even get the tests to seemingly pass 
consistently, but almost alwasy if you run them enough times (thousands or millions of times), you
_will_ eventually get a test failure, and that breeds uncertainty in your test suite.

## Looking to Async Algorithms for inspiration

So, what are we to do?

The problem with testing this kind of async code in Swift is that we have no way to predict how
the runtime will schedule and execute work. And that is fine when running the code in production,
but we don't need that complexity for tests. Most tests are verifying a very simple state machine
of actions: the user performs a few actions, one after another, and we assert at each step of the
way how the state of our feature changes.

In such situations we don't need the full power of a complex scheduling machine that manages a small
pool of threads. It would be completely sufficient to serialize all async work to a single thread.
That does not mean that multiple concurrent tasks are not able to interleave. Suspension of async
tasks can still work as you expect, but all actual work is run serially on a single thread.

And interestingly, there is even a precendent for this in one of Apple's open source Swift 
libraries! The [Async Algorithms][async-algos-gh] package comes with an 
[`AsyncSequenceValidation`][async-algos-validate-library] library with tools specifically designed
to make testing async code a deterministic process. It needs this tool in order to write reliable,
deterministic tests for its various operators, such as `debounce`, `throttle`, and more.

The way it accomplishes this is by [overriding the global enqueue hook][async-algos-hook-override] 
that Swift uses when new asynchronous tasks are created. And that hook is publicly exposed to us
from Swift's actual C++ codebase, which we can see by looking at its [headers][swift-global-hook]. 
The async algorithms package uses that global hook to serialize all async work to a single queue
rather than let the test be susceptible to the vagaries of the global concurrent executor, allowing
it to write tests that pass deterministically, 100% of the time.

## How to test async code reliably?

And so if Apple can write tests like this, why can't we?

Well, now we can thanks to a new package that we have open sourced called [Concurrency 
Extras][concurrency-extras-gh]. It provides a tool, [`withMainSerialExecutor`][wmse-docs], 
that temporarily alters the manner in which Swift enqueues asynchronous work in order to serialize 
it to the main thread. This allows you to test every facet of the async code, including what happens 
between each suspension point, in a manner that is 100% deterministic.

For example, the previous test we wrote, which passed sometimes but failed most of the times, can
now be written in a way that passes 100% of the time:

```swift
func testGetFact() async {
  await withMainSerialExecutor {
    let model = FeatureModel(numberFact: { number in
      await Task.yield()
      return "\(number) is a good number!" 
    })
    
    let task = Task { await model.getFactButtonTapped() }
    await Task.yield()
    XCTAssertEqual(model.isLoadingFact, true)  // ✅
    await task.value
    XCAssertEqual(model.fact, "0 is a good number!")  // ✅
    XCTAssertEqual(model.isLoadingFact, false)  // ✅
  }
}
```

You can even override the `invokeTest` method in your test case to force every test to run on the 
main serial executor:

```swift
override func invokeTest() {
  withMainSerialExecutor {
    super.invokeTest()
  }
}
```

This tool allows you to finally write tests against complex and subtle async code that you can be
confident in. No more seeing mysterious test failures on CI and wasting hours of CI time re-running
tests or hours of developer time investigating if they are true errors or simply flakiness in the
async scheduling.

## Testing reality

Note that by using `withMainSerialExecutor` you are technically making your tests behave in a manner
that is different from how they would run in production. However, many tests written on a day-to-day
basis do not invoke the full-blown vagaries of concurrency. Instead, tests often want to assert that
when some user action happens, an async unit of work is executed, and that causes some state to
change. Such tests should be written in a way that is 100% deterministic. And even Apple agrees
in their [documentation of `AsyncSequenceValidation`][async-validation-md] where they justify
why they think their manner of testing async sequences truly does test reality even though they are
altering the runtime that schedules async work (emphasis ours):

> Testing is a critical area of focus for any package to make it robust, catch bugs, and explain the 
expected behaviors in a documented manner. Testing things that are asynchronous can be difficult, 
testing things that are asynchronous multiple times can be even more difficult.
> 
> Types that implement AsyncSequence **can often be described in deterministic actions given 
particular inputs**. For the inputs, the events can be described as a discrete set: values, errors 
being thrown, the terminal state of returning a nil value from the iterator, or advancing in time 
and not doing anything. Likewise, the expected output has a discrete set of events: values, errors 
being caught, the terminal state of receiving a nil value from the iterator, or advancing in time 
and not doing anything.

Just as async sequences can often be described with a determinstic sequences of inputs that lead to
a deterministic sequence of outputs, the same is true of user actions in an application. And so we
too feel that many of the tests we write on a daily basis can be run inside `withMainSerialExecutor`
and that we are not weakening the strength of those tests in the least.

However, if your code has truly complex asynchronous and concurrent operations, then it may be handy 
to write two sets of tests: one set that targets the main executor (using `withMainSerialExecutor`) 
so that you can deterministically assert how the core system behaves, and then another set that 
targets the default, global executor. The latter tests will probably need to make weaker assertions 
due to non-determinism, but can still assert on some things.

## Try it yourself

If you have a flakey suite of async tests, or you just don't write tests against async code because
it is such a pain, be sure to check out our [Concurrency Extras][concurrency-extras-gh] package
today!

[wmse-docs]: https://pointfreeco.github.io/swift-concurrency-extras/main/documentation/concurrencyextras/withmainserialexecutor(operation:)-79jpc
[concurrency-extras-blog]: /blog/posts/110-reliably-testing-async-code-in-swift
[concurrency-extras-gh]: http://github.com/pointfreeco/swift-concurrency-extras
[async-algos-gh]: https://github.com/apple/swift-async-algorithms
[async-algos-validate-library]: https://github.com/apple/swift-async-algorithms/tree/07a0c1ee08e90dd15b05d45a3ead10929c0b7ec5/Sources/AsyncSequenceValidation
[async-validation-md]: https://github.com/apple/swift-async-algorithms/blob/07a0c1ee08e90dd15b05d45a3ead10929c0b7ec5/Sources/AsyncSequenceValidation/AsyncSequenceValidation.docc/AsyncSequenceValidation.md
[async-algos-hook-override]: https://github.com/apple/swift-async-algorithms/blob/07a0c1ee08e90dd15b05d45a3ead10929c0b7ec5/Sources/AsyncSequenceValidation/Test.swift#L319-L321
[swift-global-hook]: https://github.com/apple/swift/blob/e89de6e7e0952c3d0485cc07129ec17f2763c12f/include/swift/Runtime/Concurrency.h#L734-L738
