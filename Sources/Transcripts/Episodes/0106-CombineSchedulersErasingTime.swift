import Foundation

extension Episode {
  public static let ep106_combineSchedulers_erasingTime = Episode(
    blurb: """
      We refactor our application's code so that we can run it in production with a live dispatch queue for the scheduler, while allowing us to run it in tests with a test scheduler. If we do this naively we will find that generics infect many parts of our code, but luckily we can employ the technique of type erasure to make things much nicer.
      """,
    codeSampleDirectory: "0106-combine-schedulers-pt3",
    exercises: _exercises,
    id: 106,
    length: 37 * 60 + 0,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_592_197_200),
    references: [
      .combineSchedulers
    ],
    sequence: 106,
    subtitle: "Erasing Time",
    title: "Combine Schedulers",
    trailerVideo: .init(
      bytesLength: 31_410_846,
      downloadUrls: .s3(
        hd1080: "0106-trailer-1080p-e4a38adda471420ea65e9cb90291de99",
        hd720: "0106-trailer-720p-db342a6687d54d2a9c3e8b3d5dfb1b46",
        sd540: "0106-trailer-540p-1a4b331d8bab49558f25e62b93cea978"
      ),
      vimeoId: 428_639_897
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
