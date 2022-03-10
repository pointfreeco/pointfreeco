import Foundation

extension Episode {
  static let ep17_stylingWithOverture = Episode(
    blurb: """
We revisit an old topic: styling UIKit components. Using some of the machinery we have built from previous episodes, in particular setters and function composition, we refactor a screen's styles to be more modular and composable.
""",
    codeSampleDirectory: "0017-styling-pt2",
    id: 17,
    length: 29*60 + 20,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_527_501_423),
    sequence: 17,
    title: "Styling with Overture",
    trailerVideo: .init(
      bytesLength: 46632907,
      downloadUrls: .s3(
        hd1080: "0017-trailer-1080p-6b6df28e21734a5889b4cfc59e2633ea",
        hd720: "0017-trailer-720p-7a28d6211f0b4f2cb4ab2c47b83eba76",
        sd540: "0017-trailer-540p-f628012e6ce44ca2a0c88b55dfe0c74b"
      ),
      vimeoId: 352312223
    )
  )
}
