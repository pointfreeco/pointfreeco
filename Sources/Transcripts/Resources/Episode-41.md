## Introduction

@T(00:00:05)
For multiple weeks we have been designing a snapshot testing library. First we did a bunch of prep work for it by diving deep into the topic of "protocol witnesses" ([part1](/episodes/ep33-protocol-witnesses-part-1), [part2](/episodes/ep34-protocol-witnesses-part-2), [part3](/episodes/ep35-advanced-protocol-witnesses-part-1), [part4](/episodes/ep36-advanced-protocol-witnesses-part-2)). This is where you replace Swift protocols with concrete data types to represent the functionality of those protocols. In doing that we fix a lot of problems that protocols have, and also uncover some fun transformations that are just not possible with protocols.

@T(00:00:30)
Then we designed our snapshot testing library with protocols ([part 1](/episodes/ep37-protocol-oriented-library-design-part-1), [part 2](/episodes/ep38-protocol-oriented-library-design-part-2)) just so that we could see what it would look like in the protocol-oriented style, and see what problems it has. Turns out it had a bunch of problems, so we converted all of that work into the [witness-oriented style](/episodes/ep39-witness-oriented-library-design), and saw huge benefits and amazing new ways to compose our API.

@T(00:01:00)
All of that work culminated into us finally [open sourcing](/blog/posts/23-snapshottesting-1-0-delightful-swift-snapshot-testing) the library a few weeks ago for everyone to use! Now we want to show everyone just how easy it is to integrate the library into an existing project and get your first snapshot test written with very little work.

@T(00:01:20)
We'll do this by taking an open source project and adding some snapshot tests to it! It will give us an opportunity to see what kind of snapshot strategies we can take advantage of right out of the box when bringing in the library. But also see how to create all new strategies that our library doesn't even know about, and I hope that makes people feel empowered to make their own strategies for their domain as they see fit.

## Adding SnapshotTesting to BonMot

