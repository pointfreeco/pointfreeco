import Foundation

extension Episode {
  public static let ep292_crossPlatform = Episode(
    blurb: """
      Let's dial up the complexity of our Wasm application! We'll introduce some async logic in the form of a network request. We'll take steps to not only control this dependency, but we'll do so across both Apple and Wasm platforms, and we'll isolate its interface from its live implementation to speed up our builds and reduce our app's size.
      """,
    codeSampleDirectory: "0292-cross-platform-pt3",
    exercises: _exercises,
    id: 292,
    length: 42 * 60 + 17,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-08-26")!,
    references: [
      .swiftForWebAssembly,
      .batteriesNotIncluded,
      .swiftWebAssemblyGoodNotes,
    ],
    sequence: 292,
    subtitle: "Networking",
    title: "Cross-Platform Swift",
    trailerVideo: .init(
      bytesLength: 35_600_000,
      downloadUrls: .s3(
        hd1080: "0292-trailer-1080p-2d1e9376c23940829117ae390735777f",
        hd720: "0292-trailer-720p-9fe46e53c9a749e5b8483a0fda16dd54",
        sd540: "0292-trailer-540p-030fe12193e748ee88134023ef04c503"
      ),
      vimeoId: 996_439_971
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
