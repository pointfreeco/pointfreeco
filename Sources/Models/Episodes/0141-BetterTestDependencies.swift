import Foundation

extension Episode {
  public static let ep141_betterTestDependencies = Episode(
    blurb: """
Crafting better test dependencies for our code bases come with additional benefits outside of testing. We show how SwiftUI previews can be strengthened from better dependencies, and we show how we employ these techniques in our newly released game, [isowords](https://www.isowords.xyz).
""",
    codeSampleDirectory: "0141-better-test-dependencies-pt4",
    exercises: _exercises,
    id: 141,
    image: "https://i.vimeocdn.com/video/1103296509.jpg",
    length: 52*60 + 28,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1617598800),
    references: [
      .isowords,
      .isowordsGitHub,
      reference(
        forSection: .combineSchedulers,
        additionalBlurb: "",
        sectionUrl: "https://www.pointfree.co/collections/combine/schedulers"
      ),
      .designingDependencies,
      .composableArchitectureDependencyManagement,
      .theComposableArchitecture,
    ],
    sequence: 141,
    subtitle: "The Point",
    title: "Better Test Dependencies",
    trailerVideo: .init(
      bytesLength: 72548671,
      vimeoId: 531770630,
      vimeoSecret: "2cafc1cddda7d72617abe415f04f81718302fad8"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Get the [isowords code base](https://github.com/pointfreeco/isowords) running on your computer and poke around! See if you can improve the failure UI for the leaderboard view. You could even submit a [pull request](https://github.com/pointfreeco/isowords/pulls) 🤣
"""#
  ),
]
