import Foundation

extension Episode {
  public static let ep243_tourOfTCA = Episode(
    blurb: """
      The Composable Architecture has reached a major milestone: version 1.0. To celebrate this release we are doing a fresh tour of the library so that folks can become comfortable building applications with it in its most modern form. We will start with a simple, but substantial application that shows off the basics, before we recreate Apple's most complex sample project.
      """,
    codeSampleDirectory: "0243-tour-of-tca",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 545_900_000,
      downloadUrls: .s3(
        hd1080: "0243-1080p-3b3cd6595793418b98f6a69093c66cb2",
        hd720: "0243-720p-e49ed573eadd451fa6aab24b0d1c6c4f",
        sd540: "0243-540p-0ad1b0dcd6824dd5ba5e87491021f389"
      ),
      vimeoId: 848_855_056
    ),
    id: 243,
    length: .init(.timestamp(minutes: 57, seconds: 10)),
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-07-31")!,
    references: [
      .theComposableArchitecture,
      .scrumdinger,
    ],
    sequence: 243,
    subtitle: "The Point",
    title: "Tour of the Composable Architecture 1.0",
    trailerVideo: .init(
      bytesLength: 145_800_000,
      downloadUrls: .s3(
        hd1080: "0243-trailer-1080p-ee8aadee70ad4f63b81d4d389cc40b1a",
        hd720: "0243-trailer-720p-87638ff78f0048beae52359ff3fe0e81",
        sd540: "0243-trailer-540p-396cdbff506a4aa6bd032b91fc93f3e4"
      ),
      vimeoId: 848_841_923
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 243)
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Implement error handling for the number fact request, so that if it fails, the loading indicator disappears and the user is notified that the request failed.
      """#
  )
]
