import Foundation

extension Episode {
  static let ep21_playgroundDrivenDevelopment = Episode(
    blurb: """
We use Swift playgrounds on this series as a tool to dive deep into functional programming concepts, but they can be so much more. Today we demonstrate a few tricks to allow you to use playgrounds for everyday development, allowing for a faster iteration cycle.
""",
    codeSampleDirectory: "0021-playground-driven-development",
    id: 21,
    image: "https://i.vimeocdn.com/video/804928551.jpg",
    length: 24*60 + 50,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_531_130_223),
    references: [.playgroundDrivenDevelopmentFrenchKit, .playgroundDrivenDevelopmentAtKickstarter],
    sequence: 21,
    title: "Playground Driven Development",
    trailerVideo: .init(
      bytesLength: 35958594,
      downloadUrl: "https://player.vimeo.com/external/352312195.hd.mp4?s=4ced9ce59c453bd07014c93904f334f93637aa84&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/352312195"
    )
  )
}
