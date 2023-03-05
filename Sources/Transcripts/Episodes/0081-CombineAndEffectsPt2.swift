import Foundation

extension Episode {
  static let ep81_theCombineFrameworkAndEffects_pt2 = Episode(
    blurb: """
      Now that we've explored the Combine framework and identified its correspondence with the `Effect` type, let's refactor our architecture to take full advantage of it.
      """,
    codeSampleDirectory: "0081-combine-and-effects-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 405_330_619,
      downloadUrls: .s3(
        hd1080: "0081-1080p-45d5a00e9a1346c0bf925c5c87e582b9",
        hd720: "0081-720p-0860db0f98b44d029f1dba499e054014",
        sd540: "0081-540p-b2f91fc2906541ba9f9ed62c34e79992"
      ),
      vimeoId: 371_023_664
    ),
    id: 81,
    length: 38 * 60 + 46,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_574_056_800),
    references: [
      .combineFramework,
      .reactiveSwift,
      .rxSwift,
      .reactiveStreams,
      .deferredPublishers,
    ],
    sequence: 81,
    title: "The Combine Framework and Effects: Part 2",
    trailerVideo: .init(
      bytesLength: 34_771_162,
      downloadUrls: .s3(
        hd1080: "0081-trailer-1080p-c388a5bf16e54f6c8c2511afc89cd845",
        hd720: "0081-trailer-720p-b28dc87560624239ac6ed659b86e9a53",
        sd540: "0081-trailer-540p-8ed927070d6f497bb3c53899086c6e78"
      ),
      vimeoId: 371_019_239
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 81)
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      We added a `sync` helper to our `Effect` publisher, which takes a block of work that synchronously returns a value and ultimately returned an effect. It was a composition of the `Deferred` and `Just` publishers.

      Taking inspiration from this, introduce an `async` helper to `Effect` that, given a callback block, asynchronously accepts a value.

      ```swift
      extension Effect {
        static func async(
          work: @escaping (@escaping (Output) -> Void) -> Void
        ) -> Effect {
          fatalError("Unimplemented")
        }
      }
      ```

      This function is easiest to implement if you assume the effect is only allowed to emit at most one value. If you want the effect to be able to emit multiple values it will take a lot more work and a deeper understanding of Combine's concepts.
      """#,
    solution: #"""
      ```swift
      extension Effect {
        static func async(
          work: @escaping (@escaping (Output) -> Void) -> Void
        ) -> Effect {
          return Deferred {
            Future { callback in
              work { output in
                callback(.success(output))
              }
            }
          }.eraseToEffect()
        }
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      When translating our Wolfram Alpha effect to Combine, we took several steps to handle any errors by effectively ignoring them. Simplify this reusable logic with an `Effect` helper dedicated to ignoring a publisher's errors.

      ```swift
      extension Publisher {
        func hush() -> Effect<Output> {
          fatalError("Unimplemented")
        }
      }
      ```
      """#,
    solution: #"""
      ```swift
      extension Publisher {
        func hush() -> Effect<Output> {
          return self
            .map(Optional.some)
            .replaceError(with: nil)
            .compactMap { $0 }
            .eraseToEffect()
        }
      }
      ```
      """#
  ),
  .init(
    problem: """
      Refactor the Composable Architecture and app to use a `Reducer` of the form:

      ```swift
      typealias Reducer<Value, Action> = (inout Value, Action) -> Effect<Action>
      ```

      Note that we are returning a single `Effect<Action>`, not an array.

      What Combine operator can you use for the times that you need to return multiple effects? What should you use for when you do not need to return any effects at all?
      """),
  Episode.Exercise(
    problem: #"""
      In the episode we note that while we chose to refactor the architecture with the Combine framework, we could have just as easily refactored it to work with [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) or [RxSwift](https://github.com/ReactiveX/RxSwift)

      Pick your framework of choice (or both!) and refactor the Composable Architecture accordingly. If using ReactiveSwift you will need to decide between `Signal` and `SignalProducer` for your effect type.
      """#
  ),
]
