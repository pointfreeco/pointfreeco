import Foundation

extension Episode {
  public static let ep263_observableArchitecture = Episode(
    blurb: """
      We can now observe struct, optional, and enum state in the Composable Architecture, but what
      about collections? Let's explore what it takes to get rid of the `ForEachStore` wrapper view
      for a vanilla `ForEach` view instead, while still observing updates to collection state in the
      most minimal way possible.
      """,
    codeSampleDirectory: "0263-observable-architecture-pt5",
    exercises: _exercises,
    id: 263,
    length: 53 * 60 + 28,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-01-08")!,
    references: [
      // TODO
    ],
    sequence: 263,
    subtitle: "Observing Collections",
    title: "Observable Architecture",
    trailerVideo: .init(
      bytesLength: 40_100_000,
      downloadUrls: .s3(
        hd1080: "0263-trailer-1080p-8c6591a295dc430b94524b195eeeed15",
        hd720: "0263-trailer-720p-8ace791f9a2f4173917a1fe033ed3489",
        sd540: "0263-trailer-540p-93215a333881472190f971e937759b3f"
      ),
      vimeoId: 894_284_092
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
