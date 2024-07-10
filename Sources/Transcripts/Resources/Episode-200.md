## Introduction

@T(00:00:05)
For the past 10 weeks we have dived deep into concurrency in Swift.

@T(00:00:09)
First, we spent 5 weeks understanding concurrency from past to present to future, starting with threads and queues, and ending with Swift’s new concurrency tools. The new tools were modeled on two important ideas: structured concurrency, which allows you to write asynchronous and concurrent code in a style that mostly looks like regular synchronous code; and cooperation, which allows any number of tasks to make use of a smaller thread pool in a responsible and cooperative manner.

@T(00:00:35)
Then we spent another 5 weeks applying all of those ideas to our library, the Composable Architecture, in order to understand how the new concurrency tools could improve the library. We saw that not only could they greatly improve how we construct effects, but it even improves how we tie the lifetime of effects to the lifetime of views, all the while never losing out on testability. Someday, hopefully in the near future, we may even be able to further disentangle the library from Combine, and there will be even bigger gains to be had when that happens.

@T(00:01:03)
But in the meantime, this week we are finally releasing all of these new concurrency tools in the library, and it is by far the largest update we have made to the library since it was released over 2 years ago, which coincidentally was exactly 100 episodes ago.

@T(00:01:18)
We want to show off some concrete, real world uses of the Composable Architecture that greatly benefit from these changes. We will take a look at a case study in the repo with a complex effect, then we’ll take a look at a demo application in the repo with some complex dependencies, and finally we will take a look at our open-source iOS word game that is 100% built in the Composable Architecture.

@T(00:01:49)
In each of these cases we get to remove layers of complexity and indirection, and finally get to write nuanced effect code in a more natural way that reads from top-to-bottom.

@T(00:02:00)
So, let’s get started.

## SwiftUI Case Study: Animation

