import Foundation

public struct Episode {
  public var blurb: String
  public var id: Int
  public var length: Int
  public var publishedAt: Double
  public var sequence: Int
  public var subscriberOnly: Bool
  public var tags: [Tag]
  public var title: String
  public var transcriptBlocks: [TranscriptBlock]

  public init(blurb: String,
              id: Int,
              length: Int,
              publishedAt: Double,
              sequence: Int,
              subscriberOnly: Bool,
              tags: [Tag],
              title: String,
              transcriptBlocks: [TranscriptBlock]) {

    self.blurb = blurb
    self.id = id
    self.length = length
    self.publishedAt = publishedAt
    self.sequence = sequence
    self.subscriberOnly = subscriberOnly
    self.tags = tags
    self.title = title
    self.transcriptBlocks = transcriptBlocks
  }
}
