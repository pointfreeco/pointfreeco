import Foundation

extension Episode {
  public static let ep238_reliablyTestingAsync = Episode(
    blurb: """
      While Swift provides wonderful tools for writing async code, there are gaps in its tools for \
      testing it. Let's explore the tools it *does* provide to show where they succeed, and where \
      they fall short.
      """,
    codeSampleDirectory: "0238-reliably-testing-async-pt1",
    exercises: _exercises,
    id: 238,
    length: .init(.timestamp(minutes: 47, seconds: 48)),
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-06-19")!,
    references: [
      .reliablyTestingAsync,
      .concurrencyExtras,
      .announcingConcurrencyExtras,
    ],
    sequence: 238,
    subtitle: "The Problem",
    title: "Reliable Async Tests",
    trailerVideo: .init(
      bytesLength: 84_100_000,
      downloadUrls: .s3(
        hd1080: "0238-trailer-1080p-9c4741d2883d44979d7ad81a3cc2ec7e",
        hd720: "0238-trailer-720p-6fe43f05ceca45d1a7fb0d2bb8e42213",
        sd540: "0238-trailer-540p-9d885ef09d494d97a6306987e1576df5"
      ),
      vimeoId: 836_713_177
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
