import Foundation

extension Episode {
  public static let ep208_reducerProtocol = Episode(
    blurb: """
      We celebrate the release of the Composable Architecture's new reducer protocol and dependency management system by showing how they improve the case studies and demos that come with the library, as well as a larger more real-world application.
      """,
    codeSampleDirectory: "0208-reducer-protocol-in-practice",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 412_600_000,
      downloadUrls: .s3(
        hd1080: "0208-1080p-e157f69cd7f245d4b8697c84dc078a00",
        hd720: "0208-720p-94e25b3726c64de882aa183fdf749658",
        sd540: "0208-540p-9d58d1dc750640f9abe130bd4a46a407"
      ),
      id: "5ed29142628d9b03d3361989a916def9"
    ),
    id: 208,
    length: 45 * 60 + 36,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_665_378_000),
    references: [
      // TODO
    ],
    sequence: 208,
    subtitle: nil,
    title: "Reducer Protocol in Practice",
    trailerVideo: .init(
      bytesLength: 33_900_000,
      downloadUrls: .s3(
        hd1080: "0208-trailer-1080p-13239c8a762942d89b91f1e4b1a5c26c",
        hd720: "0208-trailer-720p-52ab05a3ae8a4a21a1b6610d1152a67e",
        sd540: "0208-trailer-540p-ebe9cf504610403eae7e2e6fddc9ab43"
      ),
      id: "e163378f8c461a5f84c72debe846d611"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
