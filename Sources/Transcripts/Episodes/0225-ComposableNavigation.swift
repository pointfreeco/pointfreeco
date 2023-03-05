import Foundation

extension Episode {
  public static let ep225_composableNavigation = Episode(
    blurb: """
      We add superpowers to sheet-powered navigation, including automatically cancelling a child
      feature's effects upon dismissal, and even letting child features dismiss themselves! Plus, we
      look at how "non-exhaustive" testing simplifies navigation-based tests.
      """,
    codeSampleDirectory: "0225-composable-navigation-pt4",
    exercises: _exercises,
    id: 225,
    length: .init(.timestamp(minutes: 52, seconds: 5)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-03-06")!,
    references: [
      .init(
        author: "Krzysztof Zabłocki",
        blurb: """
          The first exploration of "non-exhaustive" testing in the Composable Architecture. This
          work would eventually be included in the library itself.
          """,
        link: "https://www.merowing.info/exhaustive-testing-in-tca/",
        publishedAt: yearMonthDayFormatter.date(from: "2022-03-21"),
        title: "Exhaustive testing in TCA"
      ),
      .init(
        author: "Krzysztof Zabłocki",
        blurb: """
          An NSSpain talk in which Krzysztof covers the topic of scaling an application built in the
          Composable Architecture, including the use of non-exhaustive testing.
          """,
        link: "https://www.merowing.info/composable-architecture-scale/",
        publishedAt: yearMonthDayFormatter.date(from: "2022-09-20"),
        title: "Composable Architecture @ Scale"
      ),
      .composableNavigationBetaDiscussion
    ],
    sequence: 225,
    subtitle: "Behavior",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 60_300_000,
      downloadUrls: .s3(
        hd1080: "0225-trailer-1080p-37d8bf77zbc2fz4821z8492zc434dbe8",
        hd720: "0225-trailer-720p-8d516033z0062z4e54zb945zcb9aa37d",
        sd540: "0225-trailer-540p-986d5843z4110z442dz9cd6z0cec8756"
      ),
      vimeoId: 800_951_081
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
