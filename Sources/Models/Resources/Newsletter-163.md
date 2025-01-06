We are making the 4-part series "[Tour of Sharing][tour-of-sharing]" free for everyone to watch!
In these 4 episodes we introduce a few of the most important concepts in our new 
[Swift Sharing][sharing-gh] library, which provides a universal solution to persistence and 
data sharing across your app.

We cover the 3 main forms of persistence strategies that come with the library:

* [`appStorage`][app-storage-docs]: This tool allows you to persist small bits
of data to `UserDefaults`. We also show how this tool compares to what SwiftUI provides out of the
box (spoiler: ours has better support for animations and works _anywhere_ in an app, not just a 
SwiftUI view), and we show how it provides a type-safe interface to `UserDefaults`.

* [`fileStorage`][file-storage-docs]: This tool allows you to persist more complex data structures
to the file system. We also demonstrate how it observes changes to the file on disk so that any 
external writes are automatically kept in sync with the state in your app.

* [`inMemory`][in-memory-docs]: A simple tool for sharing state globally with your entire app,
but the state is never persisted. It is automatically cleared with each launch of the app.

These 3 persistence strategies allow you to easily persist and share state across your entire app,
but it's also only half the story. The library allows one to build their own persistence strategies
for speaking to other external storage systems. You can build one for SQLite, Firebase, API servers,
and more… your imagination is the only limit!

These topics will be the focus of next week's episode, but until then be sure to catch up on
our "[Tour of Sharing][tour-of-sharing]" today! 

[in-memory-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/inmemorykey
[file-storage-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/filestoragekey
[app-storage-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/appstoragekey
[tour-of-sharing]: /collections/tours/tour-of-swift-sharing
[sharing-gh]: http://github.com/pointfreeco/swift-sharing
