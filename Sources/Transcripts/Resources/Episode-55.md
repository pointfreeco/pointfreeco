## Previously

@T(00:00:05)
In past few episodes we explored how Swift doesn't always place structs and enums on equal footing, and in particular, we identified how struct data access is far easier and more ergonomic than enum data access: struct properties can be accessed via succinct dot-syntax, while enums require some very gnarly pattern matching code that results in a lot of extra noise, ceremony, and typing.

@T(00:00:23)
Luckily, we found that we can fix this problem ourselves by writing what we call "enum properties": computed properties per enum case that optionally return associated data when the case matches. This simple bit of boilerplate made working with enum data just as ergonomic as working with struct data. But it's quite inconvenient to write by hand, and it's a tall ask to do so in code bases that may contain dozens or even hundreds of enum cases.

@T(00:00:54)
So in order to fully embrace enum properties as something we can use in our code bases, we looked to another tool: code generation. We have been building a own code generation tool to solve this problem. It's a Swift package that uses Swift Syntax, Apple's relatively new library for parsing and inspecting Swift source code. Swift Syntax lets us walk over and inspect every token of a given Swift source file, so we used it to look for enums and enum cases in order to automatically generate enum properties for each case!

@T(00:01:17)
Our code is almost ready to go, but it's still stuck in a playground. We'll now take the final steps needed to make this tool usable in our applications. We will extract our playground code to a library, snapshot test it in a very interesting way, and create an executable that can be installed and used in other code bases.

## Extracting the playground

@T(00:01:37)
We've been working on our library entirely from within a playground. We love playground driven development at Point-Free and have talked about it at length in [a previous episode](/episodes/ep21-playground-driven-development). Playgrounds give us an environment with a rapid feedback loop that let us iterate on problems quickly. It helped us build the bulk of our code generation tool, but now it's time to extract things to a standalone library.

@T(00:01:58)
Here's what we have so far:

```swift
import Foundation
import SwiftSyntax

let url = Bundle.main.url(
  forResource: "Enums", withExtension: "swift"
)!
let tree = try SyntaxTreeParser.parse(url)

class Visitor: SyntaxVisitor {
  override func visit(
    _ node: EnumDeclSyntax
  ) -> SyntaxVisitorContinueKind {
    print("extension \(node.identifier.withoutTrivia()) {")
    return .visitChildren
  }

  override func visit(
    _ node: EnumCaseElementSyntax
  ) -> SyntaxVisitorContinueKind {
    let propertyType: String
    let pattern: String
    let returnValue: String
    if let associatedValue = node.associatedValue {
      propertyType = associatedValue.parameterList.count == 1
        ? "\(associatedValue.parameterList[0].type!)"
        : "\(associatedValue)"
      pattern = "let .\(node.identifier)(value)"
      returnValue = "value"
    } else {
      propertyType = "Void"
      pattern = ".\(node.identifier)"
      returnValue = "()"
    }
    print("  var \(node.identifier): \(propertyType)? {")
    print("    guard case \(pattern) = self else { return nil }")
    print("    return \(returnValue)")
    print("  }")
    let identifier = "\(node.identifier)"
    let capitalizedIdentifier =
      "\(identifier.first!.uppercased())\(identifier.dropFirst())"
    print("  var is\(capitalizedIdentifier): Bool {")
    print("    return self.\(node.identifier) != nil")
    print("  }")
    return .skipChildren
  }

  override func visitPost(_ node: Syntax) {
    if node is EnumDeclSyntax {
      print("}")
    }
  }
}

let visitor = Visitor()
tree.walk(visitor)
```

@T(00:02:02)
Our playground is quite simple: we first load up a URL for an `Enums.swift` fixture that contains a bunch of enums that we generate properties for. Then we feed it to SwiftSyntax's `SyntaxTreeParser`, which returns a parsed tree of Swift source code tokens.

@T(00:02:18)
After that we defined a `Visitor` class, which is a subclass of SwiftSyntax's `SyntaxVisitor` and it provides an API for inspecting every different kind of syntax Swift has. We hooked into the `visit`  methods of the few bits of syntax we care about, which includes enums and enum cases, and using these nodes we were able to generate source code for enum properties along the way.

@T(00:02:42)
Finally, we instantiated a visitor and passed it to the tree parser's `walk` method, which tells the visitor to walk over each node so that it can print out our properties.

