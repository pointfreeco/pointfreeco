import Foundation

extension Episode {
  public static let ep31_decodableRandomness_pt1 = Episode(
    blurb: """
This week we dive deeper into randomness and composition by looking to a seemingly random place: the `Decodable` protocol. While we're used to using the `Codable` set of protocols when working with JSON serialization and deserialization, it opens the opportunity for so much more.
""",
    codeSampleDirectory: "0031-arbitrary-pt1",
    exercises: _exercises,
    id: 31,
    image: "https://i.vimeocdn.com/video/802690082.jpg",
    length: 21*60 + 07,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 30,
    publishedAt: Date(timeIntervalSince1970: 1537768623),
    sequence: 31,
    title: "Decodable Randomness: Part 1",
    trailerVideo: .init(
      bytesLength: 69153231,
      downloadUrl: "https://player.vimeo.com/external/351175122.hd.mp4?s=9b46fc81f136e60ea84331179186488ef3722132&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/351175122"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
We skipped over the `allKeys` property of the `KeyedDecodingContainerProtocol`, but it's what's necessary to decode dictionaries of values. On initialization of the `KeyedDecodingContainer`, generate a random number of random `CodingKey`s to populate this property.

You'll need to return `true` from `contains(_ key: Key)`.

Decode a few random dictionaries of various decodable keys and values. What are some of the limitations of decoding dictionaries?
"""),
  Episode.Exercise(problem: """
Create a new `UnkeyedContainer` struct that conforms to the `UnkeyedContainerProtocol` and return it from the `unkeyedContainer()` method of `ArbitraryDecoder`. As with the `KeyedDecodingContainer`, you can delete the same `decode` methods and have them delegate to the `SingleValueContainer`.

The `count` property can be used to generate a randomly-sized container, while `currentIndex` and `isAtEnd` can be used to let the decoder know how far along it is. Generate a random `count`, default the `currentIndex` to `0`, and define `isAtEnd` as a computed property using these values. The `currentIndex` property should increment whenever `superDecoder` is called.

Decode a few random arrays of various decodable elements.
"""),
]
