@testable import EpisodeTranscripts

extension Episode {
  public static let mock = proofInFunctions
}

private let proofInFunctions = Episode(
  blurb: """
  Swift’s generic functions allow us to explore a beautiful idea that straddles the line between mathematics \
  and computer science. In this episode we explore how we can use Swift’s type system to prove mathematical \
  theorems, and show how this opens the doors to having the compiler verify properties of your program.
  """,
  codeSampleDirectory: "ep1-proof-in-functions",
  id: .init(unwrap: 1),
  length: 1080,
  publishedAt: 1_482_192_000,
  sequence: 1,
  subscriberOnly: true,
  title: "Proof in Functions",
  transcriptBlocks: [
    Episode.TranscriptBlock(
      content: """
      Swift’s generic `functions` allow us to **explore** a beautiful idea that straddles the line between \
      __mathematics__ and computer science. If you write down and implement a function using only generic data \
      types, there is a corresponding [mathematical](https://www.github.com) theorem that you have proven true. There are a lot of \
      pieces to that statement, but by the end of this short article you will understand what that means, \
      and we will have constructed a computer proof of De Morgan’s law.
      """,
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
      All of the code samples in this article are contained in a Swift playground available for download here.
      """,
      timestamp: 30,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Generic Functions",
      timestamp: 60,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
      Let’s start with some exercises to prepare our brains for this kind of thinking. If someone handed you \
      the following function declaration, which doesn’t currently compile, and asked you to fill it out so \
      that it compiles, could you?
      """,
      timestamp: 30,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
      func f <A> (x: A) -> A {
        ???
      }
      """,
      timestamp: 30,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: """
      It’s a function that takes an x in some type `A` (can be any type) and needs to return something in A. \
      We have absolutely no knowledge of A. No way of constructing a value in that type. For example, we \
      can’t even do something like A() to construct a value, for we have no way of knowing if A has an \
      initializer of that form. Even worse, there’s a chance that A cannot be instantiated, i.e. A has no \
      values! For example, an enum with no cases cannot be instantiated:
      """,
      timestamp: 30,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
      enum Empty {
        // no cases!
      }
      """,
      timestamp: 30,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: """
      This type is valid and compiles just fine, but no instance of it can ever be created. Kind of bizarre, \
      but it will be useful later. Some languages call this type Bottom (⊥).
      """,
      timestamp: 30,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
      So, back to that function f. How can we implement it so that the compiler says everything is A-Ok? \
      Well, we really have no choice but to just return x, i.e. it’s the identity function:
      """,
      timestamp: 30,
      type: .paragraph
    ),
    ]
)
