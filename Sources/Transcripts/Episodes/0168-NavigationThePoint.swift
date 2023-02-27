import Foundation

extension Episode {
  public static let ep168_navigationThePoint = Episode(
    blurb: """
      We've claimed that the way we handle navigation in SwiftUI unlocks the ability to deep link to any screen in your application, so let's put that claim to the test. We will add real-world deep linking to our application, from scratch, using the parsing library we open sourced many months ago.
      """,
    codeSampleDirectory: "0168-navigation-pt9",
    exercises: _exercises,
    id: 168,
    length: 59 * 60 + 51,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_636_956_000),
    references: [
      .swiftUINav,
      .swiftParsing,
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
          """#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 168,
    subtitle: "The Point",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 120_965_531,
      downloadUrls: .s3(
        hd1080: "0168-trailer-1080p-853b157347684363a0daa8b35e54e8d1",
        hd720: "0168-trailer-720p-768a69863a394644a7a31b0652c70907",
        sd540: "0168-trailer-540p-e76778cee7e94909bd0ced813fe4ac33"
      ),
      vimeoId: 645_272_445
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Add a deep linker route for duplicating an item.
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      Refactor the `inventoryDeepLinker` to group the "add" and "color picker" routes so that the `add` path component is parsed at most a single time.
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      Add the ability to deep-link into the edit and duplicate screens and further pre-fill fields and link further into the color picker screens. Try to re-use the `ItemRoute` and `item` parser to handle these routes.

      Note that parsing `Item`s as is will prevent you from deep-linking to edit or duplicate and overriding a single field. Instead, introduce a new data structure that allows you to selectively override an `Item`'s fields.
      """#,
    solution: nil
  ),

]
