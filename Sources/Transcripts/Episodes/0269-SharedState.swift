import Foundation

extension Episode {
  public static let ep269_sharedState = Episode(
    blurb: """
      The various approaches of sharing state in the Composable Architecture are mixed bag of trade
      offs and problems. Is there a better way? We’ll take a controversial approach: we will
      introduce a reference type into our state, typically a value type, and see what happens, and
      take it for a spin in an all new, flow-based case study.
      """,
    codeSampleDirectory: "0269-shared-state-pt2",
    exercises: _exercises,
    id: 269,
    length: 39 * 60 + 41,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-03-04")!,
    references: [
      // TODO
    ],
    sequence: 269,
    subtitle: "The Solution, Part 1",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 82_900_000,
      downloadUrls: .s3(
        hd1080: "0269-trailer-1080p-c9303fbc5cc848039af89571f4616007",
        hd720: "0269-trailer-720p-f9535775bf504da99ac09cfc29fa0a7b",
        sd540: "0269-trailer-540p-8634540ad04347839d24a403d8b62189"
      ),
      vimeoId: 918_939_296
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
