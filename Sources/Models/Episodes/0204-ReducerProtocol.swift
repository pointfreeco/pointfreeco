import Foundation

extension Episode {
  public static let ep204_reducerProtocol = Episode(
    blurb: """
      The new reducer protocol has improved many things, but we’re  now in an awkward place when it comes to defining them: some are conformances and some are not. We’ll fix that with inspiration from SwiftUI and the help of a new protocol feature.
      """,
    codeSampleDirectory: "0204-reducer-protocol-pt4",
    exercises: _exercises,
    id: 204,
    length: 32 * 60 + 0,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_662_958_800),
    references: [
      .se0215_conformNeverToEquatableAndHashable,
      .se0346_primaryAssociatedTypes,
      .init(
        author: "Dan Zheng, Holly Borla, Doug Gregor, et al.",
        blurb: #"""
          A forum discussion about result builder generic inference and how it differs from the rest of Swift.
          """#,
        link:
          "https://forums.swift.org/t/function-builder-cannot-infer-generic-parameters-even-though-direct-call-to-buildblock-can/35886/5",
        publishedAt: referenceDateFormatter.date(from: "2020-04-26"),
        title:
          "Function builder cannot infer generic parameters even though direct call to `buildBlock` can"
      ),
    ],
    sequence: 204,
    subtitle: "Composition, Part 2",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 59_300_000,
      downloadUrls: .s3(
        hd1080: "0204-trailer-1080p-ef73e9ab4bef4573bda5da0069be4d9e",
        hd720: "0204-trailer-720p-50ddebd3afc84163a2a65741e5624d70",
        sd540: "0204-trailer-540p-e093c8120bee4f48bb874fb93e2937d7"
      ),
      vimeoId: 742_853_158
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
