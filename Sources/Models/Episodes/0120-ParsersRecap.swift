import Foundation

extension Episode {
  public static let ep120_parsersRecap = Episode(
    blurb: """
We round out our parsing recap by reintroducing that functional trio of operators: map, zip, and flat-map. We'll use them to build up some complex parsers and make a few more ergonomic improvements to our library along the way.
""",
    codeSampleDirectory: "0120-parsers-recap-pt2",
    exercises: _exercises,
    id: 120,
    image: "https://i.vimeocdn.com/video/962585475.jpg",
    length: 38*60 + 39,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1602478800),
    references: [
      reference(
        forCollection: .parsing,
        additionalBlurb: "New to parsing? Start our collection from the beginning!",
        collectionUrl: "https://www.pointfree.co/collections/parsing"
      ),
    ],
    sequence: 120,
    subtitle: "Part 2",
    title: "Parser Combinators Recap",
    trailerVideo: .init(
      bytesLength: 31096976,
      vimeoId: 460940618,
      vimeoSecret: "52d7769fcfcdb6c79b627a19a134d769ea6d7480"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