@T(00:02:56)
The real workhorse of everything we've done so far is the `Visitor` class. If we were to extract that into its own library, we could maybe invoke it from our playground or some kind of CLI tool in order to get the code generation output, and then save that source code somewhere.

@T(00:03:14)
Swift packages are organized by directory. All of a package's libraries and executables live inside the top-level `Sources` directory as subdirectories that have the same name as the library or executable. When initializing a package, the Swift package manager uses the name of the current directory to generate a package and library of the same name. So when we ran `swift package init` in a directory called `EnumProperties`, it generated an `EnumProperties` library, and corresponding `Sources` directory with a single placeholder file, in this case `EnumProperties.swift`.

```swift
struct EnumProperties {
  var text = "Hello, World!"
}
```

@T(00:03:35)
Let's replace the contents of this file with the core part of the work we've done so far: the `Visitor` class. And let's make it public, so we can import it into other modules.

```swift
import SwiftSyntax

public class Visitor: SyntaxVisitor {
  override public func visit(
    _ node: EnumDeclSyntax
  ) -> SyntaxVisitorContinueKind {
    print("extension \(node.identifier.withoutTrivia()) {")
    return .visitChildren
  }

  override public func visit(
    _ node: EnumCaseElementSyntax
  ) -> SyntaxVisitorContinueKind {
    let propertyType: String
    let pattern: String
    let returnValue: String
    if let associatedValue = node.associatedValue {
      propertyType = associatedValue.parameterList.count == 1
        ? "\(associatedValue.parameterList[0].type!)"
        : "\(associatedValue)"
      pattern = "let .\(node.identifier)(value)"
      returnValue = "value"
    } else {
      propertyType = "Void"
      pattern = ".\(node.identifier)"
      returnValue = "()"
    }
    print("  var \(node.identifier): \(propertyType)? {")
    print("    guard case \(pattern) = self else { return nil }")
    print("    return \(returnValue)")
    print("  }")
    let identifier = "\(node.identifier)"
    let capitalizedIdentifier =
      "\(identifier.first!.uppercased())\(identifier.dropFirst())"
    print("  var is\(capitalizedIdentifier): Bool {")
    print("    return self.\(node.identifier) != nil")
    print("  }")
    return .skipChildren
  }

  override public func visitPost(_ node: Syntax) {
    if node is EnumDeclSyntax {
      print("}")
    }
  }
}
```

@T(00:03:58)
Everything builds just fine, and we can clean up our playground to use the updated library implementation.

```swift
import EnumProperties
import Foundation
import SwiftSyntax

let url = Bundle.main.url(
  forResource: "Enums", withExtension: "swift"
)!
let tree = try SyntaxTreeParser.parse(url)
let visitor = Visitor()
tree.walk(visitor)
```

@T(00:04:23)
The Swift Package Manager also generates a `Tests` directory with a subdirectory per test target. Before going any further, let's try to write a test for our `Visitor` so that we can ensure nothing breaks during future refactors.

@T(00:04:29)
Here we have the contents of `EnumPropertiesTests.swift`:

```swift
import XCTest
@testable import EnumProperties

final class EnumPropertiesTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests
    // produce the correct results.
    XCTAssertEqual(EnumProperties().text, "Hello, World!")
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
```

It has an example test and a static `allTests` property, which is needed for Linux.

@T(00:04:34)
Let's reindent the file and replace `testExample` with some code that exercises our syntax visitor. We want to perform the same work that we were previously performing in the playground, so let's copy and paste it to get started.

```swift
import SwiftSyntax

final class EnumPropertiesTests: XCTestCase {
  func testExample() {
    let url = Bundle.main.url(
      forResource: "Enums", withExtension: "swift"
    )!
    let tree = try SyntaxTreeParser.parse(url)
    let visitor = Visitor()
    tree.walk(visitor)
  }
```

@T(00:04:51)
We're going to have to make a few changes from the work we did before because we no longer have a bundle with an "Enums.swift" resource to load.

@T(00:05:02)
Instead of adding this file as a resource, let's include the source as a fixture that can be compiled alongside our tests. We can start by adding a `Fixtures` group to `EnumPropertiesTests` to keep things organized. And then we can drag `Enums.swift` over

@T(00:05:23)
Now we're ready to load this fixture in our test. The location of this fixture is relative to our test file, so we can use the magic `#file` identifier, which is a static string representation of the current file URL (in this case our test), and we can use some `URL` methods to get the fixture URL.

