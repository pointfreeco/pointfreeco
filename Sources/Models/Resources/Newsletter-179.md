After a few weeks of [teasing][twitter tease] the CloudKit synchronization tools coming to our
[SwiftData alternative], and demoing the tools during last week's [live stream], we are finally 
ready to release a private alpha. This alpha period will help us gather critical feedback so that 
we can release a public alpha in the coming weeks, and then eventually the final release of the 
tools.

Here is everything you need to know about the private alpha:

[SwiftData alternative]: http://github.com/pointfreeco/sharing-grdb
[live stream]: TODO
[twitter tease]: https://x.com/pointfreeco/status/1925944881853174212

### What tools are you previewing?

Our popular [SharingGRDB] library provides a viable alternative to SwiftData that gives you 
direct access to SQLite and all of its wonderful powers. We have multiple [demos and case studies]
built with the library, including a slimmed down [version of Apple's Reminders] app that 
demonstrates advanced querying, many-to-many join tables, search, and more.

This library forms the foundation of what we like to call ["modern persistence"], but that may be
a misnomer because the library currently does not have a solution for synchronizating data across
multiple devices. That is, **until now!**

We are happy to say that we have made a lot of progress towards bringing seamless CloudKit 
integration to apps using SQLite, with the following feature set:

* **Most apps using [SharingGRDB]** will be able to enable CloudKit syncing 
in their app with just a few lines of code. You may need to make a few tweaks to your schema to 
support CloudKit, but we will provide documentation and tools to aid in that migration.
* **Synchronization happens seamlessly** behind the scenes with no additional work on your part.
You can continue reading from and writing to your database like normal, and all changes will 
automatically be synchronized to all of your user's devices.
* **Foreign keys** are supported, including one-to-many and many-to-many associations, and even
"ON DELETE" and "ON UPDATE" cascading works. However, foreign key _constraints_ are not supported
(i.e. requiring that a parent record to exist for a child to point to it) because CloudKit may 
deliver records in multiple, disconnected batches.
* **Large binary assets** are supported (images, movies, audio files, etc.) and are automatically turned
into `CKAsset`s and uploaded to CloudKit behind the scenes. 
* You can allow **sharing of records and their assocations** in your user's database with just a few
lines of code. The library handles synchronizing changes between multiple different users and all of
their devices.
* All of the underlying CloudKit metadata (i.e. `CKRecord`s, `CKShare`s, etc.) are all **publicly
available and queryable** from SQLite. This means you can easily query for records in your 
database that are currently being shared with other iCloud users, and easily pull extra data
from CloudKit such as participants and permissions for a shared record.

It may seem too good to be true, but our library accomplishes all of this, and more.

[GRDB]: http://github.com/groue/grdb.swift
["modern persistence"]: /collections/modern-persistence
[version of Apple's Reminders]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/Reminders
[demos and case studies]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples
[SharingGRDB]: http://github.com/pointfreeco/sharing-grdb

### How can I get access to the public alpha?

Currently we are opening the alpha only to [Point-Free subscribers](/pricing). This will give us
a smaller audience to get feedback from and an audience that is already familiar with our work.
If you are interested in participating in the alpha preview, 
[contact us](mailto:support@pointfreeo.co) from the email that is associated with your Point-Free
account, and provide your GitHub username.

### What can I do with the alpha?

We **do not** recommend using the alpha version of these tools in the production version of an
existing app or an app you plan on releasing soon. The APIs will most likely change before
the final version, and there may be bugs that cause bad data to be written to your iCloud 
containers.

The most ideal way to test the alpha preview would be to build a greenfield toy app with CloudKit
synchronization to get a feel for how the tools work. Here are some ideas:

* 

### Where can I provide feedback during the alpha?

Feedback is much appreciated during the alpha preview, and it would be best to open a new topic
on the [SharingGRDB][SharingGRDB discussions] repo for long form discussion, or for chat-like 
discussion you can ask questions in the #sharing-grdb channel of our [Slack].

[SharingGRDB discussions]: http://github.com/pointfreeco/sharing-grdb/discussions
[Slack]: http://pointfree.co/slack-invite
