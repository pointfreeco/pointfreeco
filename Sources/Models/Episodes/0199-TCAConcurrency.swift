import Foundation

extension Episode {
  public static let ep199_tcaConcurrency = Episode(
    blurb: """
      We explore ways to tie the lifetime of an effect to the lifetime of a view, making it possible to automatically cancel and tear down work when a view goes away. This unexpectedly helps us write even stronger tests for our features.
      """,
    codeSampleDirectory: "0199-tca-concurrency-pt5",
    exercises: _exercises,
    id: 199,
    length: 38 * 60 + 24,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_659_330_000),
    references: [
      reference(
        forCollection: .concurrency,
        additionalBlurb: "",
        collectionUrl: "http://pointfree.co/collections/concurrency"
      )
    ],
    sequence: 199,
    subtitle: "Effect Lifetimes",
    title: "Async Composable Architecture",
    trailerVideo: .init(
      bytesLength: 68_500_000,
      downloadUrls: .s3(
        hd1080: "0199-trailer-1080p-5af665f331dd49668b90ff9879fdd222",
        hd720: "0199-trailer-720p-42c157c73d6b423097f8c7d9b5ad3769",
        sd540: "0199-trailer-540p-ecacf2d598404290829cab2001c5f49c"
      ),
      vimeoId: 730_141_544
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
