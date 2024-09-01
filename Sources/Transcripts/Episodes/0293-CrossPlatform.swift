import Foundation

extension Episode {
  public static let ep293_crossPlatform = Episode(
    blurb: """
      We will introduce navigation APIs to our Wasm application, starting simply with an alert before ramping things up with a `dialog` tag that can be fully configurable from a value type that represents its state and actions.
      """,
    codeSampleDirectory: "0293-cross-platform-pt4",
    exercises: _exercises,
    id: 293,
    length: 40 * 60 + 36,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-09-02")!,
    references: [
      // TODO
    ],
    sequence: 293,
    subtitle: "Navigation",
    title: "Cross-Platform Swift",
    trailerVideo: .init(
      bytesLength: 38_800_000,
      downloadUrls: .s3(
        hd1080: "0293-trailer-1080p-0dabb2d53ffe431784ba6446a051b90a",
        hd720: "0293-trailer-720p-c009682c458f4ba1a2ba6e66b347a219",
        sd540: "0293-trailer-540p-f76aab33775a47f5aa9d5d20c445d80f"
      ),
      vimeoId: 1002494611
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
