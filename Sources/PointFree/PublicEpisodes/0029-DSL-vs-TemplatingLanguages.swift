import Foundation

let ep29 = Episode(
  blurb: """
Templating languages are the most common way to render HTML in web frameworks, but we don't think they
are the best way. We compare templating languages to the DSL we previously built, and show that
the DSL fixes many problems that templates have, while also revealing amazing compositions that were
previously hidden.
""",
  codeSampleDirectory: "0029-dsls-vs-templating-languages",
  id: 29,
  exercises: exercises,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0029-dsl-vs-templating-languages/poster.jpg",
  length: 33*60 + 17,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1536559023),
  sequence: 29,
  sourcesFull: [
    "https://d1hf1soyumxcgv.cloudfront.net/0029-dsl-vs-templating-languages/dsl-wins.m3u8",
    "https://d1hf1soyumxcgv.cloudfront.net/0029-dsl-vs-templating-languages/dsl-wins.webm",
  ],
  sourcesTrailer: [
  ],
  title: "DSLs vs. Templating Languages",
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  .init(body: """
In this episode we expressed a lot of HTML “views” as just plain functions from some data type into the
`Node` type. In past episodes we saw that functions `(A) -> B` have both a `map` and `contramap` defined, the
former corresponding to post-composition and the latter pre-composition. What does `map` and `contramap`
represent in the context of an HTML view `(A) -> Node`?
"""),

  .init(body: """
When building a website you often realize that you want to be able to reuse an outer "shell" of a view,
and plug smaller views into it. For example, the header, nav and footer would consist of the "shell", and
then the content of your homepage, about page, contact page, etc. make up the inside. This is a kind of
"view composition", and most templating languages provide something like it (Rails calls it layouts,
Stencil calls it inheritance).

Formulate what this form of view composition looks like when you think of views as just functions of the
form `(A) -> Node`.
"""),

  .init(body: """
In previous episodes on this series we have discussed the `<>` (diamond) operator. We have remarked that this
operator comes up anytime we have a nice way of combining two values of the same type together into a third
value of the same type, i.e. functions of the form `(A, A) -> A`.

Given two views of the form `v, w: (A) -> [Node]`, it is possible to combine them into one view. Define
the diamond operator that performs this operation: `<>: ((A) -> [Node], (A) -> [Node]) -> (A) -> [Node]`.
"""),

  .init(body: """
Right now any node is allowed to be embedded inside any other node, even though certain HTML semantics
forbid that. For example, the list item tag `<li>` is only allowed to be embedded in unordered lists `<ul>`
and ordered lists `<ol>`. We can't enforce this property through the `Node` type, but we can do it through
the functions we define for constructing tags. The technique uses something known as _phantom types_, and it's
similar to what we did in our [`Tagged`](/episodes/ep12-tagged) episode. Here is a series of exercises to show
how it works:

  * First define a new `ChildOf` type. It's a struct that simply wraps a `Node` value, but most importantly
it has a generic `<T>`. We will use this generic to control when certain nodes are allowed to be embedded
inside other nodes.
  * Define two new types, `Ol` and `Ul`, that will act as the phantom types for `ChildOf`. Since we do not
care about the contents of these types, they can just be simple empty enums.
  * Define a new protocol, `ContainsLi`, and make both `Ol` and `Ul` conform to it. Again, we don't care
about the contents of this protocol, it is only a means to tag `Ol` and `Ul` as having the property that
they are allowed to contain `<li>` elements.
  * Finally, define three new tag functions `ol`, `ul` and `li` that allow you to nest `<li>`'s inside
`<ol>`'s and `<ul>`'s but prohibit you from putting `li`'s in any other tags. You will need to use the
types `ChildOf<Ol>`, `ChildOf<Ul>` and `ContainsLi` to accomplish this.
"""),

]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: (0*60 + 05),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
[In the last episode](/episodes/ep28-an-html-dsl) we introduced a new Swift EDSL for constructing HTML documents. It didn't take much work to get it going, and it showed a lot of promise. We were able to construct some complex documents very easily, and even perform transformations on those documents in the same way we might transform an array or any data structure in Swift.
""",
    timestamp: (0*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
However, we did not do a good job of comparing the HTML DSL to perhaps the most popular way of rendering HTML views: templating languages. Nearly every web framework in existence today uses templating languages to render HTML views. Definitely the most popular way of rendering HTML. But we don't think it's the best way to get the job done. We think that templating languages hide all types of fun compositions which can make our views more reusable and easier to understand.
""",
    timestamp: (0*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In this episode we will define what a templating language is, show off some popular ones, both outside the Swift community and inside, and then hopefully show the viewer that our tiny HTML DSL library that we created last time has a lot of benefits over the templating languages.
""",
    timestamp: (1*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Templating languages",
    timestamp: (1*60 + 25),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
A templating language is an all new programming language that embeds itself inside a plain text document so that it can emulate other languages. They are DSLs in their own way because they are highly tuned languages for outputting plain text documents. The templating language will provide ways of using certain tokens for interpolating values into the document or adding logical constructs.
""",
    timestamp: (1*60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's demo one such templating language. There are a lot of templating languages out there, such as [Mustache](http://mustache.github.io), [Handlebars](https://handlebarsjs.com), [ERB](https://ruby-doc.org/stdlib/libdoc/erb/rdoc/ERB.html), [Haml](http://haml.info), [Stencil](https://stencil.fuller.li/en/latest/), [Leaf](https://docs.vapor.codes/3.0/leaf/getting-started/), and more. The one we will be looking at is called Stencil. We chose this one because it's built in Swift and it even runs in playgrounds, but all of the other languages are quite similar.
""",
    timestamp: (1*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We'll start by importing Stencil and build a template using a string:
""",
    timestamp: (2*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
import Stencil

let template = Template.init(stringLiteral: \"""
<header>
  <h1>Hello!</h1>
</header>
\""")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We autocompleted the `init(stringLiteral:)` initializer, which probably shouldn't be invoked directly. `Template` comes with a more suitable `init(templateString:)` initializer.
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
And to use this template, we can call its `render` method.
""",
    timestamp: (2*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
print(try template.render(nil))
// <header>
//   <h1>Hello!</h1>
// </header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It consists of two phases. You build the template, which is just a big ole string, and then you render the template by providing a dictionary of values that you want to interpolate. Currently we aren't using any interpolated values, so let's add some.
""",
    timestamp: (3*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<header>
  <h1>Hello {{ name }}!</h1>
</header>
\""")

print(try template.render(["name": "Blob"]))
// <header>
//   <h1>Hello Blob!</h1>
// </header>
""",
    timestamp: (3*60 + 14),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So you see here that we use the token `{{ name }}` to indicate something that can be interpolated in at runtime. And this is how we add customization to our templates.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Already, there is a small problem. This entire value substitution API is stringly-typed. A small typo will cause it to not work how you expect. If we misspell the interpolated value:
""",
    timestamp: (3*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<header>
  <h1>Hello {{ nam }}!</h1>
</header>
\""")

print(try template.render(["name": "Blob"]))
// <header>
//   <h1>Hello !</h1>
// </header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We get a string back with no name. We get no indication that something went wrong. Not even a runtime error.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Misspelling a key in the render function does the same.
""",
    timestamp: (4*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<header>
  <h1>Hello {{ name }}!</h1>
</header>
\""")

print(try template.render(["nam": "Blob"]))
// <header>
//   <h1>Hello !</h1>
// </header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Again, no indication that something went wrong. It just rendered incorrectly.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
That's not great. That makes refactoring with confidence nearly impossible, as you have no static guarantees that strings are updated properly.
""",
    timestamp: (4*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Moving on, a feature that many templating languages offer are a concept usually referred to as "filters", thought I'm not exactly sure why. They are basically transformations you can perform on your interpolated values
""",
    timestamp: (4*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example, we can add `| uppercase` to indicate that we want to uppercase the name when it is interpolated.
""",
    timestamp: (4*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<header>
  <h1>Hello {{ name | uppercase }}!</h1>
</header>
\""")

print(try template.render(["name": "Blob"]))
// <header>
//   <h1>Hello BLOB!</h1>
// </header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is another stringly-typed API. Note that we didn't get any autocomplete help from Xcode, and that also means if we misspell it we only find out at runtime. For example, we may accidentally type `uppercased`, which matches Swift's String API:
""",
    timestamp: (5*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<header>
  <h1>Hello {{ name | uppercased }}!</h1>
</header>
\""")

print(try template.render(["name": "Blob"]))
// An error was thrown and was not caught:
// - Unknown filter 'uppercased'. Found similar filters: 'uppercase'
""",
    timestamp: (5*60 + 24),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The render call now threw an error at runtime, though at least it provided a helpful error message. This is a pretty big bummer, though. We are all used to our IDE catching simple errors like this for us before we are even allowed to run our app. This is one of the biggest problems with templating languages. It's a whole new programming language, yet often without all the niceties that we come to expect when dealing with a fully fledged language, one that supports syntax highlighting, autocompletion, and static analysis.
""",
    timestamp: (5*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
One of the oft-touted pros of templating languages is that they are "logicless". However, that is basically never true.
""",
    timestamp: (6*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Nearly every templating language provides many logic constructs for handling control flow. For example, Stencil offers `{% if %}` tags:
""",
    timestamp: (6*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
{% if showName %}
<header>
  <h1>Hello {{ name | uppercase }}!</h1>
</header>
{% end %}
\""")

print(try template.render(["name": "Blob"]))
// An error was thrown and was not caught:
// - Unknown template tag 'end'.
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Whoops, we get a runtime error! And this time no helpful suggestions. Turns out that the end tags in Stencil match up with the opening tags, so we wanted `endif`:
""",
    timestamp: (7*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
{% if showName %}
<header>
  <h1>Hello {{ name | uppercase }}!</h1>
</header>
{% endif %}
\""")

print(try template.render(["name": "Blob"]))
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now it prints an empty string, which is expected, because we never set `showName` to true.
""",
    timestamp: (7*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We just need to set `showName` to `true` in our dictionary.
""",
    timestamp: (7*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
{% if showName %}
<header>
  <h1>Hello {{ name | uppercase }}!</h1>
</header>
{% endif %}
\""")

print(try template.render(["name": "Blob", "showName": true]))
// <header>
//   <h1>Hello BLOB!</h1>
// </header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So there we have it. Templates _do_ typically have logic, and we see once again that this syntax is another opportunity for a typo-based runtime error.
""",
    timestamp: (7*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Templating languages also have looping. Let's say we wanted to output an HTML list of user names:
""",
    timestamp: (7*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<ul>
  {% for user in users %}
    <li>{{ user }}</li>
  {% endfor %}
</ul>
\""")

print(try template.render(["name": "Blob", "showName": true]))
// <ul>
//
// </ul>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Well, first we need to pass a list of users.
""",
    timestamp: (8*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<ul>
  {% for user in users %}
    <li>{{ user }}</li>
  {% endfor %}
</ul>
\""")

print(try template.render(["users": ["Blob", "Blob Jr.", "Blob Sr."]])
// <ul>
//
//    <li>Blob</li>
//
//    <li>Blob Jr.</li>
//
//    <li>Blob Sr.</li>
//
// </ul>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Everything rendered, but kind of strangely. All of the extra newlines and spacing are kinda gross, but there's really no nice way to get rid of them because they are a part of the template.
""",
    timestamp: (8*60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We could play around with the template in an effort to make rendering nicer, but then the template itself becomes much more difficult to read.
""",
    timestamp: (9*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<ul>{% for user in users %}
    <li>{{ user }}</li>{% endfor %}
</ul>
\""")

print(try template.render(["users": ["Blob", "Blob Jr.", "Blob Sr."]])
// <ul>
//    <li>Blob</li>
//    <li>Blob Jr.</li>
//    <li>Blob Sr.</li>
// </ul>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This unfortunately optimizes for rendering templates over reading them. We need to maintain this code, so this maybe optimizes for the wrong thing.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This problem is common enough in templating languages, that some, like ERB, provide special tag annotations for truncating leading or trailing whitespace. Even then, this is a lot of extra mental work to try to make templates render nicely. We've both written a lot of ERB and couldn't accurately describe how this truncation behavior works.
""",
    timestamp: (9*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Stencil also supports dot-syntax to reference fields in a larger structure. So if `users` contained structs or dictionaries, we could reference fields in those structures, say like `user.name`:
""",
    timestamp: (10*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<ul>
  {% for user in users %}
    <li>{{ user.name }}</li>
  {% endfor %}
</ul>
\""")

print(try template.render(["users": ["Blob", "Blob Jr.", "Blob Sr."]])
// 🛑 error: Execution was interrupted, reason: EXC_BAD_INSTRUCTION
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Ok, well this is very concerning. We now have a runtime crash. Not just an error being thrown which we can catch. This means that it could take down our server. We haven't yet updated the data being fed into the template, so when it tries to access `name` on the strings we're passing through, it presumably can't reconcile trying to find the `name` field of a string, and something in the library is causing a crash.
""",
    timestamp: (10*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We opened a GitHub [issue](https://github.com/stencilproject/Stencil/issues/231) about this crash when
we first released this episode, and a fix was [merged](https://github.com/stencilproject/Stencil/pull/234)
just a few days later.
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
We can fix this, but it's still pretty scary to think a crash could creep up so easily:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<ul>
  {% for user in users %}
    <li>{{ user.name }}</li>
  {% endfor %}
</ul>

print(try template.render(
  [
    "users": [
      ["name": "Blob"],
      ["name": "Blob Jr."],
      ["name": "Blob Sr."]
    ]
  ]
))
// <ul>
//
//    <li>Blob</li>
//
//    <li>Blob Jr.</li>
//
//    <li>Blob Sr.</li>
//
// </ul>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We're seeing, alongside another feature of templating languages, another sharp edge.
""",
    timestamp: (11*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We've now seen a few features of templating languages: interpolation, logic, loops, and handling complex data structures. Each feature had its caveats of increasing concern: all runtime errors.
""",
    timestamp: (11*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "DSLs",
    timestamp: (11*60 + 41),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Given the problems with templating languages, what is an alternative? Well, of course DSLs! Last episode we sketched the beginning of an HTML DSL, and even open sourced a full library for the DSL. Let's see how this embedded DSL solves a lot of the problems that templating languages have.
""",
    timestamp: (11*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's start easy. How do we interpolate values into the DSL so that we can dynamically build HTML? Well, since the DSL is just basic Swift types, there's nothing stopping us from just sticking a value, whether it be a literal or variable, directly into a DSL value:
""",
    timestamp: (11*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let name = "Blob"
print(
  render(
    header([
      h1([.text(name)])
      ])
  )
)
// <header ><h1 >Blob</h1></header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What's cool here is that this is just Swift code, and Swift code has to be compiled. If we introduce a typo in our template, we get an error at compile time.
""",
    timestamp: (12*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let name = "Blob"
print(
  render(
    header([
      h1([.text(name)])
      // 🛑 Use of unresolved identifier 'nam'; did you mean 'name'?
      ])
  )
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And if we misspell our data, we get a similar compiler error.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let nam = "Blob"
print(
  render(
    header([
      h1([.text(name)])
      // 🛑 Use of unresolved identifier 'name'; did you mean 'nam'?
      ])
  )
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The mere fact that our DSL is written in Swift has already solved this problem that templating languages have.
""",
    timestamp: (12*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
One thing I kinda liked about the template style of doing this, however, was that you treated the template kinda like a function in which we fed in all the data the template needed. We love functions here on Point-Free, so let's enhance this lil bit of HTML to be a function:
""",
    timestamp: (13*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func greet(name: String) -> Node {
  return header([
    h1([.text(name)])
    ])
}
""",
    timestamp: (13*60 + 31),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And generating an HTML node from this function is a simple as invoking it:
""",
    timestamp: (13*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
greet(name: "Blob")
// el("header", [], [el("h1", [], [text("Blob")])])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is starting to look more like that template style. We provide a function that acts as a template, and later we get to substitute in values by calling the function with data.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
A feature that most templating languages have is "filters", which allow you to transform interpolated values before they are put into the template. Well, we don't need special support for that because we can immediately use any function or method in Swift directly on our values.
""",
    timestamp: (14*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func greet(name: String) -> Node {
  return header([
    h1([.text(name.uppercased())])
    ])
}

print(render(greet(name: "Blob")))
// <header ><h1 >BLOB</h1></header>
""",
    timestamp: (14*60 + 21),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Again there is no way to misspell this method: we get a compiler error if we do so. And because we're in Xcode, we also have autocomplete and instant access to method documentation.
""",
    timestamp: (14*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Even better, in the template world, if you want a transformation that is not one of the default filters provided by the language, you have to go through a lengthy process to "register" your filter through a plug-in system. This becomes tiresome when all you wanna do is pass a value to a function! In a DSL we can merely work within Swift and define methods and functions as we choose.
""",
    timestamp: (15*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
What about logical constructs and control flow? Again, Swift being a fully featured language we get instant access to everything Swift has to offer and can enhance our HTML views.
""",
    timestamp: (15*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Here's a common situation: we have some HTML that should be rendered only if some condition is met. Perhaps its a view that takes a user, but only renders its contents when the user is an admin:
""",
    timestamp: (16*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct User {
  let name: String
  let isAdmin: Bool
}

func adminDetail(user: User) -> Node {
  guard user.isAdmin else { ??? }
  return header([
    h1([.text("Welcome admin: \\(user.name)")])
    ])
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can use the `guard` construct in Swift, but what should we return in the `else` case? We could make the return type optional `Node?`, or we could even alter our DSL to account for the concept of "empty" HTML. However, remember that our DSLs `element` case took in an array of nodes, an array has a very natural "empty" state...it's just the empty array! So let's upgrade this view to return an array of nodes:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func adminDetail(user: User) -> [Node] {
  guard user.isAdmin else { return [] }
  return [
    header([
      h1([.text("Welcome admin: \\(user.name)")])
      ])
  ]
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What's cool about this is that we could use a `guard` statement, which forces us to `return` in the `else` block. This is a nice control flow construction that Swift has, and we get to use it for free. I'm not even aware of any templating languages that have such a feature.
""",
    timestamp: (17*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's also plug some users into this function:
""",
    timestamp: (18*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let user = User(name: "Blob Jr.", isAdmin: false)
render(adminDetail(user: user))
// 🛑 Cannot convert value of type '[Node]' to expected argument type 'Node'
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Alright, `render` expects a node, but we're returning an array of nodes. It seems very natural to have an overload of `render` that takes an array of nodes. And because we're working in Swift, we can add this functionality ourselves.
""",
    timestamp: (18*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func render(_ nodes: [Node]) -> String {
  return nodes.map(render).joined()
}
""",
    timestamp: (18*60 + 34),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We just map over our array with the original `render` function before joining our rendered nodes into a single string.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And now it runs.
""",
    timestamp: (18*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
print(render(adminDetail(user: User(name: "Blob Jr.", isAdmin: false))))
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We get an empty string here, which makes sense because the user isn't an admin.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
What about for an admin user?
""",
    timestamp: (18*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
print(render(adminDetail(user: User(name: "Blob Sr.", isAdmin: true))))
// <header ><h1 >Welcome admin: Blob Sr.</h1></header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's pretty amazing that we're able to work within the language we're already comfortable in, Swift. We're free of the friction and issues we were seeing in templating languages. When we run our code it either works or the compiler guides us through fixes.
""",
    timestamp: (19*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We also saw that templates typically have looping constructs, and that can be nice for building up large, complex documents. Well, Swift has tons of looping constructs.
""",
    timestamp: (19*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's define a function that returns a list of users, like our earlier template. Most of our looping can be achieved with `map`.
""",
    timestamp: (19*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func users(_ names: [String]) -> Node {
  return ul(names.map { name in li([.text(name)]) })
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And to render:
""",
    timestamp: (20*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
print(render(users(["Blob", "Blob Jr.", "Blob Sr."])))
// <ul ><li >Blob</li><li >Blob Jr.</li><li >Blob Sr.</li></ul>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We're just living in the world of Swift and we're able to render more and more complex data easily by just writing and calling functions.
""",
    timestamp: (20*60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We're all familiar with Swift and we can leverage all that knowledge to write HTML.
""",
    timestamp: (20*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Because we're working with Swift code, we can also see things that might be more difficult to see in templating languages: code reuse.
""",
    timestamp: (20*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's extract out that lil bit of view logic in the `map` into its own dedicated view function:
""",
    timestamp: (21*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func users(_ names: [String]) -> Node {
  return ul(users.map { name in userItem(name) })
}

func userItem(_ name: String) -> Node {
  return li([name])
}

print(render(users(["Blob", "Blob Jr."])))
// <ul ><li >Blob</li><li >Blob Jr.</li><li >Blob Sr.</li></ul>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It builds and works exactly the same, but we're now working with a reusable unit of code that we extracted out of the original function.
""",
    timestamp: (21*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
On Point-Free we like to work with the [point-free style of programming], which allows us to fully get rid of mentioning the `name` from the names we're mapping over and supply the `userItem` function directly to the `map`.
""",
    timestamp: (21*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func users(_ names: [String]) -> Node {
  return ul(users.map(userItem))
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And this is super declarative. We've also stumbled upon an example of reusability in our HTML views. We can just extract any lil subview to its own function, and then invoke that function to get all of its DOM.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We haven't yet seen this kind of code reuse with templating languages. It's technically possible, but it's very convoluted. We aren't going to give all the details, but essentially you can refer to another template using the `include` tag.
""",
    timestamp: (22*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template = Template.init(stringLiteral: \"""
<ul>
  {% for user in users %}
    {% include "userItem" user %}
  {% endfor %}
</ul>
\""")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here we used `include "userItem" user` to indicate that we want to include the contents of the `userItem` template, and pass along the `user` value to that template.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And if we call the template.
""",
    timestamp: (23*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
print(try template1.render(["users": ["Blob", "Blob Jr."]]))
// An error was thrown and was not caught:
// Template named `userItem` does not exist. No loaders found
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now, this is currently error-ing because it doesn't know what we mean by referencing `"userItem"`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
To fix this we need the concept of a "loader" so that it knows how to load external templates. There are many kinds of loaders, including those that load things from disk or from memory. We can provide a simple in-memory template loader like so:
""",
    timestamp: (23*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
class MemoryTemplateLoader: Loader {
  func loadTemplate(name: String, environment: Environment) throws -> Template {
    if name == "userItem" {
      return Template(templateString: \"""
<li>{{ user }}</li>
\""", environment: environment)
    }

    throw TemplateDoesNotExist(templateNames: [name], loader: self)
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Then, in order to use this template loader we must create an environment with the loader specified:
""",
    timestamp: (24*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let environment = Environment(loader: MemoryTemplateLoader())
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And finally, we use this environment to render our template, instead of the template itself. It doesn't appear to be possible to specify an environment when calling `render` on a template directly:
""",
    timestamp: (24*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let template1 = \"""
<ul>
  {% for user in users %}
    {% include "userItem" user %}
  {% endfor %}
</ul>
\"""

print(
  try environment.renderTemplate(
    string: template,
    context: ["users": ["Blob", "Blob Jr."]]
  )
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We got it working, but with a lot of ceremony. And while typically you wouldn't do this much work because the library you are using does some of it for you, like [Vapor](https://vapor.codes), [Kitura](https://www.kitura.io), or [Sourcery](https://github.com/krzysztofzablocki/Sourcery), but it still speaks to the complexity of this approach. Most of the complexity is coming from the fact that none of the templates code lives in Swift, and so we are constantly having to invent new solutions to problems that pop up.
""",
    timestamp: (25*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And template loaders are yet another feature with a potential runtime error, like if we were to misspell a template name or provide an invalid value. Function application doesn't have these problems.
""",
    timestamp: (25*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And in fact, `include` statements in Stencil are nothing more than convoluted function application. And every templating language has this concept. [Rails](https://rubyonrails.org) calls it "partials", [Django](https://www.djangoproject.com) calls it "fragments", etc. All of those are just instances of function application, but have the same problems.
""",
    timestamp: (26*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "What's the point?",
    timestamp: (26*60 + 27),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
This has been informative, but it's probably a good time to ask: "what's the point?" Why are we even talking about templating languages? This is a video series on functional programming after all!
""",
    timestamp: (26*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Well, the way we look at it, server-side Swift is going to continue to grow in popularity, and we feel that it's important to question some of the long-held best practices as Swift rises to prominence. Templating languages are definitely an accepted best practice, even with all their faults. They probably became popular in the early days of web development because they are infinitely flexible, albeit complex, and most languages do not have the kinds of features that make DSLs really nice, so it was easy to miss.
""",
    timestamp: (26*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
However, Swift has proper algebraic data types, which are an important ingredient for DSLs, and we can take inspiration from functional programming to try to re-envision solutions to some of the web's problems. By doing this we were able to accomplish most of what templating languages offer, while solving a lot of their problems, and we even get to do things that templating languages have no answer for.
""",
    timestamp: (27*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example, since our DSL is just made of simple Swift data types, we can transform it just like we would an array or a dictionary in Swift. Let's show this off by cooking up a really simple transformation.
""",
    timestamp: (27*60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's cook up a function that transforms an HTML document by replacing all of its text nodes with redacted versions of the text.
""",
    timestamp: (28*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func redacted(_ node: Node) -> Node {
  switch node {
  case let .el(tag, attrs, children):
    return .el(tag, attrs, children.map(redacted))
  case let .text(string):
    return .text(
      string
        .split(separator: " ")
        .map { String(repeating: "█", count: $0.count) }
        .joined(separator: " ")
    )
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's take an example [from last time](/episodes/ep28-an-html-dsl) and take a look at it in a live view.
""",
    timestamp: (29*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
import WebKit
import PlaygroundSupport

let doc = header([
  h1(["Point-Free"]),
  p([id("blurb")], [
    "Functional programming in Swift. ",
    a([href("/about")], ["Learn more"]),
    "!"
    ]),
  img([src("https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), width(64), height(64)])
  ])

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 360, height: 480))
webView.loadHTMLString(render(doc), baseURL: nil)
PlaygroundPage.current.liveView. = webView
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
There's our document! What's it look like to redact it?
""",
    timestamp: (29*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
webView.loadHTMLString(render(redacted(doc)), baseURL: nil)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And there it is, safe from prying eyes. Now what if we want to redact the image? Well, we can pattern match on `img` elements, strip the `src`, and render a black background.
""",
    timestamp: (30*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
case let .el("img", attrs, children):
  return .el(
    "img",
    attrs.filter { attrName, _ in attr != "src" }
      + [("style", "background: black")],
    children
  )
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And when we render it, the image is redacted, as well! And just to make sure the `src` has been removed, let's look at the raw markup.
""",
    timestamp: (31*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
print(render(redacted(doc)))
// <header ><h1 >██████████</h1><p id="blurb">██████████ ███████████ ██ ██████ <a href="/about">█████ ████</a>█</p><img width="64" height="64" style="background: black"></img></header>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Templating languages have no corresponding story for this kind of transformation. There is no way to concisely traverse over a template document because ultimately it just gets rendered into a plain text file. You lose all of the structure. You typically need to bring in a whole other library that parses the HTML before you can make any such transformation before rendering it back to a string again. Why do all that work when you can start with this structure in the first place, manipulate it as much as you want, and then finally, at the last moment, interpret it. And this is the entire point of DSLs!
""",
    timestamp: (31*60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So, we think this is the point to contrasting DSLs with templating languages. DSLs are simple to understand, easy to build, and provide a lot of benefits over traditional methods of solving the same problems. And it's all based on ideas we've seen in functional programming.
""",
    timestamp: (32*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now this isn't the last we have to say about the HTML DSL. There are even more benefits to using DSLs over templating languages, and it has to do with how to compose views.

Until next time!
""",
    timestamp: (32*60 + 35),
    type: .paragraph
  ),
]
