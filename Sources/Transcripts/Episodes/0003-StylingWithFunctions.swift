import Foundation

extension Episode {
  static let ep3_uikitStylingWithFunctions = Episode(
    blurb: """
      We bring tools from previous episodes down to earth and apply them to an everyday task: UIKit styling. Plain functions unlock worlds of composability and reusability in styling of UI components. Have we finally solved the styling problem?
      """,
    codeSampleDirectory: "0003-styling-with-functions",
    exercises: [],
    fullVideo: .init(
      bytesLength: 324_873_341,
      downloadUrls: .s3(
        hd1080: "0003-1080p-7166acf6fdf04e26b7cdac64e3b060c7",
        hd720: "0003-720p-db25f205768d4cbd8c6e698099e3942e",
        sd540: "0003-540p-2d69120546bc4b72b7edf15911ef9148"
      ),
      vimeoId: 348_652_413
    ),
    id: 3,
    length: 1_634,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_518_441_151),
    sequence: 3,
    title: "UIKit Styling with Functions",
    trailerVideo: .init(
      bytesLength: 37_767_144,
      downloadUrls: .s3(
        hd1080: "0003-trailer-1080p-ba897b88831b42099d7da9a6e5412a81",
        hd720: "0003-trailer-720p-5b1502f68a624f3fb9ca021d0ce969a6",
        sd540: "0003-trailer-540p-1cbfcf4e98ae4f8c96d8f093e523e6c2"
      ),
      vimeoId: 354_215_006
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 3)
  )
}
