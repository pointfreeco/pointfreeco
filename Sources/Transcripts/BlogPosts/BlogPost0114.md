We are excited to announce a major update to our popular [SnapshotTesting][gh-snapshot-testing]
library: [_inline_ snapshot testing][gh-inline-snapshot-testing]!

This allows allows your text-based snapshots to live right alongside the test, rather than in
an external file. This makes it simpler to verify your snapshots are correct, and even allows you
to build your own testing tools on top of our tools. For example, our recently released
[MacroTesting][gh-macro-testing] library uses inline snapshotting under the hood, but as a user of
the library you would never know!

Join us for a quick overview of snapshot testing, as well as what inline snapshotting brings to 
the table.

## Snapshot testing

Snapshot testing is a style of testing where you don't explicitly provide both values you are 
asserting against, but rather you provide a single value that can be snapshot into some serializable 
format. When you run the test the first time, a snapshot is recorded to disk, and future runs of 
the test will take a new snapshot of the value and compare it against what is on disk. If those 
snapshots differ, then the test will fail.

Perhaps the most canonical example of this is snapshot testing views into images. This is because testing views can be quite difficult in general. You can sometimes perform hacks to actually assert on what kinds of view components are on the screen and what data they hold, but this often feels like testing an implementation detail. And it’s also possible to perform UI tests, but those are very slow, can be flakey, and test a wide range of behavior that you may not really care about.




## _Inline_ snapshot testing

## Why a separate library?

## Get started today



[gh-snapshot-testing]: http://github.com/pointfreeco/swift-snapshot-testing
[gh-inline-snapshot-testing]: http://github.com/pointfreeco/swift-inline-snapshot-testing
[gh-macro-testing]: http://github.com/pointfreeco/swift-macro-testing
