import Foundation

extension Episode {
  public static let ep123_fluentlyZippingParsers = Episode(
    blurb: """
The zip function shows up on many types: from Swift arrays and Combine publishers, to optionals, results, and even parsers! But zip on parsers introduces a strange problem. Let's explore why and how to fix it.
""",
    codeSampleDirectory: "0123-fluently-zipping-parsers",
    exercises: _exercises,
    id: 123,
    image: "https://i.vimeocdn.com/video/986514412.jpg",
    length: 51*60 + 23,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1604296800),
    references: [
    ],
    sequence: 123,
    subtitle: nil,
    title: "Fluently Zipping Parsers",
    trailerVideo: .init(
      bytesLength: 62177062,
      vimeoId: 474508515,
      vimeoSecret: "c4654e70af055ce6217aaff862877df2cb1c65ec"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
