import Foundation

extension Episode {
  public static let ep384_isolationDesign = Episode(
    blurb: """
      We conclude our series by showing how we can share isolation _across_ boundaries. We will \
      abstract our nonisolated core with a protocol so that our isolated shells can _scope_ down \
      to subdomains and subfeatures, all while retaining all the benefits of controlled isolation \
      we have explored over the series.
      """,
    codeSampleDirectory: "0384-isolation-design-pt5",
    exercises: _exercises,
    id: 384,
    length: 33 * 60 + 57,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-10-19")!,
    references: [
      .functionalCoreImperativeShell,
      .nonSendableCoreSendableShell,
    ],
    sequence: 384,
    socialImage: nil,
    subtitle: "Shared Isolation",
    title: "Designing for Isolation",
    trailerVideo: Video(
      bytesLength: 34_400_000,
      downloadUrls: .s3(
        hd1080: "0384-trailer-1080p-d32c0cc896564efc842301741129f5dd",
        hd720: "0384-trailer-1080p-d32c0cc896564efc842301741129f5dd",
        sd540: "0384-trailer-1080p-d32c0cc896564efc842301741129f5dd"
      ),
      id: "e4493cebfbf11f2c9d1dee85cd577260"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