@T(00:01:41)
The library we decided to add snapshot testing is called [BonMot](http://github.com/raizlabs/BonMot) from Raizlabs, and it's a nice little library for creating `NSAttributedString`s. If you've ever used attributed strings you will know how much of a pain it can be to create them. BonMot provides a nice set of APIs to make this much nicer.

@T(00:02:52)
I'm going to start by cloning their repo:

```bash
$ git clone https://github.com/Raizlabs/BonMot
Cloning into 'BonMot'...
remote: Enumerating objects: 8223, done.
remote: Total 8223 (delta 0), reused 0 (delta 0), pack-reused 8223
Receiving objects: 100% (8223/8223), 4.38 MiB | 12.30 MiB/s, done.
Resolving deltas: 100% (5443/5443), done.
$ cd BonMot
```

@T(00:03:00)
Next we need to add our `SnapshotTesting` library to this project somehow. I'm not sure if the maintainers prefer CocoaPods or Carthage or something else, so I'm just going to do CocoaPods. That means I'll create a `Podfile` and fill it out real quick:

```ruby
platform :ios, '10.0'

target 'BonMot-iOSTests' do
  pod 'SnapshotTesting', '~> 1.0'
end
```

@T(00:03:33)
And run `pod install`:

```bash
$ pod install
Analyzing dependencies
Downloading dependencies
Installing SnapshotTesting (1.0.0)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `BonMot.xcworkspace` for this project from now on.
Sending stats

Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.
```

@T(00:03:37)
Now let's open the CocoaPods-generated workspace.

@T(00:03:50)
And let's run tests just to make sure everything is in good working order.

@T(00:03:57)
It built, tests ran, and everything passed. Great!

## Our first snapshot test

@T(00:04:05)
Let's get our hands dirty by jumping right in and adding our very first snapshot test.

@T(00:04:10)
I'll add a new `SnapshotTests.swift` file to the project in the test target, and this is where we can start adding some tests.

```swift
import XCTest
@testable import BonMot
import SnapshotTesting

class SnapshotTests: XCTestCase {
}
```

Here's a base test class for us to get started.

@T(00:04:36)
Now our snapshot testing library doesn't yet support snapshotting `NSAttributedString`s, but that's OK. It turns out we can very easily create a snapshotting strategy that is capable of snapshotting any data type into a string by leveraging Swift's `dump` function. We have a snapshot strategy that does just that!

So let's try this out. Let's write a test for BonMot that constructs an interesting attributed string and then snapshots it with the dump strategy. I'm going to take a lil inspiration from BonMot's readme by constructing a string that is a quotation. The quote is from a famous mathematician named [Henri Poincare](https://en.wikipedia.org/wiki/Henri_Poincaré):

```swift
func testSnapshot() {

  """
  Mathematics is the art of giving the same name to different things.
  - Henri Poincare
  """
}
```

@T(00:05:28)
The way you style this with BonMot is to use the `style(with:)` method on strings and you pass a list of styles you want to apply. For example:

```swift
"""
Mathematics is the art of giving the same name to different things.
- Henri Poincare
"""
.styled(with: <#StringStyle#>, <#overrideParts: StringStyle.Part...#>)
```

@T(00:05:39)
This method takes a variadic list of `StringStyle` values, so you can supply as many as you want. Let's start simple and just set the baseline font, text size and line height:

```swift
let string = """
Mathematics is the art of giving the same name to different things.
- Henri Poincare
"""
  .styled(
    with: StringStyle(
      .font(UIFont(name: "AmericanTypewriter", size: 17)!),
      .lineHeightMultiple(1.1)
    )
  )
```

@T(00:06:33)
We now have an attributed string! That was easy.

@T(00:06:43)
Now before we go and snapshot test this, let's see what it would be like to unit test this directly. We would have to query for attributes at a particular index and then assert against what we found. It roughly looks like this:

```swift
XCTAssertEqual(
  UIFont(name: "AmericanTypewriter-Bold", size: 17)!,
  attributedString.attribute(
    NSAttributedString.Key.font, at: 0, effectiveRange: nil
  ) as! UIFont
)
```

@T(00:07:58)
We run our test and it succeeds, so we can have confidence that, indeed, BonMot has applied this attribute at this index.

@T(00:08:06)
First this is pretty ugly and difficult to understand, but also we only query for the attributes at a single index rather than across the entire string. We would need to do a bunch of these to get any real confidence in our code.

@T(00:08:23)
But worse, some of these asserts are really difficult. Like we can't directly assert against line height because that is technically a value embedded in something called `NSMutableParagraphStyle`, and so that's the thing we'd actually have to construct and assert against:

```swift
let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.lineHeightMultiple = 1.1
XCTAssertEqual(
  paragraphStyle,
  attributedString.attribute(
    NSAttributedString.Key.paragraphStyle,
    at: 0,
    effectiveRange: nil
  ) as! NSParagraphStyle
)
```

@T(00:09:11)
That is starting to see like a real pain.

@T(00:09:23)
So let's see what snapshot tests give us. We can add just a single line and get a huge amount of coverage for this one attributed string:

```swift
assertSnapshot(matching: attributedString, as: .dump)
```

The `dump` strategy allows us to test a value as its text dump, as Swift can produce using the `dump` function it ships with.

> Error: An existing reference was not found on disk. Automatically recorded snapshot: …

@T(00:09:52)
The test failed because it recorded a fresh reference. Let's take a look at it.

```txt
- Mathematics is the art of giving the same name to different things.
- Henri Poincare{
    NSFont = "<UICTFont> font-family: "American Typewriter"; font-weight: normal; font-style: normal; font-size: 17.00pt";
    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
}
```

And now we see we are getting a ton of coverage on paragraph styles that we didn't even know existed.

@T(00:10:55)
Let's make the string a little fancier. Let's bold both "Mathematics" and "art" in the string, since we all know those two things are basically the same thing. In BonMot you can do this by wrapping the words in tags, and then supplying styling rules for those tags:

```swift
let string = """
<strong>Mathematics</strong> is the <strong>art</strong> of giving the same name to different things.
- Henri Poincare
"""
  .styled(
    with: StringStyle(
      .font(UIFont(name: "AmericanTypewriter", size: 17)!),
      .lineHeightMultiple(1.1)
    ),
    .xmlRules([
      .style("strong", StringStyle(.font(UIFont(name: "AmericanTypewriter-Bold", size: 17)!)))
    ])
  )
```

@T(00:12:00)
And now let's run the tests...

And we get a failure:

```diff
@@ -1,6 +1,15 @@
-- Mathematics is the art of giving the same name to different things.
+- Mathematics{
+    NSFont = "<UICTFont> font-family: "American Typewriter"; font-weight: bold; font-style: normal; font-size: 17.00pt";
+    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
+} is the {
+    NSFont = "<UICTFont> font-family: "American Typewriter"; font-weight: normal; font-style: normal; font-size: 17.00pt";
+    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
+}art{
+    NSFont = "<UICTFont> font-family: "American Typewriter"; font-weight: bold; font-style: normal; font-size: 17.00pt";
+    NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
+} of giving the same name to different things.
 - Henri Poincare{
     NSFont = "<UICTFont> font-family: "American Typewriter"; font-weight: normal; font-style: normal; font-size: 17.00pt";
     NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 1.1, LineBreakMode 0, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0";
}
```

@T(00:12:17)
We get a big failure, but we expected that. It's cool to see how readable the diff is. Before our string was consistently styled throughout, but now there are breaks where styling has changed.

@T(00:13:00)
This is going to be our new string of reference for testing, so let's put the test in record mode to record a new snapshot:

```swift
SnapshotTesting.record = true
```

@T(00:13:15)
Let's introduce another level of complexity. BonMot makes it very easy to add images to attributed strings. I just so happen to have an image of Poincare, so let's add it to the test bundle. Now it's pretty easy to give Poincare some real credit for this quote:

```swift
let poincare = UIImage(
  named: "poincare",
  in: Bundle(for: SnapshotTests.self),
  compatibleWith: nil
)!
.styled(with: .baselineOffset(-4))

let string = """
<strong>Mathematics</strong> is the <strong>art</strong> of giving the same name to different things.
- Henri Poincare <poincare/>
"""
  .styled(
    with: StringStyle(
      .font(UIFont(name: "AmericanTypewriter", size: 17)!),
      .lineHeightMultiple(1.1)
    ),
    .xmlRules([
      .style(
        "strong",
        StringStyle(
          .font(UIFont(name: "AmericanTypewriter-Bold", size: 17)!)
        )
      ),
      .exit(element: "poincare", insert: poincare),
    ])
  )
```

@T(00:15:02)
Running tests we get a failure, and these are the lines that were added:

```diff
+}￼{
+    NSAttachment = "<NSTextAttachment>";
```

@T(00:15:28)
Underneath the hood BonMot is using the `NSTextAttachment` API to add the image to the string, and it seems this is all we get from Apple when dumping this object. That's a shame, but at least we get some indication that there is an attachment.

## New snapshot strategies on NSAttributedString

@T(00:15:56)
Now, although it was quite cool to get a textual snapshot of all the properties of the attributed string so easily, it would also be really cool if we could do an image snapshot of the string so that we could actually see what it looks like. Luckily the snapshot testing library is super extensible and so we can add this functionality very easily. It's even possible to do from outside the library, so people don't have to wait for us to support it, they can do it themselves and even open source it if they want to share with others.

@T(00:16:19)
When adding a new snapshotting strategy you have two choices. You can either create a value of `Snapshotting` from scratch, which also means creating a value of `Diffing` from scratch too, or you can "pullback" an existing strategy that does most of what you want to do. We will be taking the latter approach because we ultimately want to snapshot these attributed strings as images, and so we can start with the image snapshotting strategy on `UIImage`.

@T(00:16:53)
Let's get the basic scaffolding in place by reopening the `Snapshotting` type, constrained against the type we want to snapshot, and the format we want to snapshot it in. Recall that we do this because it's the natural home for our witness values, and it essentially gives us infinitely many namespaces.

```swift
extension Snapshotting
where Value == NSAttributedString, Format == UIImage {

}
```

@T(00:17:22)
In previous episodes where we designed a snapshot testing library from scratch, we used different generic names. Since then, we've refined things a bit to better describe what's going on.

@T(00:17:44)
Next, let's define the strategy:

```swift
extension Snapshotting
where Value == NSAttributedString, Format == UIImage {
  public static let image: Snapshotting =
    Snapshotting<UIView, UIImage>.image
      .pullback { (attributedString) -> UIView in

      }
}
```

Why did we decide to use `Snapshotting<UIView, UIImage>.image`? Well, because it's very easy to transform an attributed string into a view! We just have to create a label, set a few properties on it, and stick the attributed string inside the label. That is precisely what we do in the body of the `pullback`:

@T(00:18:53)
Now we just need to return a view from this block, given an attributed string.

```swift
extension Snapshotting
where Value == NSAttributedString, Format == UIImage {
  public static let image: Snapshotting =
    Snapshotting<UIView, UIImage>.image.pullback { string in
      let label = UILabel()
      label.attributedText = string
      return label
    }
}
```

This might looks like everything we need to do, but there's some more label configuration that needs to happen for these snapshots to render nicely.

```swift
extension Snapshotting
where Value == NSAttributedString, Format == UIImage {
  public static let image: Snapshotting =
    Snapshotting<UIView, UIImage>.image.pullback { string in
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
```

We've decided to hard code a few configuration values into this snapshotting witness, like `numberOfLines` and `frame.size.width`, and used `systemLayoutSizeFitting` to let the height grow as tall as it needs to fit its contents.

@T(00:19:34)
With very little work we have now created a new snapshotting strategy on `NSAttributedString`'s by leveraging all of the work the library does for us for images. It's hard to overstate just how cool I think this is. We were allowed to define this in user-land without the snapshotting library knowing anything about `NSAttributedString`'s. That is very powerful.

@T(00:20:01)
Let's take this new snapshot strategy for a spin. We can just add one line to our test and get image-based snapshot test coverage for our string:

```swift
assertSnapshot(matching: attributedString, as: .dump)
assertSnapshot(matching: attributedString, as: .image)
```

@T(00:20:22)
We've now recorded a new artifact. Let's take a look.

![inset](https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/assets/testSnapshot.2.png)

We now have test coverage on how these attributed strings actually look and render. With the text dump we weren't capturing what the attachment contained, but now we've captured Poincare's face visually in our reference.

@T(00:20:42)
Very cool! We started by using the library-provided `dump` strategy, which instantly captured a ton of test coverage with just a single line of code. We recognized a small limitation of the format: embedded images weren't being captured in a diffable way. We addressed this limitation by defined our _own_ snapshot strategy on attributed strings by pulling back an existing library-provided strategy on views!

@T(00:21:11)
This is why we describe out library as "transformable" and "extensible". The SnapshotTesting library has no knowledge of the new strategies we're building. They're completely in user-land and could be open sourced on their own as supporting libraries.

## Simplifying existing tests

@T(00:21:34)
So we've now seen how easy it is add the library, define a test, and even define a new strategy to improve coverage.

@T(00:21:45)
Let's change gears now and show how we could refactor existing tests to make them stronger using snapshots. BonMot is really, really well tested. In fact I was surprised at how well tested it is, so kudos to the maintainers! But some tests do a lot of work to make assertions, and even with all that work are not catching as much as they could.

@T(00:22:10)
For example, there's a file `TransformTests.swift` that tests the ability for performing string transformations on styles, for example uppercasing, lowercasing, capitalizing, and even custom transformations.

@T(00:22:24)
Here's an example of one of those tests:

```swift
func testLowercase() {
  let string = "Time remaining: <bold>&lt; 1 DAY</bold> FROM NOW"

  let styled = string
    .styled(with: testStyle(withTransform: .lowercase))

  XCTAssertEqual(styled.string, "Time remaining: < 1 day FROM NOW")

  assertCorrectColors(
    inSubstrings: [
      ("Time remaining: ", .darkGray),
      ("< 1 day", .blue),
      (" FROM NOW", .darkGray),
    ],
    in: styled
  )
}
```

This is doing a lot:

- First we have the plain text string we want to style. Simple enough.
- Then we style it using this `testStyle` helper that applies some base styles to the whole string, and some extra styles to the `bold` tag, including the `.lowercase` transformation.
- Then we make one assertion based on just the text content of the string. This is just to verify that the text transformation happened like we expected.
- Then we use another helper, `assertCorrectColors`, to make sure that particular spans of text are styled by the colors we expect.

@T(00:23:31)
There are 7 tests that follow this form in this test case, and I think it could be simplified a bit. Rather than doing multiple assertions to verify that certain slices of the string have the stylings that we expect, we can snapshot the whole string at once. Heck, might as well snapshot as both a dump and an image while we are at it:

```swift
assertSnapshot(matching: styled, as: .dump)
assertSnapshot(matching: styled, as: .image)
```

@T(00:24:15)
This has now recorded some snapshots so let's check em out:

```txt
- Time remaining: {
    NSColor = "UIExtendedGrayColorSpace 0.333333 1";
}< 1 day{
    NSColor = "UIExtendedSRGBColorSpace 0 0 1 1";
} FROM NOW{
    NSColor = "UIExtendedGrayColorSpace 0.333333 1";
}
```

![inset](https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/assets/testLowercase.1.png)

Now we're getting extensive test coverage on this string.

@T(00:25:13)
But even better, because it's so easy to write this test and because it's so exhaustive in what it is checking, we can delete the extra assertions, inline the styling of the string, and now a test method looks like this:

```swift
func testLowercase() {
  let styled = "Time remaining: <bold>&lt; 1 DAY</bold> FROM NOW"
    .styled(with: testStyle(withTransform: .lowercase))

  assertSnapshot(matching: styled, as: .image)
  assertSnapshot(matching: styled, as: .dump)
}
```

@T(00:25:33)
Let's simplify all the other tests.

...

@T(00:25:42)
We have one test against custom transforms that have some mini-unit tests against the transform function, but because our snapshot test captures this behavior implicitly, we can simplify things even further.

@T(00:25:58)
So we've updated all of the tests. When we run them, we get a bunch of recording failures, and when we re-run them, everything is verified and passes!

@T(00:26:11)
We can look at the snapshot directory and inspect all of the references directly, and it's nice to see that these references account for a _ton_ of test coverage, ensuring the logic of our library doesn't introduce regressions over time.

@T(00:26:37)
Meanwhile, our test file has gotten a lot smaller. We can even delete the custom assertion helper because everything it was written to do is captured automatically in our snapshot tests.

@T(00:26:49)
I would even suggest that we actually get rid of the `testStyle` test helper and instead inline all of the styles directly. I like this because there is now less indirection in the thing that we are testing being constructed and the manner in which we are testing it. Previously if there was a test failure we would have to look at what the `testStyle` and `assertCorrectColors` functions were doing to get the whole story. Now everything is self contained in this one method, and we can delete the test helpers (do that). Tests are still passing, but we have more coverage and were able to delete some code and make some tests a little more direct.

@T(00:27:17)
And all of these artifacts live in the repo. So when you open pull requests against snapshot-tested code, you get a living, visual history on changes made to your data structures over time. It's a pretty invaluable addition to the typical pull request routine.

## Conclusion

@T(00:27:49)
And that's our tour of how to integrate SnapshotTesting into a code base. We showed CocoaPods, but we also support Carthage, SwiftPM, and submodules. Once integrated, you can immediately start using the `dump` strategy to capture a raw dump of data into a text file. But you can also use a number of other strategies that ship with the library, including `image` strategies on views, layers, view controllers, and more.

@T(00:28:19)
Even better, because this library is so transformable and extensible, you can create brand new strategies against your domain-specific data types. Our library doesn't need to know about your data structures. And once you've written some cool strategies, you can even release them as libraries on their own!

@T(00:28:37)
We think this approach is super cool and that folks should check it out. It's really a game-changing testing tool. While the community may be familiar with screenshot testing, the ability to snapshot test _any_ value into _any_ format is a whole new dimension of power.

@T(00:29:01)
Well, that's it for this year. See you all in 2019!
