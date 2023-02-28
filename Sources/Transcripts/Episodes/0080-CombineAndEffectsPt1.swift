import Foundation

extension Episode {
  static let ep80_theCombineFrameworkAndEffects_pt1 = Episode(
    blurb: """
      Let's explore the Combine framework and its correspondence with the Effect type. Combine introduces several concepts that overlap with how we model effects in our composable architecture. Let's get an understanding of how they work together and compare them to our humble Effect type.
      """,
    codeSampleDirectory: "0080-combine-and-effects-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 269_920_178,
      downloadUrls: .s3(
        hd1080: "0080-1080p-fb5b81a69c09492f88d11c1084de0308",
        hd720: "0080-720p-c9f731bd943c49dc9c22bba9a3c41039",
        sd540: "0080-540p-9616648f9cf644ecb30bf9dd674e974e"
      ),
      vimeoId: 371_024_746
    ),
    id: 80,
    length: 25 * 60 + 10,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_573_452_000),
    references: [
      .combineFramework,
      .reactiveSwift,
      .rxSwift,
      .reactiveStreams,
      .deferredPublishers,
      .lazyEvaluation,
      .whyFunctionalProgrammingMatters,
      .promisesAreNotNeutralEnough,
    ],
    sequence: 80,
    title: "The Combine Framework and Effects: Part 1",
    trailerVideo: .init(
      bytesLength: 58_885_115,
      downloadUrls: .s3(
        hd1080: "0080-trailer-1080p-e6b2f035dcb6418f822f35ba75a46df2",
        hd720: "0080-trailer-720p-cd0b3121c4e14a6a8b86bf1f6c6de2b5",
        sd540: "0080-trailer-540p-fe1f91bc1bcc49eea0942b73784dbb71"
      ),
      vimeoId: 371_024_665
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 80)
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      The current version of `Effect` is "lazy": it is only evaluated the moment the `run` functions is called. Define an "eager" version of the `Effect` type that is evaluated the moment it is constructed.

      If you have any trouble defining such a type, consider the fact that in being eager, the work should be executed immediately, but call(s) to `run` may happen before _or_ after the work completes. This means:

      - A value must be set at some later time. Value types can only be mutated within a local, in-out scope, so you may need to reach for a class instead of a struct.

      - Because this value is being stored, you can cache it. This means the work only needs to be performed once.

      - There may be multiple requests for the value of a single effect. Ensure that both calls to `run` before the work has completed, as well as calls to `run` after the work has completed, feed the value to the callback. Keeping track of these calls may require introducing additional state.
      """#,
    solution: #"""
      ```swift
      class Effect<A> {
        var callbacks: [(A) -> Void] = []
        var value: A?

        init(run: @escaping (@escaping (A) -> Void) -> Void) {
          run { value in
            self.callbacks.forEach { callback in callback(value) }
            self.value = value
          }
        }

        func run(_ callback: @escaping (A) -> Void) {
          if let value = self.value {
            callback(value)
          }
          self.callbacks.append(callback)
        }
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      Continuing the previous exercise, improve the eager effect by making things thread-safe. To optimize for performance, you could use `os_unfair_lock` to protect access to the mutable storage that manages the resulting value and requests for it, but be wary of recursive calls to the lock by running the callbacks _outside_ of the lock.

      You could also use `NSRecursiveLock` to simplify this logic at the cost of some performance.
      """#,
    solution: #"""
      An example of `os_unfair_lock` is below. It synchronizes reads and writes to storage, and runs callbacks _outside_ of the lock in order to prevent recursive deadlocks.

      ```swift
      import Darwin

      class Effect<A> {
        var callbacks: [(A) -> Void] = []
        var value: A?
        var lock = os_unfair_lock()

        init(run: @escaping (@escaping (A) -> Void) -> Void) {
          run { value in
            let callbacks: [(A) -> Void]
            os_unfair_lock_lock(&self.lock)
            self.value = value
            callbacks = self.callbacks
            os_unfair_lock_unlock(&self.lock)
            callbacks.forEach { callback in callback(value) }
          }
        }

        func run(_ callback: @escaping (A) -> Void) {
          let value: A?
          os_unfair_lock_lock(&self.lock)
          if let aValue = self.value {
            value = aValue
          } else {
            value = nil
          }
          self.callbacks.append(callback)
          os_unfair_lock_unlock(&self.lock)
          if let value = value {
            callback(value)
          }
        }
      }
      ```
      """#
  ),
]
