import Foundation

extension Episode {
  public static let ep280_sharedStateInPractice = Episode(
    blurb: """
      We conclude the series by stretching our use of the `@Shared` property wrapper in isowords \
      to two more features: saved games and user defaults. In the process we'll eliminate hundreds \
      of lines of boilerplate and some truly gnarly code.
      """,
    codeSampleDirectory: "0280-shared-state-in-practice-pt4",
    exercises: _exercises,
    id: 280,
    length: 33 * 60 + 59,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-05-20")!,
    references: [
      // TODO
    ],
    sequence: 280,
    subtitle: "isowords, Part 2",
    title: "Shared State in Practice",
    trailerVideo: .init(
      bytesLength: 30_000_000,
      downloadUrls: .s3(
        hd1080: "0280-trailer-1080p-be05feda465a443bb2dc55edcd466c7c",
        hd720: "0280-trailer-720p-6dfebeea5b8642aa9533db6e7a3b3915",
        sd540: "0280-trailer-540p-48ea94447b724412b65a8c33cd6835fb"
      ),
      vimeoId: 941_683_819
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
