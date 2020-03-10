import Foundation

extension Episode {
  static let ep44_theManyFacesOfFlatMap_pt3 = Episode(
    blurb: """
We are now ready to answer the all-important question: what's the point? We will describe 3 important ideas that are now more accessible due to our deep study of `map`, `zip` and `flatMap`. We will start by showing that this trio of operations forms a kind of functional, domain-specific language for data transformations.
""",
    codeSampleDirectory: "0044-the-many-faces-of-flatmap-pt3",
    id: 44,
    image: "https://i.vimeocdn.com/video/801300524.jpg",
    length: 36*60 + 52,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 43,
    publishedAt: .init(timeIntervalSince1970: 1548054000),
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
    sequence: 44,
    title: "The Many Faces of Flat‑Map: Part 3",
    trailerVideo: .init(
      bytesLength: 92871178,
      downloadUrl: "https://player.vimeo.com/external/348490355.hd.mp4?s=62c04224d1cd547ad100dc99346abb3a19ecf4a1&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/348490355"
    )
  )
}
