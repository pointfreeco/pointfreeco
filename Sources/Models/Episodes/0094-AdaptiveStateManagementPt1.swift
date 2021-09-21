import Foundation

extension Episode {
  public static let ep94_adaptiveStateManagement_pt1 = Episode(
    blurb: """
It's time to put the finishing touches to our architecture so that we can use it in production. This week we begin exploring how to make the Composable Architecture adapt to many use cases, and we will use a potential performance problem as inspiration for this exploration.
""",
    codeSampleDirectory: "0094-adaptive-state-management-pt1",
    exercises: _exercises,
    id: 94,
    image: "https://i.vimeocdn.com/video/865220919.jpg",
    length: 21*60 + 20,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1584334800),
    references: [
      Episode.Reference(
        author: nil,
        blurb: #"""
Apple documentation around identifying memory-use inefficiencies though various means of measuring and profiling, including the memory graph debugger, which is used in this episode.
"""#,
        link: "https://developer.apple.com/documentation/xcode/improving_your_app_s_performance/reducing_your_app_s_memory_use/gathering_information_about_memory_use",
        publishedAt: nil,
        title: "Gathering Information About Memory Use"
      ),
    ],
    sequence: 94,
    title: "Adaptive State Management: Performance",
    trailerVideo: .init(
      bytesLength: 68_660_487,
      vimeoId: 397834898,
      vimeoSecret: "0e5703c2d33db6ef1d7cf72d1850ff8e45ea747e"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
