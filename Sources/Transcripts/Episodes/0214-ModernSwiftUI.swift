import Foundation

extension Episode {
  public static let ep214_modernSwiftUI = Episode(
    blurb: """
      What goes into building a SwiftUI application with best, modern practices? We’ll take a look
      at Apple’s “Scrumdinger” sample code, a decently complex app that tackles many real world
      problems, get familiar with how it's built, and then rewrite it!
      """,
    codeSampleDirectory: "0214-modern-swiftui-pt1",
    exercises: _exercises,
    id: 214,
    length: 32 * 60 + 43,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_669_615_200),
    references: [
      .scrumdinger,
      .standupsApp,
      .swiftTagged,
      .pointfreecoPackageCollection,
      .foodTruck,
      .fruta,
    ],
    sequence: 214,
    subtitle: "Introduction",
    title: "Modern SwiftUI",
    trailerVideo: .init(
      bytesLength: 81_700_000,
      downloadUrls: .s3(
        hd1080: "0214-trailer-1080p-e6977f7a72a6442c8febf065ada41f6d",
        hd720: "0214-trailer-720p-5f594b729735430c9769da7a7c66376e",
        sd540: "0214-trailer-540p-f2fb9ced263344ccacd42341e8529708"
      ),
      vimeoId: 774_866_074
    )
  )
}

private let _exercises: [Episode.Exercise] = []
