import Foundation

extension Episode {
  public static let ep109_composableSwiftUIBindings_pt3 = Episode(
    blurb: """
It's time to ask: "what's the point?" If composing bindings is so important, then why didn't Apple give us more tools to do it? To understand this we will explore how Apple handles these kinds of problems in their code samples, and compare it to what we have discovered in previous episodes.
""",
    codeSampleDirectory: "0109-composable-bindings-pt3", // TODO
    exercises: _exercises,
    id: 109,
    length: 39*60 + 33,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1595221200),
    references: [
      Episode.Reference(
        author: "Apple",
        blurb: """
In this episode we recreated a technique that Apple uses in one of their SwiftUI code samples. In the sample Apple creates a UI to handle editing a profile with the ability to either save the changes or discard the changes:

> In the Landmarks app, users can create a profile to express their personality. To give users the ability to change their profile, you’ll add an edit mode and design the preferences screen.
>
> You’ll work with a variety of common user interface controls for data entry, and update the Landmarks model types whenever the user saves their changes.
>
> Follow the steps to build this project, or download the finished project to explore on your own.
""",
        link: "https://developer.apple.com/tutorials/swiftui/working-with-ui-controls",
        publishedAt: nil,
        title: "Working with UI Controls"
      ),
      .swiftCasePaths,
      .init(
        author: "Brandon Williams & Stephen Celis",
        blurb: #"""
Enums are one of Swift's most notable, powerful features, and as Swift developers we love them and are lucky to have them! By contrasting them with their more familiar counterpart, structs, we can learn interesting things about them, unlocking ergonomics and functionality that the Swift language could learn from.
"""#,
        link: "https://www.pointfree.co/collections/enums-and-structs",
        title: "Collection: Enums and Structs"
      )
    ],
    sequence: 109,
    subtitle: "The Point",
    title: "Composable SwiftUI Bindings",
    trailerVideo: .init(
      bytesLength: 45668759,
      downloadUrls: .s3(
        hd1080: "0109-trailer-1080p-3fc4db38369040279f7f43f8792d8bbf",
        hd720: "0109-trailer-720p-ecb31cad0bf145ec971f0ef2b07ecea3",
        sd540: "0109-trailer-540p-ecb92dfd7e334a108554ea7ec80be06b"
      ),
      vimeoId: 438391332
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
