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
      )
    ],
    title: "Modern Persistence"
  )
}
