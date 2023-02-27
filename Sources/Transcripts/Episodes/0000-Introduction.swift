import Foundation

extension Episode {
  public static let ep0_introduction = Episode(
    blurb: """
      Point-Free is here, bringing you videos covering functional programming concepts using the Swift language. \
      Take a moment to hear from the hosts about what to expect from this new series.
      """,
    exercises: [],
    fullVideo: .init(
      bytesLength: 90_533_615,
      downloadUrls: .s3(
        hd1080: "0000-1080p-cccfbb7934ff42a8964d0e0393b72cf1",
        hd720: "0000-720p-0b46e32932784805a1b6b699413fe281",
        sd540: "0000-540p-c542d5fad5164174aeb83a97555d50ea"
      ),
      vimeoId: 354_215_017
    ),
    id: 0,
    length: 179,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_517_206_269),
    sequence: 0,
    title: "We launched!",
    // NB: Same as full video
    trailerVideo: .init(
      bytesLength: 90_533_615,
      downloadUrls: .s3(
        hd1080: "0000-1080p-cccfbb7934ff42a8964d0e0393b72cf1",
        hd720: "0000-720p-0b46e32932784805a1b6b699413fe281",
        sd540: "0000-540p-c542d5fad5164174aeb83a97555d50ea"
      ),
      vimeoId: 354_215_017
    ),
    transcriptBlocks: _privateTranscriptBlocks
  )
}

private let _privateTranscriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "What is Point-Free?",
    timestamp: 0,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
      Point-Free is a video series covering functional programming and Swift. We've been working in functional
      programming for quite some time now, and we've seen a lot of benefits. So, we've wanted to share with
      more people, and what better way than a video series that we can bring to our community.

      Functional programming leads to a lot of interesting ways to reuse code and make code more testable. But,
      we didn't even know about many of these ideas for most of our careers. However, by diving deeper and
      deeper things started to slowly make more sense it became clear that this was a serious tool for
      wiping away complexity that every programming should have at their disposal.

      Unfortunately, functional programming is sometimes seen as overly academic or unapproachable. That's a
      shame because it's a really beautiful way of doing programming, just a little different from what we
      are used to. It emphasizes immutable values, which means you are not allowed to mutate! And it is weirdly
      obsessed with functions and how they compose, and in some sense that is all that matters.
      """,
    timestamp: 0,
    type: .paragraph
  ),

  Episode.TranscriptBlock(
    content: "What’s the point?!",
    timestamp: 92,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
      We want to cover all of that wild and interesting ideas, but at the end of the day we want to slow down
      and ask ourselves *"what's the point?!"*. This is our chance to bring things back down to earth, take a
      deep breath, and see how these ideas are in fact applicable to our everyday programming lives.
      """,
    timestamp: 92,
    type: .paragraph
  ),

  Episode.TranscriptBlock(
    content: "We’re open source",
    timestamp: 113,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
      We also practice what we preach. This entire site is
      [open source](https://github.com/pointfreeco/pointfreeco) in server-side Swift, and written in a
      function style. The entire site is basically one function, taking a request from you, the viewer, and
      sending back a response to your browser. Everything is built on top of small components that compose
      well. There's a function that handles the routing to figure out what page to serve up, a function that
      produces the view built from lots of smaller view functions… everything is just functions!

      We will have episodes dissecting pieces of the site's codebase in the future, and we encourage everyone
      to take a look on [GitHub](https://github.com/pointfreeco/pointfreeco) and open up issues or pull
      requests if that interests you.
      """,
    timestamp: 113,
    type: .paragraph
  ),

  Episode.TranscriptBlock(
    content: "The “Fun” in “Function”",
    timestamp: 156,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
      The [first episode](https://www.pointfree.co/episodes/ep1-functions) is up and available to everyone! And if
      you enjoy that, the [second episode](https://www.pointfree.co/episodes/ep2-side-effects) is already up
      and just a [subscription](https://www.pointfree.co/pricing) away. We hope you enjoy!
      """,
    timestamp: 156,
    type: .paragraph
  ),
]
