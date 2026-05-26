public struct Beta {
  public var title: String
  public var blurb: String
  public var imageURL: String
  public var publicURL: String?
  public var repo: String
  public var skillName: String

  public var repoURL: String {
    "https://github.com/pointfreeco/\(repo)"
  }

  public static var allSkillNames: Set<String> {
    Set(all.map(\.skillName))
  }

  public static let all: [Beta] = [
    Beta(
      title: "ComposableArchitecture 2.0",
      blurb: """
        A ground-up reimagining of the ComposableArchitecture. Simpler, faster, \
        and more flexible, while keeping the same principles of testability and \
        composability that make the ComposableArchitecture great. \
        [Read more →](/blog/posts/206-beta-preview-composablearchitecture-2-0)
        """,
      imageURL:
        "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/cf5ce39b-dba6-42ad-e63b-8b43a838d800/public",
      repo: "TCA26",
      skillName: "composable-architecture-2"
    ),
  ]

  public static let graduated: [Beta] = [
    Beta(
      title: "DebugSnapshots",
      blurb: """
        A tool for exhaustively testing non-equatable types and reference types. Capture and \
        compare snapshots of your app's state in a human-readable format, making it easy to catch \
        unexpected changes.
        """,
      imageURL:
        "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/2b4c6522-30c7-4036-f9ed-c938f3935200/public",
      publicURL: "https://github.com/pointfreeco/swift-debug-snapshots",
      repo: "swift-debug-snapshots",
      skillName: "debug-snapshots"
    ),
  ]
}
