import Foundation

extension Episode {
  public static let ep123_fluentlyZippingParsers = Episode(
    blurb: """
      The zip function shows up on many types: from Swift arrays and Combine publishers, to optionals, results, and even parsers! But zip on parsers is a little unlike zip on all of those other types. Let's explore why and how to fix it.
      """,
    codeSampleDirectory: "0123-fluently-zipping-parsers",
    exercises: _exercises,
    id: 123,
    length: 51 * 60 + 23,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_604_296_800),
    references: [],
    sequence: 123,
    subtitle: nil,
    title: "Fluently Zipping Parsers",
    trailerVideo: .init(
      bytesLength: 62_177_062,
      downloadUrls: .s3(
        hd1080: "0123-trailer-1080p-28030023e5f6456782ebe0c1dff9d1d6",
        hd720: "0123-trailer-720p-c65396f9f838479196f6cc27a6827350",
        sd540: "0123-trailer-540p-9d5f312ac29f4326b6fd1e90ed0ffaa7"
      ),
      vimeoId: 474_508_515
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
