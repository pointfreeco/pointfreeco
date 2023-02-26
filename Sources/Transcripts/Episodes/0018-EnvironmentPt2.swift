import Foundation

extension Episode {
  static let ep18_dependencyInjectionMadeComfortable = Episode(
    blurb: """
      Let's have some fun with the "environment" form of dependency injection we previously explored. We're going to extract out a few more dependencies, strengthen our mocks, and use our Overture library to make manipulating the environment friendlier.
      """,
    codeSampleDirectory: "0018-environment-pt2",
    id: 18,
    length: 28 * 60 + 36,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_528_106_223),
    references: [
      .structureAndInterpretationOfSwiftPrograms,
      .howToControlTheWorld,
    ],
    sequence: 18,
    title: "Dependency Injection Made Comfortable",
    trailerVideo: .init(
      bytesLength: 70_448_269,
      downloadUrls: .s3(
        hd1080: "0018-trailer-1080p-3b1f2faa02fb492a869beca84160c8ec",
        hd720: "0018-trailer-720p-3444c13bd3984b7da39b07c8c817f0bf",
        sd540: "0018-trailer-540p-4e6ce025ae764339b9d75b71f0a03920"
      ),
      vimeoId: 352_312_276
    )
  )
}
