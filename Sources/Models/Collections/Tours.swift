extension Episode.Collection {
  public static let tours = Self(
    blurb: #"""
We've open sourced a lot of software on Point-Free, and every once in awhile we like to give casual tours of one of our projects. This gives us an opportunity to show of some features and discuss topics that are hard to glean from reading the README or documentation.
"""#,
    sections: [
      .init(
        blurb: #"""
isowords is our new word game for iOS, built in SwiftUI and the Composable Architecture. We open sourced the entire code base (including the server, which is also written in Swift!), and in this multi-part tour we show how we've applied many concepts from Point-Free episodes to build a large, complex application.
"""#,
        coreLessons: [
          .init(episode: .ep142_tourOfIsowords),
          .init(episode: .ep143_tourOfIsowords),
          .init(episode: .ep144_tourOfIsowords),
          .init(episode: .ep145_tourOfIsowords),
        ],
        related: [
        ],
        title: "isowords",
        whereToGoFromHere: nil
      ),
      .init(
        blurb: #"""
We open sourced the Composable Architecture after many, _many_ months of developing the concepts from first principles in Point-Free episodes. In this tour we build a small application from scratch, focus on breaking it down to into small understandable units, and write a full test suite to exercise every subtle aspect of the application.
"""#,
        coreLessons: [
          .init(episode: .ep100_ATourOfTheComposableArchitecture_pt1),
          .init(episode: .ep101_ATourOfTheComposableArchitecture_pt2),
          .init(episode: .ep102_ATourOfTheComposableArchitecture_pt3),
          .init(episode: .ep103_ATourOfTheComposableArchitecture_pt4),
        ],
        related: [
        ],
        title: "Composable Architecture",
        whereToGoFromHere: nil
      ),
      .init(
        blurb: #"""
Our snapshot testing library is one of the most popular ways of adding screenshot testing to a code base, but the capabilities of the library go far beyond screenshots: you can snapshot _any_ kind of data type into _any_ format. We take a tour of this library by adding a snapshot test suite to a project.
"""#,
        coreLessons: [
          .init(episode: .ep41_aTourOfSnapshotTesting),
        ],
        related: [
        ],
        title: "Snapshot Testing",
        whereToGoFromHere: nil
      ),
      .init(
        blurb: #"""
The entire code base of pointfree.co has been open source since the very first day we launched. In this tour we demonstrate how a wide variety of techniques that we discuss in episodes, such as playgrounds, dependency design, testing and more, are employed in this very site.
"""#,
        coreLessons: [
          .init(episode: .ep22_aTourOfPointFree),
        ],
        related: [
        ],
        title: "www.pointfree.co",
        whereToGoFromHere: nil
      ),
    ],
    title: "Tours"
  )
}

extension Episode.Collection.Section {
  static let isowords = Self(
    blurb: #"""
isowords is our new word game for iOS, built in SwiftUI and the Composable Architecture. We open sourced the entire code base (including the server, which is also written in Swift!), and in this multi-part tour we show how we've applied many concepts from Point-Free episodes to build a large, complex application.
"""#,
    coreLessons: [
      .init(episode: .ep142_tourOfIsowords),
      .init(episode: .ep143_tourOfIsowords),
      .init(episode: .ep144_tourOfIsowords),
      .init(episode: .ep145_tourOfIsowords),
    ],
    related: [
    ],
    title: "isowords",
    whereToGoFromHere: nil
  )
}
