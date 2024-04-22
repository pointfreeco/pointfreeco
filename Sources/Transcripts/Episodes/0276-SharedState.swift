import Foundation

extension Episode {
  public static let ep276_sharedState = Episode(
    blurb: """
      It's incredible how easy `@Shared` makes it to persist complex data types to the file \
      system, but currently it completely ruins our ability to test features that use it. Let's \
      fix that, and we will also explore what it means to derive a small piece of shared state \
      from a bigger piece of shared state.
      """,
    codeSampleDirectory: "0276-shared-state-pt9",
    exercises: _exercises,
    id: 276,
    length: 34 * 60 + 59,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-04-22")!,
    references: [
      // TODO
    ],
    sequence: 276,
    subtitle: "File Storage, Part 2",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 35_300_000,
      downloadUrls: .s3(
        hd1080: "0276-trailer-1080p-a1faef477a054a49972de328b59c7e15",
        hd720: "0276-trailer-720p-bf24ecdd9f5f4008b45ad74b4d00051a",
        sd540: "0276-trailer-540p-004936841ec54365a5007d9038253b95"
      ),
      vimeoId: 924_731_622
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
