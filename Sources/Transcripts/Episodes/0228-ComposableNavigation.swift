import Foundation

extension Episode {
  public static let ep228_composableNavigation = Episode(
    blurb: """
      While we just tackled drill-down navigation, sadly the API we used was deprecated in iOS 16. Let's get things working with the new `navigationDestination` view modifier, and see what testing in the Composable Architecture has to say about navigation.
      """,
    codeSampleDirectory: "0228-composable-navigation-pt7",
    exercises: _exercises,
    id: 228,
    length: .init(.timestamp(minutes: 31, seconds: 51)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-03-27")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 228,
    subtitle: "Destinations",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 53_400_000,
      downloadUrls: .s3(
        hd1080: "0228-trailer-1080p-5b80b4933a1e4cfb97dc1b05cdc030fb",
        hd720: "0228-trailer-720p-6ac46f9f0b2248048cfb9df86b345992",
        sd540: "0228-trailer-540p-475853b28ad4434a9efa3d793ab9924a"
      ),
      vimeoId: 806930259
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
