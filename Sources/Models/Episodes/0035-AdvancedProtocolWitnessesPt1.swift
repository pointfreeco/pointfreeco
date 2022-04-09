import Foundation

extension Episode {
  static let ep35_advancedProtocolWitnesses_pt1 = Episode(
    blurb: """
Now that we know it's possible to replace protocols with concrete datatypes, and now that we've seen how that opens up new ways to compose things that were previously hidden from us, let's go a little deeper. We will show how to improve the ergonomics of writing Swift in this way, and show what Swift's powerful conditional conformance feature is represented by just plain functions.
""",
    codeSampleDirectory: "0035-advanced-protocol-witnesses-pt1",
    exercises: _exercises,
    id: 35,
    length: 35*60 + 18,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_540_803_600),
    references: [
      .protocolOrientedProgrammingWwdc,
      .modernSwiftApiDesign,
      .pullbackWikipedia,
      .gallagherProtocolsWithAssociatedTypes,
      .protocolOrientedProgrammingIsNotASilverBullet,
      .valueOrientedProgramming,
      .scrapYourTypeClasses,
      .haskellAntipatternExistentialTypeclass,
      .someNewsAboutContramap,
      .contravariance,
      .protocolWitnessesAppBuilders2019,
    ],
    sequence: 35,
    title: "Advanced Protocol Witnesses: Part 1",
    trailerVideo: .init(
      bytesLength: 52259096,
      downloadUrls: .s3(
        hd1080: "0035-trailer-1080p-529a75c2032748068f4f1e945bdda3ba",
        hd720: "0035-trailer-720p-1b1e3ad8e85148d9981a381a19083855",
        sd540: "0035-trailer-540p-4d47287c1c774f34accde954c0c09ae4"
      ),
      vimeoId: 349952464
    )
  )
}

private let _exercises: [Episode.Exercise] = [

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
a combining witness for a function given a combining witness for the type you are mapping into.
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

]
