import Foundation

extension Episode {
  public static let ep248_tourOfTCA = Episode(
    blurb: """
      We introduce a complex dependency to the record meeting screen: speech recognition. We will begin to integrate this dependency into our app's logic, and show how to control it for Xcode previews and tests
      """,
    codeSampleDirectory: "0248-tca-tour-pt6",
    exercises: _exercises,
    id: 248,
    length: .init(.timestamp(minutes: 51, seconds: 28)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-09-04")!,
    references: [
      .theComposableArchitecture,
      .scrumdinger,
      // TODO: More dependencies references?
    ],
    sequence: 248,
    subtitle: "Dependencies",
    title: "Tour of the Composable Architecture 1.0",
    trailerVideo: .init(
      bytesLength: 53_600_000,
      downloadUrls: .s3(
        hd1080: "0248-trailer-1080p-6bf03173894b4337afee3ec71a623f2a",
        hd720: "0248-trailer-720p-78a44c9a9f884b098ac9ab676e1f920e",
        sd540: "0248-trailer-540p-35e0ea3f355b46389f4cabb017665b83"
      ),
      vimeoId: 859_105_323
    )
  )
}

private let _exercises: [Episode.Exercise] = []
