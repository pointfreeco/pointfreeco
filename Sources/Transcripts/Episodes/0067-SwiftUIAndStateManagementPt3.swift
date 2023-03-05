import Foundation

extension Episode {
  static let ep67_swiftuiAndStateManagement_pt3 = Episode(
    blurb: """
      With our moderately complex SwiftUI application complete we can finally ask ourselves: "what's the point!?" What does SwiftUI have to say about app architecture? What questions are left unanswered? What can we do about it?
      """,
    codeSampleDirectory: "0067-swiftui-and-state-management-pt3",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 353_885_387,
      downloadUrls: .s3(
        hd1080: "0067-1080p-925def882ea54bbbab6ce0e576b54d21",
        hd720: "0067-720p-2623de28215c47f5937c700b958198e1",
        sd540: "0067-540p-dbce9852ede048c89efb91eb5868006c"
      ),
      vimeoId: 349_951_722
    ),
    id: 67,
    length: 27 * 60 + 2,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_564_380_000),
    references: [
      .swiftUiTutorials,
      .insideSwiftUIAboutState,
    ],
    sequence: 67,
    title: "SwiftUI and State Management: Part 3",
    trailerVideo: .init(
      bytesLength: 24_833_339,
      downloadUrls: .s3(
        hd1080: "0067-trailer-1080p-62d35575ea1046f5b3a148c72c32b8f9",
        hd720: "0067-trailer-720p-fdc0cc3391de4578b5336c27c3907325",
        sd540: "0067-trailer-540p-2b6adf54127d46c9af3a7377238307db"
      ),
      vimeoId: 349_951_622
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 67)
  )
}

private let _exercises: [Episode.Exercise] = [
  // todo
]
