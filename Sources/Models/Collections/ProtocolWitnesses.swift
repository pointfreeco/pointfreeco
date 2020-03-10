extension Episode.Collection {
  public static let protocolWitnesses = Self(
    blurb: #"""
Protocols are great! We love them, you probably love them, and Apple certainly loves them! However, they aren't without their drawbacks. There are many times that using protocols can become cumbersome, such as when using associated types, and there are some things that are just impossible to do using protocols. We will explore some alternatives to protocols that allow us to solve some of these problems, and open up whole new worlds of composability that were previously impossible to see.
"""#,
    sections: [
      .init(
        blurb: #"""
Protocols are powerful for abstraction, but they aren't the only way to abstract. Turns out that nearly every protocol in Swift can be mechnically transformed into a simple, concrete data type. In doing so you can accomplish things that are currently impossible with Swift's protocols, and you can unlock new forms of composition that are impossible to see with protocols.
"""#,
        coreLessons: [
          .init(episode: .ep33_protocolWitnesses_pt1),
          .init(episode: .ep34_protocolWitnesses_pt2),
          .init(episode: .ep35_advancedProtocolWitnesses_pt1),
          .init(episode: .ep36_advancedProtocolWitnesses_pt2),
        ],
        related: [
          // TODO
        ],
        title: "Alternatives to Protocols",
        whereToGoFromHere: #"""
Now that we understand the drawbacks of protocols and the alternatives to protocols, its time to apply this knowledge to a real-world use case. We will develop a snapshot testing library from first principles using protocol-oriented programming, and demonstrate the problems it has. Then we will scrap the protocols, use simple concrete data types, and discover a whole new world of composition.
"""#
      ),
      .init(
        blurb: #"""
Protocol-oriented programming was first coined by Apple at the 2012 WWDC, and since then it has become the de facto way create abstractions in Swift. But, as we've seen, they have some gotchas. In this section we will build a library from first principles inspired by protocol-oriented programming, and clearly show the downsides to this approach. Then, we'll scrap the protocols, use simple concrete data types, and discover a whole new world of composition.
"""#,
        coreLessons: [
          .init(episode: .ep37_protocolOrientedLibraryDesign_pt1),
          .init(episode: .ep38_protocolOrientedLibraryDesign_pt2),
          .init(episode: .ep39_witnessOrientedLibraryDesign),
        ],
        related: [
          .init(
            blurb: #"""
After showing how to build a snapshot testing library using the technique of protocol witnesses we open sourced the library! In this episode we take a tour of the library to show how easy it is to add to your project, and how to get broad test coverage very quickly.
"""#,
            content: .episode(.ep41_aTourOfSnapshotTesting)
          ),
          .init(
            blurb: #"""
We used our snapshot testing library, in conjunction with the [composable architecture](/collections/composable-architecture), to get integration test coverage on a SwiftUI application. We are able to play a series of user actions and take a screenshot of the UI after each step.
"""#,
            content: .episode(.ep86_swiftUiSnapshotTesting))
        ],
        title: "Library Design without Protocols",
        whereToGoFromHere: #"""
TODO
"""#
      ),
    ],
    title: "Protocol Witnesses"
  )
}