```swift
func testExample() {
  let url = URL(fileURLWithPath: String(#file))
    .deletingLastPathComponent()
    .appendingPathComponent("Fixtures")
    .appendingPathComponent("Enums.swift")
```

@T(00:06:28)
Our next line has a problem:

```swift
let tree = try SyntaxTreeParser.parse(url)
```

> Error: Errors thrown from here are not handled

@T(00:06:33)
And in order for XCTest to handle this error, we can update our test to be throwing.

```swift
func testExample() throws {
```

@T(00:06:37)
Now this is an oft-overlooked feature of XCTest that is quite nice. Any test function can be made to be throwing and, should something in the test throw an error, the test will fail using all of the XCTest machinery. This is a nice alternative to introducing a `do` scope with all of its ceremony, or force-`try!`-ing, which can cause the test process to crash.

@T(00:06:58)
We can now run our test and confirm in the console that it's printing out some enum properties.

## Preparing for testability

@T(00:07:14)
Alright, we have a test that builds and runs and prints out some enum properties, but we're not really testing anything! We can't write any assertions against our syntax visitor because it's living completely in the land of side effects: it's printing everything immediately to the console. Instead we could maybe build up a value over time, and then only at the end print it.

@T(00:07:43)
This is a common theme in how we like to structure our code on Point-Free: we try to push side effects to the boundary of our programs. By building up a value over time, we'll have something we can inspect and assert against, and then at the end, we can also choose to print it to the console!

@T(00:08:01)
Let's start by adding an `output` property to our visitor that starts as an empty string. We can even use `private(set)` to make the user-facing interface immutable.

```swift
public class Visitor: SyntaxVisitor {
  public private(set) var output = ""
```

@T(00:08:26)
We don't have to change much more to get things working! Swift provides an overload of the `print` function that takes a `TextOutputStream`.

```swift
public func print<Target: TextOutputStream>(
  _ items: Any...,
  separator: String = " ",
  terminator: String = "\n",
  to output: inout Target
)
```

@T(00:08:44)
`TextOutputStream` is a Swift protocol with a single mutating `write` method that appends a given string to a stream.

```swift
public protocol TextOutputStream {
  mutating func write(_ string: String)
}
```

@T(00:08:53)
Swift's `String` type conforms to `TextOutputStream` already, so we can capture the output from `print` in a string like `self.output` instead of letting it log to standard output.

```swift
override public func visit(
  _ node: EnumDeclSyntax
) -> SyntaxVisitorContinueKind {
  print(
    "extension \(node.identifier.withoutTrivia()) {",
    to: &self.output
  )
```

@T(00:09:16)
All of our `print`s just need to add that extra `to` parameter, and we'll build up a string of enum properties instead of immediately printing them to the console.

@T(00:09:38)
Things are still building, so we can hop over to our tests, run them, and confirm that our generated code is no longer printing directly to the console.

@T(00:09:53)
Since we've exposed the `output` property, we can write an honest test that asserts against the output of our syntax visitor. Let's start with an empty string that will cause the test to fail just to see what we're working with.

```swift
func testExample() throws {
  let url = URL(fileURLWithPath: String(#file))
    .deletingLastPathComponent()
    .appendingPathComponent("Fixtures")
    .appendingPathComponent("Enums.swift")
  let tree = try SyntaxTreeParser.parse(url)
  let visitor = Visitor()
  tree.walk(visitor)
  XCTAssertEqual("", visitor.output)
}
```

> Failed: XCTAssertEqual failed: ("") is not equal to ("extension Validated {…")

@T(00:10:12)
It failed, as we expected. In order to get it passing, we can now copy and paste the failure output back into our test to get it passing.

```swift
XCTAssertEqual(
  """
  extension Validated {
    var valid: Valid? {
      guard case let .valid(value) = self else { return nil }
      return value
    }
    var isValid: Bool {
      return self.valid != nil
    }
    …
    var cancelled: Void? {
      guard case .cancelled = self else { return nil }
      return ()
    }
    var isCancelled: Bool {
      return self.cancelled != nil
    }
  }
  """,
  visitor.output
)
```

> Failed: XCTAssertEqual failed: ("extension Validated {…}") is not equal to ("extension Validated {…}")

@T(00:10:54)
Hm, it's still failing, and with a huge, unreadable assertion message. The content should be the same, so what's different? The issue here is very subtle, and it even took us a bit of time to debug it the first time around. Our assertion string needs to have a trailing newline to match the output of our visitor.

```diff
 }
+
 """, visitor.output)
```

