import Foundation

extension Episode {
  public static let ep286_modernUIKit = Episode(
    blurb: """
      While SwiftUI bindings were almost the perfect tool for UIKit navigation, they unfortunately \
      hide some crucial information that we need to build out our tools. But never fear, we can \
      rebuild them from scratch! Let's build `@Binding` and `@Bindable` from scratch to see how \
      they work, and we will use them to drive concise, tree-based navigation using enums.
      """,
    codeSampleDirectory: "0286-modern-uikit-pt6",
    exercises: _exercises,
    id: 286,
    length: 31 * 60 + 23,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-07-08")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 286,
    subtitle: "Tree-based Navigation",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 22_400_000,
      downloadUrls: .s3(
        hd1080: "0286-trailer-1080p-9dfbe70ce5cc4274883123a545df9562",
        hd720: "0286-trailer-720p-642fef48764a476ba850a78604f8e546",
        sd540: "0286-trailer-540p-794a46960cec42e191a54d3fdd3a8e1a"
      ),
      id: "e6b32e4b116c610017f6d332f7b7cce4"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
