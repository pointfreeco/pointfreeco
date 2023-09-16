import Foundation

public let post0113_InlineSnapshotTesting = BlogPost(
  author: .pointfree,
  blurb: """
    We are releasing a major update to our popular SnapshotTesting library: inline snapshot testing!
    This allows your text-based snapshots to live right in the test source code, rather than in an
    external file. 
    """,
  contentBlocks: loadBlogTranscriptBlocks(forSequence: 113),
  coverImage:
    "https://pointfreeco-blog.s3.amazonaws.com/posts/0113-inline-snapshot-testing/inline-snapshot.gif",
  id: 113,
  publishedAt: yearMonthDayFormatter.date(from: "2023-09-13")!,
  title: "Inline Snapshot Testing"
)
