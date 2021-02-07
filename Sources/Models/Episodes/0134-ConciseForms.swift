import Foundation

extension Episode {
  public static let ep134_conciseForms = Episode(
    blurb: """
Our series on forms in vanilla SwiftUI and the Composable Architecture has been firmly rooted in reality, so this time we will emphasize the point of concise forms in a real world project that we've been building.
""",
    codeSampleDirectory: "0134-concise-forms-pt4",
    exercises: _exercises,
    id: 134,
    image: "https://i.vimeocdn.com/video/TODO.jpg",
    length: 28*60 + 14,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1612764000),
    references: [
      .init(
        author: "Point-Free",
        blurb: "A word game by us, written in the Composable Architecture.",
        link: "https://www.isowords.xyz",
        publishedAt: nil,
        title: "isowords"
      ),
    ],
    sequence: 134,
    subtitle: "The Point",
    title: "Concise Forms",
    trailerVideo: .init(
      bytesLength: 59604438,
      vimeoId: 508418621,
      vimeoSecret: "c5db454d026563010c387a771b9fe16a55cef7e8"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]
