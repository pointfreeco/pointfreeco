import Foundation

extension Episode {
  public static let ep150_derivedBehavior = Episode(
    blurb: """
      We typically rewrite vanilla SwiftUI applications into Composable Architecture applications, but this week we do the opposite! We will explore "deriving behavior" by taking an existing TCA app and rewriting it using only the SwiftUI tools Apple gives us.
      """,
    codeSampleDirectory: "0150-derived-behavior-pt5",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 281_521_072,
      downloadUrls: .s3(
        hd1080: "0150-1080p-ad706c3dcec342d5b8251e1cb592bf0c",
        hd720: "0150-720p-8787cf7fabce45e4981350082f4d7d09",
        sd540: "0150-540p-595a809711ed4474bfa3936324aa9aa0"
      ),
      id: "b2bb8d5a9c2aa0e5b2e78490e848eef9"
    ),
    id: 150,
    length: 60 * 60 + 10,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_624_251_600),
    references: [
      // TODO
    ],
    sequence: 150,
    subtitle: "The Point",
    title: "Derived Behavior",
    trailerVideo: .init(
      bytesLength: 75_654_725,
      downloadUrls: .s3(
        hd1080: "0150-trailer-1080p-b8fc56fd11a742daaddc622dbceb1aec",
        hd720: "0150-trailer-720p-ea5178e5616d4001bc8af167869c26c2",
        sd540: "0150-trailer-540p-1c8dcdd3cc924e83aa71b6e38e4eb76e"
      ),
      id: "462cf1b71859a92a86aa57b1ac149f66"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
