extension Episode.Collection {
  public static let sqlite = Self(
    blurb: """
      SQLite is one of the most well-crafted, battle-tested, widely-deployed pieces of software \
      in history, and it's a great fit for apps with more complex persistence needs than user \
      defaults or a JSON file. This collection serves as an introduction to the basics of SQLite, \
      as well as an exploration into more advanced topics and techniques for integrating SQLite \
      into your applications.
      """,
    sections: [
      .sqliteIntroduction,
      Episode.Collection.Section(
        blurb: """
          Our [Swift Sharing](http://github.com/pointfreeco/swift-sharing) library allows one to \
          hold onto state in feature code that is secretly powered by an external storage system, \
          such as user defaults and the file system. But it is also flexible enough to be powered \
          by SQLite too, and when done properly a lot of amazing powers are unlocked.
          """,
        coreLessons: [
          .init(episode: .ep309_sqliteSharing)
          //          .init(episode: .ep310_sqliteSharing),
          //          .init(episode: .ep311_sqliteSharing),
          //          .init(episode: .ep312_sqliteSharing),
        ],
        isFinished: false,
        isHidden: false,
        related: [],
        title: "Sharing with SQLite",
        whereToGoFromHere: nil
      ),
    ],
    title: "SQLite"
  )
}

extension Episode.Collection.Section {
  static let sqliteIntroduction = Self(
    alternateSlug: nil,
    blurb: """
      SQLite is one of the most well-crafted, battle-tested, widely-deployed pieces of software \
      in history, and it's a great fit for apps with more complex persistence needs than user \
      defaults or a JSON file. Let's get familiar with the library, starting with a crash course \
      in interacting with C code from Swift, and ending with an overview of a popular Swift \
      library for interfacing with SQLite called [GRDB](http://github.com/groue/GRDB.swift). 
      """,
    coreLessons: [
      .init(episode: .ep301_sqlite),
      .init(episode: .ep302_sqlite),
      .init(episode: .ep303_sqlite),
      .init(episode: .ep304_sqlite),
    ],
    isHidden: false,
    related: [],
    title: "Introduction to SQLite",
    whereToGoFromHere: nil
  )
}
