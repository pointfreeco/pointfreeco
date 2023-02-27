import Foundation

extension Episode {
  public static let ep212_navStacks = Episode(
    blurb: """
      Why did Apple scrap and reinvent SwiftUI’s navigation APIs in iOS 16? Let’s look at some problems the old APIs had, how one of the new APIs solves one of them, and how we can work around a bug in this new API.
      """,
    codeSampleDirectory: "0212-navigation-stacks-pt2",
    exercises: _exercises,
    id: 212,
    length: 57 * 60 + 27,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_668_405_600),
    references: [
      .swiftUINav
    ],
    sequence: 212,
    subtitle: "Decoupling",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 62_800_000,
      downloadUrls: .s3(
        hd1080: "0212-trailer-1080p-4f1136729cc540b591b6a7941dd49c3e",
        hd720: "0212-trailer-720p-603a5327d5d74015a6eefb39c6c1f4c5",
        sd540: "0212-trailer-540p-06cfefe80241466a964cc8092dfd74ad"
      ),
      vimeoId: 768_743_212
    )
  )
}

private let _exercises: [Episode.Exercise] = []
