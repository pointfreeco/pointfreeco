import Foundation

extension Episode {
  public static let ep172_modularization = Episode(
    blurb: """
      We finish modularizing our application by extracting its deep linking logic across feature modules. We will then show the full power of modularization by building a "preview" application that can accomplish much more than an Xcode preview can.
      """,
    codeSampleDirectory: "0172-modularization-pt2",
    exercises: _exercises,
    id: 172,
    length: 32 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_639_980_000),
    references: [
      .init(
        author: "Gio Lodi",
        blurb: """
          An article from [Increment magazine](https://increment.com) about modularizing a code base into small feature applications:

          > How an emerging architecture pattern inspired by microservices can invigorate feature development and amplify developer velocity.
          """,
        link: "https://increment.com/mobile/microapps-architecture/",
        publishedAt: referenceDateFormatter.date(from: "2021-08-01"),
        title: "Meet the microapps architecture"
      ),
      .init(
        author: "Bartosz Polaczyk",
        blurb: """
          Once you modularize your code base you can begin uncovering new ways to speed up build times. This tool from Spotify allows you to cache and share build artifacts so that you can minimize the number of times you must build your project from scratch:

          > At Spotify, we constantly work on creating the best developer experience possible for our iOS engineers. Improving build times is one of the most common requests for infrastructure teams and, as such, we constantly seek to improve our infrastructure toolchain. We are excited to be open sourcing XCRemoteCache, the library we created to mitigate long local builds.
          """,
        link:
          "https://engineering.atspotify.com/2021/11/16/introducing-xcremotecache-the-ios-remote-caching-tool-that-cut-our-clean-build-times-by-70/",
        publishedAt: referenceDateFormatter.date(from: "2021-11-16"),
        title:
          "Introducing XCRemoteCache: The iOS Remote Caching Tool that Cut Our Clean Build Times by 70%"
      ),
      reference(
        forSection: .isowords,
        additionalBlurb:
          "We previously discussed modularity and modern Xcode projects in our tour of [isowords](https://github.com/pointfreeco/isowords).",
        sectionUrl: "https://www.pointfree.co/collections/tours/isowords"
      ),
    ],
    sequence: 172,
    subtitle: "Part 2",
    title: "Modularization",
    trailerVideo: .init(
      bytesLength: 80_794_646,
      downloadUrls: .s3(
        hd1080: "0172-trailer-1080p-0a14af0c02ff41e38b61bcca5176ccc7",
        hd720: "0172-trailer-720p-66df92f1a732455994304fb418f83bb8",
        sd540: "0172-trailer-540p-1e41d12e436b4e919bed7160b40013f0"
      ),
      vimeoId: 656_319_844
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Add a "Routing.swift" file to the "ItemFeature" target, and extract item-specific routing to it, like the `item` query parser.
      """#
  ),
  .init(
    problem: #"""
      Create an "InventoryPreviewApp" that allows you to run the full inventory feature in a dedicated, sandboxed application. Make it capable of deep linking through a custom URL scheme.
      """#
  ),
]
