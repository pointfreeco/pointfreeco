import Foundation

extension Episode {
  public static let ep219_modernSwiftUI = Episode(
    blurb: """
      Uncontrolled dependencies can wreak havoc on a modern SwiftUI code base. Let's explore why, and how we can begin to control them using a brand new library.
      """,
    codeSampleDirectory: "0219-modern-swiftui-pt6",
    exercises: _exercises,
    id: 219,
    length: 31 * 60 + 47,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_673_244_000),
    references: [
      .scrumdinger,
      .swiftClocks,
      .se_0374_clockSleepFor,
      //      .swiftDependencies,
      .pointfreecoPackageCollection,
    ],
    sequence: 219,
    subtitle: "Dependencies & Testing, Part 1",
    title: "Modern SwiftUI",
    trailerVideo: .init(
      bytesLength: 73_300_000,
      downloadUrls: .s3(
        hd1080: "0219-trailer-1080p-c519748fa0f24bb9bff1bd42bb731c0b",
        hd720: "0219-trailer-720p-536fdc30d6944fdcb50d8ef1de13da7e",
        sd540: "0219-trailer-540p-fa7ea56683c942948f42a798e2082078"
      ),
      vimeoId: 777_191_050
    )
  )
}

private let _exercises: [Episode.Exercise] = []
