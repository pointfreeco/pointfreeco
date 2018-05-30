import Foundation

let post0005_stylingWithFunctions = BlogPost(
  author: .brandon,
  blurb: """
We are making one of our early episodes, “UIKit Styling with Functions”, free to everyone today! It’s a
seminal episode that sets the foundation for some later work in the Point-Free series.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0005-styling-with-functions-free/0005-poster.jpg")
    ),

    .init(
      content: """
---

> We are making one of our early episodes, “[UIKit Styling with Functions](\(url(to: .episode(.left(ep3.slug)))))”,
free to everyone today! It’s a seminal episode that sets the foundation for some later work in the Point-Free
series.

---
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
Our third episode in the Point-Free series, “[UIKit Styling with Functions](\(url(to: .episode(.left(ep3.slug)))))”,
is one of our most popular episodes and has been the one that visitors have used their free episode credit on
more than any other episode. We aired it nearly four months ago, and it contains some very important,
foundational ideas on how to build reusable and composable styling using plain functions and function
composition. We’d like more people see how fun it can be to style UIKit in this way, so today we are making
the episode free!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "How to Style UIKit?",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
The episode begins by discussing three popular ways of styling UIKit and describes some of their deficiencies:


### `UIAppearance`

It’s an interesting API provided by Apple that allows you to globally specify styles in one place. However,
there are some limitations. First, you cannot style nested properties, like
`UIButton.appearance().titleLabel?.font`, only direct properties. Second, it doesn’t kick into action until a
view has been added to a `UIWindow`, which adds a level of sequencing and coordination into your view layer
that can cause subtle bugs. Third, it’s heavily tied to the subclass hierarchy of UIKit, which is deep and
wide, and offers very little granular control of how styles are applied. That’s only the beginning of its
problems!


### Inheritance

Another common approach is to create subclasses of common UIKit components to provide custom styling. For
example, you could have a `PrimaryButton`, a `SecondaryButton`, and so on. However, you will invariably be
led to the dreaded “diamond inheritance” problem in which you want a subclass to be able to share styles from
two other classes, like perhaps you want `PrimaryButton` to be able to inherit from both `RoundedButton` and
`FilledButton`.

### Factories

Factories: We often hear “favor composition of inheritance”, and one way to do this with objects is through
factories. So, instead of subclasses we will create factory methods to create the elements we need, like
`UIButton.rounded` or `UIButton.filled`. But, again we cannot share styles between these factories, and we
have the same problems that inheritance had.

---

None of these approaches give us the level of reuse and composability that we would hope for. However, it
turns out that Swift gives us an amazing tool that is perfect for styling: functions! Swift supports free
functions, which are very flexible because they are unbound (i.e. free) from being bound to any particular
data. If we apply our styles to UIKit components using functions, then we can use function composition to
layer on multiple styles at once. We are then free to build a small styleguide of styling functions, and
pick-and-choose any combination of them to express the exact style you need.

For example, we could start with a function that sets the base styles needed for all the buttons in our
application:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let baseButtonStyle: (UIButton) -> Void = {
  $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
  $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Then we could define a little helper for setting the base corner rounded style for any view:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func roundedStyle(_ view: UIView) {
  view.clipsToBounds = true
  view.layer.cornerRadius = 6
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Then we could define a “rounded button style” by just combining these two styles. The approach we took in the
episode is to use the diamond operator `<>` that is highly tuned for combining two values of the same type.
In this case, it combines two functions of the form `(A) → Void` to produce a third `(A) → Void`:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func <> <A: AnyObject>(
  f: @escaping (A) -> Void,
  g: @escaping (A) -> Void
  ) -> (A) -> Void {
  return { a in f(a); g(a) }
}

let roundedButtonStyle =
  baseButtonStyle
    <> roundedStyle
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Then we could define our “filled button style” to start with the “rounded” style and layer on some additional
styles using function composition:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let filledButtonStyle =
  roundedButtonStyle
    <> {
      $0.backgroundColor = .black
      $0.tintColor = .white
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We could even have an “image button style” that is a curried styling function that takes an upfront `UIImage`
first, and then returns a `UIButton` styling function:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let imageButtonStyle: (UIImage?) -> (UIButton) -> Void = { image in
  return {
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    $0.setImage(image, for: .normal)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And with that helper it’s a small leap to derive a “GitHub button style” by using all of our previous helpers:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let gitHubButtonStyle =
  filledButtonStyle
    <> imageButtonStyle(UIImage(named: "github"))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In just 30 lines of code we have set the foundation for the styling of all buttons in our application!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "Conclusion",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
We think that functions and function composition is a really powerful way to style UIKit components. But the
best part is that it’s so simple, and does not add many layers of abstraction onto your application.
You could get benefits from using this tool in your code base today.

If this interests you then you may also want to check out our latest episode on
“[Styling with Overture](https://www.pointfree.co/episodes/ep17-styling-with-overture)”, which improves
on the ideas discussed in this blog post by using our [Overture](\(gitHubUrl(to: .repo(.overture))))
library.
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://https://d1iqsrac68iyd8.cloudfront.net/posts/0005-styling-with-functions-free/0005-poster.jpg",
  id: 5,
  publishedAt: .init(timeIntervalSince1970: 1_527_674_223),
  title: "Styling with Functions: Free for Everyone!"
)
