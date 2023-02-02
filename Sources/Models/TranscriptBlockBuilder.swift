import Foundation

extension Array where Element == Episode.TranscriptBlock {
  public static func transcript(
    @TranscriptBlockBuilder _ build: () -> Self
  ) -> Self {
    build()
  }

  public static func paragraphs(
    _ input: String
  ) -> Self {
    try! Models.paragraphs.parse(input)
  }
}

@resultBuilder
public enum TranscriptBlockBuilder {
  public static func buildExpression(
    _ expression: Episode.TranscriptBlock
  ) -> [Episode.TranscriptBlock] {
    [expression]
  }

  public static func buildExpression(
    _ expression: [Episode.TranscriptBlock]
  ) -> [Episode.TranscriptBlock] {
    expression
  }

  public static func buildBlock(
    _ components: [Episode.TranscriptBlock]...
  ) -> [Episode.TranscriptBlock] {
    components.flatMap { $0 }
  }

  public static func buildArray(
    _ components: [[Episode.TranscriptBlock]]
  ) -> [Episode.TranscriptBlock] {
    components.flatMap { $0 }
  }
}
