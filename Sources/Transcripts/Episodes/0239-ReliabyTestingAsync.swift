import Foundation

extension Episode {
  public static let ep239_reliablyTestingAsync = Episode(
    blurb: """
      We explore a few more advanced scenarios when it comes to async code—including \
      cancellation, async sequences, and clocks—and how difficult they are to test.
      """,
    codeSampleDirectory: "0239-reliably-testing-async-pt2",
    exercises: _exercises,
    id: 239,
    length: .init(.timestamp(minutes: 27, seconds: 34)),
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-06-26")!,
    references: [
      .reliablyTestingAsync,
      .concurrencyExtras,
      .announcingConcurrencyExtras,
    ],
    sequence: 239,
    subtitle: "More Problems",
    title: "Reliable Async Tests",
    trailerVideo: .init(
      bytesLength: 53_300_000,
      downloadUrls: .s3(
        hd1080: "0239-trailer-1080p-31d50628360443b0acebf655088a4a40",
        hd720: "0239-trailer-720p-4ef126876ffd401ebe793ca1621a2576",
        sd540: "0239-trailer-540p-af707aeb5f1a43c9bc9aeae5eb3a8b46"
      ),
      vimeoId: 837_041_068
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
