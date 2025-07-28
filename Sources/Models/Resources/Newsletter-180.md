For the past 5 weeks, dozens of Point-Free community members have been testing an alpha preview of
our new SQLite + CloudKit synchronization tools. They helped us find numerous bugs and helped
us get a better understanding of how people want to use these tools in their apps.

And now we are ready to release a public beta of these tools, and we think everyone is going to be
blown away by what they are capable of. With just a few lines of code you can immediately 
synchronize a local SQLite database to CloudKit so that your user's data is available on all of 
their devices. And with just a few more lines of code you can allow your users to share their
records with participants for collaboration.

This beta period will be crucial for us to gather critical feedback so that we can release
the final version of these tools in the coming weeks. Here is everything you need to know about the 
public beta:

[SwiftData alternative]: http://github.com/pointfreeco/sharing-grdb
[live stream]: /episodes/ep329-point-free-live-a-vision-for-modern-persistence
[twitter tease]: https://x.com/pointfreeco/status/1925944881853174212

## What tools are you previewing?

Our popular [SharingGRDB] library provides a viable alternative to SwiftData that gives you 
direct access to SQLite and all of its wonderful powers. We have multiple [demos and case studies]
built with the library, including a slimmed down [version of Apple's Reminders] app that 
demonstrates advanced querying, many-to-many join tables, search, and more.

This library forms the foundation of what we like to call ["modern persistence"], but that may be
a misnomer because the library currently does not have a solution for synchronizing data across
multiple devices. That is, **until now!**

We are happy to say that we have made a lot of progress towards bringing seamless CloudKit 
integration to apps using SQLite, with the following feature set:

* **Most apps using [SharingGRDB]** will be able to enable CloudKit syncing 
in their app with just a few lines of code. You may need to make a few tweaks to your schema to 
support CloudKit, but we will provide documentation and tools to aid in that migration.
* **Synchronization happens seamlessly** behind the scenes with no additional work on your part.
You can continue reading from and writing to your database like normal, and all changes will 
automatically be synchronized to all of your user's devices.
* **Foreign keys** are supported, including constraints, one-to-many and many-to-many associations, 
and even `ON DELETE` and `ON UPDATE` cascading works.
* **Large binary assets** are supported (images, movies, audio files, _etc._) and are
automatically turned into `CKAsset`s and uploaded to CloudKit behind the scenes. 
* **Your users can share their records** with other iCloud users, all with just a few
lines of code. The library handles synchronizing changes between multiple users and all 
of their devices.
* All of the underlying CloudKit metadata (_i.e._ `CKRecord`s, `CKShare`s, etc.) are
**publicly available and queryable** from SQLite. This means you can easily query for records in
your database that are currently being shared with other iCloud users, and easily pull extra data
from CloudKit such as participants and permissions for a shared record.

It may seem too good to be true, but our library accomplishes all of this, and more.

[GRDB]: http://github.com/groue/grdb.swift
["modern persistence"]: /collections/modern-persistence
[version of Apple's Reminders]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/Reminders
[demos and case studies]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples
[SharingGRDB]: http://github.com/pointfreeco/sharing-grdb

## How can I get access to the public beta?

The public beta is being run off of the [`cloudkit`] branch of our SharingGRDB library. Simply
depend on that branch directly to get access to the CloudKit synchronization tools: 

```swift
.package(url: "https://github.com/pointfreeco/sharing-grdb", branch: "cloudkit"),
```

[`cloudkit`]: https://github.com/pointfreeco/sharing-grdb/tree/cloudkit

## What can I do with the beta?

We **do not** recommend using the beta version of these tools in the production version of an
existing app. The APIs may change before the final version, and there may be bugs that cause bad 
data to be written to your iCloud containers, or we may ask that you rotate your containers.

The most ideal way to test the beta preview would be to build a greenfield toy app with CloudKit
synchronization to get a feel for how the tools work. Here are some ideas:

* A voice memos app that synchronizes the audio file across devices. Bonus points for using the 
new [`SpeechAnalyzer`] API in iOS 26 for transcribing the audio and Foundation Models to 
summarize the memo.
* A flashcards app that allows a user to create decks of flashcards, with each deck containing 
multiple cards, and the ability to share decks with other users. Bonus points for allowing users
to associate images, audio clips and videos to the flashcards.
* A podcast app that synchronizes progress of episodes across devices. You can also add a feature
that allows a user to organize a playlist of their favorite episodes and share it with other 
users.

That's just a few fun ideas, but we're sure you can come up with more!

If you really, _really_ want to try out these tools in your app during the beta period, we 
recommend doing so in a temporary CloudKit container that you can delete at a later date. And no
matter what, _do not_ ship an app to the App Store using the beta preview of our library.

[`SpeechAnalyzer`]: https://developer.apple.com/documentation/speech/speechanalyzer

## Where can I provide feedback during the beta?

Feedback is much appreciated during the beta preview, and it would be best to open a new topic
on the [SharingGRDB][SharingGRDB discussions] repo for long form discussion, or for chat-like 
discussion you can ask questions in the #sharing-grdb channel of our [Slack].

[SharingGRDB discussions]: http://github.com/pointfreeco/sharing-grdb/discussions
[Slack]: http://pointfree.co/slack-invite

# More to come soon

This is just the beginning for these tools. Once we gather a bit of feedback we will prepare the 
official release of the tools in the coming weeks. We are excited to see what everyone makes with 
[SharingGRDB]!
