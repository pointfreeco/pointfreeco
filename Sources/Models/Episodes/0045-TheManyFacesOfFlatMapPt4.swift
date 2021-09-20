import Foundation

extension Episode {
  static let ep45_theManyFacesOfFlatMap_pt4 = Episode(
    blurb: """
Continuing our 3-part answer to the all-important question "what's the point?", we show that the definitions of `map`, `zip` and `flatMap` are precise and concisely describe their purpose. Knowing this we can strengthen our APIs by not smudging their definitions when convenient.
""",
    codeSampleDirectory: "0045-the-many-faces-of-flatmap-pt4",
    id: 45,
    image: "https://i.vimeocdn.com/video/801300469.jpg",
    length: 24*60+37,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1548658800),
    references: [
      .nioRenameThenToFlatMap,
      .se0235AddResultToTheStandardLibrary,
      .railwayOrientedProgramming,
      reference(
        forEpisode: .ep10_aTaleOfTwoFlatMaps,
        additionalBlurb: """
Up until Swift 4.1 there was an additional `flatMap` on sequences that we did not consider in this episode, but that's because it doesn't act quite like the normal `flatMap`. Swift ended up deprecating the overload, and we discuss why this happened in a previous episode:
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep10-a-tale-of-two-flat-maps"
      )
    ],
    sequence: 45,
    title: "The Many Faces of Flat‑Map: Part 4",
    trailerVideo: .init(
      bytesLength: 51687521,
      vimeoId: 349952479,
      vimeoSecret: "eb5fb6b4396a87852819412ac18ae65e863430b2"
    )
  )
}
