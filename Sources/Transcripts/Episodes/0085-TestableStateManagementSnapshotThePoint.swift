import Foundation

extension Episode {
  static let ep85_testableStateManagement_thePoint = Episode(
    blurb: """
      We've made testing in our architecture a joy! We can test deep aspects of our application with minimal ceremony, but it took us a whole 18 episodes to get here! So this week we ask: what's the point!? Can we write these kinds of tests in vanilla SwiftUI?
      """,
    codeSampleDirectory: "0085-testable-state-management-the-point",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 325_896_989,
      downloadUrls: .s3(
        hd1080: "0085-1080p-2e529b95f0d24b86a29b334b1c767cd9",
        hd720: "0085-720p-c5239c62083b4cdfbdaac1120606fb35",
        sd540: "0085-540p-0b752e9715c6440199b1e2b416583d28"
      ),
      vimeoId: 378_096_729
    ),
    id: 85,
    length: 33 * 60 + 35,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_576_476_000),
    references: [
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 85,
    subtitle: "The Point",
    title: "Testable State Management",
    trailerVideo: .init(
      bytesLength: 34_340_125,
      downloadUrls: .s3(
        hd1080: "0085-trailer-1080p-43d74bcc79ec48ad8b05ecbe64dc46ff",
        hd720: "0085-trailer-720p-245dc5a63de341dd8f1d3ea4f49b394c",
        sd540: "0085-trailer-540p-325ff8e207ff411ea1709b152d401f92"
      ),
      vimeoId: 378_096_707
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 85)
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      Add tests for VanillaPrimeTime's `FavoritePrimesView`, starting with the logic around deleting favorite primes.
      """#,
    solution: #"""
      First, in `FavoritePrimesView`, extract the list's `onDelete` logic into a method.

      ```swift
      func deleteFavoritePrimes(_ indexSet: IndexSet) {
        for index in indexSet {
          let prime = self.favoritePrimes[index]
          self.favoritePrimes.remove(at: index)
          self.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
      }
      ```

      Next, pass this method to `onDelete`.

      ```swift
      .onDelete(perform: self.deleteFavoritePrimes)
      ```

      Finally, write a test exercising this logic!

      ```swift
      func testFavoritePrimesView_deleteFavoritePrimes() {
        let view = FavoritePrimesView(
          favoritePrimes: Binding(initialValue: [2, 3, 5]),
          activityFeed: Binding(initialValue: [])
        )

        view.deleteFavoritePrimes([1])

        XCTAssertEqual(view.favoritePrimes, [2, 5])
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      While `saveFavoritePrimes` and `loadFavoritePrimes` have been extracted to methods, what makes them difficult to test? What could be introduced to aid in testing? Consider the work done in our episode, [Testable State Management: Effects](https://www.pointfree.co/episodes/ep83-testable-state-management-effects).
      """#,
    solution: nil
  ),
]
