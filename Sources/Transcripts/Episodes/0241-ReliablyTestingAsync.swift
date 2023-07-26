import Foundation

extension Episode {
  public static let ep241_reliablyTestingAsync = Episode(
    blurb: """
      We continue our deep dive into advanced Swift concurrency by exploring the concept of "executors" to better understand its global enqueue hook. We will then put this hook to work and finally have reliable, 100% deterministic async tests.
      """,
    codeSampleDirectory: "0241-reliably-testing-async-pt4",
    exercises: _exercises,
    id: 241,
    length: .init(.timestamp(minutes: 37, seconds: 54)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-07-10")!,
    references: [
      .reliablyTestingAsync,
      .concurrencyExtras,
      .announcingConcurrencyExtras,
    ],
    sequence: 241,
    subtitle: "🥹",
    title: "Reliable Async Tests",
    trailerVideo: .init(
      bytesLength: 31_400_000,
      downloadUrls: .s3(
        hd1080: "0241-trailer-1080p-35045ea30ba04909a5ecea029867bec3",
        hd720: "0241-trailer-720p-440e59b969384e3e91bc7ca4ef5eb1ce",
        sd540: "0241-trailer-540p-52afe7f8302e461fa4997609ba8e7487"
      ),
      vimeoId: 840_143_509
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