@T(00:11:22)
And now the test passes! But the failure we got illustrates just how bad this test is. When we assert against such a huge string, it's really hard to figure out what's wrong when anything changes.

@T(00:11:34)
For example, we might change how one of our lines prints. Maybe we accidentally introduce some whitespace:

```swift
pattern = "guard  case let .\(node.identifier)(value)"
```

> Failed: XCTAssertEqual failed: ("extension Validated {…}") is not equal to ("extension Validated {…}")

@T(00:11:46)
We're back to having a huge failure and no way to reason about what changed.

@T(00:12:04)
While this error messaging isn't so nice, what _is_ nice that we were able to extract our playground-driven code to our package's library with very little work, update our playground to use the library, and get a passing test written. We're well on our way to have a working command line tool that uses our library.

@T(00:12:25)
But before we go any further, let's address the shortcoming of our test code, because we have a tool that excels at writing tests for very large blobs of data: [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing)! Rather than assert against a huge blob of text directly in the test file, we can take a snapshot of that text to disk and let the SnapshotTesting library automatically compare new snapshots against this reference on future test runs. And when the test does fail, we get a much better debugging experience: a line diff highlighting specific lines that have changed.

@T(00:13:02)
In order to gain access to SnapshotTesting we need to add it as a root-level dependency of our package using its `Package.swift` file.

```swift
.package(
  url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
  from: "1.5.0"
),
```

@T(00:13:28)
And we need to add the `SnapshotTesting` module as a dependency of the `EnumPropertiesTests` test target.

```swift
.testTarget(
  name: "EnumPropertiesTests",
  dependencies: ["EnumProperties", "SnapshotTesting"]),
```

@T(00:13:40)
Finally, we need to re-run `swift package generate-xcodeproj` in order to fetch the SnapshotTesting dependency and regenerate our project file in order to make it available to our test target.

```bash
$ swift package generate-xcodeproj
Updating https://github.com/apple/swift-syntax.git
Fetching https://github.com/pointfreeco/swift-snapshot-testing.git
Completed resolution in 9.66s
Cloning https://github.com/pointfreeco/swift-snapshot-testing.git
Resolving https://github.com/pointfreeco/swift-snapshot-testing.git at 1.5.0
generated: ./EnumProperties.xcodeproj
```

@T(00:14:13)
When we return to our project, we can see that `SnapshotTesting` is now listed in the `Dependencies` group.

@T(00:14:23)
And we can import it in our tests!

```swift
import SnapshotTesting
```

@T(00:14:28)
Let's comment out our enormous, difficult-to-debug assertion and replace it with something better. The entry point to the SnapshotTesting library is the `assertSnapshot` function:

```swift
assertSnapshot(matching: <#Value#>, as: <#Snapshotting<Value, Format>#>)
```

@T(00:14:40)
The `assertSnapshot` helper takes an input value, a snapshot strategy that describes what format that input value should snapshot into, and how those snapshot references should be compared during future test runs. We want to snapshot the string output of our visitor, so we're going to use the `lines` strategy. The `lines` strategy directly snapshots a given string to a text file and on future test runs it compares updated snapshots to those references using plain old equality and a line diffing algorithm.

```swift
assertSnapshot(matching: visitor.output, as: .lines)
```

@T(00:15:02)
When we run the tests we get a failure.

> Failed: failed - No reference was found on disk. Automatically recorded snapshot: …
>
> open "…/EnumProperties/Tests/EnumPropertiesTests/__Snapshots__/EnumPropertiesTests/testExample.1.txt"
>
> Re-run "testExample" to test against the newly-recorded snapshot.

@T(00:15:08)
This is the expected behavior of snapshot testing: we always fail when recording new snapshots. This ensures that continuous integration will fail if we commit new snapshot tests but forget to commit the corresponding snapshots.

@T(00:15:24)
When we re-run the test, it passes! And should the output ever change, we'll get a much nicer failure.

@T(00:15:28)
For example, to make sure it's working let's introduce some pesky trailing whitespace:

```swift
print("    \(pattern) = self else { return nil } ", to: &self.output)
```

> Failed: Snapshot does not match reference.

@T(00:15:40)
We get a failure, which, once expanded:

