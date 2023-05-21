import Foundation

extension Episode {
  public static let ep236_composableStacks = Episode(
    blurb: """
      We round out the functionality of the Composable Architecture's stack navigation tools. This includes automatic cancellation of a child feature's effects when it's popped off the stack, and the ability for a child feature to pop itself. Along the way we will clean up the domain modeling and user experience of working with these tools.
      """,
    codeSampleDirectory: "0236-composable-navigation-pt15",
    exercises: _exercises,
    id: 236,
    length: .init(.timestamp(minutes: 37, seconds: 55)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-05-22")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 236,
    subtitle: "Effect Cancellation",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 69_000_000,
      downloadUrls: .s3(
        hd1080: "0236-trailer-1080p-b014a5cbf9d34a058c9e6fa37c70333e",
        hd720: "0236-trailer-720p-9d60c193977a49d6b373562ef4eabf44",
        sd540: "0236-trailer-540p-c11ae9ee676c4080b62037dd4479af3d"
      ),
      vimeoId: 823_410_266
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
