import Foundation

extension Episode {
  static let ep53_swiftSyntaxEnumProperties = Episode(
    blurb: """
      We've seen how "enum properties" help close the gap between the ergonomics of accessing data on structs and enums, but defining them by hand requires a _lot_ of boilerplate. This week we join forces with Apple's Swift Syntax library to generate this boilerplate automatically!
      """,
    codeSampleDirectory: "0053-swift-syntax-enum-properties",
    exercises: _exercises,
    id: 53,
    length: 23 * 60 + 49,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_554_703_200),
    references: [],
    sequence: 53,
    title: "Swift Syntax Enum Properties",
    trailerVideo: .init(
      bytesLength: 66_870_583,
      downloadUrls: .s3(
        hd1080: "0053-trailer-1080p-3b366e5a52a94deba9d66c547eee7c58",
        hd720: "0053-trailer-720p-de336841447d4036aa89d9394e244abb",
        sd540: "0053-trailer-540p-06e87e1b124441d8863563756abac004"
      ),
      vimeoId: 349_952_503
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      One problem with our enum property code generator is that it only handles enum cases with a single associated value. Update it to handle enum cases with _no_ associated values. What type of value does this enum property return?
      """),
  Episode.Exercise(
    problem: """
      Update our code generator to handle enum cases with _several_ associated values.
      """),
  Episode.Exercise(
    problem: """
      Update our code generator to handle enum cases with labeled associated values. For example, we defined a `Node` enum in our episode on building a [Swift HTML DSL](/episodes/ep28-an-html-dsl):

      ``` swift
      enum Node {
        case el(tag: String, attributes: [String: String], children: [Node])
        case text(String)
      }
      ```

      How might labels enhance our enum properties?
      """),
  Episode.Exercise(
    problem: """
      After you add support for labeled enum cases, ensure that the code generator properly handles enum cases with a single, labeled value.
      """),
]