```diff
@−
"…/EnumProperties/Tests/EnumPropertiesTests/__Snapshots__/EnumPropertiesTests/testExample.1.txt"
@+
"/var/folders/…/T/EnumPropertiesTests/testExample.1.txt"

@@ −1,64 +1,64 @@
 extension Validated {
 extension Validated {
   var valid: Valid? {
-    guard case let .valid(value) = self else { return nil }
+    guard case let .valid(value) = self else { return nil } ¬
     return value
   }
```

Highlights with a line diff the exact difference. Even here, where the difference is quite subtle, we get a symbolic indicator that one line has trailing whitespace.

@T(00:16:01)
And when we remove that trailing whitespace, the tests once again pass!

## A custom snapshot strategy

@T(00:16:09)
With just a little bit of work we improved the testing capabilities of our code generation tool. We got rid of a gigantic assert that led to difficult-to-decipher failures and replaced with a small, easy-to-troubleshoot snapshot test. It's already a huge improvement, but maybe we can do better.

@T(00:16:38)
We're currently using the `lines` snapshotting strategy, which is one of the most basic strategies that comes with the library. One of the powerful things about SnapshotTesting is that it's super transformable, and we can build entirely new snapshot testing strategies out of old ones. We might even say that any direct use of the `lines` strategy is probably an indicator that a custom strategy could generalize some extra work. I think if we maybe define a custom snapshot strategy for our generator we'll unlock some interesting things.

@T(00:17:22)
Snapshot strategies are values of `Snapshotting`, and they're best defined on the `Snapshotting`  type as static members. This lets us hook into Swift's dot-prefix syntax like we did with the `.lines` strategy.

```swift
assertSnapshot(matching: visitor.output, as: .lines)
```

@T(00:17:40)
We can start by reopening the `Snapshotting` type to define our static strategy.

```swift
extension Snapshotting {

}
```

@T(00:17:58)
`Snapshotting` is generic over two parameters, `Value` and `Format`.

```swift
public struct Snapshotting<Value, Format> {
```

The `Value` is what gets passed to `assertSnapshot(matching:)`, and the `Format` describes how the value should be serialized and diffed. The `lines` strategy is of type `Snapshotting<String, String>`, where both `Value` and `Format` are plain old `String`s.

@T(00:18:05)
We know we want to constrain our `Format` to `String` since we're working with strings of source code.

```swift
extension Snapshotting where Format == String {
```

@T(00:18:19)
And the input that gets our enum properties generating are the file URLs that point to the Swift source code in question.

```swift
extension Snapshotting where Value == URL, Format == String {
```

@T(00:18:21)
Now we need to define our strategy. We can call this one `enumProperties`, since we'll be snapshotting our enum properties as Swift source code.

```swift
extension Snapshotting where Value == URL, Format == String {
  static let enumProperties: Snapshotting
}
```

@T(00:18:33)
Creating this value from scratch with an initializer takes a bit of work, so instead, we can build it from the existing `lines` strategy. To do so we can use the `pullback` method, which allows us to derive a whole new snapshotting strategy from an existing one, but it does so in a slightly weird way. We provide a function that goes from the type that we want to snapshot, `URL`, into the type we know how to snapshot, `String`, and that allows us to pull back the `lines` strategy on `String` to a whole new strategy on `URL`.

```swift
static var enumProperties: Snapshotting =
  Snapshotting<String, String>.lines
    .pullback(<#transform: (NewValue) -> String#>
```

@T(00:19:28)
Our new strategy works with URLs, so the transform function should go from `(URL) -> String`. This transform is responsible for taking a `URL` and returning a `String` of our generated enum property source code.

```swift
extension Snapshotting where Value == URL, Format == String {
  static var enumProperties: Snapshotting =
    Snapshotting<String, String>.lines.pullback { url in
    }
}
```

@T(00:19:32)
We've already done this work a bunch of times before, including in our test. We can copy that code, paste it in, and we should have a working snapshot strategy.

```swift
extension Snapshotting where Value == URL, Format == String {
  static var enumProperties: Snapshotting =
    Snapshotting<String, String>.lines.pullback { url in
      let tree = try SyntaxTreeParser.parse(url)
      let visitor = Visitor()
      tree.walk(visitor)
      return visitor.output
    }
}
```

> Error: Invalid conversion from throwing function of type '(_) throws -> String' to non-throwing function type '(_) -> String'

@T(00:19:42)
Oh, this error message is a bit difficult to parse, but it just means that `pullback` doesn't handle `throw`ing closures. We can force `try!` to get things working again.

```swift
let tree = try! SyntaxTreeParser.parse(url)
```

@T(00:19:56)
That's all there is to it!

