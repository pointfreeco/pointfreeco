import Foundation

extension Episode {
  public static let ep222_composableNavigation = Episode(
    blurb: """
      It's finally time to tackle navigation in the Composable Architecture. We'll port the
      Inventory app we first built to understand SwiftUI navigation, which will push us to
      understand what makes the architecture "composable," how it facilitates communication between
      features, and testing.
      """,
    codeSampleDirectory: "0222-composable-navigation-pt1",
    exercises: _exercises,
    id: 222,
    length: .init(.timestamp(hours: 1, minutes: 3, seconds: 59)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-02-13")!,
    references: [
      reference(
        forEpisode: .ep216_modernSwiftUI,
        additionalBlurb: #"""
          Our favorite way of managing parent-child communication in "modern" SwiftUI.
          """#,
        episodeUrl:
          "https://www.pointfree.co/collections/swiftui/modern-swiftui/ep216-modern-swiftui-navigation-part-2#t1471"
      ),
      .init(
        author: "Krzysztof Zabłocki",
        blurb: """
          Krzysztof shows off a few patterns in the Composable Architecture, including "delegate"
          actions:

          > To maintain our codebases for years, we must create boundaries across modules. Here's
          > my approach to doing that with The Composable Architecture.
          """,
        link: "https://www.merowing.info/boundries-in-tca/",
        publishedAt: yearMonthDayFormatter.date(from: "2022-08-15"),
        title: "TCA Action Boundaries"
      ),
      .init(
        author: "Brandon Williams & Stephen Celis",
        blurb: #"""
          GitHub search results for `DelegateAction` in isowords, demonstrating the pattern of child-to-parent communication, where the child domain carves out a bit of its domain that makes it clear to the parent which actions are important to listen for.
          """#,
        link: "https://github.com/search?q=repo%3Apointfreeco%2Fisowords+DelegateAction&type=code",
        title: #"The "delegate" pattern in isowords"#
      ),
      .init(
        author: "Brandon Williams & Stephen Celis",
        blurb: #"""
          > There is a common pattern of using actions to share logic across multiple parts of a reducer. This is an inefficient way to share logic. Sending actions is not as lightweight of an operation as, say, calling a method on a class. Actions travel through multiple layers of an application, and at each layer a reducer can intercept and reinterpret the action.
          """#,
        link:
          "https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/performance/#Sharing-logic-with-actions",
        title: "Sharing logic with actions"
      ),
      .composableNavigationBetaDiscussion,
    ],
    sequence: 222,
    subtitle: "Tabs",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 110_200_000,
      downloadUrls: .s3(
        hd1080: "0222-trailer-1080p-b60209b0147b47b8bb476a0e001c21c1",
        hd720: "0222-trailer-720p-87e636d7dd7d4e588560bb25923adc14",
        sd540: "0222-trailer-540p-081a50b9d27f487595c103a42cf12cc5"
      ),
      vimeoId: 797_785_232
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
