![](https://d1iqsrac68iyd8.cloudfront.net/posts/0017-type-safe-html-with-vapor/poster.jpg)

<br>

We’ve spent the past 4 weeks discussing DSLs in Swift, and yesterday it all culminated with the open
sourcing of [swift-html](https://github.com/pointfreeco/swift-html), our new Swift library for building type-safe,
extensible and transformable HTML documents. The design of this library has been battle-tested for the past
year, for it powers every single page on the [Point-Free](/) site. The entire code base of this site is
[open source](https://github.com/pointfreeco), we built it from scratch in the functional style, and we even
gave a tour of the site on a [recent episode](/episodes/ep22-a-tour-of-point-free).

However, we know that most people are not going to adopt all of our techniques in building a Swift web app
(at least not yet 😉), and so we want to make sure that the HTML view layer is accessible to everyone.
That's why today we are open sourcing a new [micro library](https://github.com/pointfreeco/swift-html-vapor) for bringing
our [swift-html](https://github.com/pointfreeco/swift-html) library into any [Vapor](http://vapor.codes) web
application, one of the most popular server-side Swift frameworks available today!

## Vapor Leaf Templates

Typically a Vapor app renders HTML views through the use of the [Leaf](https://docs.vapor.codes/3.0/leaf/)
templating language. It's design is very similar to that of [Stencil](https://stencil.fuller.li/en/latest/),
which we discussed in our [episode](/episodes/ep29-dsls-vs-templating-languages) comparing DSLs to templating
languages. As an example, we could create a Leaf template by saving the following to a `.leaf` file:

```swift
<ul>
  #for(user in users) {
    <li>#(user.name)</li>
  }
</ul>
```

And then from a route you could render this template with an array of users by doing the following:

```swift
router.get("hello") { req in
  return try req.view()
    .render("UsersTemplate", [
      "users": [
        User(name: "Blob"),
        User(name: "Blob Jr."),
        User(name: "Blob Sr.")
      ]
    ]
  )
}
```

This templating language is flexible, easy to use, and great as a starting point. However, it has all of the
same problems that we covered in our last [episode](/episodes/ep29-dsls-vs-templating-languages), including
lack of type-safety, no good tooling support (autocomplete, syntax highlighting, refactoring, debugging, etc.)
and it can be more rigid that what we are used to.

## Using swift-html with Vapor

Luckily Vapor makes it very easy to support other methods of rendering besides Leaf, and that is precisely
what our new library helps with. Simply add the following to your `Package.swift` file:

```swift
.package(url: "https://github.com/pointfreeco/swift-html-vapor.git", from: "0.1.0"),
""",
```

And then you can return a `Node` value from a router endpoint and it will automatically be rendered!

```swift
import HtmlVaporSupport
import Vapor

let app = try Application()
let router = try app.make(Router.self)

router.get("hello") { _ in
  html([
    body([
      h1(["Type-safe Vapor HTML"]),
      p([\"\"\"
         This is a Vapor plugin that allows you to write type-safe,
         transformable, composable HTML views in a Vapor app!
         \"\"\"])
      ])
    ])
}

try app.run()
```

And that's all there is to it!

## Conclusion

If you are building a Swift web app using Vapor we hope that you will consider using our
[swift-html-vapor](https://github.com/pointfreeco/swift-html-vapor) plugin as way to create your HTML views. We think
you'll be pleasantly surprised how nice it is to code up views in Swift and Xcode, and there are lots
of opportunities for code reuse and composability when building HTML views in this way.
