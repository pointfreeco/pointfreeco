import Foundation

extension Episode {
  public static let ep197_tcaConcurrency = Episode(
    blurb: """
      We can now run async work directly in a reducer's effects, but time-based asynchrony, like `Task.sleep`, will wreak havoc in our tests. Let's explore the problem in a new feature, and see how to recover the nice syntax of modern timing tools using a protocol from the past: Combine schedulers.
      """,
    codeSampleDirectory: "0197-tca-concurrency-pt3",
    exercises: _exercises,
    id: 197,
    length: 30 * 60 + 56,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_658_120_400),
    references: [
      reference(
        forCollection: .concurrency,
        additionalBlurb: "",
        collectionUrl: "http://pointfree.co/collections/concurrency"
      )
    ],
    sequence: 197,
    subtitle: "Schedulers",
    title: "Async Composable Architecture",
    trailerVideo: .init(
      bytesLength: 78_100_000,
      downloadUrls: .s3(
        hd1080: "0197-trailer-1080p-a1976e3474c141aa89bf2826df967ee7",
        hd720: "0197-trailer-720p-97dacadaa9e44a53ad979e78c4e9ef13",
        sd540: "0197-trailer-540p-77b07bbe43694269abd5c5c9ca546941"
      ),
      vimeoId: 729_347_064
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
