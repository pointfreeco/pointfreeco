import Foundation

extension Episode {
  public static let ep301_sqlite = Episode(
    blurb: """
      SQLite is one of the most well-crafted, battle-tested, widely-deployed pieces of software in history, and it's a great fit for apps with more complex persistence needs than user defaults or a JSON file. Let's get familiar with the library, starting with a crash course in interacting with C code from Swift.
      """,
    codeSampleDirectory: "0301-sqlite-pt1",
    exercises: _exercises,
    id: 301,
    length: 36 * 60 + 13,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-11-04")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      ),
      .init(
        blurb: """
          > SQLite is likely used more than all other database engines combined. Billions and billions of copies of SQLite exist in the wild.
          """,
        link: "https://www.sqlite.org/mostdeployed.html",
        title: "Most Widely Deployed and Used Database Engine"
      ),
      .init(
        blurb: """
          > As of version 3.42.0 (2023-05-16), the SQLite library consists of approximately 155.8 KSLOC of C code. (KSLOC means thousands of "Source Lines Of Code" or, in other words, lines of code excluding blank lines and comments.) By comparison, the project has 590 times as much test code and test scripts - 92053.1 KSLOC.
          """,
        link: "https://www.sqlite.org/testing.html",
        title: "How SQLite Is Tested"
      ),
    ],
    sequence: 301,
    subtitle: "The C Library",
    title: "SQLite",
    trailerVideo: .init(
      bytesLength: 85_800_000,
      downloadUrls: .s3(
        hd1080: "0301-trailer-1080p-16804d48775d459abcf31d9f833031ee",
        hd720: "0301-trailer-720p-9ae8035b78264fcba0ed2c76e8a3614a",
        sd540: "0301-trailer-540p-dcd31e5dbd6d4d1b9b2c7bf9c85d1131"
      ),
      id: "a24cb145b58b89a0c5fc3c1b62568ee7"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
