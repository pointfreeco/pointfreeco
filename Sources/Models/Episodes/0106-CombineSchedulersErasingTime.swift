import Foundation

extension Episode {
  public static let ep106_combineSchedulers_erasingTime = Episode(
    blurb: """
We refactor our application's code so that we can run it in production with a live dispatch queue for the scheduler, while allowing us to run it in tests with a test scheduler. If we do this naively we will find that generics infect many parts of our code, but luckily we can employ the technique of type erasure to make things much nicer.
""",
    codeSampleDirectory: "0106-combine-schedulers-pt3",
    exercises: _exercises,
    id: 106,
    length: 37*60 + 0, 
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1592197200),
    references: [
      .combineSchedulers,
    ],
    sequence: 106,
    subtitle: "Erasing Time",
    title: "Combine Schedulers",
    trailerVideo: .init(
      bytesLength: 31_410_846, 
      vimeoId: 428639897,
      vimeoSecret: "366eb6312c6244e00822ddab1dc8e5ae7b676e60"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
