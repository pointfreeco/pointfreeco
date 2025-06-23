We are excited to release version 0.7.0 of our powerful query building library: [StructuredQueries](http://github.com/pointfreeco/swift-structured-queries). It brings all new tools for building type-safe and schema-safe triggers in SQLite databases. Join us for a quick overview of this feature, and be sure to [update your dependencies](release link) to get access to these tools.

# Triggers

SQL triggers are one of the most powerful features of databases. They give you a declarative syntax for observing any insertions, updates or deletes in your tables so that you can react with additional actions. As an example, suppose you are building a reminders app that requires there to always be at least one reminders list in the app.

You could of course audit your entire code base for anytime you perform a “DELETE” statement on the “remindersLists” table and immediately afterwards check if the table is empty so that you can create a new one. But that is error prone and you are likely to forget to check if the “remindersLists” table is emptied out every time you run a query.

This is a perfect use case for SQL triggers. We can create one that monitors deletions on the “remindersLists” table so that when the table is empty we insert a brand new list:

```swift
CREATE TEMPORARY TRIGGER "nonEmptyRemindersLists"
AFTER DELETE ON "remindersLists"
FOR EACH ROW WHEN NOT (EXISTS (SELECT * FROM "remindersLists"))
BEGIN
  INSERT INTO "remindersLists"
  ("id", "color", "title")
  VALUES
  (NULL, 0xffaaff00, 'Personal');
END
```

It’s incredible how compact and declarative this SQL is, and it has a global view of the database. No matter what caused a row to be deleted from “remindersLists”, this trigger will see the deletion and be able to react to it.

Further, with version 0.7.0 of [StructuredQueries](http://github.com/pointfreeco/swift-structured-queries) we now can create these kinds of statements using a powerful, type-safe and schema-safe Swift syntax:

```swift
RemindersList.createTemporaryTrigger(
  "nonEmptyRemindersLists",
  after: .delete { old in
    RemindersList.insert { 
      RemindersList.Draft(title: "Personal") 
     }
  } when: { old in
    !RemindersList.exists()
  }
)
```

This generates the same SQL, but each step of the way Swift has our back to make sure we are only referencing symbols that actually exist in our schema.

# Get started today

This is just the basics of creating triggers in SQL. We plan to devote episodes to this topic very
soon, and these techniques form the basis of our upcoming [CloudKit synchronization] tools. In the 
meantime be sure to update to version 0.7.0 of StructuredQueries to start using these tools!

[CloudKit Synchronization]: /blog/posts/175-upcoming-live-stream-a-vision-for-modern-persistence
