import Foundation

extension Episode {
  public static let ep155_focusState = Episode(
    blurb: """
      Let's explore another API just announced at WWDC: `@FocusState`. We'll take a simple example and layer on some complexity, including side effects and testability, and we'll see that the solution we land on works just as well in the Composable Architecture!
      """,
    codeSampleDirectory: "0155-focus-state",
    exercises: _exercises,
    id: 155,
    length: 39 * 60 + 36,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_627_880_400),
    references: [
      Episode.Reference(
        author: "Matt Ricketson and Taylor Kelly",
        blurb: #"""
          A WWDC session covering what's new in SwiftUI this year, including the `@FocusState` property wrapper.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10018/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-06-08"),
        title: "What's new in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
          Documentation for the `@FocusState` property wrapper.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/focusstate/",
        publishedAt: nil,
        title: "`FocusState`"
      ),
    ],
    sequence: 155,
    subtitle: nil,
    title: "SwiftUI Focus State",
    trailerVideo: .init(
      bytesLength: 28_971_455,
      downloadUrls: .s3(
        hd1080: "0155-trailer-1080p-5d5bef777f2b4e48a51d6fab283e3133",
        hd720: "0155-trailer-720p-b384bd7c06b848a49016c39374f9f74c",
        sd540: "0155-trailer-540p-72e1a13833fd4cf79f25ef7fbff52375"
      ),
      vimeoId: 577_546_109
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 155)
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      While it is not yet possible to abstract over a property wrapper in Swift, it _is_ possible to abstract over getting and setting a value in the form of key paths! Write a version of `synchronize` that works with writable key paths instead of bindings. What does the signature look like and what are some of the caveats?
      """#,
    solution: #"""
      This implementation is maybe not as straightforward as the ones that use bindings. This is because bindings are already bound to a specific instance of mutable state, but key paths are not. Because of this, we must reference this mutable state in addition to they key paths.

      Maybe we would pass a `Root` along:

      ```swift
      extension View {
        func synchronize<Root, Value>(
          _ root: Root,
          _ first: ReferenceWritableKeyPath<Root, Value>,
          _ second: ReferenceWritableKeyPath<Root, Value>
        ) -> some View
        where Value: Equatable {
          self
            .onChange(of: root[keyPath: first]) { root[keyPath: second] = newValue }
            .onChange(of: root[keyPath: second]) { root[keyPath: first] = newValue }
        }
      }
      ```

      This would work for a view with an `@ObservedObject` view model (or view store) and `@FocusState`, but would unfortunately not work for a `WithViewStore` helper. To support synchronizing state among two completely separate entities, we'd need to pass both values along:

      ```swift
      extension View {
        func synchronize<Root, Value>(
          _ first: Root,
          _ firstKeyPath: ReferenceWritableKeyPath<Root, Value>,
          _ second: Root,
          _ secondKeyPath: ReferenceWritableKeyPath<Root, Value>
        ) -> some View
        where Value: Equatable { … }
      ```

      But now this is looking quite verbose, and perhaps it isn't pulling its weight.
      """#
  )
]

extension Episode.Video {
  public static let ep155_focusState = Self(
    bytesLength: 374_673_376,
    downloadUrls: .s3(
      hd1080: "0155-1080p-f59aa7a0f057408f9c8e6e48c53b47cf",
      hd720: "0155-720p-e6c96b1b54c34c5ab01ff81373f0ac11",
      sd540: "0155-540p-da0ac6e419354837b907b1c5af4b4456"
    ),
    vimeoId: 577_546_117
  )
}
