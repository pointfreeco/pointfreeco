import Foundation

extension Episode {
  public static let ep94_adaptiveStateManagement_pt1 = Episode(
    blurb: """
      It's time to put the finishing touches to our architecture so that we can use it in production. This week we begin exploring how to make the Composable Architecture adapt to many use cases, and we will use a potential performance problem as inspiration for this exploration.
      """,
    codeSampleDirectory: "0094-adaptive-state-management-pt1",
    exercises: _exercises,
    id: 94,
    length: 21 * 60 + 20,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_584_334_800),
    references: [
      Episode.Reference(
        author: nil,
        blurb: #"""
          Apple documentation around identifying memory-use inefficiencies though various means of measuring and profiling, including the memory graph debugger, which is used in this episode.
          """#,
        link:
          "https://developer.apple.com/documentation/xcode/improving_your_app_s_performance/reducing_your_app_s_memory_use/gathering_information_about_memory_use",
        publishedAt: nil,
        title: "Gathering Information About Memory Use"
      )
    ],
    sequence: 94,
    subtitle: "Performance",
    title: "Adaptive State Management",
    trailerVideo: .init(
      bytesLength: 68_660_487,
      downloadUrls: .s3(
        hd1080: "0094-trailer-1080p-5a9fd5b56f004b8d845a884c8731de1d",
        hd720: "0094-trailer-720p-bde6aa5d2a954c57b3f4f3b7a065fbba",
        sd540: "0094-trailer-540p-e348f86c799b473ba7864f42d03d840f"
      ),
      vimeoId: 397_834_898
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
