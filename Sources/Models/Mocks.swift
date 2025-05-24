import Foundation

extension Episode {
  public static let mock = subscriberOnlyEpisode
  public static let free = freeEpisode
  public static let subscriberOnly = subscriberOnlyEpisode
}

extension Episode.Reference {
  public static let mock = Episode.Reference(
    author: "Blob",
    blurb: "Blob uses functional programming to impress all of their friends.",
    link: "https://www.pointfree.co/episodes/ep100-this-is-a-really-long-url",
    publishedAt: Date(timeIntervalSince1970: 1_234_567_890),
    title: "Functional Programming is Fun!"
  )
}

extension Episode.Exercise {
  public static let mock = Episode.Exercise(
    problem: """
      Show that every simply-connected, 3-dimensional manifold is homeomorphic to the 3-sphere.

      ```
      pi_1(X) = 0
      ```
      """,
    solution: "Let g be a Riemannian metric on X, and consider the Ricci flow..."
  )
}

private let subscriberOnlyEpisode = Episode(
  blurb: """
    This is a short blurb to give a high-level overview of what the episode is about. It can only be plain
    text, no markdown allowed. Here is some more text just to have some filler.
    """,
  codeSampleDirectory: "ep2-proof-in-functions",
  exercises: [.mock],
  fullVideo: .init(
    bytesLength: 500_000_000,
    downloadUrls: .s3(
      hd1080: "TODO",
      hd720: "TODO",
      sd540: "TODO"
    ),
    id: "deadbeef"
  ),
  id: 2,
  image: "",
  length: 1380,
  permission: .subscriberOnly,
  publishedAt: Date(timeIntervalSince1970: 1_482_192_000),
  sequence: 2,
  title: "Proof in Functions",
  trailerVideo: .init(
    bytesLength: 5_000_000,
    downloadUrls: .s3(
      hd1080: "TODO",
      hd720: "TODO",
      sd540: "TODO"
    ),
    id: "deadbeef"
  )
)

private let freeEpisode = Episode(
  blurb: """
    As server-side Swift becomes more popular and widely adopted, it will be important to re-examine some of the past “best-practices” of web frameworks to see how Swift’s type system can improve upon them.
    """,
  codeSampleDirectory: "ep1-type-safe-html",
  exercises: [.mock],
  fullVideo: .init(
    bytesLength: 500_000_000,
    downloadUrls: .s3(
      hd1080: "TODO",
      hd720: "TODO",
      sd540: "TODO"
    ),
    id: "deadbeef"
  ),
  id: 1,
  image: "",
  length: 1380,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_497_960_000),
  sequence: 1,
  title: "Type-Safe HTML in Swift",
  trailerVideo: Episode.mock.trailerVideo
)

extension Episode.Collection {
  public static var mock: Episode.Collection {
    Episode.Collection(
      blurb: #"""
        This is the blurb for the collection. It can be as long as you want, and it _can_ contain `markdown`.
        """#,
      sections: [
        .init(
          blurb: #"""
            This is the blurb for the section of the collection.
            """#,
          coreLessons: [
            .init(episode: .mock),
            .init(episode: .free),
          ],
          related: [
            .init(
              blurb: #"""
                This is a blurb for some related grouping of episodes.
                """#,
              content: .episodes([.mock, .mock])
            ),
            .init(
              blurb: #"""
                This is a blurb for a single related episode
                """#,
              content: .episode(.mock)
            ),
          ],
          title: "Functions that begin with A",
          whereToGoFromHere: #"""
            Here are some closing remarks for the collection.
            """#
        ),
        .init(
          blurb: #"""
            This is the blurb for the section of the collection.
            """#,
          coreLessons: [
            .init(episode: .mock),
            .init(episode: .free),
          ],
          related: [
            .init(
              blurb: #"""
                This is a blurb for some related grouping of episodes.
                """#,
              content: .episodes([.mock, .mock])
            ),
            .init(
              blurb: #"""
                This is a blurb for a single related episode
                """#,
              content: .episode(.mock)
            ),
          ],
          title: "Functions that begin with B",
          whereToGoFromHere: #"""
            Here are some closing remarks for the collection.
            """#
        ),
        .init(
          blurb: #"""
            This is the blurb for the section of the collection.
            """#,
          coreLessons: [
            .init(episode: .mock),
            .init(episode: .free),
          ],
          related: [
            .init(
              blurb: #"""
                This is a blurb for some related grouping of episodes.
                """#,
              content: .episodes([.mock, .mock])
            ),
            .init(
              blurb: #"""
                This is a blurb for a single related episode
                """#,
              content: .episode(.mock)
            ),
          ],
          title: "Functions that begin with C",
          whereToGoFromHere: #"""
            Here are some closing remarks for the collection.
            """#
        ),
      ],
      title: "Functions"
    )
  }
}
