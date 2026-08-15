import Foundation

extension Episode {
  public static let ep377_wwdc26 = Episode(
    blurb: """
      This year SwiftData introduced `ResultsObserver`, a brand new way to observe changes outside \
      of the view, where `@Query` for example cannot be used. What's SQLiteData have to say about \
      that? To explore, we'll build a moderately complex geofence map editor _and_ get full test \
      coverage of the feature.
      """,
    codeSampleDirectory: "0377-wwdc26-pt8",
    exercises: _exercises,
    id: 377,
    length: 56 * 60 + 45,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-17")!,
    references: [
      .sqliteData,
      .debugSnapshots,
      Episode.Reference(
        blurb: """
          > In mathematics, the winding number or winding index of a closed curve in the plane around a given point is an integer representing the total number of times that the curve travels counterclockwise around the point, i.e., the curve's number of turns.
          
          We use this in the episode to determine if a location's coordinate is inside its geofence.
          """,
        link: "https://en.wikipedia.org/wiki/Winding_number",
        title: "Winding number"
      )
    ],
    sequence: 377,
    socialImage: nil,
    subtitle: "SQLiteData Observation",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 55_800_000,
      downloadUrls: .s3(
        hd1080: "0377-trailer-1080p-9487f35c961d45fc9f473e2d3d06d265",
        hd720: "0377-trailer-1080p-9487f35c961d45fc9f473e2d3d06d265",
        sd540: "0377-trailer-1080p-9487f35c961d45fc9f473e2d3d06d265"
      ),
      id: "6f1e032226a60f7831dc997050eadd1e"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
