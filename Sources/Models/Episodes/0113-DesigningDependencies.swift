import Foundation

extension Episode {
  public static let ep113_designingDependencies_pt4 = Episode(
    blurb: """
Now that we've tackled two dependencies of varying complexity we are ready to handle our most complicated dependency yet: Core Location. We will see what it means to control a dependency that communicates with a delegate and captures a complex state machine with many potential flows.
""",
    codeSampleDirectory: "0113-designing-dependencies-pt4",
    exercises: _exercises,
    id: 113,
    image: "https://i.vimeocdn.com/video/941523768.jpg",
    length: 50*60 + 58,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1597640400),
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
      bytesLength: 39905374,
      vimeoId: 448362098,
      vimeoSecret: "ebb9a3b273bfa765b58bda750d84b479fdc7a90c"
    )
    //https://player.vimeo.com/external/448362098.hd.mp4?s=ebb9a3b273bfa765b58bda750d84b479fdc7a90c&profile_id=175&download=1
  )
}

private let _exercises: [Episode.Exercise] = [
]