@T(00:19:58)
Assuming all is working, we should be able to simplify our existing test by deleting our ad hoc code and using our brand new snapshot strategy instead.

```swift
func testExample() throws {
  let url = URL(fileURLWithPath: String(#file))
    .deletingLastPathComponent()
    .appendingPathComponent("Enums.swift")
  assertSnapshot(matching: url, as: .enumProperties)
```

@T(00:20:18)
Our test is now super direct in describing that: given a URL I want to assert that a snapshot of its source as enum properties exists and matches our reference. We can even re-use this strategy with other fixtures.

## Compiler-verified snapshots

@T(00:20:48)
This is looking really cool, but one thing I noticed is that the text-based snapshot of our code was saved as a `.txt` file. The SnapshotTesting library supports custom file extensions, so it might be nice to update our custom strategy to correctly identify our references as `.swift` files.

@T(00:21:18)
For example. Let's take a look at our current reference. Because this is a `.txt` file we don't get source code highlighting or any indicator that this is valid Swift.

@T(00:21:29)
What we can do is modify our strategy and change its path extension to `swift` so that the reference can be loaded by default as Swift source rather than text. In order to mutate this property, we'll need to update our assignment to do a bit more work. We can do so by opening up a closure, which allows us to temporarily assign the strategy to a mutable variable, mutate its file extension, and then return the result from the closure. And we can call this closure immediately so that it gets assigned to our static property.

```swift
static let enumProperties: Snapshotting = {
  var snapshotting: Snapshotting =
    Snapshotting<String, String>.lines.pullback { url -> String in
      let tree = try! SyntaxTreeParser.parse(url)
      let visitor = Visitor()
      tree.walk(visitor)
      return visitor.output
    }
  snapshotting.pathExtension = "swift"
  return snapshotting
}()
```

@T(00:21:56)
Now when we re-run our tests, we should get a newly-recorded reference with a `.swift` path extension.

> Failed: failed - No reference was found on disk. Automatically recorded snapshot: …
>
> open "…/EnumProperties/Tests/EnumPropertiesTests/__Snapshots__/EnumPropertiesTests/testExample.1.swift"
>
> Re-run "testExample" to test against the newly-recorded snapshot.

@T(00:21:59)
And we do! We get a failure that indicates we recorded a new snapshot, and we can see right there in the error message that the file saved has a `.swift` extension. We can even open up this reference and see that as a Swift file it's much easier to read, with editor affordances like syntax highlighting.

@T(00:22:16)
By outputting our snapshot as a Swift file we've also unlocked something kinda amazing: we've saved a valid Swift source file into our test target's directory, so if we can bring it into our Xcode project, we can use the Swift compiler to guarantee that we have valid Swift.

@T(00:22:35)
Let's hop back over to the terminal and regenerate our Xcode project.

```bash
$ swift package generate-xcodeproj
generated: ./EnumProperties.xcodeproj
```

@T(00:22:50)
When we open the project navigator and expand the `Tests` group we can see that the Swift Package Manager has included our snapshot in the test target. And because both the fixture defining our enums and the snapshot defining our enum properties are included in the test target, we now have a compile-time guarantee that, if our tests build and pass, then our generated code is completely valid Swift!

@T(00:23:05)
This is incredibly powerful! And it's a use case we never even dreamed of when we first started snapshot testing: we get compiler verification of our generated code, almost accidentally, and for free!

@T(00:23:37)
To show just how powerful this is, let's break our generator by forgetting to close our enum extensions.

```swift
// print("}", to: &self.output)
```

@T(00:23:55)
If we run our tests, they fail, since the snapshot has changed.

> Error: Snapshot does not match reference.

But maybe we're not paying attention and we record over this snapshot with invalid Swift.

```swift
record=true
assertSnapshot(matching: url, as: .enumProperties)
```

> Failed: Record mode is on. Turn record mode off and re-run "testExample" to test against the newly-recorded snapshot.

@T(00:24:17)
This time we get a failure because we're in record mode, which is expected.

@T(00:24:28)
What's incredible is if we try to build and run our tests again, we get a compiler failure! Our snapshot has a bunch of enums that aren't being closed:

> Error: Expected '}' at end of extension

@T(00:24:38)
This is very cool stuff, and we believe that any kind of source code generation tool should take advantage of this kind of feature, where you get compiler verification that the generated code is correct.

@T(00:24:44)
To get things building again, we can delete the contents of our fixture.

