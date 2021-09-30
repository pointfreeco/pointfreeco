import Foundation

extension Episode {
  public static let ep162_navigationSheets = Episode(
    blurb: """
It's time to look at a more advanced kind of navigation: modals. This includes sheets, popovers, and even full screen covers. We will implement a new feature that will be driven by a sheet and can be deep-linked into.
""",
    codeSampleDirectory: "0162-navigation-pt3",
    exercises: _exercises,
    id: 162,
    length: 43*60 + 32,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1633323600),
    references: [
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
      Episode.Reference(
        author: "Holly Borla & Filip Sakel",
        blurb: "The proposal that added property wrapper support to function and closure parameters, unlocking the ability to make binding transformations even more powerful.",
        link: "https://github.com/apple/swift-evolution/blob/79b9c8f09450cf7f38d5479e396998e3888a17e4/proposals/0293-extend-property-wrappers-to-function-and-closure-parameters.md",
        publishedAt: referenceDateFormatter.date(from: "2020-10-06")!,
        title: "SE-0293: Extend Property Wrappers to Function and Closure Parameters"
      ),
      Episode.Reference(
        author: "Matt Ricketson, Luca Bernardi & Raj Ramamurthy",
        blurb: "An in-depth explaining on view identity, lifetime, and more, and crucial to understanding how `@State` works.",
        link: "https://developer.apple.com/videos/play/wwdc2021/10022/",
        publishedAt: referenceDateFormatter.date(from: "2020-10-06")!,
        title: "WWDC 2021: Demystifying SwiftUI"
      ),
    ],
    sequence: 162,
    subtitle: "Sheets and Popovers, Part 1",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 52804666,
      vimeoId: 617405822,
      vimeoSecret: "c7053b4d4f6232ff3d302928a1f6e4310259e0af"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
