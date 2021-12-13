import Foundation

extension Episode {
  public static let ep171_modularization = Episode(
    blurb: """
We've talked about modularity a lot in the past, but we've never devoted full episodes to show how we approach the subject. We will define and explore various kinds of modularity, and we’ll show how to modularize a complex application from scratch using modern build tools.
""",
    codeSampleDirectory: "0171-modularization-pt1",
    exercises: _exercises,
    id: 171,
    length: 43*60 + 55,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1639375200),
    references: [
      reference(
        forSection: .isowords,
        additionalBlurb: "We previously discussed modularity and modern Xcode projects in our tour of [isowords](https://github.com/pointfreeco/isowords).",
        sectionUrl: "https://www.pointfree.co/collections/tours/isowords"
      )
    ],
    sequence: 171,
    subtitle: "Part 1",
    title: "Modularization",
    trailerVideo: .init(
      bytesLength: 276338642,
      vimeoId: 655905170,
      vimeoSecret: "0adfcfd50a9a3e7e402fdb7cba599f5c3e0657a7"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]

extension Episode.Video {
  public static let ep171_modularization = Self(
    bytesLength: 620286634,
    vimeoId: 655905307,
    vimeoSecret: "315be3ab99edc54550375ca854e2d19ea2031218"
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep171_modularization: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Over the last 11 episodes we have built up a pretty complex application in order to dive deep into the concepts of navigation. We discovered many new tools along the way that allow us to fully drive navigation off of state, including binding transformations, new overloads on existing SwiftUI Navigation APIs, and even all new SwiftUI views that aid in navigation. And most recently we even applied some of these concepts to UIKit to show how its navigation can also be purely driven off of state.
"""#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
When we finished the series of episodes we realized that the application we built actually serves as a really great example of something we've talked about quite a bit on Point-Free, and that's modularity. In past episodes we have shown how to split an application into many modules, and many months ago we even open sourced an entire application, called [isowords](https://github.com/pointfreeco/isowords), which was hyper-modularized into 86 (!) different modules. There are a ton of benefits to doing this, such as improved build times, stronger boundaries between unrelated components, the ability to run small pieces of the application in isolation, and more.
"""#,
      timestamp: 35,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, in the episodes in which we performed modularization the applications were quite small and toy-like, and in isowords we only demonstrated that it's possible to modularize but we didn't actually show how to do it from scratch.
"""#,
      timestamp: (1*60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, this week we are going to begin modularizing the application we built for exploring navigation and along the way we are going to uncover quite a few exciting things. We hope this inspires you to start looking into ways you can modularize your current code bases and start reaping the benefits today.
"""#,
      timestamp: (1*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"The "styles" of modularity"#,
      timestamp: (1*60 + 40),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
To begin with, what is modularity? When we say "modularity" we mean a very specific thing, and that is code put into Swift modules so that we can explicitly describe a public interface that is accessible from the outside. It may be hard to remember, but before the days of SPM it was laborious to create modules, and so we may have instead "modularized" by grouping related code files into directories and creating some kind of system of folders for organizing a code base. But none of that enforces the boundaries between parts of your code base, and so it isn't too helpful beyond simple organization. So when we say "module" we literally mean Swift modules.
"""#,
      timestamp: (1*60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
With the definition of modularity out of the way, let's discuss two important types of modularity in a code base. One of these styles is very easy to get started with but it makes a relatively small impact on your code base, whereas the other can be quite difficult to achieve but has the biggest impact.
"""#,
      timestamp: (2*60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The first style is to extract out commonly used code out of the main application target and into a module on its own. An example of this is the models in your application. Ideally the model layer of your application is just a bunch of simple structs representing plain data. Models tend to have the fewest dependencies on other parts of your application, and so they are the easiest to extract out into their own module.
"""#,
      timestamp: (2*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Another good example is "helper" code. Any moderately complex iOS application naturally builds up a suite of helper code, such as extensions on standard library types, reusable SwiftUI view components, and more. This type of code also tends to have no external dependencies and so it is also typically easy to extract into its own module.
"""#,
      timestamp: (2*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Library code such as API clients, analytics clients, etc., are another example of common, "cross-cutting" code that can typically be easily extracted into modules.
"""#,
      timestamp: (3*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, extracting out these kinds of modules can be useful, but their impact on the healthiness of your code base is quite limited. You probably aren't going to get a significant boost in compile times with these modules, as the code in models and helpers doesn't grow at the same rate as the actual feature code in your application. Also, extracting out these kinds of modules doesn't help a lot in enforcing stronger boundaries between parts of your code. It can certainly be nice to isolate model code from feature code, but that kind of boundary isn't as important as being able to create a boundary between independent features of your application, like say between a search feature and a user profile feature.
"""#,
      timestamp: (3*60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Even though model and helper modularity has limitations, it is still a pre-requisite for the second, more powerful, albeit more difficult, style of modularity, which we call "feature" modularity. This is where you take everything that defines a single, atomic feature of your application and bundle it up into a module.
"""#,
      timestamp: (4*60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Some natural candidates for this type of modularity are full screen views of your application. For example, if you were making a social photo application you could think of the activity feed as a single feature, the photo detail as another feature, the search screen as a feature, the profile, settings, and more. Even things that are not full screen views can be features, such as if you have a row in a list with some particularly complex behavior.
"""#,
      timestamp: (4*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
As an example, in our isowords application we have 17 dedicated feature modules, such as a daily challenge feature, a game feature, a leaderboard feature, a multiplayer feature, an onboarding feature, an upgrade feature for handling in-app purchases, and more. The benefits of these feature modules are numerous. We can build a feature in full isolation without building anything that is not necessary. This can greatly cut down compile times, maximize how often you perform incremental builds, and minimize the number of times you must perform a full build from scratch.
"""#,
      timestamp: (5*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Further, having many independent feature modules can help Swift be smarter about how it compiles multiple things in parallel. For example, the game feature and leaderboard feature are pretty hefty modules, but they are completely independent, and so ostensibly they can be built in parallel.
"""#,
      timestamp: (5*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And lastly, these feature modules enforce very strong boundaries between different parts of your application. A module is simply not allowed to access the types and functions of another module unless it has an explicit dependency on that module. This can help you uncover potential problems in your code base if suddenly a module needs to start depending on another module that is completely unrelated. For example, it would be quite strange if the leaderboard feature needed to depend on the onboarding feature. If we find ourselves in a situation where the leaderboard feature does need access from some things in onboarding, then it either means we should extract out some code from onboarding into a third module that both can depend on, or it could mean we are approaching our problem in the wrong way and there's a higher level of abstraction that needs to happen.
"""#,
      timestamp: (5*60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Although the feature style of modularity is very powerful, it's also typically the most difficult to get into place in a code base. Code bases that weren't built with modularity in mind from the beginning tend to have a lot of hidden, implicit dependencies between parts of the code, meaning you have to perform some upfront work to dis-entangle things before you can even think about modularizing.
"""#,
      timestamp: (6*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Modern Xcode project modularization"#,
      timestamp: (6*60 + 54),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that was a whole bunch of talking about modularity without doing anything. Let's now get our hands dirty. We are going to show off both styles of modularity in the navigation app we built in previous episodes, and along the way we are going to uncover some really interesting things.
"""#,
      timestamp: (6*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's start by deciding how we want to add modules to our existing Xcode project. We could support additional modules by adding new targets to the project, but that is really cumbersome. Each new target comes with a bunch of baggage, such as huge changes to the Xcode project file, which means more chances for merge conflicts, an "Info.plist" file, and more. We could also try out a third party tool for managing multiple targets in an Xcode project, such as [CocoaPods](https://cocoapods.org) or [XcodeGen](https://github.com/yonaskolb/XcodeGen), but introducing a dependency like that should not be taken lightly and should be heavily discussed with your team.
"""#,
      timestamp: (7*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We are going to use SPM in order to organize modules in our project. In our opinion this is the simplest way to structure a modern Xcode project, and requires the fewest steps and tools.
"""#,
      timestamp: (7*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
To introduce SPM into an existing Xcode project we will just `cd` into the root directory of the project and run `swift package init`:
"""#,
      timestamp: (8*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
$ swift package init
Creating library package: Inventory
Creating Package.swift
Creating README.md
Creating .gitignore
Creating Sources/
Creating Sources/Inventory/Inventory.swift
Creating Tests/
Creating Tests/InventoryTests/
Creating Tests/InventoryTests/InventoryTests.swift
"""#,
      timestamp: nil,
      type: .code(lang: .shell)
    ),
    Episode.TranscriptBlock(
      content: #"""
This creates a couple of files and directories for us at the root, including a `Package.swift` file that describes what libraries and targets the package holds.
"""#,
      timestamp: (8*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now technically we have two different Xcode projects available to us. Opening the "Package.swift" opens an Xcode project that just manages the libraries in the package, but we can also open the "SwiftUINavigation.xcodeproj" file that holds all the targets and code for our application. Ideally we should have a way of combining both of these things into a single project so that we could develop modules in the SPM package and make use of them in the application project.
"""#,
      timestamp: (8*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It's easy enough to do this, we just need to open the application project, and then drag the directory that holds the "Package.swift" file into the project. Xcode will instantly recognize that the directory represents an SPM package and will nicely format its appearance in the file list on the left.
"""#,
      timestamp: (9*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
One strange thing is that we can see the "SwiftUINavigation" directory in the SPM package, as well as at the root of the Xcode project. There's a trick you can perform to hide the directory in the SPM directory, and that's to drop a "Package."swift file in the "SwiftUINavigation" directory with all empty fields:
"""#,
      timestamp: (9*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import PackageDescription

let package = Package(
  name: "",
  products: [],
  dependencies: [],
  targets: []
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If we close and re-open the Xcode project we will see that the directory is now omitted.
"""#,
      timestamp: (10*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Model, helper, and library modularity"#,
      timestamp: (10*60 + 20),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Ok, we are now in a position to create our first module. Let's start with some of those simpler modules that we described earlier, like ones that hold models or helpers. Whenever we want to add a new module there's just a few steps we need to take.
"""#,
      timestamp: (10*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
For example, suppose we want to extract the `Item` type into its own module. We'd first update the "Package.swift" file to specify that we want a library named "Models" and a target named "Models":
"""#,
      timestamp: (10*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "Inventory",
  products: [
    .library(name: "Models", targets: ["Models"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Models"),
  ]
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If this module needed some external dependencies or if we wanted to write tests for this module then we would also add those things here.
"""#,
      timestamp: nil,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
After the "Package.swift" file is updated we need a "Models" directory in the "Sources" directory.
"""#,
      timestamp: (11*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And now we can cut and paste the entire `Item` type into an "Models.swift" file in the "Models" directory.
"""#,
      timestamp: (11*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And with just that we now have a brand new target in Xcode for building just the models code. If we try building the "Models" module we will get some errors that we are accessing stuff from frameworks that hasn't been imported. In particular, we are using `UUID`s and SwiftUI colors, so let's import those frameworks:
"""#,
      timestamp: (11*60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import Foundation
import SwiftUI
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Further, it seems that we are using some SwiftUI APIs that are not available on iOS 12 and older, so let's restrict our package to only work for iOS 15 and newer:
"""#,
      timestamp: (12*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
platforms: [.iOS(.v15)],
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the Models module is building, and that's pretty cool. This means that if we needed to do heavy work on our model layer, then we could build it in full isolation without worrying about the rest of the app building. That will be a great boon for productivity.
"""#,
      timestamp: (12*60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now that we have our first module set up, let's try getting the full application building. If we try building the application target it will of course fail because we have moved the `Item` type out of the target.
"""#,
      timestamp: (13*60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We need to make the application target depend on the "Models" module.
"""#,
      timestamp: (13*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And we need to import the Models module in any file that wants access to models, which is basically every file.
"""#,
      timestamp: (13*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
When we try to build, we still get compilation errors:

> 🛑 Cannot find 'Item' in scope

And that's because, by default everything defined in a module is "internal" to the module and not accessible from the outside. Everything that we want access to outside of the module must make this contract explicit by being annotated with the `public` access control modifier.
"""#,
      timestamp: (14*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This is one of the annoying things with modularizing, but it's necessary. When developing everything in a single app target we didn't have to worry about internal access versus public because they were effectively the same. But now that the `Item` type and everything in it is internal and in another module, it means we can't access it from other modules, like the app.
"""#,
      timestamp: (14*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, let's quickly make everything public:
"""#,
      timestamp: (14*60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import SwiftUI

public struct Item: Equatable, Identifiable {
  public let id = UUID()
  public var name: String
  public var color: Color?
  public var status: Status

  public enum Status: Equatable {
    case inStock(quantity: Int)
    case outOfStock(isOnBackOrder: Bool)

    public var isInStock: Bool { ... }
  }

  public struct Color: Equatable, Hashable {
    public var name: String
    public var red: CGFloat = 0
    public var green: CGFloat = 0
    public var blue: CGFloat = 0

    public static var defaults: [Self] = [ ... ]

    public static let red = Self(name: "Red", red: 1)
    public static let green = Self(name: "Green", green: 1)
    public static let blue = Self(name: "Blue", blue: 1)
    public static let black = Self(name: "Black")
    public static let yellow = Self(name: "Yellow", red: 1, green: 1)
    public static let white = Self(name: "White", red: 1, green: 1, blue: 1)

    public var swiftUIColor: SwiftUI.Color { ... }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If we try building, it still fails, though with fewer errors. The main has to do with the item's initializer:

> 🛑 'Item' initializer is inaccessible due to 'internal' protection level

The initializers that structs automatically synthesize is also internal, which means we must do a little extra work here.
"""#,
      timestamp: (15*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's also get a public initializer in place:
"""#,
      timestamp: (15*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public init(
  name: String,
  color: Color? = nil,
  status: Status
) {
  self.name = name
  self.color = color
  self.status = status
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we'll need one for the `Item.Color` as well:
"""#,
      timestamp: (16*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public init(
  name: String,
  red: CGFloat = 0,
  green: CGFloat = 0,
  blue: CGFloat = 0
) {
  self.name = name
  self.red = red
  self.green = green
  self.blue = blue
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
The project now successfully compiles and we have finished extracting our first bit of shared code!
"""#,
      timestamp: (16*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that took a little bit of work, but it also wasn't too difficult.
"""#,
      timestamp: (16*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's try another module. We have a file that holds a whole bunch of SwiftUI helpers that we developed over the course of the navigation episodes, and everything in the file is fully self-contained. We actually open sourced all of these helpers in our [swiftui-navigation](https://github.com/pointfreeco/swiftui-navigation) package, but for now let's forget that project exists so that we can move it into its own module in this code base.
"""#,
      timestamp: (16*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We'll start by adding a "SwiftUIHelpers" library to the "Package.swift" file:
"""#,
      timestamp: (16*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
products: [
  .library(name: "Models", targets: ["Models"]),
  .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
],
dependencies: [
],
targets: [
  .target(name: "Models"),
  .target(name: "SwiftUIHelpers"),
]
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we'll create a "SwiftUIHelpers" directory in the "Sources" directory.
"""#,
      timestamp: (17*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we'll drop-and-drop the "SwiftUIHelpers.swift" file into that directory.
"""#,
      timestamp: (17*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And just like that we have another target in Xcode for the SwiftUI helpers.
"""#,
      timestamp: (17*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If we try building the module real quick to make sure everything is ok we will see that it can't find the "CasePaths" module. This is because "CasePaths" is something that the main app target depends on, but we haven't added it as an explicit dependency in our SPM package.
"""#,
      timestamp: (17*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It's easy enough to do that. We can add the "swift-case-paths" package to our dependencies array:
"""#,
      timestamp: (17*60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
dependencies: [
  .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.7.0"),
]
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then have the "SwiftUIHelpers" depend on "CasePaths":
"""#,
      timestamp: (18*60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.target(
  name: "SwiftUIHelpers",
  dependencies: [
    .product(name: "CasePaths", package: "swift-case-paths"),
  ]
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now the "SwiftUIHelpers" module compiles.
"""#,
      timestamp: (18*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we need to make everything public:
"""#,
      timestamp: (18*60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
extension Binding {
  public init?(unwrap binding: Binding<Value?>) {
  ...
  public func isPresent<Wrapped>() -> Binding<Bool>
  ...
  public func isPresent<Enum, Case>(_ casePath: CasePath<Enum, Case>) -> Binding<Bool>
  ...
  public func `case`<Enum, Case>(_ casePath: CasePath<Enum, Case>) -> Binding<Case?>
  ...
  public func didSet(_ callback: @escaping (Value) -> Void) -> Self {
  ...
}
extension View {
  public func alert<A: View, M: View, T>(
  ...
  public func alert<A: View, M: View, Enum, Case>(
  ...
  public func confirmationDialog<A: View, M: View, T>(
  ...
  public func confirmationDialog<A: View, M: View, Enum, Case>(
  ...
  public func sheet<Value, Content>(
  ...
  public func sheet<Enum, Case, Content>(
  ...
  public func popover<Value, Content>(
  ...
  public func popover<Enum, Case, Content>(
  ...
}
extension NavigationLink {
  public init<Value, WrappedDestination>(
  ...
  public init<Enum, Case, WrappedDestination>(
  ...
}
public struct IfCaseLet<Enum, Case, Content>: View where Content: View {
  ...
  public init(
  ...
  public var body: some View {
  ...
}
public struct ToSwiftUI: UIViewControllerRepresentable {
  ...
  public init(_ viewController: @escaping: () -> UIViewController) {
    self.viewController = viewController
  }
  ...
  public func makeUIViewController(context: Context) -> UIViewController {
  ...
  public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then, to get the main app target building we need to update the project settings to depend on the new "SwiftUIHelpers" module.
"""#,
      timestamp: (19*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And import the module everywhere we are using it.
"""#,
      timestamp: (19*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And now everything builds. Once you get a hang of extracting things you can do it very quickly.
"""#,
      timestamp: (19*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
There's one more quick module that can be extracted, and that's all the parser helpers we developed in the last episode of our navigation series. Right now they are all in the top of the "ContentView.swift" and they contain some basic types and parsers for parsing URL requests, which allowed us to add deep linking to our application.
"""#,
      timestamp: (20*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's create a new "ParsingHelpers" library in our SPM package:
"""#,
      timestamp: (20*60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.library(name: "ParsingHelpers", targets: ["ParsingHelpers"]),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we'll need to add an external dependency on our parsing library:
"""#,
      timestamp: (20*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.3.1"),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then we can add a new target for our parser helpers that depends on the parsing library:
"""#,
      timestamp: (20*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.target(
  name: "ParsingHelpers",
  dependencies: [
    .product(name: "Parsing", package: "swift-parsing")
  ]
),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we need to create a "ParsingHelpers" directory.
"""#,
      timestamp: (21*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We'll create a "ParsingHelpers.swift" file in that directory.
"""#,
      timestamp: (21*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And we'll cut-and-paste the parser-related code from the "ContentView.swift" file to this new file.
"""#,
      timestamp: (21*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
To get this file compiling we need to import some things:
"""#,
      timestamp: (21*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import Foundation
import Parsing
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we'll need to make everything public:
"""#,
      timestamp: (21*60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public struct DeepLinkRequest { ... }

extension DeepLinkRequest {
  public init(url: URL) {
    ...
  }
}

public struct PathComponent<ComponentParser>: Parser
  ...
  public init(_ component: ComponentParser) {
  ...
  public func parse(_ input: inout DeepLinkRequest) -> ComponentParser.Output? {
  ...
}

public struct PathEnd: Parser {
  public init() {}

  public func parse(_ input: inout DeepLinkRequest) -> Void? {
  ...
}

public struct QueryItem<ValueParser>: Parser
  ...
  public init(_ name: String, _ valueParser: ValueParser) {
  ...
  public init(_ name: String) where ValueParser == Rest<Substring> {
  ...
  public func parse(_ input: inout DeepLinkRequest) -> ValueParser.Output? {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now we can have the application target depend on our new "ParsingHelpers" module.
"""#,
      timestamp: (22*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And import it from "ContentView.swift":
"""#,
      timestamp: (22*60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import ParsingHelpers
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the application builds and we have extracted out yet another module.
"""#,
      timestamp: (22*60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Feature modularity, and the item feature"#,
      timestamp: (22*60 + 53),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we have now completed the simplest kind of modularity one can do in a code base. We have extracted out models and some helpers into their own modules. It's typically easy to perform this kind of modularity because models and helpers usually do not have complex dependencies or entanglement with feature code. So we think this is the first approach you should take when trying to modularize an existing code base. It gives you a few small wins really quickly.
"""#,
      timestamp: (22*60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But now let's try for a more complicated type of modularity: "feature" modularity. We want to extract out an entire feature into its own module so that it can be built and run in full isolation. The best way to ease into this kind of modularity is to pick a feature of your application that has the fewest dependencies. These features are usually the leaf nodes of your application's navigation. Screens that you can navigate to, but that don't have any (or many) places to navigate to next.
"""#,
      timestamp: (23*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
For our application that leaf node is the item view. Or, if we wanted to really modularize, we could even start with the color picker view. But for now, let's start with the item view.
"""#,
      timestamp: (23*60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We'll add a library entry to our "Package.swift" file:
"""#,
      timestamp: (24*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.library(name: "ItemFeature", targets: ["ItemFeature"]),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we'll add a target, but the item feature has some dependencies we need to specify. We'll definitely need to depend on at least the "Models" and "SwiftUIHelpers" modules, and maybe even more, but let's start there:
"""#,
      timestamp: (24*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.target(
  name: "ItemFeature",
  dependencies: [
    "Models",
    "SwiftUIHelpers"
  ]
),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we'll create a "ItemFeature" directory and drag-and-drop the "ItemView.swift" file as well as the "ItemViewController.swift" file into the directory.
"""#,
      timestamp: (24*60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If we try to build we will see that it succeeds, but that is also a little surprising. In the "ItemViewController.swift" file we are explicitly importing "CasePaths", but our "ItemFeature" doesn't actually depend on "CasePaths". So, how is this compiling?
"""#,
      timestamp: (24*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Well, it seems that Xcode and SPM pick up transitive dependencies, and since "SwiftUIHelpers" depends on "CasePaths", and "ItemFeature" depends on "SwiftUIHelpers", then we don't need to explicitly need to explicitly depend on "CasePaths".
"""#,
      timestamp: (25*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, if you want to keep your dependencies as explicit as possible, maybe you will want to specify it:
"""#,
      timestamp: (25*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.target(
  name: "ItemFeature",
  dependencies: [
    "Models",
    "SwiftUIHelpers",
    .product(name: "CasePaths", package: "swift-case-paths")
  ]
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And with just that we can already build the ItemFeature module in isolation.
"""#,
      timestamp: (25*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In fact, this already comes with huge benefits because we have an Xcode preview in place for this view, which means we run it now without having to build the entire application. No matter how much the full application bloats with new features, we will always be able to build this one little screen in isolation and run its preview nearly instantaneously.
"""#,
      timestamp: (25*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This wasn’t possible when we had a single, large app target. The only way to run this preview was to build the entire application. And that meant if we were in the middle of an `ItemView` refactor, we would not be allowed to preview our refactor until we got the entire application building.
"""#,
      timestamp: (26*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
That’s really unfortunate because while refactoring we want the freedom to try out many experimental refactors, and if we had to get the entire application building everytime it would really slow down the feedback loop and deter us from refactoring in the first place.
"""#,
      timestamp: (26*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So already this is incredibly powerful.
"""#,
      timestamp: (26*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But, there’s a bit more work to do. In order for the code in the item feature to be usable from other modules we need to make a bunch of stuff public:
"""#,
      timestamp: (26*60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// ItemView.swift
public class ItemViewModel: Identifiable, ObservableObject {
  @Published public var item: Item
  ...
  public var id: Item.ID { self.item.id }

  public enum Route { ... }

  public init(item: Item, route: Route? = nil) {
  ...
}

public struct ItemView: View {
  ...
  public init(viewModel: ItemViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
// ItemViewController.swift
public class ItemViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  ...
  public init(viewModel: ItemViewModel) {
  ...
  override public func viewDidLoad() {
  ...
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
  ...
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
  ...
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
  ...
  public func pickerView(
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now we can make the main app target depend on this module, and we can `import ItemFeature` wherever we need access to this code.
"""#,
      timestamp: (27*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the entire application builds and runs just as it did before, but we have an entire feature split off into its own module.
"""#,
      timestamp: (28*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"The item row feature"#,
      timestamp: (28*60 + 28),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's move onto the next feature. We could jump all the way to the inventory feature, which is responsible for the list of inventory items as well as quite a bit of logic for add and removing items.
"""#,
      timestamp: (28*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, there's a smaller feature that sits between the item feature and the inventory feature, and that's the item row feature. This feature is responsible for all of the behavior in a single row, which is actually pretty substantial. It has its own view model, handles the navigation to three different destinations (delete alert, duplicate popover and edit drill down), and even performs some "asynchronous" work to simulate the idea of saving the edits of an item.
"""#,
      timestamp: (28*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It would be great to run this feature in full isolation without having to build the rest of the application. We should have the hang of this by now, so let's quickly do it. We'll add a library to the Package.swift file:
"""#,
      timestamp: (28*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.library(name: "ItemRowFeature", targets: ["ItemRowFeature"]),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We'll add a target for the "ItemRowFeature", which will have all the same dependencies as the "ItemFeature" but will also depend on the "ItemFeature" since we need to navigate to it:
"""#,
      timestamp: (29*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.target(
  name: "ItemRowFeature",
  dependencies: [
    "ItemFeature",
    "Models",
    "SwiftUIHelpers",
    .product(name: "CasePaths", package: "swift-case-paths")
  ]
),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we'll create an "ItemRowFeature" directory, and drag the "ItemRow.swift" file and "ItemRowCellView.swift" file into it.
"""#,
      timestamp: (29*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And already we can build the "ItemRowFeature" in complete isolation. Let's take advantage of this by introducing a preview dedicated to just displaying this row view, which is something we didn't do when everything was just in the app target. After all, why create a preview just for the row when we have to build everything anyway. Might as well just use the inventory preview.
"""#,
      timestamp: (29*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We can create a simple preview like so:
"""#,
      timestamp: (29*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct ItemRowPreviews: PreviewProvider {
  static var previews: some View {
    ItemRowView(
      viewModel: .init(
        item: .init(name: "Keyboard", status: .inStock(quantity: 1))
      )
    )
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But doing it like this is a little silly. It's just sharing a bare row in the middle of the screen. The item row really feels most at home when embedded in a list:
"""#,
      timestamp: (30*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct ItemRowPreviews: PreviewProvider {
  static var previews: some View {
    List {
      ItemRowView(
        viewModel: .init(
          item: .init(name: "Keyboard", status: .inStock(quantity: 1))
        )
      )
    }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This looks better, but the row is grayed out. And that's because the whole row is a navigation link, which further wants to be embedded in a navigation view:
"""#,
      timestamp: (30*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct ItemRowPreviews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      List {
        ItemRowView(
          viewModel: .init(
            item: .init(name: "Keyboard", status: .inStock(quantity: 1))
          )
        )
      }
    }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now it's looking much better, and if we run the preview we will see that quite a bit of the row's behavior is fully functional. For example, we can drill down, make edits, hit save, we see the asynchronous work being performed, and then we are automatically popped back to the root.
"""#,
      timestamp: (30*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Of course things like duplicate and delete aren't fully functional because the parent domain, in particular the inventory list, implements most of that logic. We can still tap on those buttons and see the alert and popover, but the actions in those UIs don't do anything.
"""#,
      timestamp: (31*60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But still, this is pretty amazing that we can run such a specific feature in full isolation without building the full inventory list feature, not to mention any of the code that would go into the other tabs of the application. Recall that the full application is tab-based with 2 other tabs besides the inventory list. Each of those features is probably going to be significant, which means if we wanted to work on our little item row view we would have to build all of that unrelated code.
"""#,
      timestamp: (31*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now, the "ItemRowFeature" isn't usable from other modules yet because everything is still internal, so let's make everything public:
"""#,
      timestamp: (31*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// ItemRow.swift
public class ItemRowViewModel: Hashable, Identifiable, ObservableObject {
  @Published public var item: Item
  @Published public var route: Route?
  ...
  public func hash(into hasher: inout Hasher) {
  ...
  public static func == (lhs: ItemRowViewModel, rhs: ItemRowViewModel) -> Bool {
  ...
  public enum Route: Equatable {
    ...
    public static func == (lhs: Self, rhs: Self) -> Bool {
    ...
  }

  public var onDelete: () -> Void = {}
  public var onDuplicate: (Item) -> Void = { _ in }

  public var id: Item.ID { self.item.id }

  public init(
  ...
  public func deleteButtonTapped() {
  ...
  public func setEditNavigation(isActive: Bool) {
  ...
  public func cancelButtonTapped() {
  ...
  public func duplicateButtonTapped() {
  ...
}

extension Item {
  public func duplicate() -> Self {
}

public struct ItemRowView: View {
  ...
  public init(viewModel: ItemRowViewModel) {
  ...
  public var body: some View {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
// ItemRowCellView.swift
public class ItemRowCellView: UICollectionViewListCell {
  ...
  override public func prepareForReuse() {
  ...
  public func bind(viewModel: ItemRowViewModel, context: UIViewController) {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now we can get the main application target building by having it depend on the `ItemRowFeature` and importing the module into a few files.
"""#,
      timestamp: (32*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
One interesting thing you will notice is that we have an extension of the `ItemRowViewModel` that adds a `navigate(to:)` method for deep linking. That should probably go in the "ItemRowFeature" now, but we will look into that in a moment.
"""#,
      timestamp: (33*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the main application is building and should run exactly as it did before, but we have split off another small feature from the main application target. The "SwiftUINavigation" target is getting smaller and smaller, which is nice.
"""#,
      timestamp: (33*60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"The inventory feature"#,
      timestamp: (33*60 + 56),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's move onto the next feature. Sitting one level above the "ItemRowFeature" is the "InventoryFeature". This is an even more significant feature. It manages the full behavior for the list of inventory items. It has a view model that handles some routing, including some nuanced logic for synchronizing routes between the inventory domain and the row domain, it performs some "advanced" "ML" and "AI" logic of predicting some details of the item you want to add when the new item view modal comes up, and it manages adding and removing items from the list.
"""#,
      timestamp: (33*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
By this point we are pros at making new feature models, so let's do it. We can add a new library to the "Package.swift" file:
"""#,
      timestamp: (34*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.library(name: "InventoryFeature", targets: ["InventoryFeature"]),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we need to add the target, but recall that the inventory view model depends on our "IdentifiedCollections" package. We do this because we need a precise and efficient way of holding a collection of `ItemRowViewModel`s so that when asynchronous work is performed we can correctly find which row originated that work. So, let's add "IdentifiedCollections" to our list of dependencies:
"""#,
      timestamp: (34*60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.3.2"),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now we can create the target for the InventoryFeature, which also needs to depend on the ItemRowFeature:
"""#,
      timestamp: (35*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.target(
  name: "InventoryFeature",
  dependencies: [
    "ItemRowFeature",
    "Models",
    "SwiftUIHelpers",
    .product(name: "CasePaths", package: "swift-case-paths"),
    .product(name: "IdentifiedCollections", package: "swift-identified-collections")
  ]
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we will add a "InventoryFeature" directory and drag the "Inventory.swift" and "InventoryViewController.swift" files to it.
"""#,
      timestamp: (35*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And already the "InventoryFeature" module should compile just fine, and in fact we can run its preview. This allows us to now actually test the delete and duplicate functionality because it's the `InventoryViewModel` that implements that logic.
"""#,
      timestamp: (35*60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In order for the code in this module to be usable outside the module we need to make everything public:
"""#,
      timestamp: (36*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// Inventory.swift
public class InventoryViewModel: ObservableObject {
  @Published public var inventory: IdentifiedArrayOf<ItemRowViewModel>
  @Published public var route: Route?
  ...
  public enum Route: Equatable {
    ...
    public static func == (lhs: Self, rhs: Self) -> Bool {
    ...
  }

  public init(
  ...
}

public struct InventoryView: View {
  ...
  public init(viewModel: InventoryViewModel) {
  ...
  public var body: some View {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
// InventoryViewController.swift
public class InventoryViewController: UIViewController, UICollectionViewDelegate {
  ...
  public init(viewModel: InventoryViewModel) {
  ...
  override public func viewDidLoad() {
  ...
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then we can get the main application target building by adding "InventoryFeature" as a dependency and importing it in a few spots.
"""#,
      timestamp: (36*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And now the application target builds, everything should work exactly as it did before, but we have now extracted yet another feature module. The app target module is starting to get really slim.
"""#,
      timestamp: (36*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"The "app" feature"#,
      timestamp: (37*60 + 5),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
You may think we're done extracting feature modules, but there's actually still one more we can do. Recall that the root `ContentView` consists of a tab view that brings together the inventory view with a few other tabs, and it holds an `AppViewModel` which integrates the domains for each tab into a single package. This view and view model are going to get a lot more complicated as we start building out the features for the other tabs and when we need to start integrating the domains of each tab in more complex ways.
"""#,
      timestamp: (37*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This is reason enough for us to want to extract out this domain into its own feature module, which we will call the "AppFeature". Let's add the library to our "Package.swift" file:
"""#,
      timestamp: (37*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.library(name: "AppFeature", targets: ["AppFeature"]),
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And a target:
"""#,
      timestamp: (37*60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.target(
  name: "AppFeature",
  dependencies: [
    "InventoryFeature",
    "Models",
    "ParsingHelpers",
    .product(name: "Parsing", package: "swift-parsing"),
  ]
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we will create the "AppFeature" directory and move the "ContentView.swift" and "ContentViewController.swift" files to it.
"""#,
      timestamp: (38*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
With that the "AppFeature" module is building, and we can even run its preview if we wanted to.
"""#,
      timestamp: (38*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
To get the main app target building we need to mark a bunch of stuff as public:
"""#,
      timestamp: (38*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// ContentView.swift
public enum Tab {
  ...
}

public class AppViewModel: ObservableObject {
  ...
  public init(
  ...
  public func open(url: URL) {
  ...
}

public struct ContentView: View {
  ...
  public init(viewModel: AppViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
// ContentViewController.swift
public class ContentViewController: UITabBarController {
  ...
  public init(viewModel: AppViewModel) {
  ...
  override public func viewDidLoad() {
  ...
  override public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then main the app target depend on the "AppFeature" and import it into the entry point of the application.
"""#,
      timestamp: (38*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the full app builds and would work exactly as it did before, but now the app target only consists of a single file: just the entry point. Its only responsibility is to construct the root content view and view model to kick things off, and everything else is handled by our feature modules.
"""#,
      timestamp: (39*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In fact, since the entry point really only needs the app feature to kick things off we can even simplify how we specify the dependencies are specified in the Xcode project settings.
"""#,
      timestamp: (39*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This simplifies dependencies because we only need to worry about our dependency tree in the SPM package. We don't need to manage this additional dependency structure in the Xcode project, which is only editable via this graphical interface and can become a serious headache for large projects, especially when dealing with merge conflicts in git.
"""#,
      timestamp: (39*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In fact, because our entire dependency tree is fully captured in the SPM package we can even delete all the external dependencies that were added directly to the Xcode project file.
"""#,
      timestamp: (39*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The main app target of the application now only holds a single file, the entry point of the app, and all the real code of the project lies in one of 7 SPM modules.
"""#,
      timestamp: (40*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This proliferation of modules and targets may worry you a little bit. You may think it makes it harder to navigate the project. However, we think the opposite is true. In a non-modularized code base one tends to create some system of directories in order to organize all of the code files. This directory structure is ad hoc, and it is your and your team's responsibility to uphold it. Modules on the other hand give us a more structured way to organize code files, and each collection of files becomes a buildable unit on its own.
"""#,
      timestamp: (40*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It is true that we have some added overhead of needing to know which target we currently have selected, and it takes work to search and find a different target to switch to. Previously, with just a single app target, we didn't have to worry about that because we essentially only had a single target.
"""#,
      timestamp: (40*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, there are some handy keyboard shortcuts you can learn that make this situation much better. In Xcode you can type in the shortcut control+0 to bring up the targets popup menu. Once this menu is opened you can use your keyboard's arrow keys to choose a different target, or even choose a different simulator to build for.
"""#,
      timestamp: (40*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Even better, the popup menu is also searchable by just typing letters while it's open. So, if we just type the letters "Row" we instantly see the list of targets filtered down to only the "ItemRowFeature" module, which is now easy to select. This little trick makes it much easier to navigate between targets very easily, allowing you to build only the parts of the application that are important to you right now.
"""#,
      timestamp: (41*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Next time: deep link modularity"#,
      timestamp: (41*60 + 39),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
We have now completed a full modularization of our application. What used to be a single application target with 8 Swift files and many hundreds of lines of code is now 7 Swift modules, each with just one or two files, and each file under 200 lines except for our SwiftUI helpers file and UIKit files.
"""#,
      timestamp: (41*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Previously any change to a file, no matter how small, would trigger a build of the application target, and we would just have to hope that Swift's incremental compilation algorithm was smart enough to not build more than is necessary. Swift's incremental compilation is really, really good, but there are still times it gets tripped up and a build will take a lot longer than you expect. Or worse, if you need to merge main into your branch to get up-to-date with what your colleagues are doing, you will most likely trigger a full re-compilation of your entire project because many things have probably changed.
"""#,
      timestamp: (41*60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now, with feature modules, we have a lot more control over what gets built and what doesn't. If you are deep in focus mode on just the item view, then you can choose to build only the "ItemFeature". Then you should feel free to merge main into your branch as often as you want because, at worse, you will only trigger a re-build of the "ItemFeature" module, which is a lot smaller than the full application. This can be a huge boon to productivity.
"""#,
      timestamp: (42*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But, we can take this even further. Right now the "AppFeature" has a pretty significant amount of logic that spans the responsibilities of many feature modules we have just created, and that's the deep linking functionality. The "AppFeature" is handling deep linking for the entire application, even though the only view the module holds is a tab view, and the only deep linking logic important for that view is to figure out which tab we should switch to. All the other deep linking logic just delegates to `navigate(to:)` methods that are defined on the child view models.
"""#,
      timestamp: (42*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
What if we could fully modularize our deep linking logic? Not only would we move the `navigate(to:)` methods to each feature's view model, but we would even move the parsers themselves to the feature modules. That would mean we could even work on parsing and deep linking logic in complete isolation from the rest of the application, which would be pretty incredible.
"""#,
      timestamp: (43*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's give it a shot.
"""#,
      timestamp: (43*60 + 51),
      type: .paragraph
    ),
  ]
}
