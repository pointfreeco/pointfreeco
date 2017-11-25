public struct Episode {
  var blurb: String
  var id: Int
  var length: Int
  var publishedAt: Double
  var sequence: Int
  var slug: String
  var tags: [Tag]
  var title: String
  var transcriptBlocks: [TranscriptBlock]

  public struct TranscriptBlock {
    var content: String
    var timestamp: Double?
    var type: BlockType

    public enum BlockType {
      case code
      case paragraph
      case title
    }
  }
}

public struct Tag: Equatable {
  var name: String

  var slug: String {
    return PointFree.slug(for: name)
  }

  public static let all = (
    algebra: Tag(name: "Algebra"),
    generics: Tag(name: "Generics"),
    math: Tag(name: "Math"),
    polymorphism: Tag(name: "Polymorphism"),
    programming: Tag(name: "Programming"),
    swift: Tag(name: "Swift")
  )

  public static func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.name == rhs.name
  }
}

extension Tag {
  public init?(slug: String) {
    guard let tag = array(Tag.all).first(where: { PointFree.slug(for: slug) == $0.slug })
      else { return nil }
    self = tag
  }
}

let episodes = [
  Episode(
    blurb:
"""
Swift’s generic functions allow us to explore a beautiful idea that straddles the line between mathematics \
and computer science
""",
    id: 1,
    length: 1080,
    publishedAt: 1_482_192_000,
    sequence: 1,
    slug: "ep1-proof-in-functions",
    tags: [Tag.all.algebra, Tag.all.generics, Tag.all.polymorphism, Tag.all.swift, Tag.all.programming],
    title: "Proof in Functions",
    transcriptBlocks: [
      Episode.TranscriptBlock(
        content: """
Swift’s generic functions allow us to explore a beautiful idea that straddles the line between mathematics and computer science. If you write down and implement a function using only generic data types, there is a corresponding mathematical theorem that you have proven true. There are a lot of pieces to that statement, but by the end of this short article you will understand what that means, and we will have constructed a computer proof of De Morgan’s law.
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
Let’s start with some exercises to prepare our brains for this kind of thinking. If someone handed you the \
following function declaration, which doesn’t currently compile, and asked you to fill it out so that it \
compiles, could you?
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
        type: .code
      ),
      Episode.TranscriptBlock(
        content: """
It’s a function that takes an x in some type A (can be any type) and needs to return something in A. We have \
absolutely no knowledge of A. No way of constructing a value in that type. For example, we can’t even do \
something like A() to construct a value, for we have no way of knowing if A has an initializer of that form. \
Even worse, there’s a chance that A cannot be instantiated, i.e. A has no values! For example, an enum with \
no cases cannot be instantiated:
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
        type: .code
      ),
      Episode.TranscriptBlock(
        content: """
This type is valid and compiles just fine, but no instance of it can ever be created. Kind of bizarre, but \
it will be useful later. Some languages call this type Bottom (⊥).
""",
        timestamp: 30,
        type: .paragraph
      ),
      Episode.TranscriptBlock(
        content: """
So, back to that function f. How can we implement it so that the compiler says everything is A-Ok? Well, we \
really have no choice but to just return x, i.e. it’s the identity function:
""",
        timestamp: 30,
        type: .paragraph
      ),
      ]
  ),

  Episode(
    blurb: """
           We formulate predicates and sorting functions in terms of monoids \
           and show how they can lead to very composable constructions.
           """,
    id: 42,
    length: 1380 ,
    publishedAt: 1_497_960_000,
    sequence: 2,
    slug: "ep6-the-algebra-of-predicates-and-sorting-functions",
    tags: [Tag.all.math, Tag.all.algebra],
    title: "The Algebra of Predicates and Sorting Functions",
    transcriptBlocks: [
      Episode.TranscriptBlock(
        content: """
In the article “Algebraic Structure and Protocols” we described how to use Swift protocols to describe some basic algebraic structures, such as semigroups and monoids, provided some simple examples, and then provided constructions to build new instances from existing. Here we apply those ideas to the concrete ideas of predicates and sorting functions, and show how they build a wonderful little algebra that is quite expressive.
""",
        timestamp: 0,
        type: .paragraph
      ),
      Episode.TranscriptBlock(
        content: "Recall from last time...",
        timestamp: 30,
        type: .title
      ),
      Episode.TranscriptBlock(
        content:
"""
infix operator <>: AdditionPrecedence

protocol Semigroup {
  // **AXIOM** Associativity
  // For all a, b, c in Self:
  //    a <> (b <> c) == (a <> b) <> c
  static func <> (lhs: Self, rhs: Self) -> Self
}

protocol Monoid: Semigroup {
  // **AXIOM** Identity
  // For all a in Self:
  //    a <> e == e <> a == a
  static var e: Self { get }
}
""",
        timestamp: 60,
        type: .code
      ),
      ]
  )
]

func slug(for string: String) -> String {
  return string.lowercased().replacingOccurrences(of: " ", with: "-")
}
