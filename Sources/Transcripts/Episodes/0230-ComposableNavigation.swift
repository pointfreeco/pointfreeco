import Foundation

extension Episode {
  public static let ep230_composableNavigation = Episode(
    blurb: """
      We take a detour to learn about the stack, the heap, copy-on-write, and how we can use this knowledge to further improve our navigation tools by introducing of a property wrapper.
      """,
    codeSampleDirectory: "0230-composable-navigation-pt8",
    exercises: _exercises,
    id: 230,
    length: .init(.timestamp(minutes: 50, seconds: 29)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-04-10")!,
    references: [
      .init(
        author: "Johannes Weiss",
        blurb: """
          For more information on copy-on-write, be sure to check out this detailed video from
          [Johannes Weiss](https://jweiss.io):

          > Languages that have a rather low barrier to entry often struggle when it comes to performance because too much is abstracted from the programmer to make things simple. Therefore in those languages, the key to unlock performance is often to write some of the code in C, collaterally abandoning the safety of the higher-level language.
          >
          > Swift on the other hand lets you unlock best of both worlds: performance and safety. Naturally not all Swift code is magically fast and just like everything else in programming performance requires constant learning.
          >
          > Johannes discusses one aspect of what was learned during SwiftNIO development. He debunks one particular performance-related myth that has been in the Swift community ever since, namely that classes are faster to pass to functions than structs.
          """,
        link: "https://www.youtube.com/watch?v=iLDldae64xE",
        publishedAt: yearMonthDayFormatter.date(from: "2019-02-22")!,
        title: "High-performance systems in Swift"
      ),
      .composableNavigationBetaDiscussion,
    ],
    sequence: 230,
    subtitle: "Stack vs Heap",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 110_400_000,
      downloadUrls: .s3(
        hd1080: "0230-trailer-1080p-0aa5aab9f58742dc8a45fbb2239284d2",
        hd720: "0230-trailer-720p-049101547e7f467ca4aa2460ecf7be06",
        sd540: "0230-trailer-540p-90853cc9f99c40eeafcaf6d559621623"
      ),
      vimeoId: 815_032_602
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
