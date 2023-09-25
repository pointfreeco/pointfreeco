import Foundation

extension Episode {
  public static let ep251_macroTesting = Episode(
    blurb: """
      Let's take our MacroTesting library for a spin with some more advanced macros, including those
      that Apple has gathered since the feature's introduction, as well as a well-tested library in
      the community: Ian Keen's MacroKit.
      """,
    codeSampleDirectory: "0251-macro-testing-pt2",
    exercises: _exercises,
    id: 251,
    length: .init(.timestamp(minutes: 43, seconds: 41)),
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-09-25")!,
    references: [
      .macroAdoptionConcerns,
      Episode.Reference(
        author: "Ian Keen",
        blurb: """
          Exploring Swifts new macro system

          > This repo contains some examples of what can be done with Swift macros. I am not an
          > expert on SwiftSyntax so this repo is also for me to learn more and perhaps build out
          > some helper code to make writing macros even easier
          """,
        link: "https://github.com/iankeen/MacroKit",
        publishedAt: yearMonthDayFormatter.date(from: "2023-06-14"),
        title: "MacroKit"
      )
    ],
    sequence: 251,
    subtitle: "Part 2",
    title: "Testing & Debugging Macros",
    trailerVideo: .init(
      bytesLength: 35_600_000,
      downloadUrls: .s3(
        hd1080: "0251-trailer-1080p-13cb6b7c38ec4d34a49ea29b2f3b7c26",
        hd720: "0251-trailer-720p-a3980afab0294fbfae9be918122c5d80",
        sd540: "0251-trailer-540p-06f93dcc449f4623848e9c6ec3f5e312"
      ),
      vimeoId: 861_810_404
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
