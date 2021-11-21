import Foundation

extension Episode {
  public static let ep167_navigationLinks = Episode(
    blurb: """
Over the past weeks we have come up with some seriously powerful tools for SwiftUI navigation that have allowed us to more precisely and correctly model our app's domain, so let's exercise them a bit more by adding more behavior and deeper navigation to our application.
""",
    codeSampleDirectory: "0167-navigation-pt8",
    exercises: _exercises,
    id: 167,
    length: 40*60 + 29,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1636351200),
    references: [
      .swiftUINav,
      .demystifyingSwiftUI,
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 167,
    subtitle: "Links, Part 3",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 256138756,
      vimeoId: 642998519,
      vimeoSecret: "acdd7f87def882f67ba8c9bab92bb8a7461253c0"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
In this episode we were able to swap out our custom `sheet(unwrap:)` and `popover(unwrap:)` helpers for the simpler `sheet(item:)` and `popover(item:)` modifiers that come with SwiftUI when moving from a binding to an observed object.

However, we were unable to swap out our custom `NavigationLink.init(unwrap:)` helper, because no such equivalent API exists in vanilla SwiftUI. Why is that, and can you define a `NavigationLink.init(item:)` helper that does just that?
"""#,
    solution: #"""
It is possible, and we can even leverage our helper to define it simply:

```swift
extension NavigationLink {
  init<Value, WrappedDestination>(
    item optionalValue: Binding<Value?>,
    onNavigate: @escaping (Bool) -> Void,
    @ViewBuilder destination: @escaping (Value) -> WrappedDestination,
    @ViewBuilder label: @escaping () -> Label
  )
  where Destination == WrappedDestination?
  {
    self.init(
      unwrap: option,
      onNavigate: onNavigate,
      destination: { binding in destination(binding.wrappedValue) },
      label: label
    )
  }
}
```
"""#)
]
