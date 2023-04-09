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
      .composableNavigationBetaDiscussion
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
      vimeoId: 815032602
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
