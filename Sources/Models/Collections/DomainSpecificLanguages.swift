extension Episode.Collection {
  public static let domainSpecificLanguages = Self(
    section: .init(
      blurb: #"""
"Domain-specific languages" allow us to capture more domain-specific problems using the features of another language, like Swift. We'll explore just what that means, starting with a toy example to pave the way for building more real-world examples.
"""#,
      coreLessons: [
        .init(episode: .ep26_domainSpecificLanguages_pt1),
        .init(episode: .ep27_domainSpecificLanguages_pt2),
      ],
      related: [
        .init(
          blurb: #"""
We explore a real-world application of domain-specific languages: HTML. We will see that HTML can be modeled in Swift using types and functions and we can leverage the entire language to improve the safety and ergonomics of writing plain ole HTML.
"""#,
          content: .episode(.ep28_anHtmlDsl)
        ),
        .init(
          blurb: #"""
We compare domain-specific languages to a popular alternative: templating languages.
"""#,
          content: .episode(.ep29_dslsVsTemplatingLanguages)
        )
      ],
      title: "Domain‑Specific Languages",
      whereToGoFromHere: nil
    )
  )
}
