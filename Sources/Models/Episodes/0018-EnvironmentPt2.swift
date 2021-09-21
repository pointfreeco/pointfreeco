import Foundation

extension Episode {
  static let ep18_dependencyInjectionMadeComfortable = Episode(
    blurb: """
Let's have some fun with the "environment" form of dependency injection we previously explored. We're going to extract out a few more dependencies, strengthen our mocks, and use our Overture library to make manipulating the environment friendlier.
""",
    codeSampleDirectory: "0018-environment-pt2",
    id: 18,
    image: "https://i.vimeocdn.com/video/804928206.jpg",
    length: 28*60 + 36,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_528_106_223),
    references: [
      .structureAndInterpretationOfSwiftPrograms,
      .howToControlTheWorld,
    ],
    sequence: 18,
    title: "Dependency Injection Made Comfortable",
    trailerVideo: .init(
      bytesLength: 70448269,
      vimeoId: 352312276,
      vimeoSecret: "c8e59caf31653beebbbce1572bfccc768bae5816"
    )
  )
}
