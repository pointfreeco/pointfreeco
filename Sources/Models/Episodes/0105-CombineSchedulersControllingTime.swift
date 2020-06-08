import Foundation

extension Episode {
  public static let ep105_combineSchedulers_controllingTime = Episode(
    blurb: """
The `Scheduler` protocol of Combine is a powerful abstraction that unifies many ways of executing asynchronous work, and it can even control the flow of time through our code. Unfortunately Combine doesn't give us this abililty out of the box, so let's build it from scratch.
""",
    codeSampleDirectory: "0105-combine-schedulers-pt2",
    exercises: _exercises,
    id: 105,
    image: "https://i.vimeocdn.com/video/905440786.jpg",
    length: 66*60 + 28,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1591592400),
    references: [
      // TODO
    ],
    sequence: 105,
    subtitle: "Controlling Time",
    title: "Combine Schedulers",
    trailerVideo: .init(
      bytesLength: 20_432_712,
      vimeoId: 426821769,
      vimeoSecret: "7b170a288356f5e79f88a69c3a3b7790d4af23cb"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
