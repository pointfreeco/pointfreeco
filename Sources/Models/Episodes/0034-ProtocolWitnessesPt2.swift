import Foundation

extension Episode {
  static let ep34_protocolWitnesses_pt2 = Episode(
    blurb: """
Last time we covered some basics with protocols, and demonstrated one of their biggest pitfalls: types can only conform to a protocol a single time. Sometimes it's valid and correct for a type to conform to a protocol in many ways. We show how to remedy this by demonstrating that one can scrap any protocol in favor of a simple datatype, and in doing so opens up a whole world of composability.
""",
    codeSampleDirectory: "0034-protocol-witnesses-pt2",
    exercises: _exercises,
    id: 34,
    image: "https://i.vimeocdn.com/video/802688980.jpg",
    length: 22*60 + 41,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1540187322),
    references: [
      .protocolOrientedProgrammingWwdc,
      .modernSwiftApiDesign,
      .gallagherProtocolsWithAssociatedTypes,
      .protocolOrientedProgrammingIsNotASilverBullet,
      .valueOrientedProgramming,
      .scrapYourTypeClasses,
      .haskellAntipatternExistentialTypeclass,
      .protocolWitnessesAppBuilders2019,
    ],
    sequence: 34,
    title: "Protocol Witnesses: Part 2",
    trailerVideo: .init(
      bytesLength: 49840092,
      downloadUrl: "https://player.vimeo.com/external/351174975.hd.mp4?s=f63c5dd430c15b0ef865ee2cea7627cbe9db778b&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/351174975"
    )
  )
}

private let _exercises: [Episode.Exercise] = [

  .init(problem: """
Translate the `Equatable` protocol into an explicit datatype `struct Equating`.
"""),

  .init(problem: """
Currently in Swift (as of 4.2) there is no way to extend tuples to conform to protocols. Tuples are what is
known as "non-nominal", which means they behave differently from the types that you can define. For example, one
cannot make tuples `Equatable` by implementing `extension (A, B): Equatable where A: Equatable, B: Equatable`.
To get around this Swift implements overloads of `==` for tuples, but they aren't truly equatable, i.e.
you cannot pass a tuple of equatable values to a function wanting an equatable value.

However, protocol witnesses have no such problem! Demonstrate this by implementing the function
`pair: (Combining<A>, Combining<B>) -> Combining<(A, B)>`. This
function allows you to construct a combining witness for a tuple given two combining witnesses for each
component of the tuple.
"""),

  .init(problem: """
Functions in Swift are also "non-nominal" types, which means you cannot extend them to conform to protocols.
However, again, protocol witnesses have no such problem! Demonstrate this by implementing the function
`pointwise: (Combining<B>) -> Combining<(A) -> B>`. This allows you to construct
a combining witness for a function given a combining witnesss for the type you are mapping into. There
is _exactly_ one way to implement this function.
"""),

  .init(problem: """
One of Swift's most requested features was "conditional conformance", which is what allows you to express,
for example, the idea that an array of equatable values should be equatable. In Swift it is written
`extension Array: Equatable where Element: Equatable`. It took Swift nearly 4 years after its launch
to provide this capability!

So, then it may come as a surprise to you to know that "conditional conformance" was supported for
protocol witnesses since the very first day Swift launched! All you need is generics. Demonstrate this by
implementing a function `array: (Combining<A>) -> Combining<[A]>`. This is saying that
conditional conformance in Swift is nothing more than a function between protocol witnesses.
"""),

  .init(problem: """
Currently all of our witness values are just floating around in Swift, which may make some feel
uncomfortable. There's a very easy solution: implement witness values as static computed variables
on the datatype! Try this by moving a few of the witnesses from the episode to be static variables. Also try
moving the `pair`, `pointwise` and `array` functions to be static functions on the `Combining` datatype.
"""),

  .init(problem: """
Protocols in Swift can have "associated types", which are types specified in the body of a protocol but
aren't determined until a type conforms to the protocol. How does this translate to an explicit datatype
to represent the protocol?
"""),

  .init(problem: """
Translate the `RawRepresentable` protocol into an explicit datatype `struct RawRepresenting`. You will
need to use the previous exercise to do this.
"""),

  .init(problem: """
Protocols can inherit from other protocols, for example the `Comparable` protocol inherits from the
`Equatable` protocol. How does this translate to an explicit datatype
to represent the protocol?
"""),

  .init(problem: """
Translate the `Comparable` protocol into an explicit datatype `struct Comparing`. You will need to use the
previous exercise to do this.
"""),

  .init(problem: """
We can combine the best of both worlds by using witnesses and having our default protocol, too. Define a `DefaultDescribable` protocol which provides a static member that returns a default witness of `Describing<Self>`. Using this protocol, define an overload of `print(tag:)` that doesn't require a witness.
""")
]
