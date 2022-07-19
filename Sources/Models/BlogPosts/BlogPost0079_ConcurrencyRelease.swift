import Foundation

public let post0079_ConcurrencyRelease = BlogPost(
  author: .pointfree,
  blurb: """
    TODO
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Today is a very special day. It both marks the 200th episode of [Point-Free](/) _and_
        the biggest release of our popular library, the [Composable Architecture][tca-github], since
        its initial release over 2 years ago.

        This update brings all new concurrency tools to the library, allowing you to construct
        complex effects using structured concurrency, tie effect lifetimes to view lifetimes, and
        accomplishing all of that while keeping your code 100% testable.

        ## Structured effects

        The library's dependence on Combine for effects is now considered "soft-deprecated". Rather
        than using using Combine publishers and magical incantations of publisher operators to
        express your effects, you can now write complex effects from top-to-bottom using Swift's
        structured concurrency tools.

        As an example, in the [speech recognition demo][speech-recognition-demo] from the repo we
        construct an effect for 1) asking the user for recording authorization and, if granted, 2)
        start a voice recognition task to get a stream of transcription results. Previously this
        was quite complex with Combine, requiring expert use of `flatMap`, `filter` and `map`
        operators, but can now be a simple combination of `await`, `guard` and `for await`:

        ```swift
        case .recordButtonTapped:
          return Effect.run { send in
            let status = await speechClient.requestAuthorization()
            await send(.speechRecognizerAuthorizationStatusResponse(status))

            guard status == .authorized
            else { return }

            let request = SFSpeechAudioBufferRecognitionRequest()
            for try await result in await speechClient.startTask(request) {
              await send(
                .speech(result.bestTranscription.formattedString),
                animation: .linear
              )
            }
          }
        ```

        This will greatly simplify how you construct complex effects. You can make use of all the
        tools gives us for concurrency, such as `await` for concatenating asynchronous work,
        `for await` for subscribing to async sequences, as well as `async let` and task groups
        for

        - [ ] https://www.pointfree.co/collections/concurrency

        ## Effect lifetimes

        ## Testable concurrency

        - [ ] combine schedulers

        ## Start using 0.39.0 today!

        - [ ] combine schedulers


        [tca-github]: http://github.com/pointfreeco/swift-composable-architecture
        [speech-recognition-demo]: https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/SpeechRecognition
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 79,  // TODO
  publishedAt: .distantFuture,  // TODO
  title: "Async Composable Architecture"
)
