import Foundation

extension Episode {
  public static let ep369_isolation = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0369-beyond-basics-isolation-pt14",
    exercises: _exercises,
    id: 369,
    length: 14 * 60 + 42,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-15")!,
    references: [
      .se0430_sending,
    ],
    sequence: 369,
    socialImage: nil,
    subtitle: "MainActor Default",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 36_500_000,
      downloadUrls: .s3(
        hd1080: "0369-trailer-1080p-cdc7fdbf271042148810fe711fbc2b20",
        hd720: "0369-trailer-1080p-cdc7fdbf271042148810fe711fbc2b20",
        sd540: "0369-trailer-1080p-cdc7fdbf271042148810fe711fbc2b20"
      ),
      id: "29b1d0708ba3acb85866f866d9186ec3"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
