import Foundation

extension Episode {
  static let ep43_theManyFacesOfFlatMap_pt2 = Episode(
    blurb: """
Now that we know that `flatMap` is important for flattening nested arrays and optionals, we should feel empowered to define it on our own types. This leads us to understanding its structure more in depth and how it's different from `map` and `zip`.
""",
    codeSampleDirectory: "0043-the-many-faces-of-flatmap-pt2",
    id: 43,
    image: "https://i.vimeocdn.com/video/801300768.jpg",
    length: 27 * 60 + 19,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1547622000),
    references: [
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
    sequence: 43,
    title: "The Many Faces of Flat‑Map: Part 2",
    trailerVideo: .init(
      bytesLength: 45323451,
      vimeoId: 349952476,
      vimeoSecret: "8018674a83d15d84a9467faec8fb1091e3813504"
    )
  )
}
