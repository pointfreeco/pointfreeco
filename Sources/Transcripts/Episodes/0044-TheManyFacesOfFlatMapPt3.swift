import Foundation

extension Episode {
  static let ep44_theManyFacesOfFlatMap_pt3 = Episode(
    blurb: """
      We are now ready to answer the all-important question: what's the point? We will describe 3 important ideas that are now more accessible due to our deep study of `map`, `zip` and `flatMap`. We will start by showing that this trio of operations forms a kind of functional, domain-specific language for data transformations.
      """,
    codeSampleDirectory: "0044-the-many-faces-of-flatmap-pt3",
    id: 44,
    length: 36 * 60 + 52,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_548_054_000),
    references: [
      .se0235AddResultToTheStandardLibrary,
      .railwayOrientedProgramming,
      reference(
        forEpisode: .ep10_aTaleOfTwoFlatMaps,
        additionalBlurb: """
          Up until Swift 4.1 there was an additional `flatMap` on sequences that we did not consider in this episode, but that's because it doesn't act quite like the normal `flatMap`. Swift ended up deprecating the overload, and we discuss why this happened in a previous episode:
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep10-a-tale-of-two-flat-maps"
      ),
    ],
    sequence: 44,
    title: "The Many Faces of Flat‑Map: Part 3",
    trailerVideo: .init(
      bytesLength: 92_871_178,
      downloadUrls: .s3(
        hd1080: "0044-trailer-1080p-b7ecbd70eb8e4ec182e2f7059ca55cd0",
        hd720: "0044-trailer-720p-83dc8935aa0f4271a1e151b81e8c2283",
        sd540: "0044-trailer-540p-3f8608d2f2114bd58248531ceda9a8e8"
      ),
      vimeoId: 348_490_355
    )
  )
}
