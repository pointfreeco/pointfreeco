extension Episode.Collection {
  public static let modernPersistence = Self(
    blurb: """
      What are the best, modern practices for persisting your application's state? We explore \
      the topic by rebuilding Apple's Reminders app from scratch using SQLite, the most widely \
      deployed database in all software. We will dive into many of SQL's most powerful \
      features, such as foreign keys, triggers, common table expressions, and more. 
      """,
    sections: [
      .init(
        alternateSlug: nil,
        blurb: """
          What are the best, modern practices for persisting your application's state? We explore \
          the topic by rebuilding Apple's Reminders app from scratch using SQLite, the most widely \
          deployed database in all software. We will dive into many of SQL's most powerful \
          features, such as foreign keys, triggers, common table expressions, and more. 
          """,
        coreLessons: [
          Section.Lesson(episode: .ep323_modernPersistence),
          Section.Lesson(episode: .ep324_modernPersistence),
          Section.Lesson(episode: .ep325_modernPersistence),
          Section.Lesson(episode: .ep326_modernPersistence),
          Section.Lesson(episode: .ep327_modernPersistence),
          Section.Lesson(episode: .ep328_modernPersistence),
        ],
        isFinished: true,
        isHidden: false,
        related: [],
        title: "Modern Persistence",
        whereToGoFromHere: nil
      ),
      .init(
        alternateSlug: nil,
        blurb: """
          SQLite triggers are an incredibly powerful tool that is criminally underused in the \
          iOS community. They give you a global view into what is happening in your database, and \
          allow you to react to those events by executing additional SQL statements, raising \
          errors, and even calling directly into your Swift code!
          """,
        coreLessons: [
          Section.Lesson(episode: .ep330_callbacks),
          Section.Lesson(episode: .ep331_callbacks),
          Section.Lesson(episode: .ep332_callbacks),
          Section.Lesson(episode: .ep333_callbacks),
        ],
        isFinished: true,
        isHidden: false,
        related: [],
        title: "SQLite Triggers",
        whereToGoFromHere: nil
      ),
      .init(
        alternateSlug: nil,
        blurb: """
          Full-text search is a technology that allows a user to efficiently search a large \
          collection of documents for a search term, and includes advanced features such as \
          tokenizing, stemming and supports a basic query language for constructing complex search \
          terms. We give an overview of the technology by building powerful search capabilities \
          into a reminders app.
          """,
        coreLessons: [
          Section.Lesson(episode: .ep334_fts),
          Section.Lesson(episode: .ep335_fts),
          Section.Lesson(episode: .ep336_fts),
          Section.Lesson(episode: .ep337_fts),
          Section.Lesson(episode: .ep338_fts),
          Section.Lesson(episode: .ep339_fts),
        ],
        isFinished: true,
        isHidden: false,
        related: [],
        title: "Full-Text Search",
        whereToGoFromHere: nil
      ),
      .init(
        alternateSlug: nil,
        blurb: """
          Can this collection really be called "modern" persistence if we don't describe how to \
          synchronize data across all of a user's devices? Of course not! It's now time to show \
          how our powerful [SQLiteData] library makes synchronizing your users' local data to \
          CloudKit a breeze, and even how they can share data with other iCloud users for \
          collaboration.

          [SQLiteData]: http://github.com/pointfreeco/sqlite-data
          """,
        coreLessons: [
          Section.Lesson(episode: .ep340_sync),
          Section.Lesson(episode: .ep341_sync),
          Section.Lesson(episode: .ep342_sync),
          Section.Lesson(episode: .ep343_sync),
        ],
        isFinished: false,
        isHidden: false,
        related: [],
        title: "CloudKit synchronization",
        whereToGoFromHere: nil
      ),
    ],
    title: "Modern Persistence"
  )
}
