import Foundation

extension Episode {
  public static let ep290_crossPlatform = Episode(
    blurb: """
      It's time to go cross-platform! We will take a feature written in Swift and use it in vastly different situations, including not only SwiftUI and UIKit, but beyond Apple's frameworks and ecosystems. We will start with a baby step and introduce our feature to a third party view paradigm, Airbnb's Epoxy.
      """,
    codeSampleDirectory: "0290-cross-platform-pt1",
    exercises: _exercises,
    id: 290,
    length: 33 * 60 + 48,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-08-12")!,
    references: [
      Reference(
        author: "Airbnb Engineering",
        blurb: """
          A suite of declarative UI APIs for building UIKit applications in Swift.
          """,
        link: "https://github.com/airbnb/epoxy-ios",
        publishedAt: yearMonthDayFormatter.date(from: "2021-03-16"),
        title: "Epoxy"
      )
    ],
    sequence: 290,
    subtitle: "View Paradigms",
    title: "Cross-Platform Swift",
    trailerVideo: .init(
      bytesLength: 211_200_000,
      downloadUrls: .s3(
        hd1080: "0290-trailer-1080p-55d6568695334e7eb6d6c1c0fb3e9af8",
        hd720: "0290-trailer-720p-4e925fcaa61e461196212ea703b0eddd",
        sd540: "0290-trailer-540p-a234f8af6b0745118997e2a46f4c44c7"
      ),
      vimeoId: 996253829
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
