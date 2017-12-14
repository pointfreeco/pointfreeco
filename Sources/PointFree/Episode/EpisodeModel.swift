public struct Episode {
  var blurb: String
  var codeSampleDirectory: String
  var id: Int
  var length: Int
  var publishedAt: Double
  var sequence: Int
  var subscriberOnly: Bool
  var tags: [Tag]
  var title: String
  var transcriptBlocks: [TranscriptBlock]

  var slug: String {
    return "ep\(self.sequence)-\(PointFree.slug(for: self.title))"
  }

  public struct TranscriptBlock {
    var content: String
    var timestamp: Int?
    var type: BlockType

    public enum BlockType: Equatable {
      case code(lang: CodeLang)
      case paragraph
      case title

      public enum CodeLang: Equatable {
        case html
        case other(String)
        case swift

        var identifier: String {
          switch self {
          case .html:             return "html"
          case let .other(other): return other
          case .swift:            return "swift"
          }
        }

        public static func ==(lhs: CodeLang, rhs: CodeLang) -> Bool {
          switch (lhs, rhs) {
          case (.html, .html), (.swift, .swift):
            return true
          case let (.other(lhs), .other(rhs)):
            return lhs == rhs
          case (.html, _), (.other, _), (.swift, _):
            return false
          }
        }
      }

      public static func ==(lhs: Episode.TranscriptBlock.BlockType, rhs: Episode.TranscriptBlock.BlockType) -> Bool {
        switch (lhs, rhs) {
        case let (.code(lhs), .code(rhs)):
          return lhs == rhs
        case (.paragraph, .paragraph), (.title, .title):
          return true
        case (.code, _), (.paragraph, _), (.title, _):
          return false
        }
      }
    }
  }
}

let episodes: [Episode] = []// = [proofInFunctions, algebraOfPredicates, algebraicStructure, typeSafeHtml]

private let proofInFunctions = Episode(
  blurb:
  """
Swift’s generic functions allow us to explore a beautiful idea that straddles the line between mathematics \
and computer science
""",
  codeSampleDirectory: "ep1-proof-in-functions",
  id: 1,
  length: 1080,
  publishedAt: 1_482_192_000,
  sequence: 1,
  subscriberOnly: true,
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
      type: .code(lang: .swift)
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
      type: .code(lang: .swift)
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
)

private let algebraOfPredicates = Episode(
  blurb: """
           We formulate predicates and sorting functions in terms of monoids \
           and show how they can lead to very composable constructions.
           """,
  codeSampleDirectory: "ep2-sorting-functions",
  id: 3,
  length: 1380 ,
  publishedAt: 1_497_960_000,
  sequence: 3,
  subscriberOnly: false,
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
      type: .code(lang: .swift)
    ),
    ]
)

private let algebraicStructure = Episode(
  blurb:
  """
Protocols in Swift allow us to abstractly work with types that we know very little about. We distill the \
smallest piece of an interface that we want a type to conform to, and then we can write functions that are \
highly reusable. Mathematicians do something very similar to study objects abstractly, and it forms the \
field known as algebra. In this article we will link these two worlds together, and show that there is a \
fundamental piece missing when we only look at the protocol level.
""",
  codeSampleDirectory: "ep3-algebra",
  id: 2,
  length: 1380 ,
  publishedAt: 1_497_960_000,
  sequence: 2,
  subscriberOnly: true,
  tags: [Tag.all.math, Tag.all.algebra],
  title: "Algebraic Structure and Protocols",
  transcriptBlocks: [
    Episode.TranscriptBlock(
      content: """
Protocols in Swift allow us to abstractly work with types that we know very little about. We distill the smallest piece of an interface that we want a type to conform to, and then we can write functions that are highly reusable. Apple provides a nice description in their “The Swift Programming Language” book:
""",
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
“A protocol defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol doesn’t actually provide an implementation for any of these requirements—it only describes what an implementation will look like.”
""",
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
Mathematicians do something very similar to study objects abstractly, and it forms the field known as algebra. In this article we will link these two worlds together, and show that there is a fundamental piece missing when we only look at the protocol level.

""",
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "How mathematicians think about structure",
      timestamp: 30,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
In every day work, a mathematician will often have a set of elements that is equipped with some operation(s) and want to study the properties of that object. Perhaps she is studying the set of solutions to some equation, and it turns out that she has discovered a binary operation, denoted by •, that takes two solutions a, b and produces a third solution a • b. There is now algebraic structure on something that was previously a naked set of elements.
""",
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
Through much arduous work she then discovers that this operation satisfies some nice properties. For example, it’s associative so that when performing the operation on three elements it doesn’t matter the manner in which they are paranthesized: a • (b • c) = (a • b) • c. Then she realizes that there’s an element e in this set such that whenever it’s combined with any other element it leaves that element unchanged: e • a = a • e = a for every element a.
""",
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
What this mathematician has discovered is that her set and operation form what is known in algebra as a monoid. Other mathematicians studied monoids abstractly and found many nice properties and proved many nice theorems, and now that entire body of knowledge is available to her. For example, through a process known as the Grothendieck group construction she can enhance this simple algebraic structure into something stronger known as an abelian group.
""",
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
The process of studying algebraic structures abstractly and then specializing them to real world cases is relatively recent. A class of structures known as permutation groups had been studied in various guises throughout the 18th and 19th centuries, but it wasn’t until the late 1800’s that it was finally realized that all of that was just a special case of something far more general called a group. With that discovery came a major change in how mathematics was done. It became preferable to build a general theory around abstract objects and axiomatic systems and then apply them to concrete problems.
""",
      timestamp: 0,
      type: .paragraph
    ),
    ]
)

