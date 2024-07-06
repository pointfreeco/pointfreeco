![](https://d1iqsrac68iyd8.cloudfront.net/posts/0005-styling-with-functions-free/poster.jpg)

<br>

Our third episode in the Point-Free series, “[UIKit Styling with Functions](/episodes/ep3-uikit-styling-with-functions)”,
is one of our most popular episodes and has been the one that visitors have used their free episode credit on
more than any other episode. It aired nearly four months ago, and it contains some very important,
foundational ideas on how to build reusable and composable styling using plain functions and function
composition. We’d like more people to see how fun it can be to style UIKit in this way, so today we are making
the episode free!

## How to Style UIKit?

The episode begins by discussing three popular ways of styling UIKit and describes some of their deficiencies:

### `UIAppearance`

This API is the only truly Apple-sanctioned way of creating reusable styling. It’s an interesting API that
allows you to globally specify styles in one place. However, there are some limitations. First, you cannot
style sub-properties of a view:

```swift
UIButton.appearance().titleLabel?.font =
  .systemFont(ofSize: 16, weight: .medium)
```

Drilling into `titleLabel` does nothing. `UIAppearance` will only affect `UIButton` properties in this
example, and you can only style direct properties on a component.

Second, it doesn’t kick into action until a view has been added to a `UIWindow`, which adds a level of
sequencing and coordination into your view layer that can cause subtle bugs.

Third, it’s heavily tied to the subclass hierarchy of UIKit, which is deep and wide, and offers very little
granular control of how styles are applied. And that’s only the beginning of its problems.

### Inheritance

Another common approach is to create subclasses of common UIKit components to provide custom styling. For
example, you could have a `PrimaryButton`, a `SecondaryButton`, and so on.

Unfortunately, you will invariably be led to the dreaded
“[diamond inheritance](https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem)” problem in
which you want a subclass to be able to share styles from two other classes, like perhaps you want
`PrimaryButton` to be able to inherit from both `RoundedButton` and `FilledButton`.

### Factories

Factories: We often hear “favor composition of inheritance”, and one way to do this with objects is through
factories. So, instead of subclasses we will create factory methods to create the elements we need, like
`UIButton.rounded` or `UIButton.filled`. But, again we cannot share styles between these factories, and we
have the same problems that inheritance had.

---

None of these approaches give us the level of reuse and composability that we would hope for.

It turns out that Swift gives us an amazing tool that is _perfect_ for styling: functions! Swift supports
free functions, which are very flexible because they are unbound (i.e. free). This means we can use them
without any particular data attached. If we apply our styles to UIKit components using functions, we can use
function composition to layer on multiple styles at once. We are then free to build a small styleguide of
styling functions, and pick-and-choose any combination of them to express the exact style we need.

For example, we could start with a function that sets the base styles needed for all the buttons in our
application:

```swift
let baseButtonStyle: (UIButton) -> Void = {
  $0.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
  $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
}
```

Then we could define a little helper for setting the base corner rounded style for any view:

```swift
func roundedStyle(_ view: UIView) {
  view.clipsToBounds = true
  view.layer.cornerRadius = 6
}
```

Then we could define a “rounded button style” by just combining these two styles. The approach we took in the
episode is to use the diamond operator `<>`, which is highly tuned for combining two values of the same type.
In this case, it combines two functions of the form `(A) -> Void` to produce a third `(A) -> Void`:

```swift
func <> <A: AnyObject>(
  f: @escaping (A) -> Void,
  g: @escaping (A) -> Void
  ) -> (A) -> Void {
  return { a in f(a); g(a) }
}

let roundedButtonStyle =
  baseButtonStyle
    <> roundedStyle
```

Then we could define our “filled button style” to start with the “rounded” style and layer on some additional
styles using function composition:

```swift
let filledButtonStyle =
  roundedButtonStyle
    <> {
      $0.backgroundColor = .black
      $0.tintColor = .white
}
```

We could even have an “image button style” that is a curried styling function that takes an upfront `UIImage`
first, and then returns a `UIButton` styling function:

```swift
let imageButtonStyle: (UIImage?) -> (UIButton) -> Void = { image in
  return {
    $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 16)
    $0.setImage(image, for: .normal)
  }
}
```

And with that helper it’s a small leap to derive a “GitHub button style” by using all of our previous helpers:

```swift
let gitHubButtonStyle =
  filledButtonStyle
    <> imageButtonStyle(UIImage(named: "github"))
```

In just 30 lines of code we have set the foundation for the styling of all buttons in our application!

## Conclusion

We think that functions and function composition are a really powerful way to style UIKit components. But the
best part is that it’s simple and doesn't add layers of abstraction to your application. You can get benefits
from using this tool in your code base today.

If this interests you then you may also want to check out our latest episode on
“[Styling with Overture](https://www.pointfree.co/episodes/ep17-styling-with-overture)”, which improves
on the ideas discussed in this blog post by using our [Overture](https://github.com/pointfreeco/swift-overture)
library.
