import Foundation

extension Episode {
  public static let ep18_dependencyInjectionMadeComfortable = Episode(
    blurb: """
Let's have some fun with the "environment" form of dependency injection we previously explored. We're going to extract out a few more dependencies, strengthen our mocks, and use our Overture library to make manipulating the environment friendlier.
""",
    codeSampleDirectory: "0018-environment-pt2",
    id: 18,
    image: "https://i.vimeocdn.com/video/804928206.jpg",
    length: 28*60 + 36,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 16,
    publishedAt: Date(timeIntervalSince1970: 1_528_106_223),
    references: [
      .structureAndInterpretationOfSwiftPrograms,
      .howToControlTheWorld,
    ],
    sequence: 18,
    title: "Dependency Injection Made Comfortable",
    trailerVideo: .init(
      bytesLength: 70448269,
      downloadUrl: "https://player.vimeo.com/external/352312276.hd.mp4?s=c8e59caf31653beebbbce1572bfccc768bae5816&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/352312276"
    )
  )
}
