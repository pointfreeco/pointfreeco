import Foundation

let post0017_typeSafeVapor = BlogPost(
  author: .stephen,
  blurb: """
todo
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "") // TODO
    ),

    .init(
      content: """
---

> todo

---
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "", // TODO
  id: 17, // TODO
  publishedAt: .init(timeIntervalSince1970: 1536724800),
  title: "Type-safe HTML with Vapor"
)
