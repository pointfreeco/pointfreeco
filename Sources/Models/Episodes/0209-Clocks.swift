import Foundation

extension Episode {
  public static let ep209_clocks = Episode(
    blurb: """
      The `Clock` protocol is a brand-new feature of Swift 5.7 for dealing with time-based asynchrony. We will explore its interface, compare it to Combine's `Scheduler` profile, and see what it takes to write and use our own conformances.
      """,
    codeSampleDirectory: "0209-clocks-pt1",
    exercises: _exercises,
    id: 209,
    length: 53 * 60 + 2,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_665_982_800),
    references: [
      .se_0374_clockSleepFor
    ],
    sequence: 209,
    subtitle: "Existential Time",
    title: "Clocks",
    trailerVideo: .init(
      bytesLength: 61_200_000,
      downloadUrls: .s3(
        hd1080: "0209-trailer-1080p-fa69729490864ebc926d92ad4dbfa98b",
        hd720: "0209-trailer-720p-710024ee675643238cc46da960c72159",
        sd540: "0209-trailer-540p-ad8caaa926a64465967bf5713650d493"
      ),
      vimeoId: 756_544_245
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
