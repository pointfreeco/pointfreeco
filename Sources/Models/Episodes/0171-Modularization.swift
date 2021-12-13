import Foundation

extension Episode {
  public static let ep171_modularization = Episode(
    blurb: """
We've talked about modularity a lot in the past, but we've never devoted full episodes to how we approach the subject. We will define and explore various kinds of modularity, and we’ll show how to modularize a complex application from scratch using modern build tools.
""",
    codeSampleDirectory: "0171-modularization-pt1",
    exercises: _exercises,
    id: 171,
    length: 43*60 + 55,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1639375200),
    references: [
      // TODO
    ],
    sequence: 171,
    subtitle: "Part 1",
    title: "Modularization",
    trailerVideo: .init(
      bytesLength: 276338642,
      vimeoId: 655905170,
      vimeoSecret: "0adfcfd50a9a3e7e402fdb7cba599f5c3e0657a7"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]
