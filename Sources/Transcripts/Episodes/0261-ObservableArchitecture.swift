import Foundation

extension Episode {
  public static let ep261_observableArchitecture = Episode(
    blurb: """
      The Composable Architecture can now observe _struct_ state, but it requires a lot of boilerplate. Let's fix this by leveraging the `@Observable` macro from the Swift open source repository. And let's explore what it means to observe _optional_ state and eliminate the library's `IfLetStore` view for a simple `if let` statement.
      """,
    codeSampleDirectory: "0261-observable-architecture-pt3",
    exercises: _exercises,
    id: 261,
    length: 40 * 60 + 37,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-12-11")!,
    references: [
      // TODO
    ],
    sequence: 261,
    subtitle: "Observing Optionals",
    title: "Observable Architecture",
    trailerVideo: .init(
      bytesLength: 59_700_000,
      downloadUrls: .s3(
        hd1080: "0261-trailer-1080p-77a2bfd79cb0404ca1dc87930a774879",
        hd720: "0261-trailer-720p-0165cd0991894c92ad6317972e27daa6",
        sd540: "0261-trailer-540p-35c1263c7c014dc6b1d6fa9a79adc31b"
      ),
      vimeoId: 887_464_843
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
