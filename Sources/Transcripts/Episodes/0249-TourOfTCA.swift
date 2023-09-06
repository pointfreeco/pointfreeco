import Foundation

extension Episode {
  public static let ep249_tourOfTCA = Episode(
    blurb: """
      We conclude the series by adding the final bit of functionality to our application: persistence. We'll see how adding a dependency on persistence can wreak havoc on previews and tests, and all the benefits of controlling it.
      """,
    codeSampleDirectory: "0249-tca-tour-pt7",
    exercises: _exercises,
    id: 249,
    length: .init(.timestamp(minutes: 51, seconds: 28)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-09-11")!,
    references: [
      .theComposableArchitecture,
      .scrumdinger,
    ],
    sequence: 249,
    subtitle: "Persistence",
    title: "Tour of the Composable Architecture 1.0",
    trailerVideo: .init(
      bytesLength: 18_400_000,
      downloadUrls: .s3(
        hd1080: "0249-trailer-1080p-97665625dfa6426294185335ddeb7296",
        hd720: "0249-trailer-720p-06092d21e5364b388ce09ee2e6d6bfcd",
        sd540: "0249-trailer-540p-b6f463916c0b4308be516f7a11a821fb"
      ),
      vimeoId: 859_106_477
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      Add error handling for the speech recognition task. If the task fails, show the user an error with options to abandon the meeting, resume the meeting without transcription, or to retry speech transcription.

      Write tests against the failure and each resolution.

      Enhance the logic of the feature so that if they retry speech transcription, it is appended to the transcript from the task that failed rather than written over.
      """
  ),
  Episode.Exercise(
    problem: """
      Add error handling for when persisted data fails to load.
      """
  ),
  Episode.Exercise(
    problem: """
      Add error handling for when persisted data fails to save.
      """
  ),
  Episode.Exercise(
    problem: """
      Beef up the `DataManager.mock`. It is currently limited to saving and loading a single value with no regard to the URL passed in. Instead, have it hold onto a dictionary mapping URL to value so that it can emulate an entire file system.
      """
  ),
]
