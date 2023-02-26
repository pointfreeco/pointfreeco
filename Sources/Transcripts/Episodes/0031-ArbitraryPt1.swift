import Foundation

extension Episode {
  static let ep31_decodableRandomness_pt1 = Episode(
    blurb: """
      This week we dive deeper into randomness and composition by looking to a seemingly random place: the `Decodable` protocol. While we're used to using the `Codable` set of protocols when working with JSON serialization and deserialization, it opens the opportunity for so much more.
      """,
    codeSampleDirectory: "0031-arbitrary-pt1",
    exercises: _exercises,
    id: 31,
    length: 21 * 60 + 07,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_537_768_623),
    sequence: 31,
    title: "Decodable Randomness: Part 1",
    trailerVideo: .init(
      bytesLength: 69_153_231,
      downloadUrls: .s3(
        hd1080: "0031-trailer-1080p-262c638b214746acb90e94b2720b7a27",
        hd720: "0031-trailer-720p-c68648bacb954d9ea5578b323c63d389",
        sd540: "0031-trailer-540p-c923da8192f84451b4a64c8cfb02b6b6"
      ),
      vimeoId: 351_175_122
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      We skipped over the `allKeys` property of the `KeyedDecodingContainerProtocol`, but it's what's necessary to decode dictionaries of values. On initialization of the `KeyedDecodingContainer`, generate a random number of random `CodingKey`s to populate this property.

      You'll need to return `true` from `contains(_ key: Key)`.

      Decode a few random dictionaries of various decodable keys and values. What are some of the limitations of decoding dictionaries?
      """),
  Episode.Exercise(
    problem: """
      Create a new `UnkeyedContainer` struct that conforms to the `UnkeyedContainerProtocol` and return it from the `unkeyedContainer()` method of `ArbitraryDecoder`. As with the `KeyedDecodingContainer`, you can delete the same `decode` methods and have them delegate to the `SingleValueContainer`.

      The `count` property can be used to generate a randomly-sized container, while `currentIndex` and `isAtEnd` can be used to let the decoder know how far along it is. Generate a random `count`, default the `currentIndex` to `0`, and define `isAtEnd` as a computed property using these values. The `currentIndex` property should increment whenever `superDecoder` is called.

      Decode a few random arrays of various decodable elements.
      """),
]