@T(00:24:54)
And re-comment in the code that generates those closing braces.

```swift
print("}", to: &self.output)
```

@T(00:24:57)
And finally re-record the snapshot.

```swift
record=true
assertSnapshot(matching: url, as: .enumProperties)
```

> Failed: Record mode is on. Turn record mode off and re-run "testExample" to test against the newly-recorded snapshot.
>
> open "…/EnumProperties/Tests/EnumPropertiesTests/__Snapshots__/EnumPropertiesTests/testExample.1.swift"

@T(00:25:03)
And once we leave `record` mode…

```swift
// record=true
```

We have a passing test again! And we can hop on over to the fixture to verify.

## Creating an executable

@T(00:25:08)
Alright, so far we've taken our experimental playground code generator, extracted it to a library, and written some really impressive snapshot tests that not only verify the output of our code generator, but give us a compile-time guarantee that the generated code builds!

@T(00:25:53)
There's just one thing left to do: we need a way of running our generator outside of our playground and tests. After all, the whole point of writing this tool is to be able to use it and benefit from enum properties everywhere, but it's not quite there yet. What we want is a command line tool that we can point at a bunch of Swift source files and generate enum properties for any enums it finds. The Swift Package Manager makes it incredibly easy to build executable targets, so let's do just that.

@T(00:26:16)
We can hop on over to `Package.swift` and add another product to our array of products. This time it's an `executable` target. While libraries are compiled as modules that can be imported by other targets, executables are compiled to programs that can be invoked from the command line.

```swift
.executable(
  name: "generate-enum-properties",
  targets: ["generate-enum-properties"]),
```

@T(00:26:37)
We gave our executable a lowercase name to match the convention of most command line tools.

@T(00:26:51)
We also need to add a new target of the same name to our array of targets. Our executable will depend on both `EnumProperties` and `SwiftSyntax`.

```swift
.target(
  name: "generate-enum-properties",
  dependencies: ["EnumProperties", "SwiftSyntax"]),
```

@T(00:27:03)
If we try to build our package right now it's going to fail because there's no corresponding `generate-enum-properties` directory and source code in the `Sources` directory.

```bash
$ swift package generate-xcodeproj
error: could not find source files for target(s): generate-enum-properties; use the 'path' property in the Swift 4 manifest to set a custom target path
```

@T(00:27:18)
We can start to fix this by hopping over to a terminal and make the expected directory.

```bash
$ mkdir Sources/generate-enum-properties
```

@T(00:27:27)
But we're not quite there yet.

```bash
$ swift package generate-xcodeproj
warning: target 'generate-enum-properties' in package 'EnumProperties' contains no valid source files
error: target 'generate-enum-properties' referenced in product 'generate-enum-properties' could not be found
```

We need a single source file, so let's stub out an empty `main.swift` file, which executable targets need. They act as an entryway into the application.

```bash
$ touch Sources/generate-enum-properties/main.swift
```

@T(00:27:49)
Running `swift package generate-xcodeproj` will update our project to include the new executable target.

```bash
$ swift package generate-xcodeproj
generated: ./EnumProperties.xcodeproj
```

@T(00:27:58)
Now our project file includes a new `Sources` directory with its empty `main.swift` file.

@T(00:28:06)
And we have a brand new target, `generate-enum-properties`, which we can build and run, but it doesn't do much yet.

@T(00:28:19)
What we want to do in `main.swift` is build the logic for our command line tool. We want to be able to pass in URLs that point to Swift source code so that we can run our code generation library against it before outputting code that can be saved to disk.

@T(00:28:41)
To get our feet wet, let's look at how we can get access to the command line arguments that get passed to our executable. Command line arguments are available on a static member of a standard library `CommandLine` type, which is an enum that has no cases and acts as a kind of namespace. We can print out these arguments whenever our command line tool is invoked.

```swift
print(CommandLine.arguments)
```

@T(00:28:57)
And to invoke our tool we can call `swift run generate-enum-properties`.

```bash
$ swift run generate-enum-properties
[4/4] Linking ./.build/x86_64-apple-macosx/debug/generate-enum-properties
[".build/x86_64-apple-macosx/debug/generate-enum-properties"]
```

@T(00:29:11)
It prints an array with a string that represents the path to the executable.

@T(00:29:22)
We can pass along more arguments and see how it affects the output.

