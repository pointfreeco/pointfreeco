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
      downloadUrls: .s3(
        hd1080: "0021-trailer-1080p-13f4d5dea28e48409a8266cdd8ca86fd",
        hd720: "0021-trailer-720p-709f74fe50994a018bde043a97533ede",
        sd540: "0021-trailer-540p-cef8eee882fd45df90590ee76ea0b524"
      ),
      vimeoId: 352312195
    )
  )
}
