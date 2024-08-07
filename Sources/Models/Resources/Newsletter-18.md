> Announcement: Today we're open sourcing a
> [plugin](https://github.com/pointfreeco/swift-html-kitura) for [Kitura](http://www.kitura.io) to
> render type-safe HTML. It provides a Swift compile-time API to HTML that prevents many of the
> runtime errors and vulnerabilities of traditional templated HTML rendering.

![](https://d1iqsrac68iyd8.cloudfront.net/posts/0018-type-safe-html-with-kitura/poster.jpg)

We’ve spent the past 4 weeks discussing DSLs in Swift, and yesterday it all culminated with the open
sourcing of [swift-html](https://github.com/pointfreeco/swift-html), our new Swift library for
building type-safe, extensible and transformable HTML documents. The design of this library has been
battle-tested for the past year, for it powers every single page on the [Point-Free](/) site. The
entire code base of this site is [open source](https://github.com/pointfreeco), we built it from
scratch in the functional style, and we even gave a tour of the site on a
[recent episode](/episodes/ep22-a-tour-of-point-free).

However, we know that most people are not going to adopt all of our techniques in building a Swift
web app (at least not yet 😉), and so we want to make sure that the HTML view layer is accessible to
everyone. That's why today we are open sourcing a new
[micro library](https://github.com/pointfreeco/swift-html-kitura) for bringing our
[swift-html](https://github.com/pointfreeco/swift-html) library into any
[Kitura](http://www.kitura.io) web application, one of the most popular server-side Swift frameworks
available today!

## Kitura Stencil Templates

Typically a Kitura app renders HTML views through the use of
[Stencil](https://stencil.fuller.li/en/latest/), which is the templating language we explored in our
most recent [episode](/episodes/ep29-dsls-vs-templating-languages). As an example, we could create a
Stencil template by saving the following to a `.stencil` file:

```
<ul>
  {% for user in users %}
    <li>{% user.name %}</li>
  {% endfor %}
</ul>
```

And then from a route you could render this template with an array of users by doing the following:

```swift
router.get("/") { request, response, next in
  try response.render("Users.stencil", context: [
    "users": [
      User(name: "Blob"),
      User(name: "Blob Jr."),
      User(name: "Blob Sr.")
    ]
  ])
  response.status(.OK)
  next()
}
```

This templating language is flexible, easy to use, and great as a starting point. However, it has all of the
problems that we covered in our last [episode](/episodes/ep29-dsls-vs-templating-languages), including
lack of type-safety, no good tooling support (autocomplete, syntax highlighting, refactoring, debugging, etc.)
and it can be more rigid that what we are used to.

## Using swift-html with Kitura

Luckily Kitura makes it very easy to support other methods of rendering besides Stencil, and that is precisely
what our new library helps with. Simply add the following to your `Package.swift` file:

```swift
.package(
  url: "https://github.com/pointfreeco/swift-html-kitura",
  from: "0.1.0"
),
```

And then you can pass a `Node` value to the `response.send` function in your router endpoint and it will
automatically be rendered!

```swift
import HtmlKituraSupport
import Kitura

let router = Router()

router.get("/") { request, response, next in
  response.send(
    html([
      body([
        h1(["Type-safe Kitura HTML"]),
        p([
          """
          This is a Kitura plugin that allows you to \
          write type-safe, transformable, composable \
          HTML views in a Kitura app!
          """
        ])
      ])
    ])
  )
  next()
}

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
```

And that's all there is to it!

## Conclusion

If you are building a Swift web app using Kitura we hope that you will consider using our
[swift-html-kitura](https://github.com/pointfreeco/swift-html-kitura) plugin as way to create your HTML views. We think
you'll be pleasantly surprised how nice it is to code up views in Swift and Xcode, and there are lots
of opportunities for code reuse and composability when building HTML views in this way.
