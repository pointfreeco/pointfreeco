import Foundation

extension Episode {
  public static let ep187_tourOfParserPrinters = Episode(
    blurb: """
URL routing is a large problem that has been solved in various ways over the years...but what does that have to do with swift-parsing!? A lot! swift-parsing comes with a URL routing library built on top of parser-printers, and it solves a lot of problems that still exist in today's most popular web frameworks.
""",
    codeSampleDirectory: "0187-parser-printers-tour-pt3",
    exercises: _exercises,
    id: 187,
    length: 48*60 + 42,
    permission: .free,
    publishedAt:  Date(timeIntervalSince1970: 1650862800),
    references: [
      .swiftParsing,
      .invertibleSyntaxDescriptions,
      .init(
        blurb: #"""
A popular Ruby web framework that includes a URL router that is not only used to dispatch incoming requests to particular application logic, but it can also be used to generate URLs that link to other parts of the site.
"""#,
        link: "https://rubyonrails.org",
        title: "Ruby On Rails"
      ),
      .init(
        blurb: #"""
A popular Node.js web framework that comes with a minimalist routing library.
"""#,
        link: "https://expressjs.com",
        title: "Express"
      ),
      .init(
        blurb: #"""
A popular Swift web framework. It comes with a router that is clearly inspired by frameworks like Express, but as a result is less type safe than it could be.
"""#,
        link: "https://vapor.codes",
        title: "Vapor"
      ),
    ],
    sequence: 187,
    subtitle: "URL Routing",
    title: "Tour of Parser-Printers",
    trailerVideo: .init(
      bytesLength: 108_100_000,
      downloadUrls: .s3(
        hd1080: "0187-trailer-1080p-4a4b5712c34f46d8a41b9b3d68c4dcef",
        hd720: "0187-trailer-720p-13c22270a74343b4933c8101e342d75e",
        sd540: "0187-trailer-540p-4918b4e6c3464dae9e2f466a1de24d69"
      ),
      vimeoId: 702279822
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
