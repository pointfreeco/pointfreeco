import Foundation

extension Episode {
  static let ep21_playgroundDrivenDevelopment = Episode(
    blurb: """
We use Swift playgrounds on this series as a tool to dive deep into functional programming concepts, but they can be so much more. Today we demonstrate a few tricks to allow you to use playgrounds for everyday development, allowing for a faster iteration cycle.
""",
    codeSampleDirectory: "0021-playground-driven-development",
    id: 21,
    length: 24*60 + 50,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_531_130_223),
    references: [.playgroundDrivenDevelopmentFrenchKit, .playgroundDrivenDevelopmentAtKickstarter],
    sequence: 21,
    title: "Playground Driven Development",
    trailerVideo: .init(
      bytesLength: 35958594,
      vimeoId: 352312195,
      vimeoSecret: "4ced9ce59c453bd07014c93904f334f93637aa84"
    )
  )
}
