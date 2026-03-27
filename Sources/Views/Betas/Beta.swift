public struct Beta {
  public let title: String
  public let blurb: String
  public let imageSrc: String
  public let repo: String

  public var repoURL: String {
    "https://github.com/pointfreeco/\(repo)"
  }

  public static let all: [Beta] = [
    Beta(
      title: "ComposableArchitecture 2.0",
      blurb: """
        A ground-up reimagining of the ComposableArchitecture. Simpler, faster, \
        and more flexible, while keeping the same principles of testability and \
        composability that make the ComposableArchitecture great.
        """,
      imageSrc:
        "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/cf5ce39b-dba6-42ad-e63b-8b43a838d800/public",
      repo: "TCA26"
    ),
    Beta(
      title: "DebugSnapshots",
      blurb: """
        A tool for making it possible to test non-equatable types and reference types. \
        Capture and compare snapshots of your app's state in a human-readable format, \
        making it easy to catch unexpected changes.
        """,
      imageSrc:
        "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/2b4c6522-30c7-4036-f9ed-c938f3935200/public",
      repo: "swift-debug-snapshots"
    ),
  ]
}
