import Foundation

extension Episode {
  public static let ep262_observableArchitecture = Episode(
    blurb: """
      We've made structs and optionals observable in the Composable Architecture, eliminating the
      need for `ViewStore`s and `IfLetStore`s, so what about enums? If we can make enums observable,
      we could further eliminate the concept of the `SwitchStore`, greatly improving the ergonomics
      of working with enums in the library.
      """,
    codeSampleDirectory: "0262-observable-architecture-pt4",
    exercises: _exercises,
    id: 262,
    length: 43 * 60 + 57,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-12-18")!,
    references: [
      // TODO
    ],
    sequence: 262,
    subtitle: "Observing Enums",
    title: "Observable Architecture",
    trailerVideo: .init(
      bytesLength: 38_700_000,
      downloadUrls: .s3(
        hd1080: "0262-trailer-1080p-3d779803ea0d48bcaf8f1aa6f603f2a1",
        hd720: "0262-trailer-720p-18e9f50dd20848aba7ccd7b0ac2bdaee",
        sd540: "0262-trailer-540p-84b6c87084d74fc1a719d69505c72ee3"
      ),
      vimeoId: 892357251
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