@T(00:02:03)
I am currently in the Composable Architecture workspace from the library’s repo, which includes a whole bunch of case studies and demo applications, each built with the library and each with an extensive test suite. We are also on the most recent release of the library, which is [version 0.39](https://github.com/pointfreeco/swift-composable-architecture/releases/0.39.0) and has all of the new concurrency tools, including some things that we didn’t get a chance to talk about in episodes.

@T(00:02:28)
Let’s begin with a fun example. There’s an animation case study that demonstrates how to send actions from an effect with an animation. We can run it in the preview.

@T(00:02:41)
And see that we can fling around the dot, increase and decrease the size of the dot, and have the dot cycle between a bunch of colors. We can even reset its state, which first brings up an alert, and only if we confirm does the dot reset to its initial state, cancelling any inflight effects happening.

@T(00:03:08)
Currently this case study is fully updated to use Swift’s fancy concurrency tools, but let’s quickly rewind the code back to when it was still using Combine. We will revert this file and its tests to [just before the 0.39.0 release](https://github.com/pointfreeco/swift-composable-architecture/tree/3f5f3c850f623714a91900e3b3f56755d5dce111):

```bash
$ git checkout 3f5f3c85 -- \
  Examples/CaseStudies/SwiftUICaseStudies/01-GettingStarted-Animations.swift \
  Examples/CaseStudies/SwiftUICaseStudiesTests/01-GettingStarted-AnimationsTests.swift
```

@T(00:03:52)
One interesting thing already is that the old Combine code still compiles and tests still pass. Although the concurrency update to the library is the biggest update we’ve had to the library since it’s release over 2 years ago, it is still fully backwards compatible, so everyone can incrementally adopt it as they see fit.

@T(00:04:17)
The part we are most interested in is what happens when the “Rainbow” button is tapped. Currently the logic for the rainbow animation is handled in the reducer, where we return an effect by calling out to some function called `keyFrames`:

```swift
case .rainbowButtonTapped:
  return .keyFrames(
    values: [Color.red, .blue, .green, .orange, …]
      .map { (output: .setColor($0), duration: 1) },
    scheduler: environment.mainQueue.animation(.linear)
  )
  .cancellable(id: CancelID.self)
```

@T(00:04:32)
We do this because the effect for cycling over a bunch of colors to send actions in the store in a staggered fashion is surprisingly complicated in Combine:

```swift
extension Effect where Failure == Never {
  public static func keyFrames<S: Scheduler>(
    values: [
      (
        output: Output,
        duration: S.SchedulerTimeType.Stride
      )
    ],
    scheduler: S
  ) -> Self {
    .concatenate(
      values
        .enumerated()
        .map { index, animationState in
          index == 0
            ? Effect(value: animationState.output)
            : Just(animationState.output)
              .delay(
                for: values[index - 1].duration,
                scheduler: scheduler
              )
              .eraseToEffect()
        }
    )
  }
}
```

@T(00:04:49)
We start by constructing a `.concatenate` effect, which allows you to transform a collection of effects into a single effect, where each one is run after the previous finishes:

```swift
.concatenate(
  …
)
```

@T(00:05:00)
Then we want to transform the values we are “key framing” in order to turn them into the effects that will be concatenated. But, we first need to enumerate those values because we do not want the very first color to have a delay, it should animate immediately:

```swift
values
  .enumerated()
  .map { index, animationState in
    …
  }
```

@T(00:05:18)
Once we have the `index` of the value as well as the value we want to send into the system, we can check if we are on the first index, if so we just synchronously send that value through, otherwise we construct an effect that emits the value after a small delay, but we also have to be sure to erase it to the `Effect` type:

```swift
.map { index, animationState in
  index == 0
    ? Effect(value: animationState.output)
    : Just(animationState.output)
      .delay(
        for: values[index - 1].duration,
        scheduler: scheduler
      )
      .eraseToEffect()
}
```

@T(00:05:39)
This code gets the job done, but it is intense for something that should be simple. It’s definitely a lot better than how one would construct these kinds of things before we had Combine, such as using `DispatchQueue`s, but it’s still a lot more verbose and obtuse than how the equivalent code could look in a world where we have structured concurrency.

@T(00:05:58)
Well, luckily we now live in the world of structured concurrency, so let’s make use of it. We can start by return a `.run` effect, which gives us an asynchronous context to operate in as well as a value that can be used to send actions back into the system:

```swift
case .rainbowButtonTapped:
  return .run { send in
  }
}
```

@T(00:06:30)
This already compiles, but it just represents an effect that doesn’t send any actions and immediately completes.

@T(00:06:43)
We can start by looping over all the colors we want to cycle through, but this time we can just use a simple `for` loop directly on the array of colors:

```swift
for color in [Color.red, .blue, .green, .orange, …] {
}
```

@T(00:06:54)
Then we can immediately send the color into the system, with an animation:

```swift
send(.setColor(color), animation: .linear)
```

@T(00:07:17)
Further, in order for this to compile we need to also `await` this statement because actions must be sent on the main thread, and hence we need to serialize to the main actor:

```swift
await send(.setColor(color), animation: .linear)
```

@T(00:07:29)
It’s pretty amazing that the compiler is keeping us in check when we access an API in the library that requires the main thread. Previously, before integrating Swift’s concurrency tools, it was our responsibility to make sure effect actions were sent back on the main thread. There was no compile-level enforcement of this fact, it’s just something we needed to know, either by experience or by meticulously reading the documentation.

@T(00:08:02)
Right after sending that action we can sleep for one second to represent that we want to wait a bit before moving onto the next color:

```swift
try await environment.mainQueue.sleep(for: 1)
```

@T(00:08:39)
And amazingly that’s it. All that is left is to make the whole effect cancellable so that we can cancel it later:

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

@T(00:08:55)
The effect is so short and simple that it’s no longer necessary to extract it into its own function. It’s really just 3 significant lines of code, whereas the previous effect had about 12 significant lines, and was a lot more indirect, and did not read linearly from top-to-bottom.

@T(00:09:24)
Now one weird thing we are seeing here is a warning:

> Warning: Non-sendable type 'Animation?' passed in call to main actor-isolated function cannot cross actor boundary

@T(00:09:27)
Apparently the `Animation` type from SwiftUI does not conform to the `Sendable` protocol, even though it is a seemingly simple value type.

@T(00:09:36)
Hopefully this is just an oversight right now, and will be fixed in a future Xcode 14 beta, but for now we can just ignore this warning by importing SwiftUI with the `@preconcurrency` directive:

```swift
@preconcurrency import SwiftUI
```

@T(00:09:51)
That gets rid of the warning.

@T(00:09:55)
So this is looking pretty amazing already, but the best part is that the testability of this feature is not hurt at all by using these fancy new concurrency tools.

@T(00:10:04)
If we run tests right now.

@T(00:10:05)
Well, OK, tests do fail. But that’s only because we are now making use of Swift’s new concurrency tools, but the test as written now is tuned specifically for Combine effects, not concurrency effects. The way we allow ourselves to test concurrency effects is to make the test suite `@MainActor` and the test function `async`:

```swift
@MainActor
class AnimationTests: XCTestCase {
  func testRainbow() async {
    …
  }

  func testReset() async {
    …
  }
}
```

@T(00:10:39)
Then we get a bunch of compiler errors because any place we send an action, receive an action or advance the scheduler, we must now await:

```swift
await store.send(…)
…
await store.receive(…)
…
await mainQueue.advance(…)
```

@T(00:11:14)
Awaiting for received actions and scheduler advancements is something we discussed in depth in our previous episodes, but awaiting to send an action is new.

@T(00:11:28)
This await represents the time it takes for the action to be sent, and for the resulting effect to start up. Due to the intricacies and complexities of how concurrent code runs in Swift, we have no guarantees on when exactly a new asynchronous context will begin, and so we do our best to suspend until this happens. This can be handy for asserting on what happens in `fireAndForget` effects after sending an action.

## Demo: Speech Recognition

@T(00:11:54)
So already we are seeing that Swift’s concurrency tools mixed in with the Composable Architecture allow you to write complex asynchronous logic that is still 100% testable.

@T(00:12:16)
Let’s move onto another example in the repo. There’s a demo application called “Speech Recognition” that shows how to interface with a complex Apple framework in order to record audio and live transcribe the speech into text that is shown on the screen.

@T(00:12:34)
We can give it a spin in the simulator to see what it’s all about.

@T(00:13:02)
Currently this demo application has been completely refactored to make use of all of Swift’s fancy new concurrency tools, but let’s turn back time in order to see what the demo looked like when built with Combine:

```bash
$ git checkout 3f5f3c85 -- Examples/SpeechRecognition
```

@T(00:13:32)
Before jumping straight to the domain, reducer and view for the feature, let’s look at something that the animation case study did not need: a dependency. Because this demo needs to make use of Apple’s Speech framework for transcribing audio, and because we want our code to remain testable, we model this dependency so that we can take control over it rather than it having control over us.

@T(00:13:52)
We do this by introducing a lightweight struct to define the interface of endpoints we need to interface with in Apple’s framework:

```swift
struct SpeechClient {
  var finishTask: () -> Effect<Never, Never>
  var requestAuthorization: () -> Effect<
    SFSpeechRecognizerAuthorizationStatus, Never
  >
  var startTask: (SFSpeechAudioBufferRecognitionRequest)
    -> Effect<SpeechRecognitionResult, Error>

  enum Error: Swift.Error, Equatable {
    case taskError
    case couldntStartAudioEngine
    case couldntConfigureAudioSession
  }
}
```

@T(00:14:01)
This includes starting a new speech recognition task, finishing the task, as well as asking for authorization.

@T(00:14:07)
Note that all of these endpoints return the `Effect` type the Composable Architecture vends, which means this dependency must depend on the Composable Architecture. This also means you have to build our library just to build this lightweight struct, and if you wanted to share this dependency with another application, one that isn’t using the Composable Architecture, then it would be a little awkward to deal with these `Effect` values.

@T(00:14:30)
Once we convert this to async/await we will be able to rely purely on Swift constructs, and will not need to import and build the library just to make use of this little dependency, which will be awesome.

@T(00:14:40)
There are also a few implementations of this interface, such as the live and “unimplemented” implementations. We will be looking at those in detail soon, but just know that the live implementation is what you use when running the app in the simulator or on an actual device, and the unimplemented one is what you use in tests in order to exhaustively prove that your test is exercising what you think it is.

@T(00:15:00)
Let’s now hop over to the actual feature code. Up top we have the domain. This includes the state, which has fields for things like whether an alert is showing or not, the current recording status, as well as the text that has been transcribed so far.

@T(00:15:16)
The actions include things you can do in the UI, such as tapping the record button or dismissing the alert, as well as action that effects use to feed data back into the system, such as a speech recognition result or authorization status.

@T(00:15:29)
The environment contains a main queue scheduler, because the speech recognition effect can send actions on any thread, so we have to get them back to the main thread, and the speech client dependency we looked at a moment ago. Once we convert this over to async/await we will be able to get rid of the main queue dependency entirely because we are only using it to send data to the main thread, and `@MainActor` takes care of that for us.

@T(00:15:50)
Then we have the reducer, which implements the actual feature’s logic. We’re really only interested in the parts of the logic that deal with effects, so let’s look at just those actions.

@T(00:15:58)
For example, when the record button is tapped:

```swift
case .recordButtonTapped:
  state.isRecording.toggle()
  if state.isRecording {
    return environment.speechClient.requestAuthorization()
      .receive(on: environment.mainQueue)
      .eraseToEffect(
        AppAction
          .speechRecognizerAuthorizationStatusResponse
      )
  } else {
    return environment.speechClient.finishTask()
      .fireAndForget()
  }
```

@T(00:16:01)
We toggle the `isRecording` state and if we are now recording, we ask for authorization, and otherwise we finish the task since we are stopping the recording.

@T(00:16:10)
Then, down below a bit, we have the `speechRecognizerAuthorizationStatusResponse` action, which is sent once the user approves or denies our request for recording access:

```swift
case let .speechRecognizerAuthorizationStatusResponse(
  status
):
  …
```

@T(00:16:17)
We do a few things depending on the authorization status. If for some reason we get back `.notDetermined`, which really shouldn’t happen, we can show an alert asking the user to try again:

```swift
case .notDetermined:
  state.alert = AlertState(
    title: TextState("Try again.")
  )
  return .none
```

@T(00:16:27)
If the user denied us we can show an alert letting the user know we really do need access in order to transcribe speech:

```swift
case .denied:
  state.alert = AlertState(
    title: TextState(
      """
      You denied access to speech recognition. This \
      app needs access to transcribe your speech.
      """
    )
  )
  return .none
```

@T(00:16:35)
If the status is “restricted” it means that due to parental controls on the device they can’t give authorization even if they wanted to:

```swift
case .restricted:
  state.alert = AlertState(
    title: TextState(
      """
      Your device does not allow speech recognition.
      """
    )
  )
  return .none
```

@T(00:16:44)
And finally, if they authorized us, then we can start the recording:

```swift
case .authorized:
  let request = SFSpeechAudioBufferRecognitionRequest()
  request.shouldReportPartialResults = true
  request.requiresOnDeviceRecognition = false
  return environment.speechClient.startTask(request)
    .map(\.bestTranscription.formattedString)
    .animation()
    .catchToEffect(AppAction.speech)
```

@T(00:16:47)
Starting the recording causes a long-living effect to fire up, the `startTask` effect, which sends a stream of events back into the system to let us know when Apple’s framework delivered a new speech result. We accept those actions in the `.speech` case of the action enum:

```swift
case let .speech(.success(result)):
  state.transcribedText =
    result.bestTranscription.formattedString
  return .none
```

@T(00:17:09)
Here we mutate state to have the newest transcribed text.

@T(00:17:12)
Next we have the view, which isn’t anything too special. We just construct the view hierarchy for the view components, use the state from the view store to popular the components, and use the view store to send actions when certain events happen in the UI, such as tapping a button.

@T(00:17:26)
And then finally we have the preview. It’s pretty standard, but the cool thing here is when we construct the environment of dependencies for use in the preview we don’t use the live speech client, we instead use something called `.lorem`:

```swift
environment: AppEnvironment(
  mainQueue: .main,
  speechClient: .lorem
)
```

@T(00:17:40)
The reason for this is that Apple’s Speech framework does not work in previews.

@T(00:17:44)
You are not able to give authorization and you are not able to start up a recognition task. We don’t know if this is a bug or perhaps it is purposefully done since Xcode previews are supposed to be lightweight. But it does mean we can’t see how this interface looks when text streams in without running the app in the simulator or on an action device, which can be cumbersome.

@T(00:18:11)
Well, luckily for us we can swap in a different speech client just for previews. The `.lorem` client is one that simply streams in some “lorem ipsum” text at a rate of 3 words a second.

@T(00:18:22)
This is really cool to see because we can now see that we even use animation when new words get added to the transcript. That is a huge part of the user experience of this feature, and it would be a real bummer if we were relegated to the slow cycle of running the app on a simulator or device in order to tweak the animation.

@T(00:18:38)
So, that’s the basics of the speech demo. Let’s convert everything to use Swift’s new concurrency tools!

@T(00:18:42)
We will start with the speech client dependency. Let’s forget we have Combine, and let’s remake this interface using only Swift’s native concurrency tools. In particular, the endpoints to finish a task and request authorization can now be simple async functions:

```swift
struct SpeechClient {
  var finishTask: () async -> Void
  var requestAuthorization: () async
    -> SFSpeechRecognizerAuthorizationStatus
  …
}
```

@T(00:19:09)
The `startTask` endpoint is a little more complicated. The effect returned by this endpoint doesn’t emit just a single time, but rather emits a stream of events as the audio is being live transcribed. So, this can’t be a simple async function, but somehow needs to return a bunch of values over time.

@T(00:19:24)
We haven’t talked about this type before, but the tool to do this is called `AsyncStream`, or if you need to throw errors, `AsyncThrowingStream`:

```swift
var startTask: (SFSpeechAudioBufferRecognitionRequest)
  -> AsyncThrowingStream<
    SpeechRecognitionResult, Swift.Error
  >
```

@T(00:19:34)
Here we must use `Swift.Error` rather than the error type used below because `AsyncThrowingStream` doesn’t actually expose any APIs that would allow throwing typed errors. However, as we saw in previous episodes when we introduced the `TaskResult` type with erased errors, it turns out this isn’t a big deal in practice.

@T(00:19:52)
Now, we have made some pretty huge breaking changes to the dependency client, so we have some things to fix, but before even doing that let’s see that we no longer need to import `ComposableArchitecture` in order for this file to build.

@T(00:20:04)
So we are starting to see that we will be able to design our dependencies without any mention of the Composable Architecture library, which will be nice.

@T(00:20:11)
Now let’s start fixing the errors, first with an easy one. The “unimplemented” conformance of the interface is not compiling because we are no longer returning effects. We can use the `XCTUnimplemented` helper from our [XCTest Dynamic Overlay library](https://github.com/pointfreeco/xctest-dynamic-overlay) that helps to painlessly stub in any function such that if it is ever invoked it will cause the test suite to fail:

```swift
import XCTestDynamicOverlay

#if DEBUG
  extension SpeechClient {
    static let unimplemented = Self(
      finishTask: XCTUnimplemented(
        "\(Self.self).finishTask"
      ),
      requestAuthorization: XCTUnimplemented(
        "\(Self.self).requestAuthorization",
        placeholder: .notDetermined
      ),
      startTask: XCTUnimplemented(
        "\(Self.self).recognitionTask",
        placeholder: .finished
      )
    )
  }
#endif
```

@T(00:21:43)
By using this unimplemented speech client by default in tests we can know exactly what dependencies our feature needs in order to execute the flow we are trying to test. This can be great for catching bugs and being notified in the future when an execution flow starts using dependencies that you did not expect.

@T(00:21:57)
Next we’ve got the live implementation of the speech client. This is currently implemented by holding onto a bit of mutable state, the audio engine and recognition task, and then accessing and updating those values from within the client’s endpoints.

```swift
extension SpeechClient {
  static var live: Self {
    var audioEngine: AVAudioEngine?
    var recognitionTask: SFSpeechRecognitionTask?

    return Self(
      finishTask: {
        …
      },
      requestAuthorization: {
        …
      },
      startTask: { request in
        …
      }
    )
  }
}
```

@T(00:22:11)
For example, when finishing the task we can just spin up a fire-and-forget effect in order to stop the audio engine and task:

```swift
finishTask: {
  .fireAndForget {
    audioEngine?.stop()
    audioEngine?.inputNode.removeTap(onBus: 0)
    recognitionTask?.finish()
  }
},
```

@T(00:22:18)
Requesting authorization can just directly access the static method on `SFSpeechRecognizer`, no need to even touch the mutable variables:

```swift
requestAuthorization: {
  .future { callback in
    SFSpeechRecognizer.requestAuthorization { status in
      callback(.success(status))
    }
  }
}
```

@T(00:22:31)
And finally, the `startTask` endpoint does the real heavy lifting. It fires up an `Effect.run` since we need to send multiple actions:

```swift
startTask: { request in
  Effect.run { subscriber in
    …
  }
}
```

@T(00:22:38)
We don’t have to know about everything that is happening in this endpoint. The two most important things are that we start a recognition task and feed all of the events directly to the effect subscriber:

```swift
recognitionTask = speechRecognizer.recognitionTask(
  with: request
) { result, error in
  switch (result, error) {
  case let (.some(result), _):
    subscriber.send(SpeechRecognitionResult(result))
  case (_, .some):
    subscriber.send(completion: .failure(.taskError))
  case (.none, .none):
    fatalError(
      """
      It should not be possible to have both a nil \
      result and nil error.
      """
    )
  }
}
```

@T(00:22:51)
And we create a cancellable to hold onto all the resources we want to live for as long as the effect, and we stop the resources once we detect cancellation:

```swift
let cancellable = AnyCancellable {
  audioEngine?.stop()
  audioEngine?.inputNode.removeTap(onBus: 0)
  recognitionTask?.cancel()
}
```

@T(00:22:59)
Some of these endpoints are quite easy to convert to use Swift’s concurrency tools. For example, to finish a task we no longer need to open up a `fireAndForget` effect, we can just perform the work right in the closure:

```swift
finishTask: {
  audioEngine?.stop()
  audioEngine?.inputNode.removeTap(onBus: 0)
  recognitionTask?.finish()
}
```

@T(00:23:14)
In fact, it doesn’t seem like we are even doing async work in here now, so should we consider dropping the async annotation from this endpoint?

@T(00:23:21)
We don’t think that is the right thing to do. By making it async we make it more clear to users of the dependency that this endpoint is not meant to be used directly in the reducer, which doesn’t have an asynchronous context, and instead only inside effects.

@T(00:23:33)
Further, we should really be using actors behind these scenes of this dependency in order to isolate and serialize access to all this mutable state. In fact, if we had concurrency warnings turned on in this project we would be notified of a few spots that need attention. We aren't going to spend any time on that subject right now, but in the future we will be doing a deep dive into using actors for dependencies, and once you do that you are forced to make your dependency endpoints async since you must always suspend to access anything on an actor.

@T(00:24:01)
The `requestAuthorization` endpoint is also straightforward. We can interface with the callback-based `SFSpeechRecognizer` method by starting up an unsafe continuation:

```swift
requestAuthorization: {
  await withUnsafeContinuation { continuation in
    SFSpeechRecognizer.requestAuthorization { status in
      continuation.resume(returning: status)
    }
  }
}
```

@T(00:24:30)
And finally there’s the `startTask`. We can trade out the `Effect.run` for an `AsyncThrowingStream`, which can be constructed with a closure that takes a continuation, which can be used in a similar fashion as the subscriber:

```swift
startTask: { request in
  AsyncThrowingStream { continuation in
    …
  }
}
```

@T(00:24:43)
In this closure we can basically do all the same work, except using the continuation to send data and errors rather than the subscriber:

```swift
continuation.finish(
  throwing: SpeechClient.Error
    .couldntConfigureAudioSession
)
…
continuation.yield(SpeechRecognitionResult(result))
…
continuation.finish(
  throwing: SpeechClient.Error.taskError
)
…
continuation.finish(
  throwing: SpeechClient.Error.couldntStartAudioEngine
)
```

@T(00:25:25)
And instead of a cancellable for holding onto resources and tearing them down when the effect is cancelled, we can use the continuation’s `onTermination` property:

```swift
continuation.onTermination = { _ in
  audioEngine?.stop()
  audioEngine?.inputNode.removeTap(onBus: 0)
  recognitionTask?.cancel()
}
```

> Warning: Reference to captured var 'audioEngine' in concurrently-executing code; this is an error in Swift 6

> Warning: Reference to captured var 'recognitionTask' in concurrently-executing code; this is an error in Swift 6

@T(00:25:54)
Well, now we get a bunch of warnings. It turns out that the `onTermination` closure is marked as `@Sendable`, which greatly restricts the kinds of closures you can use. In particular, it cannot capture non-isolated mutable data or non-sendable data. We don’t actually need these variables to be mutable in the closure, so let’s capture them in an immutable fashion:

```swift
continuation.onTermination =
  { [audioEngine, recognitionTask] _ in
    …
  }
```

@T(00:26:25)
The live speech client is now compiling. The only compiler errors left are in the actual feature code. Let’s see what it takes to get it to use the new async endpoints.

@T(00:26:35)
First, let’s update the `.speech` action case to take a `TaskResult` instead of a regular `Result`, since Swift’s concurrency tools currently do not support typed errors:

```swift
enum AppAction: Equatable {
  case speech(TaskResult<SpeechRecognitionResult>)
  // case speech(
  //   Result<
  //     SpeechRecognitionResult, SpeechClient.Error
  //   >
  // )
  …
}
```

@T(00:26:49)
We can still catch specific errors in the reducer if we want, we just can’t have a type-level description of the exact kind of errors that can be thrown.

@T(00:26:57)
The first error we have is where we request authorization, and when we receive it we send an action. This can now be a simple `.task` effect:

```swift
return .task {
  .speechRecognizerAuthorizationStatusResponse(
    await environment.speechClient.requestAuthorization()
  )
}
// return environment.speechClient.requestAuthorization()
//   .receive(on: environment.mainQueue)
//   .eraseToEffect(
//     AppAction
//       .speechRecognizerAuthorizationStatusResponse
//   )
```

@T(00:27:31)
Most important thing here is that we were able to get rid of the `.receive(on:)` operator, which means we aren’t using the main queue, and we don’t need to erase to the effect type.

@T(00:27:41)
Next we have a few spots where we want to finish the speech recognition task, and that can now be done using the async/await-friendly `fireAndForget` effect:

```swift
return .fireAndForget {
  await environment.speechClient.finishTask()
}
// return environment.speechClient.finishTask()
//   .fireAndForget()
```

@T(00:27:57)
The next error is where we are trying to destructure a speech client failure into two different types so that we can show a specific alert. Now that we are dealing with a fully type erased error we have to be more explicit about the type of error:

```swift
case
  .speech(
    .failure(
      SpeechClient.Error.couldntConfigureAudioSession
    )
  ),
  .speech(
    .failure(SpeechClient.Error.couldntStartAudioEngine)
  ):
  state.alert = AlertState(
    title: TextState(
      "Problem with audio device. Please try again."
    )
  )
  return .none
```

@T(00:28:22)
Next we have the spot where we start up the speech recognition task, and send all of those results back into the system. We can do this using the new concurrency tools by opening up an `Effect.run` so that we can send multiple actions, and then performing a `for await` on the async stream in the speech client:

```swift
return .run { send in
  for try await result
  in environment.speechClient.startTask(request) {
    await send(
      .speech(
        .success(
          result.bestTranscription.formattedString
        )
      ),
      animation: .default
    )
  }
}
// return environment.speechClient.startTask(request)
//   .map(\.bestTranscription.formattedString)
//   .animation()
//   .catchToEffect(AppAction.speech)
```

@T(00:29:26)
Technically this is not a 1-1 conversion. The old code also caught any errors and bundled them up into a `Result`. We need to do the same in our `Effect.run`.

@T(00:29:35)
The closure used to construct an `Effect.run` is allowed to throw, but it will raise a runtime warning and a test-time failure if a non-cancellation error is thrown. In order to catch that error and send it back into the system we can use the `catch` trailing closure on `Effect.run`:

```swift
return .run { send in
  for try await result
  in environment.speechClient.startTask(request) {
    await send(
      .speech(.success(result)), animation: .default
    )
  }
} catch: { error, send in
  await send(.speech(.failure(error)))
}
// return environment.speechClient.startTask(request)
//   .map(\.bestTranscription.formattedString)
//   .animation()
//   .catchToEffect(AppAction.speech)
```

@T(00:30:03)
Now they are completely 1-1.

@T(00:30:05)
The `Effect.run` style is a little longer, but it’s also a lot more flexible if we needed to layer on additional logic when receiving speech results.

@T(00:30:18)
The final compiler error in this file is the preview. The `.lorem` client is no longer compiling because it’s trying to implement the speech client endpoints with Combine publishers and operators, rather than async/await and async streams.

@T(00:31:09)
First we must replace the local mutable boolean with state that is safe to mutate from asynchronous contexts. The library ships with a type called `ActorIsolated` that does just that.

```swift
let isRecording = ActorIsolated(false)
```

@T(00:31:26)
`ActorIsolated` wraps some kind of mutable state in an actor and provides endpoints for accessing and mutating that state in a serialized manner. It is most useful in tests and previews, and you will probably not reach for it often in production code.

@T(00:31:48)
In `finishTask` we toggle this state to false.

```swift
finishTask: {
  await isRecording.setValue(false)
},
```

@T(00:31:54)
The `requestAuthorization` endpoint can just immediately return a status to represent that we are authorized:

```swift
requestAuthorization: { .authorized },
```

@T(00:32:00)
And the `startTask` endpoint can create an async stream, and then create an unstructured task inside there so that we can perform an infinite loop with some sleeps:

```swift
startTask: { _ in
  AsyncThrowingStream { continuation in
    isRecording = true
    Task {
      var finalText = """
      Lorem ipsum dolor sit amet, consectetur \
      adipiscing elit, sed do eiusmod tempor \
      incididunt ut labore et dolore magna aliqua. \
      Ut enim ad minim veniam, quis nostrud \
      exercitation ullamco laboris nisi ut aliquip \
      ex ea commodo consequat. Duis aute irure \
      dolor in reprehenderit in voluptate velit \
      esse cillum dolore eu fugiat nulla pariatur. \
      Excepteur sint occaecat cupidatat non \
      proident, sunt in culpa qui officia deserunt \
      mollit anim id est laborum.
      """
      var text = ""
      while await isRecording.value {
        let word = finalText.prefix { $0 != " " }
        finalText.removeFirst(word.count)
        text += word
        if finalText.first == " " {
          finalText.removeFirst()
          text += " "
        }
        try await Task.sleep(
          nanoseconds: NSEC_PER_SEC / 3
        )
        continuation.yield(
          .init(
            bestTranscription: .init(
              formattedString: text,
              segments: []
            ),
            isFinal: false,
            transcriptions: []
          )
        )
      }
    }
  }
}
```

@T(00:32:26)
And with that everything is compiling, and if we run the demo in the preview or in the simulator everything still works just as it did before.

@T(00:32:38)
But now that we are using Swift’s structured concurrency tools, there are a few fun things we can do.

@T(00:32:43)
First of all, we are no longer using the main queue. It was only used to force the emission of an effect on the main thread, but the `Effect.task`, `Effect.run` and `Effect.fireAndForget` helpers now take care of that for us automatically. So, we can remove the main queue from our environment.

@T(00:33:09)
That will help us simplify our environments. The only time we need to introduce a scheduler into our environment is if we need to perform actual time-based asynchrony. It’s no longer necessary just to get something to execute on the main thread.

@T(00:33:22)
Next, now that our `.lorem` client is expressed as just a simple `while` loop with some sleeps on the inside, we can subtly tweak its logic. Right now the words appear at a rate of 3 words per second, which is cool because we can see how the animation actually works, but it’s also oddly robotic. In a more real world scenario the words would come in a variable cadence, where longer words take longer to say.

@T(00:33:45)
We can emulate this by defining the sleep in terms of how long the word is, as well as mix in a little bit of randomness to make it feel more organic:

```swift
try await Task.sleep(
  nanoseconds: UInt64(word.count) * NSEC_PER_MSEC * 50
    + .random(in: 0 ... (NSEC_PER_MSEC * 200))
)
```

@T(00:34:04)
Now this is looking really great.

@T(00:34:17)
And finally, now that chaining together multiple asynchronous calls is as simple as performing multiple awaits, one after another, I think we can simplify our reducer a bit.

@T(00:34:25)
Currently there is a bit of ping-ponging happening where we ask for authorization and send the status back to the system:

```swift
return .task {
  .speechRecognizerAuthorizationStatusResponse(
    await environment.speechClient
      .requestAuthorization()
  )
}
```

@T(00:34:36)
And when we receive that status, if we are authorized we start the recording:

```swift
case .authorized:
  let request = SFSpeechAudioBufferRecognitionRequest()
  request.shouldReportPartialResults = true
  request.requiresOnDeviceRecognition = false
  return .run { send in
    …
  }
```

@T(00:34:45)
It’s a bit of a bummer that these two intimately related effects are split across two actions. What if we could combine it all into one single effect so that it was clear what the order of operations was: first we request access, and then if we are granted we start recording.

@T(00:35:00)
Well, we know that we are going to need to send multiple actions in this effect, so we can start by opening up an `Effect.run`:

```swift
case .recordButtonTapped:
  state.isRecording.toggle()
  if state.isRecording {
    return .run { send in
      …
    }
```

@T(00:35:09)
The first thing we can do in this effect is request authorization, and then send that action along so that we can handle its various states:

```swift
return .run { send in
  let status = await environment.speechClient
    .requestAuthorization()
  await send(
    .speechRecognizerAuthorizationStatusResponse(status)
  )
}
```

@T(00:35:23)
But then, directly in this effect, we can check if we are authorized:

```swift
return .run { send in
  let status = await environment.speechClient
    .requestAuthorization()
  await send(
    .speechRecognizerAuthorizationStatusResponse(status)
  )

  guard status == .authorized
  else { return }
}
```

@T(00:35:33)
If we get past this guard we can immediately start recording:

```swift
let request = SFSpeechAudioBufferRecognitionRequest()
request.shouldReportPartialResults = true
request.requiresOnDeviceRecognition = false
for try await result
in environment.speechClient.startTask(request) {
  await send(
    .speech(
      .success(result.bestTranscription.formattedString)
    ),
    animation: .default
  )
}
```

@T(00:35:59)
And finally we can catch the errors so that we can send them into the system:

```swift
return .run { send in
  …
} catch: { error, send in
  await send(.speech(.failure(error)))
}
```

Now we can completely delete the effect for the authorized case when we receive the status:

```swift
case .authorized:
  return .none
```

@T(00:36:06)
And the application should behave exactly as it did before, but we’ve now combined two effects that were scattered throughout the reducer into one single effect that tells a succinct story, linearly from top-to-bottom.

@T(00:36:21)
Now, we say that the applications works exactly as before, and it certainly seems like it does by running it in the previews and simulator, but can we be sure? Luckily for us we’ve got an extensive test suite for this demo application that tests many different edge cases, so let’s see if those tests still pass.

@T(00:36:38)
Well, unfortunately there are a lot of compiler errors. That’s to be expected because we have made some substantial changes to the feature, including removing one dependency from its environment and substantially changing the other dependency to use async/await instead of Combine.

@T(00:36:52)
We can perform a bunch of very tiny updates to the test code in order to get it compiling, without significantly changing the logic of the tests, and amazingly the test suite will still pass.

@T(00:37:07)
The first thing we can do is remove all mentions of the main queue because we no longer use it.

@T(00:37:19)
Next we can refactor each spot where we override the `requestAuthorization` endpoint to simply return the status directly. No need to wrap it in an effect anymore:

```swift
store.environment.speechClient.requestAuthorization = {
  .denied
}
```

@T(00:37:42)
That already fixes quite a few compiler errors.

@T(00:37:45)
The main ones we have left are the places where we used a passthrough subject to represent the long-living effect of the speech recognition task. Since we are no longer using Combine we can’t use passthrough subjects.

@T(00:37:57)
Instead, we can use async streams and continuations. The library even comes with a helper that makes it easy to capture a stream and its continuation, side by side, making it easy to use the stream in mocked dependency endpoints while still being able to send data to the continuation:

```swift
class SpeechRecognitionTests: XCTestCase {
  let recognitionTask = AsyncThrowingStream<
    SpeechRecognitionResult, Error
  >.streamWithContinuation()
```

@T(00:38:36)
Now everywhere we were sending data to the passthrough subject, we can instead send it to the continuation:

```swift
store.environment.speechClient.finishTask = {
  self.recognitionTask.continuation.finish()
}
…
self.recognitionTask.continuation.yield(result)
…
self.recognitionTask.continuation.finish(
  throwing: SpeechClient.Error
    .couldntConfigureAudioSession
)
```

And then everywhere we were using the passthrough subject as a publisher, we can instead use the stream:

```swift
store.environment.speechClient.startTask = { _ in
  self.recognitionTask.stream
}
```

And finally there are a few failures we have to fix where previously we were using `Result` values, and now they are `TaskResult`:

```swift
store.receive(
  .speech(
    .failure(
      SpeechClient.Error.couldntConfigureAudioSession
    )
  )
) {
  …
}
…
store.receive(
  .speech(
    .failure(SpeechClient.Error.couldntStartAudioEngine)
  )
) {
  …
}
```

@T(00:39:29)
Everything is now compiling, and we did not make a single significant change to the test. We are still sending the same actions, making the same assertions on state changes, and making the same changes on received actions.

@T(00:39:40)
But sadly if we run tests, they fail.

@T(00:39:46)
But this is just because we are now using async effects, which means our tests need to be async. So, let’s mark the test class as `@MainActor` and every test as async.

@T(00:40:04)
Let’s await every single `send` and `receive` method call.

@T(00:40:20)
Now when we run tests they pass!

@T(00:40:23)
It’s hard to describe how incredible this is. We have made a significant refactor to our demo application. Not only have we completely revamped its dependency to use structured concurrency rather than Combine, and subsequently crafted all effects using `Effect.task` and `Effect.run`, but we even completely changed how the effects are structured.

@T(00:40:43)
Previously we were ping-ponging actions by firing off an effect to get the authorization status, sending that status back into the system, and then reacting to that status by kicking off a recording effect. Now that entire process is captured in just a single effect that reads clearly from top-to-bottom. And the previously written test suite passes with zero significant changes made. It’s absolutely incredible.

## isowords: Playback Effects

@T(00:41:05)
We’ve got one last showcase of the library’s new powers, and that is [isowords](https://www.isowords.xyz), our [open source](https://github.com/pointfreeco/isowords) iOS word game that is built 100% in the Composable Architecture.

@T(00:41:16)
The code base has many parts where we need to construct complex effects. Sometimes we need to run a few effects in parallel and then a few effects in sequence, one after the other. Other times we need to construct a gigantic effect that plays a sequence of user actions so that we can emulate the user doing something. This is handy for onboarding to show the user how to play the game, and is used to play back games so that users can see how certain, complex words were made, and even drives the game trailer on the App Store.

@T(00:41:48)
Let’s quickly take a look at some of these effects, and see how much simpler they got using structured concurrency instead of Combine.

@T(00:42:00)
Most of the code base has already been updated to take advantage of Swift’s structured concurrency. Dependencies have been updated to use async functions and async streams, reducers have been updated to return `Effect.task`, `Effect.run` or `Effect.fireAndForget` depending on the situation, and in my places we have been able to turn large, complex effects into simple, linear, top-to-bottom expressions of asynchronous work.

@T(00:42:28)
There are a couple of particular features we want to quickly show off to see just how massive these improvements can be.

@T(00:42:35)
First we are going to take a look at the “cube preview” feature, which holds the functionality of replaying a word on the cube. We use this feature to allow people to see how the top-scoring words on the leaderboards were found, and we have more places we’d like to use this functionality, such as showing the last word played in a multiplayer game.

@T(00:42:54)
We even have a dedicated preview app showing off this feature so that we can build, test and iterate on it without having to run the full application.

@T(00:43:18)
The bulk of the logic for this feature is in just creating a very large effect that plays a script of user actions to emulate playing a word on the cube. If we quickly revert the code to what it looked like before we updated to use structured concurrency:

```bash
$ git checkout origin/main -- Sources/CubePreview
```

@T(00:43:58)
…we will see that in the `onAppear` action we construct a large array of effects that are then concatenated at the end. So already this code does not read linearly from top-to-bottom because we have to first upfront understand that we are building an array of effects, and then at the end realize that we are concatenating those effects, as opposed to merging or something else.

@T(00:44:41)
In order to construct the array we have to use all kinds of Combine operators as well as a lot of `eraseToEffect` in order to get the effects into the right form. We even have one really strange effect that delays an `Effect.none` in order to simulate a kind of “sleep”:

```swift
Effect.none
  .delay(for: 1, scheduler: environment.mainQueue)
  .eraseToEffect(),
```

@T(00:45:02)
We do this in order to show the cube for a brief amount of time before performing the replay animation. This gets the job done, but it’s also kind of a bizarre thing to see. I think if I came across this code many months after having written it, it would take me a moment to figure out what it really means.

@T(00:45:20)
In short, this code is just hard to read.

@T(00:45:23)
So, let’s go back to what it looks like using structured concurrency:

```bash
$ git reset head .
$ git checkout .
```

@T(00:45:33)
In the structured concurrency style we can simply open up a single `Effect.run` to provide us with an asynchronous context that can be used to send any number of actions back into the system:

```swift
case .task:
  return .run {
    [move = state.moves[state.moveIndex]] send in
    …
  }
```

@T(00:45:47)
We have also upgraded to the `.task` view modifier style of kicking off an effect when the view appears, which will also give us automatic cancellation when the view goes away. Something we didn’t have in the old style, which technically causes a bug in the application where if you close a preview while it is still playing the word you continue hearing the selection sounds, even after the view has completely gone away.

@T(00:46:21)
Inside this `Effect.run` we can express the complex concatenation of a bunch of effects in a more natural manner. We can simply perform many `await`s on asynchronous work, one after the other.

@T(00:46:34)
For example, we can start by loading the current low power mode, sending it back into the system, and then sleeping for one second so that the cube sits still for a bit:

```swift
await send(
  .lowPowerModeResponse(
    await environment.lowPowerMode.start()
      .first(where: { _ in true })
      ?? false
  )
)
try await environment.mainQueue.sleep(for: .seconds(1))
```

@T(00:46:51)
And then we can loop over all the cube faces that we want to select, move the nub view to the face, press down the nub and select the cube face. Then after the loop we can un-press the nub and move the nub off the screen.

@T(00:47:11)
This effect can be read linearly from top-to-bottom. We know immediately that we are concatenating these effects because execution flow is suspended as soon as we `await` for some asynchronous work.

@T(00:47:32)
We do something similar to the cube preview feature over in the trailer feature of the codebase. We won’t go in as much detail, but hoping over to **Trailer.swift** we will see that in the `.task` action of the reducer we again construct a very large effect.

@T(00:48:02)
Taking a peek inside the effect we see that we have a nested loop for looping over each word in the trailer and then each character in each word. And then we perform a mixture of sending user actions and sleeping small amounts of time, all with animation.

@T(00:48:22)
So, already we are seeing a huge win for constructing complex effects, at least in the case of constructing an effect to emulate a sequence of user actions. This is actually a pretty common use case in the Composable Architecture, because it makes it very easy to construct rich, immersive onboarding experiences for demonstrating how to use your application.

## isowords: Game Over Effects

@T(00:48:44)
But there are other kinds of complex effects that one deals with in an application. Many times we need to make network requests, fetch data from the disk, interact with Apple frameworks, and more, and do so in subtle and nuanced ways. For example, some of the work may be able to run in parallel, and other work may need to wait until some other work finishes before it should start.

@T(00:49:07)
We have an interesting example of this in our game over feature. It’s the screen that shows when a game completes, and there is a lot that needs to happen on this screen. We have a dedicated module for this feature, and even a preview application target so that we can run just this one feature in the simulator.

@T(00:49:46)
Let’s quickly revert the code to see what the previous, Combine-based code looks like:

```bash
$ git checkout origin/main — Sources/GameOverFeature
```

@T(00:50:03)
We again have an `onAppear` action so that we can perform all of this logic as soon as the game over screen appears. And there is a lot in here.

@T(00:50:10)
We first do a little bit of logic to check if we should even show the game over screen. If no points were scored we can skip it because there’s nothing interesting to show, unless the game is what we call a “demo game”, which is the term we use for games played in the App Clip. Then we do want to show game over because it gives important information on how to download the full version of the game.

@T(00:50:40)
Then we have some logic to figure out how to submit the score to the leaderboards. If they are in demo-mode then we submit the score to a special API request that doesn’t actually save their score in the leaderboards, after all they aren’t even authenticated, but instead just sends back what their rankings would be. If they are not in demo-mode then we actually submit to the real leaderboard API endpoint.

@T(00:51:08)
Then, after constructing that one-off effect, we construct a big ole merged effect that does a whole bunch of stuff:

@T(00:51:15)
- We wait for 2 seconds to send a `delayedOnAppear` action. We do this because we cause the game over screen to be disabled for a few seconds when it first appears just in case you are frantically tapping on the screen in the last seconds of your game and we don’t want you to accidentally tap on something on this screen.

@T(00:51:33)
- At the same time, we submit the game score to the leaderboards.

@T(00:51:39)
- Then we perform a complex effect to first figure out if we should show the upgrade interstitial to the user, which requires checking their in-app purchase receipt as well as how many games they have played, and then based on that boolean we send an action to show the interstitial after a one second delay.

@T(00:52:04)
- We also fetch their notification settings so that we can see if we should prompt the user to turn on push notifications.

@T(00:52:12)
- And finally we play some sound effects and music.

@T(00:52:18)
It’s a really intense effect!

@T(00:52:21)
It’s a lot more complex that it really needs to be. Let’s see what it looks like in the structured concurrency world:

```bash
$ git reset head .
$ git checkout .
```

@T(00:52:46)
First of all, we are now using the `.task` view modifier style to kick off this work, which means we get automatically cancellation of the game over screen is closed before all the work is done:

```swift
case .task:
  …
```

@T(00:52:55)
And then we can just open up a single `Effect.run` to put all of the effect logic:

```swift
return .run {
  [
    completedGame = state.completedGame,
    isDemo = state.isDemo
  ] send in
  …
}
```

@T(00:53:02)
First, as before, we check to see if we’re a demo game or scored any points, just as before, but rather than spin off a one-off effect to do this work, we can do it in this shared async context:

```swift
guard isDemo || completedGame.currentScore > 0
else {
  await send(.delegate(.close), animation: .default)
  return
}
```

@T(00:53:14)
Next, before structured concurrency, we threw the audio effects into the `.merge` just because it was easy to do, but we really don’t need to parallelize that work. Those dependencies just call out to an underlying audio engine and return immediately. We wouldn’t mind running that work sequentially, but just due to how Combine operators work it was easier to throw in a `.merge` than try to figure out how handle it differently.

Well, things are a lot simpler in structured concurrency. We can just run it sequentially:

```swift
await environment.audioPlayer.play(.transitionIn)
await environment.audioPlayer.loop(.gameOverMusicLoop)
```

@T(00:53:43)
Then, the work that really does need to be done in parallel can be put in a `withThrowingTaskGroup`:

```swift
await withThrowingTaskGroup(of: Void.self) { group in
  …
}
```

@T(00:53:57)
Further, all of that logic for constructing the submit game effect can now go directly in the effect itself. No reason to pre-construct it just because we need to perform some `if`/`else` logic:

```swift
group.addTask {
  if isDemo {
    …
  } else if let request = ServerRoute.Api.Route.Games
    .SubmitRequest( completedGame: completedGame)
  {
    …
  }
}
```

@T(00:54:15)
And then the last 3 things that can be run in parallel is added to the task group down below.

@T(00:54:40)
Further, we have a very comprehensive test suite for this feature because it is so nuanced, and everything continued to pass after minimal updates to make the tests async-friendly.

## isowords: Home Screen Effects

@T(00:56:04)
There’s another feature in the application that has quite a complex initial effect when the view appears, and that’s the home feature.

@T(00:56:11)
Just like all the other features, this feature’s code is all put into a dedicated module so that it can be iterated on and tested in isolation, and there is a preview app so that we can run it in isolation in the simulator.

@T(00:56:30)
When the home view appears there is a very complex sequence of effects that execute. We must authenticate with Game Center, because that is our primary way of identifying users in the game without having to ask for email, phone number, or social login. Once we have that, we authenticate with our server so that we can fetch personalized information for them. Then we fetch the current daily challenge so they can see how many have played so far or how their rank is doing so far, and in parallel we also fetch the user’s “week in review”, which just gives some top-level stats of how their scores compare to other isowords players. On top of that we also load the user’s turn based matches so that we can see if it’s their turn on any matches. And then on top of all of that, we start listening for Game Center events so that we can be notified when turn based matches update.

@T(00:57:38)
Already that sounds complicated, but there is also a lot of nuance in how those effects are organized. Some of the effects gate the others so that if the effect fails it prevents later effects from executing. Also some effects can be run in parallel but others must be run sequentially.

@T(00:57:48)
Doing this in Combine was an absolute nightmare, and honestly it was code that we dreaded to touch. We can quickly take a peek at what this looked like by checking out the old home feature code:

```bash
$ git checkout origin/main -- Sources/HomeFeature
```

@T(00:58:07)
And what we will find is a function called `onAppearEffects` that constructs an incredibly complex effect. We are making use of `flatMap` for sequencing and `merge` for running in parallel, and we define a few helper effects along the way so that we can compose everything together. It’s very difficult to understand.

@T(00:58:55)
So let’s go back to the structured concurrency version of this file:

```bash
$ git reset head .
$ git checkout .
```

@T(00:59:00)
And we now see that the kick-off action is `.task` instead of `onAppear`, so that we can take advantage of tying the lifetime of this effect to the lifetime of the view. And it performs two asynchronous tasks sequentially:

```swift
case .task:
  return .run { send in
    async let authenticate: Void =
      authenticate(send: send, environment: environment)
    await listenForGameCenterEvents(
      send: send, environment: environment
    )
  }
  .animation()
```

@T(00:59:17)
First we perform something called “authentication”, and then in parallel and without waiting for authentication to finish, we start listening for Game Center events, which is what we use for turn based games.

@T(00:59:33)
The `authenticate` method is long and complicated, but it now at least reads linearly and from top-to-bottom. First we try to authenticate with Game Center, and if that fails we silently ignore any errors because even if the user doesn’t have Game Center configured we still want to fetch daily challenges.

@T(00:59:53)
Once we get passed Game Center authentication we then authenticate with our server by passing along all of the info from Game Center, such as their player ID and display name. When we get a response from our server we send it back into the system so that we can react to it, in particular we use data from that response to determine whether or not we should show a banner at the bottom of the screen to nag you to upgrade to the fully paid version of the app.

@T(01:00:12)
Then, after all of the authentication logic we perform 4 units of work, all in parallel. We fetch a config file from the server, we fetch the details for today’s daily challenge, we fetch the user’s “week in review”, which just has some top-level stats about their scores for the past week, and we fetch any active turn based games from Game Center. Each of these units of work is completely independent from the other, but we want to wait until the user is fully authenticated before kicking them off. This is incredibly easy to express in structured concurrency but was incredibly difficult in Combine.

@T(01:00:46)
And then finally the `listenForGameCenterEvents` function can simply `for await` over all events that game center emits, and we can react to them, such as loading fresh turn-based match data.

@T(01:01:09)
Again, it is absolutely incredible how much simpler this is than the Combine-based version. Yes, this effect is incredibly complicated, but this is essential complexity due to everything we need to get done for this feature. Perhaps we could do more work to break this out into smaller functions or something, but at the end of the day its essential complexity remains roughly the same.

@T(01:01:36)
However, when the code was written with Combine, we added accidental complexity due to the nature of Combine that had nothing to do with the what we were trying to accomplish. We were forced to break up effects into small pieces just because it’s difficult to insert logic into publishers, and we had to use `flatMap` and indent our code a level just to chain two asynchronous tasks together, and the code did not even read from top-to-bottom

## isowords: Upgrade Interstitial

@T(01:02:02)
Let’s look at one last example of structured concurrency in isowords, and that is in the upgrade interstitial feature. There is the screen that we show every once in awhile in order to ask people to support the game with a one-time in-app purchase.

@T(01:02:16)
We can even run this in a preview app to see what it looks like.

@T(01:02:55)
It’s cool we can run this in isolation in a little preview app because we get to focus on just this one feature and it’s not possible to run this in SwiftUI previews because previews do not support Store Kit.

@T(01:03:09)
I won't even show what this code looked like in Combine, but we kick off a complex effect when the view appears. We run three asynchronous jobs all in parallel using task groups:

@T(01:03:34)
- First we start up a long-living subscription to listen for store kit events, such as when errors occur or when transactions complete.

@T(01:03:46)
- Then we load products from store kit in order to show current pricing information in the modal.

@T(01:03:52)
- And finally we start a timer in order to count down and allow the person to close the interstitial.

@T(01:04:10)
This also uses a tool that is new in the library but we haven’t discussed in episodes. We can mark just a small part of the effect to be cancellable by an id, and if later we cancel that id, only this part will stop execution:

```swift
if !isDismissable {
  group.addTask {
    await withTaskCancellation(id: TimerID.self) {
      for await _
      in environment.mainRunLoop.timer(interval: 1) {
        await send(.timerTick, animation: .default)
      }
    }
  }
}
```

The rest of the effect runs just like normal. Only the timer will actually be cancelled, and that’s really cool.

## Conclusion

@T(01:04:37)
So, that concludes this episode on showing off some more real world examples of how structured concurrency can massively improve existing Composable Architecture applications. It is by far the biggest update to the library since we released it over 2 years ago, and we think it will help simplify how people construct effects in their applications. We even think that testing in the Composable Architecture is perhaps even the best way to test asynchronous code in Swift, just in general. It provides all of the necessary tools for awaiting asynchronous work and making assertions on what happens during that work.

@T(01:05:09)
Next time we begin a new series of episodes that will simplify how one constructs Composable Architecture features even more, and in some ways it’s even more significant than the concurrency changes we have made.

@T(01:05:22)
But that will have to wait until next time…
