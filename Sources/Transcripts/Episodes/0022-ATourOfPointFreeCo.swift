import Foundation

extension Episode {
  static let ep22_aTourOfPointFree = Episode(
    blurb: """
      Join us for a tour of the code base that powers this very site and see what functional programming can look like in a production code base! We'll walk through cloning the repo and getting the site running on your local machine before showing off some of the fun functional programming we do on a daily basis.
      """,
    codeSampleDirectory: "0022-a-tour-of-point-free",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 325_311_571,
      downloadUrls: .s3(
        hd1080: "0022-1080p-f8f5183d5ffb4802a2ff82dedcbed9d2",
        hd720: "0022-720p-8793fae0ead64a90a3c3b5853d438107",
        sd540: "0022-540p-923c08932c374f5d8f752f1e6bfdf95c"
      ),
      vimeoId: 355_115_759
    ),
    id: 22,
    length: 39 * 60 + 21,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_531_735_023),
    references: [.serverSideSwiftFromScratch, .pointfreeco],
    sequence: 22,
    title: "A Tour of Point-Free",
    trailerVideo: .init(
      bytesLength: 27_774_800,
      downloadUrls: .s3(
        hd1080: "0022-trailer-1080p-ee8b944402cd49aaa744c310a46c0a98",
        hd720: "0022-trailer-720p-e3940fbe9db042fe9bcb6ef0cead3c90",
        sd540: "0022-trailer-540p-2ef71ca0f3bc4af6975b565f44550473"
      ),
      vimeoId: 355_115_419
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 22)
  )
}

private let _exercises: [Episode.Exercise] = [

  ]
