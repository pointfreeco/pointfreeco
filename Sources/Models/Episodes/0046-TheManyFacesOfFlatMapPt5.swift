import Foundation

extension Episode {
  static let ep46_theManyFacesOfFlatMap_pt5 = Episode(
    blurb: """
      Finishing our 3-part answer to the all-important question "what's the point?", we finally show that standing on the foundation of our understanding of `map`, `zip` and `flatMap` we can now ask and concisely answer very complex questions about the nature of these operations.
      """,
    codeSampleDirectory: "0046-the-many-faces-of-flatmap-pt5",
    exercises: _exercises,
    id: 46,
    length: 32 * 60 + 40,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_549_263_600),
    references: [
      .railwayOrientedProgramming,
      reference(
        forEpisode: .ep10_aTaleOfTwoFlatMaps,
        additionalBlurb: """
          Up until Swift 4.1 there was an additional `flatMap` on sequences that we did not consider in this episode, but that's because it doesn't act quite like the normal `flatMap`. Swift ended up deprecating the overload, and we discuss why this happened in a previous episode:
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep10-a-tale-of-two-flat-maps"
      ),
      monadRef,
    ],
    sequence: 46,
    title: "The Many Faces of Flat‑Map: Part 5",
    trailerVideo: .init(
      bytesLength: 103_605_774,
      downloadUrls: .s3(
        hd1080: "0046-trailer-1080p-c4a1d41df59a4ace8272f6f230281ee8",
        hd720: "0046-trailer-720p-3b289b994f044c62a69d9a36dbb550e6",
        sd540: "0046-trailer-540p-436bb52edee74abdb8a08b4d4b183172"
      ),
      vimeoId: 348_489_897
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Implement `flatMap` on the nested type `Result<A?, E>`. It would have the signature:

      ```
      func flatMap<A, B, E>(
        _ f: @escaping (A) -> Result<B?, E>
        ) -> (Result<A?, E>) -> Result<B?, E> {

        fatalError("Implement me!")
      }
      ```
      """,
    solution: """
      This function cannot be implemented easily using just the `map` and `flatMap` on `Result` and `Optional`. We have to drop down into explicit `switch` destructuring to handle all of the cases:

      ```
      func flatMap<A, B, E>(
        _ f: @escaping (A) -> Result<B?, E>
        ) -> (Result<A?, E>) -> Result<B?, E> {

        return { resultOfOptionalA in
          switch resultOfOptionalA {
          case let .success(.some(a)):
            return f(a)
          case .success(.none):
            return .success(.none)
          case let .failure(error):
            return .failure(error)
          }
        }
      }
      ```
      """),

  .init(
    problem: """
      Implement `flatMap` on the nested type `Func<A, B?>`. It would have the signature:

      ```
      func flatMap<A, B, C>(
        _ f: @escaping (B) -> Func<A, C?>
        ) -> (Func<A, B?>) -> Func<A, C?> {

        fatalError("Implement me!")
      }
      ```
      """),

  .init(
    problem: """
      Implement `flatMap` on the nested type `Parallel<A?>`. It would have the signature:

      ```
      func flatMap<A, B>(
        _ f: @escaping (A) -> Parallel<B?>
        ) -> (Parallel<A?>) -> Parallel<B?> {

        fatalError("Implement me!")
      }
      ```
      """),

  .init(
    problem: """
      Do you see anything in common with all of the implementations in the previous 3 exercises? It turns out that if a generic type `F<A>` has a `flatMap` operation, then you can define a `flatMap` on `F<A?>` in a natural way.
      """),

  //  .init(problem: """
  //Consider the following type:
  //
  //```
  //struct Cont<R, A> {
  //  let run: (@escaping (A) -> R) -> R
  //}
  //```
  //
  //`Cont` is like a generalization of `Parallel`, where `Parallel<A> = Cont<Void, A>`. Implement `map` and `flatMap` for the `R` type parameter of `Cont`.
  //"""),
  //
  //  .init(problem: """
  //Implement `flatMap` on the nested type `Cont<R?, A>`. It would have the signature:
  //
  //```
  //func flatMap<R, S, A>(
  //  _ f: @escaping (R) -> Cont<S?, A>
  //  ) -> (Cont<R?, A>) -> Cont<S?, A> {
  //
  //  fatalError("Implement me!")
  //}
  //```
  //"""),
  //
  //  .init(problem: """
  //Implement `flatMap` on the nested type `Cont<[R], A>`. It would have the signature:
  //
  //```
  //func flatMap<R, S, A>(
  //  _ f: @escaping (R) -> Cont<[S], A>
  //  ) -> (Cont<[R], A>) -> Cont<[S], A> {
  //
  //  fatalError("Implement me!")
  //}
  //```
  //"""),
  //
  //  .init(problem: """
  //Do you see anything in common with the implementations in the previous 2 exercises? It turns out that if a generic type `F<R>` has a `flatMap` operation, then you can define a `flatMap` on `Cont<F<R>, A>` in a natural way.
  //"""),

  .init(
    problem: """
      Implement `flatMap` on the nested type `Func<A, Result<B, E>>`. It would have the signature:

      ```
      flatMap: ((B) -> Func<A, Result<C, E>>)
               -> (Func<A, Result<B, E>>)
               -> Func<A, Result<C, E>>
      ```
      """),
]

private let monadRef = { () -> Episode.Reference in
  var ref = Episode.Reference.wikipediaMonad
  ref.blurb = """
    Well, the cat's out of the bag. For the past 5 episodes, while we've been talking about `flatMap`, we were really talking about something called "monads." Swift cannot (yet) fully express the idea of monads, but we can still leverage the intuition of how they operate.

    This reference is to the Wikipedia page for monads, which is terse but concise.
    """
  return ref
}()
