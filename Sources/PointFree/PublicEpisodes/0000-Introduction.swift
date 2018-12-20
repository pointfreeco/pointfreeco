import Foundation

let introduction = Episode(
  blurb: """
Point-Free is here, bringing you videos covering functional programming concepts using the Swift language. \
Take a moment to hear from the hosts about what to expect from this new series.
""",
  codeSampleDirectory: "",
  exercises: [],
  fullVideo: .init(
    bytesLength: 411_951_213,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0000-introduction/full-720p-DE41675F-1919-4023-A5B3-1B9522C6BBBE.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0000-introduction/full/0000-introduction.m3u8"
  ),
  id: 0,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0000-introduction/0000-poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0000-introduction/itunes-poster.jpg",
  length: 179,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_517_206_269),
  sequence: 0,
  title: "We launched!",
  trailerVideo: nil,
  transcriptBlocks: transcriptBlocks
)

private let transcriptBlocks: [Episode.TranscriptBlock] = [
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

Functional programming leads to a lot of intersting ways to reuse code and make code more testable. But,
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
[open source](https://www.github.com/pointfreeco/pointfreeco) in server-side Swift, and written in a
function style. The entire site is basically one function, taking a request from you, the viewer, and
sending back a response to your browser. Everything is built on top of small components that compose
well. There's a function that handles the routing to figure out what page to serve up, a function that
produces the view built from lots of smaller view functions… everything is just functions!

We will have episodes dissecting pieces of the site's codebase in the future, and we encourage everyone
to take a look on [GitHub](https://www.github.com/pointfreeco/pointfreeco) and open up issues or pull
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
