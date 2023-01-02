import Foundation

extension Episode {
  public static let ep218_modernSwiftUI = Episode(
    blurb: """
      We wrap up the "record meeting" screen by implementing two more side effects: speech recognition, and persistence. We'll experience the pitfalls of interacting directly with these dependencies, and why we should care about controlling them.
      """,
    codeSampleDirectory: "0218-modern-swiftui-pt5",
    exercises: _exercises,
    id: 218,
    length: 25 * 60 + 2,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_672_639_200),
    references: [
      .scrumdinger
    ],
    sequence: 218,
    subtitle: "Effects, Part 2",
    title: "Modern SwiftUI",
    trailerVideo: .init(
      bytesLength: 22_100_000,
      downloadUrls: .s3(
        hd1080: "0218-trailer-1080p-6d70460f48ce42f18cf623646193ef7b",
        hd720: "0218-trailer-720p-95033474e78b4765aa0bd15bd2891b3d",
        sd540: "0218-trailer-540p-a388458694cb4b0e9f0817edd815e88c"
      ),
      vimeoId: 776_647_385
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Display an alert if the speech recognizer throws an error.
      """#
  ),
  .init(
    problem: #"""
      Display an alert before starting a meeting if they have previously denied speech authorization. Ask if they would like to proceed, or if they'd like to go to Settings to authorize.
      """#
  ),
  .init(
    problem: #"""
      Update the previous logic so that the alert is only displayed the first time, or add a button that says "Stop reminding me".
      """#
  ),
  .init(
    problem: #"""
      Display an alert if JSON decoding fails when the model is initialized.
      """#
  ),
  .init(
    problem: #"""
      Use a dedicated queue to load and persist standup data.
      """#
  ),
]
