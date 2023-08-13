import Foundation

extension Episode {
  public static let ep246_tourOfTCA = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0246-tca-tour-pt4",
    exercises: _exercises,
    id: 246,
    length: .init(.timestamp(hours: 1, minutes: 2, seconds: 42)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-08-21")!,
    references: [
      .theComposableArchitecture,
      .scrumdinger,
    ],
    sequence: 246,
    subtitle: "Stacks",
    title: "Tour of the Composable Architecture 1.0",
    trailerVideo: .init(
      bytesLength: 79_500_000,
      downloadUrls: .s3(
        hd1080: "0246-trailer-1080p-2e25ac72bd6b47b99e9199c09ac63c78",
        hd720: "0246-trailer-720p-1b6771a7018b48e2914669af203187c5",
        sd540: "0246-trailer-540p-ca8fe1ac8b514221a2c8864deb2dac3a"
      ),
      vimeoId: 852_441_943
    )
  )
}

private let _exercises: [Episode.Exercise] = []
