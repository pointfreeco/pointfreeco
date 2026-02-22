import Foundation

extension Episode {
  public static let ep355_isolation = Episode(
    blurb: """
      It's time to go beyond the basics with a deep exploration of isolation, noncopyable, and \
      nonescapable types. But before we get into all the nitty gritty details we will demonstrate \
      why understanding these topics matters, starting with a preview of isolation in Composable \
      Architecture 2.0.
      """,
    codeSampleDirectory: "0355-beyond-basics-isolation-pt1",
    exercises: _exercises,
    id: 355,
    length: 31 * 60 + 33,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-02-23")!,
    references: [
      // TODO
    ],
    sequence: 355,
    subtitle: "Isolation, ~Copyable, ~Escapable",
    title: "Beyond Basics",
    trailerVideo: Video(
      bytesLength: 100_200_000,
      downloadUrls: .s3(
        hd1080: "0355-trailer-1080p-d2bec8cd45b34679ba887413811cb5ca",
        hd720: "0355-trailer-1080p-d2bec8cd45b34679ba887413811cb5ca",
        sd540: "0355-trailer-1080p-d2bec8cd45b34679ba887413811cb5ca"
      ),
      id: "76db8d31f8735d7eecc87333179a065f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
