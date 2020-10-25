import Foundation

extension Episode {
  public static let ep122_parsersRecap = Episode(
    blurb: """
We finish up our XCTest log parser by parsing out the data associated with a test failure. Once done we will format the results in a pretty way and package everything up in a CLI tool we can run in our own projects.
""",
    codeSampleDirectory: "0122-parsers-recap-pt4",
    exercises: _exercises,
    id: 122,
    image: "TODO",
    length: 28*60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1603688400),
    references: [
      reference(
        forCollection: .parsing,
        additionalBlurb: "New to parsing? Start our collection from the beginning!",
        collectionUrl: "https://www.pointfree.co/collections/parsing"
      ),
    ],
    sequence: 122,
    subtitle: "Part 2",
    title: "Parsing Xcode Logs",
    trailerVideo: .init(
      bytesLength: 18137087,
      vimeoId: 470758672,
      vimeoSecret: "9dfacb340ffdba1d62c2b140b3da0a1c76b5a596"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
