import Foundation

let ep41 = Episode(
  blurb: """
Our snapshot testing library is now official open source! In order to show just how easy it is to integrate the library into any existing code base, we add some snapshot tests to a popular open source library for attributed strings. This gives us the chance to see how easy it is to write all new, domain-specific snapshot strategies from scratch.
""",
  codeSampleDirectory: "",
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 2013890736,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/full/0041-tour-of-snapshot-testing-full-.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/full/0041-tour-of-snapshot-testing.m3u8"
  ),
  id: 41,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/0041-poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/0041-itunes-poster.jpg",
  length: 29*60+16,
  permission: .free,
  publishedAt: .init(timeIntervalSince1970: 1545116400),
  references: [
    .swiftSnapshotTesting,
    .bonMot,
    .protocolOrientedProgrammingWwdc,
    .iosSnapshotTestCaseGithub,
    .snapshotTestingBlogPost,
  ],
  sequence: 41,
  title: "A Tour of Snapshot Testing",
  trailerVideo: .init(
    bytesLength: 178376389,
  downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/trailer/0041-trailer-trailer-.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/trailer/0041-trailer.m3u8"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  .init(body: """
Write an `.html` strategy for snapshotting `NSAttributedString`. You will want to use the
`data(from:documentAttributes:)` method on `NSAttributedString` with the
`NSAttributedString.DocumentType.html` attribute to convert any attribtued string into an HTML document.
"""),
  .init(body: """
Integrate the [snapshot testing library](http://github.com/pointfreeco/swift-snapshot-testing) into one
of your projects, and write a snapshot test.
"""),
  .init(body: """
Create a custom, domain-specific snapshot strategy for one of your types.
"""),
  .init(body: """
Send us a [pull request](http://github.com/pointfreeco/swift-snapshot-testing/pulls) to add a snapshot strategy for a Swift standard library or cocoa data type that
we haven't yet implemented.
"""),
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: (0*60 + 05),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
For multiple weeks we have been designing a snapshot testing library. First we did a bunch of prep work for it by diving deep into the topic of "protocol witnesses" ([part1](/episodes/ep33-protocol-witnesses-part-1), [part2](/episodes/ep34-protocol-witnesses-part-2), [part3](/episodes/ep35-advanced-protocol-witnesses-part-1), [part4](/episodes/ep36-advanced-protocol-witnesses-part-2)). This is where you replace Swift protocols with concrete data types to represent the functionality of those protocols. In doing that we fix a lot of problems that protocols have, and also uncover some fun transformations that are just not possible with protocols.
""",
    timestamp: (0*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Then we designed our snapshot testing library with protocols ([part 1](/episodes/ep37-protocol-oriented-library-design-part-1), [part 2](/episodes/ep38-protocol-oriented-library-design-part-2)) just so that we could see what it would look like in the protocol-oriented style, and see what problems it has. Turns out it had a bunch of problems, so we converted all of that work into the [witness-oriented style](/episodes/ep39-witness-oriented-library-design), and saw huge benefits and amazing new ways to compose our API.
""",
    timestamp: (0*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
All of that work culminated into us finally [open sourcing](/blog/posts/23-snapshottesting-1-0-delightful-swift-snapshot-testing) the library a few weeks ago for everyone to use! Now we want to show everyone just how easy it is to integrate the library into an existing project and get your first snapshot test written with very little work.
""",
    timestamp: (1*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We'll do this by taking an open source project and adding some snapshot tests to it! It will give us an opportunity to see what kind of snapshot strategies we can take advantage of right out of the box when bringing in the library. But also see how to create all new strategies that our library doesn't even know about, and I hope that makes people feel empowered to make their own strategies for their domain as they see fit.
""",
    timestamp: (1*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Adding SnapshotTesting to BonMot",
    timestamp: (1*60 + 41),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
The library we decided to add snapshot testing is called [BonMot](http://github.com/raizlabs/BonMot) from Raizlabs, and it's a nice little library for creating `NSAttributedString`s. If you've ever used attributed strings you will know how much of a pain it can be to create them. BonMot provides a nice set of APIs to make this much nicer.
""",
    timestamp: (1*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I'm going to start by cloning their repo:
""",
    timestamp: (2*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
$ git clone https://github.com/Raizlabs/BonMot
Cloning into 'BonMot'...
remote: Enumerating objects: 8223, done.
remote: Total 8223 (delta 0), reused 0 (delta 0), pack-reused 8223
Receiving objects: 100% (8223/8223), 4.38 MiB | 12.30 MiB/s, done.
Resolving deltas: 100% (5443/5443), done.
$ cd BonMot
""",
    timestamp: nil,
    type: .code(lang: .shell)
  ),
  Episode.TranscriptBlock(
    content: """
Next we need to add our `SnapshotTesting` library to this project somehow. I'm not sure if the maintainers prefer CocoaPods or Carthage or something else, so I'm just going to do CocoaPods. That means I'll create a `Podfile` and fill it out real quick:
""",
    timestamp: (3*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
platform :ios, '10.0'

target 'BonMot-iOSTests' do
  pod 'SnapshotTesting', '~> 1.0'
end
""",
    timestamp: (3*60 + 15),
    type: .code(lang: .ruby)
  ),
  Episode.TranscriptBlock(
    content: """
And run `pod install`:
""",
    timestamp: (3*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
$ pod install
Analyzing dependencies
Downloading dependencies
Installing SnapshotTesting (1.0.0)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `BonMot.xcworkspace` for this project from now on.
Sending stats

Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.
""",
    timestamp: nil,
    type: .code(lang: .shell)
  ),
  Episode.TranscriptBlock(
    content: """
Now let's open the CocoaPods-generated workspace.
""",
    timestamp: (3*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And let's run tests just to make sure everything is in good working order.
""",
    timestamp: (3*60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It built, tests ran, and everything passed. Great!
""",
    timestamp: (3*60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Our first snapshot test",
    timestamp: (4*60 + 05),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's get our hands dirty by jumping right in and adding our very first snapshot test.
""",
    timestamp: (4*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I'll add a new `SnapshotTests.swift` file to the project in the test target, and this is where we can start adding some tests.
""",
    timestamp: (4*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
import XCTest
@testable import BonMot
import SnapshotTesting

class SnapshotTests: XCTestCase {
}
""",
    timestamp: (4*60 + 24),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here's a base test class for us to get started.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now our snapshot testing library doesn't yet support snapshotting `NSAttributedString`s, but that's OK. It turns out we can very easily create a snapshotting strategy that is capable of snapshotting any data type into a string by leveraging Swift's `dump` function. We have a snapshot strategy that does just that!
""",
    timestamp: (4*60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So let's try this out. Let's write a test for BonMot that constructs an interesting attributed string and then snapshots it with the dump strategy. I'm going to take a lil inspiration from BonMot's readme by constructing a string that is a quotation. The quote is from a famous mathematician named [Henri Poincare](https://en.wikipedia.org/wiki/Henri_Poincaré):
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func testSnapshot() {

  \"""
  Mathematics is the art of giving the same name to different things.
  - Henri Poincare
  \"""
}
""",
    timestamp: (5*60 + 06),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The way you style this with BonMot is to use the `style(with:)` method on strings and you pass a list of styles you want to apply. For example:
""",
    timestamp: (5*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
\"""
Mathematics is the art of giving the same name to different things.
- Henri Poincare
\"""
.styled(with: <#StringStyle#>, <#overrideParts: StringStyle.Part...#>)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This method takes a variadic list of `StringStyle` values, so you can supply as many as you want. Let's start simple and just set the baseline font, text size and line height:
""",
    timestamp: (5*60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let string = \"""
Mathematics is the art of giving the same name to different things.
- Henri Poincare
\"""
  .styled(with: StringStyle(
    .font(UIFont(name: "AmericanTypewriter", size: 17)!),
    .lineHeightMultiple(1.1)
  ))
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We now have an attributed string! That was easy.
""",
    timestamp: (6*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now before we go and snapshot test this, let's see what it would be like to unit test this directly. We would have to query for attributes at a particular index and then assert against what we found. It roughly looks like this:
""",
    timestamp: (6*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
XCTAssertEqual(
  UIFont(name: "AmericanTypewriter-Bold", size: 17)!,
  attributedString.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as! UIFont
)
""",
    timestamp: (6*60 + 57),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We run our test and it succeeds, so we can have confidence that, indeed, BonMot has applied this attribute at this index.
""",
    timestamp: (7*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
First this is pretty ugly and difficult to understand, but also we only query for the attributes at a single index rather than across the entire string. We would need to do a bunch of these to get any real confidence in our code.
""",
    timestamp: (8*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
But worse, some of these asserts are really difficult. Like we can't directly assert against line height because that is technically a value embedded in something called `NSMutableParagraphStyle`, and so that's the thing we'd actually have to construct and assert against:
""",
    timestamp: (8*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.lineHeightMultiple = 1.1
XCTAssertEqual(
  paragraphStyle,
  attributedString.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as! NSParagraphStyle
)
""",
    timestamp: (8*60 + 33),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
That is starting to see like a real pain.
""",
    timestamp: (9*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So let's see what snapshot tests give us. We can add just a single line and get a huge amount of coverage for this one attributed string:
""",
    timestamp: (9*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertSnapshot(matching: attributedString, as: .dump)
""",
    timestamp: (9*60 + 34),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The `dump` strategy allows us to test a value as its text dump, as Swift can produce using the `dump` function it ships with.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
> 🛑 An existing reference was not found on disk. Automatically recorded snapshot: …

The test failed because it recorded a fresh reference. Let's take a look at it.
""",
    timestamp: (9*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- Mathematics is the art of giving the same name to different things.
- Henri Poincare{
    NSFont = "<UICTFont> font-family: \"American Typewriter\"; font-weight: normal; font-style: normal; font-size: 17.00pt";
    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\\n    28L,\\n    56L,\\n    84L,\\n    112L,\\n    140L,\\n    168L,\\n    196L,\\n    224L,\\n    252L,\\n    280L,\\n    308L,\\n    336L\\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
}
""",
    timestamp: (10*60 + 04),
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
And now we see we are getting a ton of coverage on paragraph styles that we didn't even know existed.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's make the string a little fancier. Let's bold both "Mathematics" and "art" in the string, since we all know those two things are basically the same thing. In BonMot you can do this by wrapping the words in tags, and then supplying styling rules for those tags:
""",
    timestamp: (10*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let string = \"""
<strong>Mathematics</strong> is the <strong>art</strong> of giving the same name to different things.
- Henri Poincare
\"""
  .styled(with:
    StringStyle(
        .font(UIFont(name: "AmericanTypewriter", size: 17)!),
        .lineHeightMultiple(1.1)
    ),
    .xmlRules([
      .style("strong", StringStyle(.font(UIFont(name: "AmericanTypewriter-Bold", size: 17)!)))
    ])
  )
""",
    timestamp: (11*60 + 12),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now let's run the tests...

And we get a failure:
""",
    timestamp: (12*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
@@ -1,6 +1,15 @@
-- Mathematics is the art of giving the same name to different things.
+- Mathematics{
+    NSFont = "<UICTFont> font-family: \"American Typewriter\"; font-weight: bold; font-style: normal; font-size: 17.00pt";
+    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\\n    28L,\\n    56L,\\n    84L,\\n    112L,\\n    140L,\\n    168L,\\n    196L,\\n    224L,\\n    252L,\\n    280L,\\n    308L,\\n    336L\\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
+} is the {
+    NSFont = "<UICTFont> font-family: \"American Typewriter\"; font-weight: normal; font-style: normal; font-size: 17.00pt";
+    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\\n    28L,\\n    56L,\\n    84L,\\n    112L,\\n    140L,\\n    168L,\\n    196L,\\n    224L,\\n    252L,\\n    280L,\\n    308L,\\n    336L\\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
+}art{
+    NSFont = "<UICTFont> font-family: \"American Typewriter\"; font-weight: bold; font-style: normal; font-size: 17.00pt";
+    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\\n    28L,\\n    56L,\\n    84L,\\n    112L,\\n    140L,\\n    168L,\\n    196L,\\n    224L,\\n    252L,\\n    280L,\\n    308L,\\n    336L\\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
+} of giving the same name to different things.
 - Henri Poincare{
     NSFont = "<UICTFont> font-family: \"American Typewriter\"; font-weight: normal; font-style: normal; font-size: 17.00pt";
     NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\\n    28L,\\n    56L,\\n    84L,\\n    112L,\\n    140L,\\n    168L,\\n    196L,\\n    224L,\\n    252L,\\n    280L,\\n    308L,\\n    336L\\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
}
""",
    timestamp: nil,
    type: .code(lang: .diff)
  ),
  Episode.TranscriptBlock(
    content: """
We get a big failure, but we expected that. It's cool to see how readable the diff is. Before our string was consistently styled throughout, but now there are breaks where styling has changed.
""",
    timestamp: (12*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is going to be our new string of reference for testing, so let's put the test in record mode to record a new snapshot:
""",
    timestamp: (13*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
record = true
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's introduce another level of complexity. BonMot makes it very easy to add images to attributed strings. I just so happen to have an image of Poincare, so let's add it to the test bundle. Now it's pretty easy to give Poincare some real credit for this quote:
""",
    timestamp: (13*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let poincare = UIImage(named: "poincare", in: Bundle(for: SnapshotTests.self), compatibleWith: nil)!
  .styled(with: .baselineOffset(-4))

let string = \"""
<strong>Mathematics</strong> is the <strong>art</strong> of giving the same name to different things.
- Henri Poincare <poincare/>
\"""
  .styled(with:
    StringStyle(
        .font(UIFont(name: "AmericanTypewriter", size: 17)!),
        .lineHeightMultiple(1.1)
    ),
    .xmlRules([
      .style("strong", StringStyle(.font(UIFont(name: "AmericanTypewriter-Bold", size: 17)!))),
      .exit(element: "poincare", insert: poincare),
    ])
  )
""",
    timestamp: (13*60 + 39),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Running tests we get a failure, and these are the lines that were added:
""",
    timestamp: (15*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
+}￼{
+    NSAttachment = "<NSTextAttachment>";
""",
    timestamp: nil,
    type: .code(lang: .diff)
  ),
  Episode.TranscriptBlock(
    content: """
Underneath the hood BonMot is using the `NSTextAttachment` API to add the image to the string, and it seems this is all we get from Apple when dumping this object. That's a shame, but at least we get some indication that there is an attachment.
""",
    timestamp: (15*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "New snapshot strategies on NSAttributedString",
    timestamp: (15*60 + 56),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Now, although it was quite cool to get a textual snapshot of all the properties of the attributed string so easily, it would also be really cool if we could do an image snapshot of the string so that we could actually see what it looks like. Luckily the snapshot testing library is super extensible and so we can add this functionality very easily. It's even possible to do from outside the library, so people don't have to wait for us to support it, they can do it themselves and even open source it if they want to share with others.
""",
    timestamp: (15*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
When adding a new snapshotting strategy you have two choices. You can either create a value of `Snapshotting` from scratch, which also means creating a value of `Diffing` from scratch too, or you can "pullback" an existing strategy that does most of what you want to do. We will be taking the latter approach because we ultimately want to snapshot these attributed strings as images, and so we can start with the image snapshotting strategy on `UIImage`.
""",
    timestamp: (16*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's get the basic scaffolding in place by reopening the `Snapshotting` type, constrained against the type we want to snapshot, and the format we want to snapshot it in. Recall that we do this because it's the natural home for our witness values, and it essentially gives us infinitely many namespaces.
""",
    timestamp: (16*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Snapshotting where Value == NSAttributedString, Format == UIImage {

}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
In previous episodes where we designed a snapshot testing library from scratch, we used different generic names. Since then, we've refined things a bit to better describe what's going on.
""",
    timestamp: (17*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Next, let's define the strategy:
""",
    timestamp: (17*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Snapshotting where Value == NSAttributedString, Format == UIImage {
  public static let image: Snapshotting = Snapshotting<UIView, UIImage>.image.pullback { (attributedString) -> UIView in

  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Why did we decide to use `Snapshotting<UIView, UIImage>.image`? Well, because it's very easy to transform an attributed string into a view! We just have to create a label, set a few properties on it, and stick the attributed string inside the label. That is precisely what we do in the body of the `pullback`:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now we just need to return a view from this block, given an attributed string.
""",
    timestamp: (18*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Snapshotting where Value == NSAttributedString, Format == UIImage {
  public static let image: Snapshotting = Snapshotting<UIView, UIImage>.image.pullback { string in
    let label = UILabel()
    label.attributedText = string
    return label
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This might looks like everything we need to do, but there's some more label configuration that needs to happen for these snapshots to render nicely.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Snapshotting where Value == NSAttributedString, Format == UIImage {
  public static let image: Snapshotting = Snapshotting<UIView, UIImage>.image.pullback { string in
    let label = UILabel()
    label.attributedText = string
    label.numberOfLines = 0
    label.backgroundColor = .white
    label.frame.size = label.systemLayoutSizeFitting(
      CGSize(width: 300, height: 0),
      withHorizontalFittingPriority: .defaultHigh,
      verticalFittingPriority: .defaultLow
    )
    return label
  }
}
""",
    timestamp: (19*60 + 11),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've decided to hard code a few configuration values into this snapshotting witness, like `numberOfLines` and `frame.size.width`, and used `systemLayoutSizeFitting` to let the height grow as tall as it needs to fit its contents.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
With very little work we have now created a new snapshotting strategy on `NSAttributedString`'s by leveraging all of the work the library does for us for images. It's hard to overstate just how cool I think this is. We were allowed to define this in user-land without the snapshotting library knowing anything about `NSAttributedString`'s. That is very powerful.
""",
    timestamp: (19*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's take this new snapshot strategy for a spin. We can just add one line to our test and get image-based snapshot test coverage for our string:
""",
    timestamp: (20*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertSnapshot(matching: attributedString, as: .dump)
assertSnapshot(matching: attributedString, as: .image)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've now recorded a new artifact. Let's take a look.
""",
    timestamp: (20*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "",
    timestamp: (20*60 + 28),
    type: .image(src: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/assets/testSnapshot.2.png", sizing: .inset)
  ),
  Episode.TranscriptBlock(
    content: """
We now have test coverage on how these attributed strings actually look and render. With the text dump we weren't capturing what the attachment contained, but now we've captured Poincare's face visually in our reference.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Very cool! We started by using the library-provided `dump` strategy, which instantly captured a ton of test coverage with just a single line of code. We recognized a small limitation of the format: embedded images weren't being captured in a diffable way. We addressed this limitation by defined our _own_ snapshot strategy on attributed strings by pulling back an existing library-provided strategy on views!
""",
    timestamp: (20*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is why we describe out library as "transformable" and "extensible". The SnapshotTesting library has no knowledge of the new strategies we're building. They're completely in user-land and could be open sourced on their own as supporting libraries.
""",
    timestamp: (21*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Simplifying existing tests",
    timestamp: (21*60 + 34),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
So we've now seen how easy it is add the library, define a test, and even define a new strategy to improve coverage.
""",
    timestamp: (21*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's change gears now and show how we could refactor existing tests to make them stronger using snapshots. BonMot is really, really well tested. In fact I was surprised at how well tested it is, so kudos to the maintainers! But some tests do a lot of work to make assertions, and even with all that work are not catching as much as they could.
""",
    timestamp: (21*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example, there's a file `TransformTests.swift` that tests the ability for performing string transformations on styles, for example uppercasing, lowercasing, capitalizing, and even custom transformations.
""",
    timestamp: (22*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Here's an example of one of those tests:
""",
    timestamp: (22*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func testLowercase() {
    let string = "Time remaining: <bold>&lt; 1 DAY</bold> FROM NOW"

    let styled = string.styled(with: testStyle(withTransform: .lowercase))

    XCTAssertEqual(styled.string, "Time remaining: < 1 day FROM NOW")

    assertCorrectColors(inSubstrings: [
        ("Time remaining: ", .darkGray),
        ("< 1 day", .blue),
        (" FROM NOW", .darkGray),
        ], in: styled)
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is doing a lot:

- First we have the plain text string we want to style. Simple enough.
- Then we style it using this `testStyle` helper that applies some base styles to the whole string, and some extra styles to the `bold` tag, including the `.lowercase` transformation.
- Then we make one assertion based on just the text content of the string. This is just to verify that the text transformation happened like we expected.
- Then we use another helper, `assertCorrectColors`, to make sure that particular spans of text are styled by the colors we expect.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
There are 7 tests that follow this form in this test case, and I think it could be simplified a bit. Rather than doing multiple assertions to verify that certain slices of the string have the stylings that we expect, we can snapshot the whole string at once. Heck, might as well snapshot as both a dump and an image while we are at it:
""",
    timestamp: (23*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertSnapshot(matching: styled, as: .dump)
assertSnapshot(matching: styled, as: .image)
""",
    timestamp: (23*60 + 54),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This has now recorded some snapshots so let's check em out:
""",
    timestamp: (24*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- Time remaining: {
    NSColor = "UIExtendedGrayColorSpace 0.333333 1";
}< 1 day{
    NSColor = "UIExtendedSRGBColorSpace 0 0 1 1";
} FROM NOW{
    NSColor = "UIExtendedGrayColorSpace 0.333333 1";
}
""",
    timestamp: (24*60 + 25),
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: "",
    timestamp: (24*60 + 49),
    type: .image(src: "https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/assets/testLowercase.1.png", sizing: .inset)
  ),
  Episode.TranscriptBlock(
    content: """
Now we're getting extensive test coverage on this string.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
But even better, because it's so easy to write this test and because it's so exhaustive in what it is checking, we can delete the extra assertions, inline the styling of the string, and now a test method looks like this:
""",
    timestamp: (25*60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func testLowercase() {
  let styled = "Time remaining: <bold>&lt; 1 DAY</bold> FROM NOW"
    .styled(with: testStyle(withTransform: .lowercase))

  assertSnapshot(matching: styled, as: .image)
  assertSnapshot(matching: styled, as: .dump)
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's simplify all the other tests.

...
""",
    timestamp: (25*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We have one test against custom transforms that have some mini-unit tests against the transform function, but because our snapshot test captures this behavior implicitly, we can simplify things even further.
""",
    timestamp: (25*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So we've updated all of the tests. When we run them, we get a bunch of recording failures, and when we re-run them, everything is verified and passes!
""",
    timestamp: (25*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We can look at the snapshot directory and inspect all of the references directly, and it's nice to see that these references account for a _ton_ of test coverage, ensuring the logic of our library doesn't introduce regressions over time.
""",
    timestamp: (26*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Meanwhile, our test file has gotten a lot smaller. We can even delete the custom assertion helper because everything it was written to do is captured automatically in our snapshot tests.
""",
    timestamp: (26*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I would even suggest that we actually get rid of the `testStyle` test helper and instead inline all of the styles directly. I like this because there is now less indirection in the thing that we are testing being constructed and the manner in which we are testing it. Previously if there was a test failure we would have to look at what the `testStyle` and `assertCorrectColors` functions were doing to get the whole story. Now everything is self contained in this one method, and we can delete the test helpers (do that). Tests are still passing, but we have more coverage and were able to delete some code and make some tests a little more direct.
""",
    timestamp: (26*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And all of these artifacts live in the repo. So when you open pull requests against snapshot-tested code, you get a living, visual history on changes made to your data structures over time. It's a pretty invaluable addition to the typical pull request routine.
""",
    timestamp: (27*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Conclusion",
    timestamp: (27*60 + 49),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
And that's our tour of how to integrate SnapshotTesting into a code base. We showed CocoaPods, but we also support Carthage, SwiftPM, and submodules. Once integrated, you can immediately start using the `dump` strategy to capture a raw dump of data into a text file. But you can also use a number of other strategies that ship with the library, including `image` strategies on views, layers, view controllers, and more.
""",
    timestamp: (27*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Even better, because this library is so transformable and extensible, you can create brand new strategies against your domain-specific data types. Our library doesn't need to know about your data structures. And once you've written some cool strategies, you can even release them as libraries on their own!
""",
    timestamp: (28*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We think this approach is super cool and that folks should check it out. It's really a game-changing testing tool. While the community may be familiar with screenshot testing, the ability to snapshot test _any_ value into _any_ format is a whole new dimension of power.
""",
    timestamp: (28*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Well, that's it for this year. See you all in 2019!
""",
    timestamp: (29*60 + 01),
    type: .paragraph
  ),
]
