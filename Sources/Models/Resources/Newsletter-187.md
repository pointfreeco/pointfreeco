Three weeks ago we released SQLiteData 1.0, a library that allows one to persist user data using SQLite and seamlessly synchronizes data to all of your users’ devices via CloudKit. However, one big caveat to CloudKit synchronization is that your database tables must all have globally unique primary keys (e.g. UUIDs). That is easy enough to accommodate when building a new app, but existing apps are likely to have simple, auto-increment integer IDs for their tables, which are not CloudKit sync compatible.

The steps to migrate such tables to be CloudKit sync-compatible are numerous, complex, and easy to get wrong. That is why we are excited to announce that with [SQLiteData 1.1](https://github.com/pointfreeco/sqlite-data/releases/tag/1.1.0) we are providing a dedicated tool for migrating your existing schema to convert any integer primary keys to UUIDs.

## Migrating an existing schema without our tool

Before showing off the tool, it is important to understand just how much of a slog it can be to migrate any existing schema manually. While SQLite is an incredibly powerful tool, it unfortunately does not offer a robust set of table alteration tools. The only alterations you can make to existing tables are renaming tables and columns, as well as adding and deleting columns. In particular, there is no way to change the definition of a column, such as changing its type from "INTEGER AUTOINCREMENT" to "TEXT DEFAULT (uuid())".

However, the SQLite docs do provide a [concise 12-step program](https://sqlite.org/lang_altertable.html#making_other_kinds_of_table_schema_changes) you can follow to perform such alterations. The essence of these steps really boils down to just 4 fundamental steps:

1. create a new table with the schema you want for your table,
2. copy the data from the old table to the new table and during this copy convert the integer IDs from the old table to UUIDs,
3. drop the old table, and then finally
4. rename the new table to have the old table’s name.

As an example of this 4-step process, here is what it takes to migrate a `remindersLists` table with 4 columns (`id`, `color`, `title`, `position`) from using an auto-incrementing integer ID to a UUID:

```swift
// Step 1: Create a new table with the schema you want, i.e. a UUID primary key.
try #sql(
  """
  CREATE TABLE "new_remindersLists" (
    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
    "color" INTEGER NOT NULL DEFAULT 1251602431,
    "title" TEXT NOT NULL DEFAULT '', 
    "position" INTEGER NOT NULL DEFAULT 0
  ) STRICT
  """
)
.execute(db)

// Step 2: Copy the data from the old table to the new, and along the way convert
//         integer primary keys to UUIDs.
try #sql(
  """
  INSERT INTO "new_remindersLists"
  SELECT
    '00000000-0000-0000-0000-' || printf('%012x', "id"),
    "color", 
    "title", 
    "position"
  FROM "remindersLists"
  """
)
.execute(db)

// Step 3: Drop the old table.
try #sql(
  """
  DROP TABLE "remindersLists"
  """
)
.execute(db)

// Step 4: Rename the new table to have the old table's name.
try #sql(
  """
  ALTER TABLE "new_remindersLists" RENAME TO "remindersLists"
  """
)
.execute(db)
```

This is quite a bit of work, and this is only one table. You may have dozens of tables you have to convert, and things only get more complicated for tables that have foreign keys, indices, triggers and more. 

But in reality there are a few more important steps to take in addition to these. For example, all of these steps should be wrapped in a database transaction and foreign key constraints should be temporarily turned off so that during this migration foreign keys are allowed to point to non-existent tables. Further, any indices and stored triggers that were affected by the dropping of tables need to be recreated, *and* a dedicate [foreign key check](https://sqlite.org/pragma.html#pragma_foreign_key_check) should be run on the database to make sure that data integrity is still upheld after the migration. And lastly, it is technically not correct to create UUIDs in the simplistic fashion above. It would be best to create legitimately unique IDs for the new table.

And so the process for migrating an existing database can be quite a pain, and can unfortunately prevent you from taking advantage of our seamless CloudKit synchronization tools.

## Migrating an existing schema with our tool

Well, that was until [SQLiteData 1.1](https://github.com/pointfreeco/sqlite-data/releases/tag/1.1.0). This release brings a dedicate tool for migrating an existing database to use globally unique primary keys. What could have been hundreds of lines of SQL code for creating temporary tables, copying data, dropping tables, and renaming tables, now becomes one single statement:

```swift
try SyncEngine.migratePrimaryKeys(
  db,
  tables: 
    RemindersList.self, 
    Reminder.self, 
    Tag.self, 
    ReminderTag.self
)
```

And this tool properly follows the extended 12-step program from SQLite’s documentation, including recreating indices and stored triggers that were affected by the migration, and performing a foreign key check to make sure data integrity is upheld.

# Get started today

If you were holding off on enabling CloudKit synchronization in your app because you dreaded the migration you were going to have to perform on your database, then fear no more! Upgrade to [SQLiteData 1.1](https://github.com/pointfreeco/sqlite-data/releases/tag/1.1.0) today and give our new `migratePrimaryKeys` tool a spin.