private let typeSafeHtml = Episode(
  blurb:
  """
As server-side Swift becomes more popular and widely adopted, it will be important to re-examine some of the past “best-practices” of web frameworks to see how Swift’s type system can improve upon them.
""",
  codeSampleDirectory: "ep4-type-safe-html",
  id: 4,
  length: 1380,
  publishedAt: 1_497_960_000,
  sequence: 4,
  subscriberOnly: false,
  tags: [Tag.all.html, Tag.all.dsl, Tag.all.serverSideSwift],
  title: "Type-Safe HTML in Swift",
  transcriptBlocks: [
    Episode.TranscriptBlock(
      content: """
As server-side Swift becomes more popular and widely adopted, it will be important to re-examine some of the past “best-practices” of web frameworks to see how Swift’s type system can improve upon them. One important job of a web server is to produce the HTML that will be served up to the browser. We claim that by using types and pure functions, we can enhance this part of the web request lifecycle.
""",
      timestamp: 1,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Template Languages",
      timestamp: 0,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
A popular method for generating HTML is using so-called “templating languages”, for example Mustache and Handlebars. There is even one written in Swift for use with the Vapor web framework called Leaf. These libraries ingest plain text that you provide and interpolate values into it using tokens. For example, here is a Mustache (and Handlebar) template:
""",
      timestamp: 2,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "<h1>{{title}}</h1>",
      timestamp: 3,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: "and here is a Leaf template:",
      timestamp: 4,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "<h1>#(title)</h1>",
      timestamp: 5,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: """
You can then render these templates by providing a dictionary of key/value pairs to interpolate, e.g. ["title": "Hello World!"], and then it will generate HTML that can be sent to the browser:
""",
      timestamp: 6,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "<h1>Hello World!</h1>",
      timestamp: 7,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: """
Templating languages will also provide simple constructs for injecting small amounts of logic into the templates. For example, an if statement can be used to conditionally show some elements:
""",
      timestamp: 8,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content:
      """
{{#if show}}
  <span>I’m here!</span>
{{/if}}
""",
      timestamp: 9,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content:
      """
#if(show) {
  <span>I’m here!</span>
}
""",
      timestamp: 10,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: """
The advantages of approaching views like this is that you get support for all that HTML has to offer out of the gate, and focus on building a small language for interpolating values into the templates. Some claim also that these templates lead to “logic-less” views, though confusingly they all support plenty of constructs for logic such as “if” statements and loops. A more accurate description might be “less logic” views since you are necessarily constricted by what logic you can use by the language.
""",
      timestamp: 11,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
The downsides, however, far outweigh the ups. Most errors in templating languages appear at runtime since they are usually not compiled. One can adopt a linting tool to find some (but not all) errors, but that is also an extra dependency that you need to manage. Some templating languages are compiled (like HAML), but even then the tooling is basic and can return confusing error messages. In general, it is on you to make these languages safe for you to deploy with confidence.
""",
      timestamp: 12,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
Furthermore, a templating language is just that: a language! It needs to be robust enough to handle what most users what to do with a language. That means it should support expressions, logical flow, loops, IDE autocomplete, IDE syntax highlighting, and more. It also needs to solve all of the new problems that appear, like escaping characters that are ambiguous with respect to HTML and the template language.
""",
      timestamp: 13,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
We claim that rather than embracing “logic-less” templates, and instead embracing pure functions and types, we will get a far more expressive, safer and composable view layer that can be compiled directly in Swift with no extra tooling or dependencies.
""",
      timestamp: 14,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Embedded Domain Specific Language",
      timestamp: 3,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
An alternative approach to views is using “embedded domain specific languages” (EDSLs). In this approach we use an existing programming language (e.g. Swift), to build a system of types and functions that models the structure of the domain we are modeling (e.g. HTML). Let’s take a fragment of HTML that we will use as inspiration to build in an EDSL:
""",
      timestamp: 15,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content:
      """
<header>
  <h1 id="welcome">Welcome!</h1>
  <p>
    Welcome to you, who has come here. See <a href="/more">more</a>.
  </p>
</header>
""",
      timestamp: 2,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: "Making the EDSL easier to use",
      timestamp: 7,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
Currently our EDSL is not super friendly to work with. It’s a bit more verbose than the plain HTML, and it’s hard to see the underlying HTML from looking at the code. Fortunately, these problems are fixed with a couple of helper functions and some nice features of Swift!
""",
      timestamp: 3,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Safer Attributes",
      timestamp: 9,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
Right now our Attribute type is just a pair of strings representing the key and value. This allows for non-sensical pairs, such as width="foo". We can encode the fact that attributes require specific types of values into the type system, and get additional safety on this aspect.
""",
      timestamp: 4,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
We start by creating a type specifically to model keys that can be used in attributes. This type has two parts: the name of the key as a string (e.g. "id", "href", etc…), and the type of value this key is allowed to hold. There is a wonderful way to encode this latter requirement into the type system: you make the key’s type a generic parameter, but you don’t actually use it! Such a type is called a phantom type. We define our type as such:
""",
      timestamp: 6,
      type: .paragraph
    ),


    ]
)

func slug(for string: String) -> String {
  return string.lowercased().replacingOccurrences(of: " ", with: "-")
}
