import Foundation

extension Bundle {
  public static let transcripts = Bundle.module
}

func loadTranscriptBlocks(forSequence sequence: Int) -> [Episode.TranscriptBlock] {
  try! .paragraphs(
    String(
      decoding: Data(
        contentsOf: Bundle.module.url(
          forResource: String(format: "%04d", sequence),
          withExtension: "md"
        )!,
        options: []
      ),
      as: UTF8.self
    )
  )
}

func loadBlogTranscriptBlocks(forSequence sequence: Int) -> [Episode.TranscriptBlock] {
  try! .paragraphs(
    String(
      decoding: Data(
        contentsOf: Bundle.module.url(
          forResource: String(format: "BlogPost%04d", sequence),
          withExtension: "md"
        )!,
        options: []
      ),
      as: UTF8.self
    )
  )
}
