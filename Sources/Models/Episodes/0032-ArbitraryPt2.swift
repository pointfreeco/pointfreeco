import Foundation

extension Episode {
  static let ep32_decodableRandomness_pt2 = Episode(
    blurb: """
This week we compare our `Decodable` solution to building random structures with a composable solution involving the `Gen` type, exploring the differences and trade-offs of each approach. Along the way we'll rediscover a familiar old friend with a brand new application.
""",
    codeSampleDirectory: "0032-arbitrary-pt2",
    exercises: _exercises,
    id: 32,
    image: "https://i.vimeocdn.com/video/802688834.jpg",
    length: 26*60 + 25,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1538373423),
    sequence: 32,
    title: "Decodable Randomness: Part 2",
    trailerVideo: .init(
      bytesLength: 39431469,
      downloadUrl: "https://player.vimeo.com/external/351175100.hd.mp4?s=67404341e5b8c4b83894c37e28ba69b2989dfd94&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/351175100"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Redefine `Gen`'s base unit of randomness, `random`, which is a `Gen<UInt32>` to work with Swift 4.2's base unit of randomness, the `RandomNumberGenerator` protocol. The base random type should should change to `UInt64`.
"""),
  Episode.Exercise(problem: """
Swift 4.2's protocol-oriented solution allows us to define custom types that conform to `RandomNumberGenerator`. Update `Gen` to evaluate given any `RandomNumberGenerator` by changing `run`'s signature.
"""),
  Episode.Exercise(problem: """
Use a custom random number generator that can be configured with a stable seed to allow for the `Gen` type to predictably generate the same random value for a given seed.

You can look to [Nate Cook's playground](https://forums.swift.org/t/se-0202-random-unification/11313/30), shared on the Swift forums, or (for bonus points), you can define your own [linear congruential generator](https://en.wikipedia.org/wiki/Linear_congruential_generator) (or LCG).
"""),
  Episode.Exercise(problem: """
Write a helper that runs a property test for `XCTest`! A property test, given a generator and a block of code, will evaluate the block of code with a configurable number of random runs. If the block returns `true`, the property test passes. It it returns `false`, it fails. The signature should be the following.

    func forAll<A>(_ a: Gen<A>, propertyShouldHold: (A) -> Bool)

It should, internally, call an `XCTAssert` function. Upon failure, print out the seed so that it can be reproduced.
"""),
  Episode.Exercise(problem: """
Enhance the `forAll` API to take `file: StaticString = #file, line: UInt = #line`, which can be passed to XCTest in order to highlight the correct line on failure.
"""),
]
