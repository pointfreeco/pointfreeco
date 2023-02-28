import Foundation

extension Episode {
  public static let ep134_conciseForms = Episode(
    blurb: """
      We've shown how to dramatically streamline forms in the Composable Architecture, but it's time to ask "what's the point?" We apply the concepts previously developed to a real world application: [isowords](https://www.isowords.xyz). It's a word game built in the Composable Architecture, launching soon.
      """,
    codeSampleDirectory: "0134-concise-forms-pt4",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 373_699_419,
      downloadUrls: .s3(
        hd1080: "0134-1080p-0166386c8bcd47a1bfe5624a4f28ab96",
        hd720: "0134-720p-9f5f9c354f0f40d9b82f4ef28f16ffd4",
        sd540: "0134-540p-dbcb2476a0af492ea46305204d3fe8d1"
      ),
      vimeoId: 508_418_783
    ),
    id: 134,
    length: 28 * 60 + 14,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_612_764_000),
    references: [
      .isowords
    ],
    sequence: 134,
    subtitle: "The Point",
    title: "Concise Forms",
    trailerVideo: .init(
      bytesLength: 59_604_438,
      downloadUrls: .s3(
        hd1080: "0134-trailer-1080p-2e57ba5fa7e84426a6ecd48b38f8c695",
        hd720: "0134-trailer-720p-2e48d4e086624af7b455aafbb8940912",
        sd540: "0134-trailer-540p-7538814ba1e74b0c8d88bbf957f8fd85"
      ),
      vimeoId: 508_418_621
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 134)
  )
}

private let _exercises: [Episode.Exercise] = []
