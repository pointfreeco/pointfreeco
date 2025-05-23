import Foundation

extension Episode {
  public static let ep283_modernUIKit = Episode(
    blurb: """
      It's time to build modern tools for UIKit from scratch, heavily inspired by SwiftUI and using
      the Observation framework. Surprisingly, Swift 5.9's observation tools _can_ be used in UIKit,
      and in fact they work _great_, despite being specifically tuned for SwiftUI.
      """,
    codeSampleDirectory: "0283-modern-uikit-pt3",
    exercises: _exercises,
    id: 283,
    length: 41 * 60 + 13,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-06-17")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 283,
    subtitle: "Observation",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 72_200_000,
      downloadUrls: .s3(
        hd1080: "0283-trailer-1080p-4052b6e1ca2e430f98dd42c5b1216a65",
        hd720: "0283-trailer-720p-ad8d257ccd424cb58ee2abec6458adba",
        sd540: "0283-trailer-540p-421dae9650e2467bafc25421f669deab"
      ),
      id: "ba7de5dc8c52420dd445c64eff2a3e5f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
