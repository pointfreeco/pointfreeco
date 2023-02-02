import Foundation

extension Episode {
  public static let ep221_pfLive_dependenciesStacks = Episode(
    blurb: """
      Our first ever livestream! We talk about a few new features that made it into our
      [Dependencies](http://github.com/pointfreeco/swift-dependencies) library when we extracted it
      from the Composable Architecture, live code our way through a `NavigationStack` refactor of
      our [Standups](http://github.com/pointfreeco/standups) app, and answer your questions along
      the way!
      """,
    codeSampleDirectory: "0221-pflive-dependencies-stacks",
    exercises: _exercises,
    format: .livestream,
    id: 221,
    length: 94 * 60 + 34,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-02-06")!,
    references: [
      .onTheNewPointFreeDependenciesLibrary,
      .swiftDependencies,
      .designingDependencies,
      .theComposableArchitecture,
      .swiftUINav,
      .swiftUINavigation,
      .isowordsGitHub,
      .isowords,
    ],
    sequence: 221,
    subtitle: "Dependencies & Stacks",
    title: "Point-Free Live",
    trailerVideo: .init(
      bytesLength: 44_200_000,
      downloadUrls: .s3(
        hd1080: "0221-trailer-1080p-8979f93a83ee49fcad7acb291c15264c",
        hd720: "0221-trailer-720p-b434d9a0fca44f14990171929136754f",
        sd540: "0221-trailer-540p-5cd5fcac05ed4dd288f1a56a6550d01b"
      ),
      vimeoId: 795389609
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
