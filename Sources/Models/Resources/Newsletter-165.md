It’s hard to believe, but we launched Point-Free 7 years ago today! In that time we have released dozens of open source projects that collectively are cloned hundreds of thousands of times a week, responded to thousands of comments and discussions, and explored a wide breadth of topics. Everything from mathematical topics (algebraic data types, existentials, foundations of equality) to practical, real world topics (SQLite, parsers, architecture, cross-platform Swift), and everything in between.

## Open Source Retrospective

When we started Point-Free 7 years ago we did not plan on open source being a critical part of our mission. We both had a lot of experience with open source (Stephen maintained many projects in the past, including the popular [SQLite.swift](http://github.com/stephencelis/SQLite.swift) library, and Brandon spearheaded Kickstarter’s initiative to [open source their apps](https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd?gi=bed3dbf18147)), but we anticipated Point-Free to be a straightforward, educational video series.

However, our courses started naturally covering many topics and concepts that could be bottled up into reusable libraries. We started with some small libraries that aimed to solve specific problems. One such early library was [Tagged](http://github.com/pointfreeco/swift-tagged), which makes it easy to provide type-safe identifiers to types that helps prevent mistakes in your code. Another early library was [Snapshot Testing](http://github.com/pointfreeco/swift-snapshot-testing), which provides tools for testing types by snapshotting them into a serializable format (_e.g._, image, text, JSON, etc.).

Later we started releasing more complex libraries that either tackle something we feel is missing from the Swift language, or that is our opinionated take on how one can build large scape apps. In the former category we released [Case Paths](http://github.com/pointfreeco/swift-case-paths), [Parsing](http://github.com/pointfreeco/swift-parsing), [Swift Navigation](http://github.com/pointfreeco/swift-navigation), and a lot more. And in the latter category we released [Composable Architecture](http://github.com/pointfreeco/swift-composable-architecture), [Dependencies](http://github.com/pointfreeco/swift-dependencies), and [Sharing](http://github.com/pointfreeco/swift-sharing). These libraries provide large amounts of functionality, and have a large, vibrant community using them.

But a question (or concern) we get often is what happens if we decide to stop maintaining these projects? Funding in open source is a thorny problem with no universal solution. There’s plenty of stories out there of a sole developer [maintaining a library](https://www.explainxkcd.com/wiki/index.php/2347:_Dependency) that is critical to large swaths of infrastructure, or big tech companies using open source libraries without funding their support.

We don’t know the solution to any of these problems, at large, but we do feel we have solved the problem for our specific situation. Our open source efforts are funded by the Point-Free community through [subscriptions to our educational video series](/pricing). Thousands of people and companies pay us monthly or yearly to get access to our videos, and in the process of making our videos we uncover new projects to open source and ways to improve upon our existing open source. 

It might sound strange to say, but our libraries are as stable and well-designed as they are because we create a comprehensive video series that builds their core components from scratch. And it’s icing on the cake that we get paid to do it. This funding cycle has sustained us for the past 7 years, and we see no reason it won’t for the next 7.

## Live Stream and Giveaway

We are excited to announce that we are hosting a [live stream on February 14th](https://www.notion.so/1528b290427b801fa3eff614a60281fa?pvs=21) (Valentine's Day 😍) at 9am PST / 5pm GMT. And to celebrate our 7th anniversary we will be giving away 7 yearly subscriptions to Point-Free. Simply tune into the live stream to join the giveaway!

We will be discussing some recent updates around our popular [Sharing](http://github.com/pointfreeco/swift-sharing) library, which brings powerful state sharing and persistence tools to apps no matter if you are using SwiftUI, UIKit, or AppKit. We will even be able to get into some topics that haven’t gotten much attention, such as how Sharing can be used for global navigation patterns, how it can be used with Firebase, and even how it can be used with cross-platform Swift, such as Wasm.

We will also give a sneak peek to a brand new open source library that we are working on, as well as a preview of our next series of episodes. And of course we will devote copious amounts of time to answer questions for our viewers, and the [Q&A is already open](http://pointfree.co/live) so submit your questions today!

## Here’s to another 7 years of Point-Free!

Point-Free has been the most enjoyable and fulfilling work of our careers, and we would love to keep doing it another 7 years. Thanks to everyone in the community that supports us and helps make our libraries what they are today!
