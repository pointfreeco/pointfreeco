import Foundation

extension Episode {
  public static let ep149_derivedBehavior = Episode(
    blurb: """
We will explore two more domain transformations in the Composable Architecture. One comes with the library: the ability to embed a smaller domain, optionally, in a larger domain. Another we will build from scratch: the ability to embed smaller domains in the cases of an enum!
""",
    codeSampleDirectory: "0149-derived-behavior-pt4",
    exercises: _exercises,
    id: 149,
    length: 81*60 + 4,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1623646800),
    references: [
      Episode.Reference(
        author: "Luke Redpath",
        blurb: #"""
Earlier this year, one of our viewers, [Luke Redpath](http://twitter.com/lukeredpath/status/1403333865108873217), started a Composable Architecture GitHub discussion around the creation of a `SwitchStore`-like view that inspired the design introduced in this episode.
"""#,
        link: "https://github.com/pointfreeco/swift-composable-architecture/discussions/388",
        publishedAt: referenceDateFormatter.date(from: "2021-02-18"),
        title: "GitHub Discussion: CaseLetStore (for example)"
      ),
      .init(
        author: "Brandon Williams and Stephen Celis",
        blurb: """
          After publishing this episode we released 0.19.0 of the Composable Architecture, bringing `SwitchStore` and `CaseLet` views to all users of the library.
          """,
        link: "https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.19.0",
        publishedAt: referenceDateFormatter.date(from: "2021-06-14"),
        title: "Composable Architecture Release 0.19.0"
      )
    ],
    sequence: 149,
    subtitle: "Optionals and Enums",
    title: "Derived Behavior",
    trailerVideo: .init(
      bytesLength: 42478068,
      downloadUrls: .s3(
        hd1080: "0149-trailer-1080p-21620c7ecb704fa990d8b8856c8aaef0",
        hd720: "0149-trailer-720p-e9f08cc848e542a3a988152677ba114b",
        sd540: "0149-trailer-540p-c98dee5f8b3245e48cbe4f4bf444520a"
      ),
      vimeoId: 561807126
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Enhance the `SwitchStore` with a `Default` view that can be tacked to the end of its content block and is evaluated if none of the given `CaseLet` cases match.
"""#,
    solution: nil
  )
]
