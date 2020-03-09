extension Episode.Collection {
  public static let protocolWitnesses = Self(
    blurb: #"""
Protocols are great! We love them, you probably love them, and Apple certainly loves them! However, they aren't without their drawbacks. There are many times that using protocols can become cumbersome, such as when using associated types, and there are some things that are just impossible to do using protocols. We will explore some alternatives to protocols that open up whole new worlds of composability that were previously impossible to see.
"""#,
    sections: [
      .init(
        blurb: #"""
TODO
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
TODO
"""#
      ),
      .init(
        blurb: #"""
TODO
"""#,
        coreLessons: [
          .init(episode: .ep37_protocolOrientedLibraryDesign_pt1),
          .init(episode: .ep38_protocolOrientedLibraryDesign_pt2),
          .init(episode: .ep39_witnessOrientedLibraryDesign),
        ],
        related: [
          // TODO
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
