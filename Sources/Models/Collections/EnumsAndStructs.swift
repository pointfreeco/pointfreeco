extension Episode.Collection {
  public static let enumsAndStructs = Self(
    blurb: #"""
Enums are one of Swift's most notable, powerful features, and as Swift developers we love them and are lucky to have them! By contrasting them with their more familiar counterpart, structs, we can learn interesting things about them, unlocking ergonomics and functionality that the Swift language could learn from.
"""#,
    sections: [
      .init(
        blurb: #"""
Although structs and enums have first class treatment in Swift and are awesome to use, structs tend to have nicer ergonomics than enums. We will explore what it would look like for enums to get many of the affordances that structs have.
"""#,
        coreLessons: [
          .init(episode: .ep51_structs🤝Enums),
          .init(episode: .ep52_enumProperties),
        ],
        related: [
          .init(
            blurb: #"""
These supplemental episodes use SwiftSyntax to build a code generation tool for enum properties, eliminating the burden of having to hand-roll them.
"""#,
            content: .episodes([
              .ep53_swiftSyntaxEnumProperties,
              .ep54_advancedSwiftSyntaxEnumProperties,
              .ep55_swiftSyntaxCommandLineTool,
            ])
          ),
          .init(
            blurb: #"""
In this episode we compare structs and enums in a more abstract way: using algebra!
"""#,
            content: .episode(.ep4_algebraicDataTypes)
          )
        ],
        title: "Enum Properties",
        whereToGoFromHere: #"""
We've now seen how we can take a feature of structs, properties in particular, explore the equivalent API on enums, and find benefits, like more ergonomic data access. It's time to take things to the next level by taking another, related feature of structs, key paths, and make a case for the enum equivalent.
"""#
      ),
      .init(
        blurb: #"""
Key paths are an incredibly powerful feature of the Swift language: they are compiler-generated bundles of getter-setter pairs and are automatically made available for every struct property. So what happens when we theorize an equivalent feature for every enum case?
"""#,
        coreLessons: [
          .init(episode: .ep87_theCaseForCasePaths_pt1),
          .init(episode: .ep88_theCaseForCasePaths_pt2),
          .init(episode: .ep89_theCaseForCasePaths_pt3),
        ],
        related: [
          .init(
            blurb: #"""
Let's apply case paths to a real-world use case: application architecture! We'll use case paths to refactor one of the most important operations of our [composable architecture](/collections/composable-architecture).
"""#,
            content: .episode(.ep90_composingArchitectureWithCasePaths))
        ],
        title: "Case Paths",
        whereToGoFromHere: nil
      ),
    ],
    title: "Enums and Structs"
  )
}
