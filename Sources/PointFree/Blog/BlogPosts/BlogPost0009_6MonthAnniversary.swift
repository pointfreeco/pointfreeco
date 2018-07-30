import Foundation

let post0009_6moAnniversary = BlogPost(
  author: .brandon,
  blurb: """
This week marks 6 months since our launch, and we’re making one of our most popular episodes free to
the public!
""",
  contentBlocks: [

    .init(
      content: """
This week marks 6 months since we launched [Point-Free](\(url(to: .home))). In that time we’ve
released 24 episodes with over 12 hours of video, published 9 [blog posts](\(url(to: .blog(.index)))), had
33 thousand unique visitors, more than 400 subscriptions, and
[open sourced](\(gitHubUrl(to: .organization))) 3 libraries from the topics covered in our episodes.

The content covered so far spans a broad range of topics, from core functional programming concepts
that will be the building block of later ideas, to the immediately useful ideas that can be brought into
your codebase today. We strive to strike a balance between the theoretical and the practical, and always
ask ourselves "what's the point?" to prove to our viewers that these things are worth learning.

## Algebraic Data Types free for all!

To celebrate our 6 month anniversary, we are making one of our most popular episodes free to everyone:
[Algebraic Data Types](\(url(to: .episode(.left(ep4.slug))))). In this episode we set an important foundation
of understanding the Swift type system in terms of algebra. This allows us to do very powerful refactorings
of our data types that would otherwise be very counterintuitive and difficult to see. If this episode
piques your interest, you may also want to checkout the two follow up episodes that go deeper into
algebraic data types: [Exponents](/episodes/ep9-algebraic-data-types-exponents) and
[Generic Functions and Recursion](/episodes/ep19-algebraic-data-types-generics-and-recursion).

## Here's to another 6

We've been having a lot of fun making episodes so far, but we're only just getting started. We haven't
yet talked about how `flatMap` fits into the `map` and `zip` story we have been developing. We also need
to explore what functional programming has to say about async operations. And functional programming is
well-regarded as a good tool for parsing, but we haven't said anything about that yet. There's still so
much more to cover!

So, we hope you'll join us for the next 6 months in diving even deeper into functional programming and
Swift. And if you're not a subscriber, please consider
[subscribing](\(url(to: .pricing(nil, expand: nil)))) today!
""",
      timestamp: nil,
      type: .paragraph
    ),
  ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
  id: 9,
  publishedAt: .init(timeIntervalSince1970: 1_532_944_623),
  title: "Celebrating 6 Months"
)
