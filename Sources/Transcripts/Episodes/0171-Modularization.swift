import Foundation

extension Episode {
  public static let ep171_modularization = Episode(
    blurb: """
      We've talked about modularity a lot in the past, but we've never devoted full episodes to show how we approach the subject. We will define and explore various kinds of modularity, and we’ll show how to modularize a complex application from scratch using modern build tools.
      """,
    codeSampleDirectory: "0171-modularization-pt1",
    exercises: _exercises,
    id: 171,
    length: 43 * 60 + 55,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_639_375_200),
    references: [
      .init(
        author: "Gio Lodi",
        blurb: """
          An article from [Increment magazine](https://increment.com) about modularizing a code base into small feature applications:

          > How an emerging architecture pattern inspired by microservices can invigorate feature development and amplify developer velocity.
          """,
        link: "https://increment.com/mobile/microapps-architecture/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-08-01"),
        title: "Meet the microapps architecture"
      ),
      .init(
        author: "Alejandro Martinez",
        blurb: """
          A detailed post touching code base structure, modularity, UI, architecture and more.
          """,
        link: "https://alejandromp.com/blog/ios-app-architecture-in-2022/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-12-15"),
        title: "iOS App Architecture in 2022"
      ),
      .init(
        author: "Bartosz Polaczyk",
        blurb: """
          Once you modularize your code base you can begin uncovering new ways to speed up build times. This tool from Spotify allows you to cache and share build artifacts so that you can minimize the number of times you must build your project from scratch:

          > At Spotify, we constantly work on creating the best developer experience possible for our iOS engineers. Improving build times is one of the most common requests for infrastructure teams and, as such, we constantly seek to improve our infrastructure toolchain. We are excited to be open sourcing XCRemoteCache, the library we created to mitigate long local builds.
          """,
        link:
          "https://engineering.atspotify.com/2021/11/16/introducing-xcremotecache-the-ios-remote-caching-tool-that-cut-our-clean-build-times-by-70/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-11-16"),
        title:
          "Introducing XCRemoteCache: The iOS Remote Caching Tool that Cut Our Clean Build Times by 70%"
      ),
      .init(
        author: nil,
        blurb: """
          XcodeGen is a developer tool that automates the process of creating an Xcode project. This helps prevent merge conflicts and makes it easier to maintain a large project.
          """,
        link: "https://github.com/yonaskolb/XcodeGen",
        publishedAt: nil,
        title: "XcodeGen"
      ),
      .init(
        author: nil,
        blurb: """
          Tuist is a collection of dev tools that make it easier for you to maintain an Xcode project with many app targets and frameworks.
          """,
        link: "https://github.com/tuist",
        publishedAt: nil,
        title: "Tuist"
      ),
      .init(
        author: nil,
        blurb: """
          A classic tool in the iOS development community that helps manage dependencies, but can also be used to split your existing codebase into separate frameworks.
          """,
        link: "https://cocoapods.org",
        publishedAt: nil,
        title: "Cocoapods"
      ),
      reference(
        forSection: .isowords,
        additionalBlurb:
          "We previously discussed modularity and modern Xcode projects in our tour of [isowords](https://github.com/pointfreeco/isowords).",
        sectionUrl: "https://www.pointfree.co/collections/tours/isowords"
      ),
      .isowordsGitHub,
      .isowords,
    ],
    sequence: 171,
    subtitle: "Part 1",
    title: "Modularization",
    trailerVideo: .init(
      bytesLength: 276_338_642,
      downloadUrls: .s3(
        hd1080: "0171-trailer-1080p-d8aff62e3261446cbb12dc177a7edb66",
        hd720: "0171-trailer-720p-705bb09565ac4baaa7ebf0c855842308",
        sd540: "0171-trailer-540p-372e87f996cf43c688a512a3298f33c2"
      ),
      vimeoId: 655_905_170
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 171)
  )
}

private let _exercises: [Episode.Exercise] = []

extension Episode.Video {
  public static let ep171_modularization = Self(
    bytesLength: 620_286_634,
    downloadUrls: .s3(
      hd1080: "0171-1080p-ac573b187ace476db33ee1122e30e80d",
      hd720: "0171-720p-0408e3aafa554b70be2b869841dbad5e",
      sd540: "0171-540p-1b30d4fc60a943139e2e8deebb83d1cd"
    ),
    vimeoId: 655_905_307
  )
}
