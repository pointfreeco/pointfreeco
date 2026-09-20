import Foundation

extension Episode {
  public static let ep380_isolationDesign = Episode(
    blurb: """
      It is time to take all that we've learned about isolation and put them into practice in a \
      real world code base. We will be building the reimagined ComposableArchitecture store from \
      scratch and show all the benefits that come out of strictly controlling isolation through \
      every layer of the library.
      """,
    codeSampleDirectory: "0380-isolation-design-pt1",
    exercises: _exercises,
    id: 380,
    length: 25 * 60 + 43,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-21")!,
    references: [
      .functionalCoreImperativeShell,
    ],
    sequence: 380,
    socialImage: nil,
    subtitle: "The Store",
    title: "Designing for Isolation",
    trailerVideo: Video(
      bytesLength: 34_400_000,
      downloadUrls: .s3(
        hd1080: "0380-trailer-1080p-d744c42f16f540ca999c82dbe14e53c3",
        hd720: "0380-trailer-1080p-d744c42f16f540ca999c82dbe14e53c3",
        sd540: "0380-trailer-1080p-d744c42f16f540ca999c82dbe14e53c3"
      ),
      id: "fb15931db4bcbd619f7e2ecbe4fe89b9"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