```bash
$ swift run generate-enum-properties ./Tests/EnumPropertiesTests/Fixtures/Enums.swift
[4/4] Linking ./.build/x86_64-apple-macosx/debug/generate-enum-properties
[".build/x86_64-apple-macosx/debug/generate-enum-properties", "./Tests/EnumPropertiesTests/Fixtures/Enums.swift"]
```

@T(00:29:41)
Now we get a second string in that array of output that represents that argument. So now we have a way of accessing the inputs we need for our tool.

@T(00:29:53)
Now we can drop the first element of this input and we're left with all of the URLs passed as arguments to the main executable.

```swift
let urls = CommandLine.arguments.dropFirst()
```

@T(00:30:19)
Now we are working with an array of URL strings, but we need to transform them into actual `URL`s that can be passed to SwiftSyntax's syntax tree parser.

```swift
import Foundation

let urls = CommandLine.arguments.dropFirst()
  .map { URL(fileURLWithPath: $0) }
```

@T(00:30:37)
All that's left is the work that we've done a bunch before: parsing and visiting `URL`s in order to build up our generated source. This time we're working with more than one URL, so we can loop over them, parse them, and have the same `visitor` walk each one before finally printing the combined output.

```swift
import Foundation
import EnumProperties
import SwiftSyntax

let urls = CommandLine.arguments.dropFirst()
  .map { URL(fileURLWithPath: $0) }

let visitor = Visitor()

try urls.forEach { url in
  let tree = try SyntaxTreeParser.parse(url)
  tree.walk(visitor)
}

print(visitor.output)
```

@T(00:31:41)
And now when we `swift run` our executable.

```swift
$ swift run generate-enum-properties Tests/EnumPropertiesTests/Enums.swift
[2/2] Linking ./.build/x86_64-apple-macosx/debug/generate-enum-properties
extension Validated {
  var valid: Valid? {
    guard case let .valid(value) = self else { return nil }
    return value
  }
  var isValid: Bool {
    return self.valid != nil
  }
  var invalid: [Invalid]? {
    guard case let .invalid(value) = self else { return nil }
    return value
  }
  var isInvalid: Bool {
    return self.invalid != nil
  }
}
extension Node {
  var element: (tag: String, attributes: [String: String], children: [Node])? {
    guard case let .element(value) = self else { return nil }
    return value
  }
  var isElement: Bool {
    return self.element != nil
  }
  var text: String? {
    guard case let .text(value) = self else { return nil }
    return value
  }
  var isText: Bool {
    return self.text != nil
  }
}
extension Loading {
  var loading: Void? {
    guard case .loading = self else { return nil }
    return ()
  }
  var isLoading: Bool {
    return self.loading != nil
  }
  var loaded: A? {
    guard case let .loaded(value) = self else { return nil }
    return value
  }
  var isLoaded: Bool {
    return self.loaded != nil
  }
  var cancelled: Void? {
    guard case .cancelled = self else { return nil }
    return ()
  }
  var isCancelled: Bool {
    return self.cancelled != nil
  }
}
```

@T(00:31:51)
We get all of the output we expected!

@T(00:31:56)
We now have a tool that we can run against valid Swift source code and end up with output that we can integrate into our projects. For instance, we can redirect that output to a specific file:

```bash
$ swift run generate-enum-properties \
    Tests/EnumPropertiesTests/Enums.swift \
    > output.swift
```

@T(00:32:43)
And all of the generated code has been saved to disk, which we can verify by opening it, and which we can from here import into the project that needs it.

## What's the point?

@T(00:33:00)
Alright, we did it! We have a mostly-working library for generating enum properties. It took a few episodes to get there: we first identified that enum properties are important because it makes enum data access as ergonomic as struct data access. Then we sought out to use Swift Syntax to code generate enum properties, because it's a lot of boilerplate that you wouldn't want to write by hand. Finally we packaged it into a CLI tool that can be pointed to Swift source code and output all of that code.

@T(00:33:36)
It's not quite production-ready yet, though. It doesn't handle nested enums. It doesn't (not can it with its current design) handle private enums. And it doesn't know how to work with associated values that must be imported from another module. So even though we'll get a lot of use out of this tool as is, it will never be the same as if the Swift compiler did it for us.

@T(00:34:36)
While the compiler could handle all of these edge cases, who knows how long we'll have to wait. In the meantime, we can use this tool for many of our use cases today, and perhaps there could be an open source tool that others can use.

@T(00:34:54)
Code generation is a valuable tool to have in our tool set and lets us close the gap between things the compiler can accomplish for us in the future, today. Till next time!
