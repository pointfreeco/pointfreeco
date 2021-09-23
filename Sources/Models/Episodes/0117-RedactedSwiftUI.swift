import Foundation

extension Episode {
  public static let ep117_redactions_pt3 = Episode(
    alternateSlug: "redacted-swiftui-the-point-part-1",
    blurb: """
Not only can we easily redact the logic from a view using the Composable Architecture, but we can also insert new logic into our views without making any changes to the core logic of the view. To demonstrate this we will build an onboarding flow for a more complex application.
""",
    codeSampleDirectory: "0117-redacted-swiftui-pt3",
    exercises: _exercises,
    id: 117,
    length: 29*60 + 43,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1600059600),
    references: [
      .init(
        author: nil,
        blurb: #"""
          Apple's new API for redacting content in SwiftUI.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)",
        publishedAt: nil,
        title: "redacted(reason:)"
      ),
      .init(
        author: nil,
        blurb: #"""
          "Separation of Concerns" is a design pattern that is expressed often but is a very broad guideline, and not something that can be rigorously applied.
          """#,
        link: "https://en.wikipedia.org/wiki/Separation_of_concerns",
        publishedAt: nil,
        title: "Separation of Concerns"
      ),
    ],
    sequence: 117,
    title: "The Point of Redacted SwiftUI: Part 1",
    trailerVideo: .init(
      bytesLength: 54174532,
      vimeoId: 457561951,
      vimeoSecret: "f9d65d2e64468cef7a1e6da48d8db1f2260d9c0d"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
The `unredacted` helper is super cool, but it might be nicer to define a more general view modifier that can transform the current view in a trailing closure. Define an `applying` helper that would allow us to replace our `unredacted` code above:

```swift
//.unredacted(if: self.onboardingStep == .filters)
.applying {
  if self.onboardingStep == .filters {
    $0.unredacted()
  } else {
    $0
  }
}
```
"""#,
    solution: #"""
```swift
extension View {
  func applying<V: View>(
    @ViewBuilder _ builder: @escaping (Self) -> V
  ) -> some View {
    builder(self)
  }
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Update the onboarding flow to allow for interacting with navigation actions when on the `actions` step.
"""#,
    solution: #"""
Watch next week's episode 😁
"""#
  ),
  Episode.Exercise(
    problem: #"""
Update the onboarding flow to allow for filtering when on the `filters` step.
"""#,
    solution: #"""
Watch next week's episode 😁
"""#
  ),
  Episode.Exercise(
    problem: #"""
Update the onboarding flow to allow for interacting with todos when on the `todos` step. How might you maintain the live behavior where completed todos are sorted to the bottom of the todos list after a second?
"""#,
    solution: #"""
Watch next week's episode 😁
"""#
  ),
]
