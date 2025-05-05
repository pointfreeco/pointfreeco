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
          .init(episode: .ep323_modernPersistence)
          //          .init(episode: .ep324_modernPersistence),
          //          .init(episode: .ep325_modernPersistence),
        ],
        isFinished: false,
        isHidden: false,
        related: [],
        title: "Modern Persistence",
        whereToGoFromHere: nil
      )
    ],
    title: "Modern Persistence"
  )
}
