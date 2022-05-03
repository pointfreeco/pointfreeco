import Foundation

extension Episode {
  public static let ep113_designingDependencies_pt4 = Episode(
    blurb: """
      Now that we've tackled two dependencies of varying complexity we are ready to handle our most complicated dependency yet: Core Location. We will see what it means to control a dependency that communicates with a delegate and captures a complex state machine with many potential flows.
      """,
    codeSampleDirectory: "0113-designing-dependencies-pt4",
    exercises: _exercises,
    id: 113,
    length: 50 * 60 + 58,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_597_640_400),
    references: [
      .init(
        author: nil,
        blurb: #"""
          A design pattern of object-oriented programming that flips the more traditional dependency pattern so that the implementation depends on the interface. We accomplish this by having our live dependencies depend on struct interfaces.
          """#,
        link: "https://en.wikipedia.org/wiki/Dependency_inversion_principle",
        publishedAt: nil,
        title: "Dependency Inversion Principle"
      )
    ],
    sequence: 113,
    subtitle: "Core Location",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 39_905_374,
      downloadUrls: .s3(
        hd1080: "0113-trailer-1080p-d10087a55bad4aea882ea81a6afa2bc0",
        hd720: "0113-trailer-720p-9d0cf52baca74e52bf74e655838383e4",
        sd540: "0113-trailer-540p-ad9b49fe7cd74b5bb89dc534a97cce9b"
      ),
      vimeoId: 448_362_098
    )
  )
}

private let _exercises: [Episode.Exercise] = []
