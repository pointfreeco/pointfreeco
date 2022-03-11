import Foundation

extension Episode {
  static let ep26_domainSpecificLanguages_pt1 = Episode(
    blurb: """
We interact with domain-specific languages on a daily basis, but what does it take to build your own? After introducing the topic, we will begin building a toy example directly in Swift, which will set the foundation for a future DSL with far-reaching applications.
""",
    codeSampleDirectory: "0026-edsls-pt1",
    exercises: _exercises,
    id: 26,
    length: 24*60 + 19,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1534744623),
    sequence: 26,
    title: "Domain‑Specific Languages: Part 1",
    trailerVideo: .init(
      bytesLength: 27200230,
      downloadUrls: .s3(
        hd1080: "0026-trailer-1080p-07e2786d64c948e5ab70ee073f774cc6",
        hd720: "0026-trailer-720p-dde5c33a1d3f42aeb59146cb1ce53ec1",
        sd540: "0026-trailer-540p-18eb242ab03b4148a40e9fe99d10259c"
      ),
      vimeoId: 348628453
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Improve the `simplify` function to also recognize the following patterns:
* Factorize the `c` out of this expression: `a * c + b * c`.
* Reduce `1 * a` and `a * 1` to just `a`.
* Reduce `0 * a` and `a * 0` to just `0`.
* Reduce `0 + a` and `a + 0` to just `a`.
* Are there any other simplification patterns you know of that you could implement?
"""),

  .init(problem: """
Enhance `Expr` to allow for any number of variables. The `eval` implementation will need to change to
allow passing values in for all of the variables introduced.
"""),

  .init(problem: """
Implement infix operators `*` and `+` to work on `Expr` to get rid of the `.add` and `.mul` annotations.
"""),

  .init(problem: """
Implement a function `varCount: (Expr) -> Int` that counts the number of `.var`'s used in an expression.
"""),

  .init(problem: """
Write a pretty printer for `Expr` that adds a new line and indentation when printing the sub-expressions
inside `.add` and `.mul`.
""")
]
