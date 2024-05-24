import Foundation

extension Episode {
  public static let ep277_sharedStateInPractice = Episode(
    blurb: """
      In our last series we developed a wonderful way to share state between features in the \
      Composable Architecture, and even persist it, all without sacrificing testability, but we \
      also didn't get to show the (just now released) tools being used in real world applications, \
      so let's do just that, starting with SyncUps.
      """,
    codeSampleDirectory: "0277-shared-state-in-practice-pt1",
    exercises: _exercises,
    id: 277,
    length: 44 * 60 + 47,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-04-29")!,
    references: [
      .scrumdinger,
      .tourOfTCA,
      .syncUpsApp,
    ],
    sequence: 277,
    subtitle: "SyncUps, Part 1",
    title: "Shared State in Practice",
    trailerVideo: .init(
      bytesLength: 86_500_000,
      downloadUrls: .s3(
        hd1080: "0277-trailer-1080p-c0c91f5277034488a1bba199c5711e53",
        hd720: "0277-trailer-720p-465ebe4d6fd54de2b4a76eec729bdd4b",
        sd540: "0277-trailer-540p-b4add6670ae64ee69bbaeb44402a2232"
      ),
      vimeoId: 939_318_885
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
