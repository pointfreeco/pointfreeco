## Introduction

The past two episodes have been a little abstract. We've been exploring composition in a way that may not seem relevant and even at-hand in our day-to-day code. Let's see how we can apply composition to something more concrete: UIKit.

```swift
import UIKit

final class SignInViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white

    let gradientView = GradientView()
    gradientView.fromColor = UIColor(
      red: 0.5, green: 0.85, blue: 1, alpha: 0.85
    )
    gradientView.toColor = .white
    gradientView.translatesAutoresizingMaskIntoConstraints = false

    let logoImageView = UIImageView(image: UIImage(named: "logo"))
    logoImageView.widthAnchor.constraint(
      equalTo: logoImageView.heightAnchor,
      multiplier: logoImageView.frame.width
        / logoImageView.frame.height
    )
    .isActive = true

    let gitHubButton = UIButton(type: .system)
    gitHubButton.contentEdgeInsets = UIEdgeInsets(
      top: 12, left: 16, bottom: 12, right: 16
    )
    gitHubButton.titleLabel?.font = .systemFont(
      ofSize: 16, weight: .medium
    )
    gitHubButton.clipsToBounds = true
    gitHubButton.layer.cornerRadius = 6
    gitHubButton.backgroundColor = .black
    gitHubButton.tintColor = .white
    gitHubButton.imageEdgeInsets = UIEdgeInsets(
      top: 0, left: 0, bottom: 0, right: 16
    )
    gitHubButton.setImage(UIImage(named: "github"), for: .normal)
    gitHubButton.setTitle("Sign in with GitHub", for: .normal)

    let orLabel = UILabel()
    orLabel.font = .systemFont(ofSize: 14, weight: .medium)
    orLabel.textAlignment = .center
    orLabel.textColor = UIColor(white: 0.625, alpha: 1)
    orLabel.text = "or"

    let emailField = UITextField()
    emailField.clipsToBounds = true
    emailField.layer.cornerRadius = 6
    emailField.layer.borderColor = UIColor(
      white: 0.75, alpha: 1
    )
    .cgColor
    emailField.layer.borderWidth = 1
    emailField.borderStyle = .roundedRect
    emailField.heightAnchor.constraint(
      equalToConstant: 44
    )
    .isActive = true
    emailField.keyboardType = .emailAddress
    emailField.placeholder = "blob@pointfree.co"

    let passwordField = UITextField()
    passwordField.clipsToBounds = true
    passwordField.layer.cornerRadius = 6
    passwordField.layer.borderColor = UIColor(
      white: 0.75, alpha: 1
    )
    .cgColor
    passwordField.layer.borderWidth = 1
    passwordField.borderStyle = .roundedRect
    passwordField.heightAnchor.constraint(
      equalToConstant: 44
    )
    .isActive = true
    passwordField.isSecureTextEntry = true
    passwordField.placeholder = "••••••••••••••••"

    let signInButton = UIButton(type: .system)
    signInButton.contentEdgeInsets = UIEdgeInsets(
      top: 12, left: 16, bottom: 12, right: 16
    )
    signInButton.titleLabel?.font = .systemFont(
      ofSize: 16, weight: .medium
    )
    signInButton.clipsToBounds = true
    signInButton.layer.cornerRadius = 6
    signInButton.layer.borderColor = UIColor.black.cgColor
    signInButton.layer.borderWidth = 2
    signInButton.setTitleColor(.black, for: .normal)
    signInButton.setTitle("Sign in", for: .normal)

    let forgotPasswordButton = UIButton(type: .system)
    forgotPasswordButton.contentEdgeInsets = UIEdgeInsets(
      top: 12, left: 16, bottom: 12, right: 16
    )
    forgotPasswordButton.titleLabel?.font = .systemFont(
      ofSize: 16, weight: .medium
    )
    forgotPasswordButton.setTitleColor(.black, for: .normal)
    forgotPasswordButton.setTitle(
      "I forgot my password", for: .normal
    )

    let legalLabel = UILabel()
    legalLabel.font = .systemFont(ofSize: 11, weight: .light)
    legalLabel.numberOfLines = 0
    legalLabel.textAlignment = .center
    legalLabel.textColor = UIColor(white: 0.5, alpha: 1)
    legalLabel.text = """
      By signing into Point-Free you agree to our latest \
      terms of use and privacy policy.
      """

    let rootStackView = UIStackView(arrangedSubviews: [
      logoImageView,
      gitHubButton,
      orLabel,
      emailField,
      passwordField,
      signInButton,
      forgotPasswordButton,
      legalLabel,
      ])

    rootStackView.axis = .vertical
    rootStackView.isLayoutMarginsRelativeArrangement = true
    rootStackView.layoutMargins = UIEdgeInsets(
      top: 32, left: 16, bottom: 32, right: 16
    )
    rootStackView.spacing = 16
    rootStackView.translatesAutoresizingMaskIntoConstraints = false

    self.view.addSubview(gradientView)
    self.view.addSubview(rootStackView)

    NSLayoutConstraint.activate([
      gradientView.topAnchor
        .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      gradientView.leadingAnchor
        .constraint(equalTo: self.view.leadingAnchor),
      gradientView.trailingAnchor
        .constraint(equalTo: self.view.trailingAnchor),
      gradientView.bottomAnchor
        .constraint(equalTo: self.view.centerYAnchor),

      rootStackView.topAnchor
        .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      rootStackView.leadingAnchor
        .constraint(equalTo: self.view.leadingAnchor),
      rootStackView.trailingAnchor
        .constraint(equalTo: self.view.trailingAnchor),
    ])
  }
}
```

A common problem we face when building UIs is reusable styling. This code makes no attempt to make styles reusable yet. It merely configures each view inline after instantiation. A lot of these components have overlapping styles, so let's try to find a nicer way of styling components without so much duplication.

## UIAppearance

First let's explore `UIAppearance`, and API Apple provides to help tackle reusable styling. `UIAppearance` is a protocol with a few static methods, primarily one called `appearance`. These methods return a proxy view that can be configured just like a regular view. Once this proxy is configured, any view of its kind added to the view hierarchy will be configured the same way.

All of our buttons have the same content edge insets and font, so let's try to move this configuration to use `UIAppearance`.

```swift
UIButton.appearance().contentEdgeInsets = UIEdgeInsets(
  top: 12, left: 16, bottom: 12, right: 16
)
UIButton.appearance().titleLabel?.font = .systemFont(
  ofSize: 16, weight: .medium
)
```

If we remove the corresponding lines from our button configuration, things look mostly the same.

```swift
let gitHubButton = UIButton(type: .system)
// gitHubButton.contentEdgeInsets = UIEdgeInsets(
//   top: 12, left: 16, bottom: 12, right: 16
// )
// gitHubButton.titleLabel?.font = .systemFont(
//   ofSize: 16, weight: .medium
// )
…
let loginButton = UIButton(type: .system)
// loginButton.contentEdgeInsets = UIEdgeInsets(
//   top: 12, left: 16, bottom: 12, right: 16
// )
// loginButton.titleLabel?.font = .systemFont(
//   ofSize: 16, weight: .medium
// )
```

But we notice a difference: the font's a little smaller. What's going on? We're using the `.system` button type, which provides some nice styling to the button title, which might be getting in the way. On closer inspection, though, we're reaching two layers deep through the proxy object, attempting to update the font through the title label. `UIAppearance` changes only work on direct view properties. One workaround would be to extend our view and expose this configuration as a new property, but that's a bit of work.

Another issue with `UIAppearance` is that it works on the class level. We've already hit our limit of reusable configuration for `UIButton`, so in order to build more kinds of reusable buttons, our main path forward is to subclass.

## Subclassing

Subclassing is a popular way of managing reusable styles throughout an app. Let's start by defining a base button class and overriding its initializer to style it.

```swift
class BaseButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentEdgeInsets = UIEdgeInsets(
      top: 12, left: 16, bottom: 12, right: 16
    )
    self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
```

We were also forced by the compiler to define that extra initializer.

Now we can instantiate our buttons as `BaseButton`

```swift
let gitHubButton = BaseButton(type: .system)
…
let loginButton = BaseButton(type: .system)
```

But the font's looking wrong again. Button subclasses don't play nicely with the `.system` type, so we're going to have to give up the things that we get from that button type for now.

```swift
let gitHubButton = BaseButton()
…
let loginButton = BaseButton()
```

Now the font's rendering as it should.

We're now using this `BaseButton` class directly, but whenever we prefix a class name with `Base`, we're usually working with some abstract functionality that gets further subclassed for actual use.

What are some more direct button styles we see on our screen? We have a "filled" button style, a "border" button style, and a "text" button style. Let's start by defining a `FilledButton` subclass.

```swift
class FilledButton: BaseButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .black
    self.tintColor = .white
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
```

We again, need to provide the extra `init(coder:)` initializer to satisfy the compiler, but now have a new class we can use.

```swift
let gitHubButton = FilledButton()
// gitHubButton.contentEdgeInsets = UIEdgeInsets(
//   top: 12, left: 16, bottom: 12, right: 16
// )
// gitHubButton.titleLabel?.font = .systemFont(
//   ofSize: 16, weight: .medium
// )
gitHubButton.clipsToBounds = true
gitHubButton.layer.cornerRadius = 6
// gitHubButton.backgroundColor = .black
// gitHubButton.tintColor = .white
```

These styles have been grouped together by reuse, and it looks like we've skipped ahead here. We have a couple lines that round our button edges, shared with the sign-in button. Sounds like we need another subclass.

```swift
class RoundedButton: BaseButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.clipsToBounds = true
    self.layer.cornerRadius = 6
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
```

Now we're forced to think of the order of operations. Both `FilledButton` and `RoundedButton` inherit from `BaseButton`. For now, it seems that `FilledButton` should inherit from `RoundedButton` to ensure that filled buttons are rounded.


```swift
class FilledButton: RoundedButton {
  …
}
```

We could continue along these lines and define `BorderButton` and `TextButton` subclasses and figure out where they fit in the hierarchy. Where they fit may be easy to figure out for this small screen, but over time we'll find that we have disconnected subclasses that need to share the same logic.

This is the diamond inheritance problem: given a base class with two subclasses, we may want another subclass that inherits from both of these subclasses. Swift doesn't support diamond inheritance, so let's explore some other alternate ways of sharing logic.

## Object Composition

We have an old adage in our industry: "prefer composition over inheritance." What does "composition" mean in this sense?

Instead of using a subclass, let's define a static property for creating a button with a base style.

```swift
extension UIButton {
  static var base: UIButton {
    let button = UIButton()
    button.contentEdgeInsets = UIEdgeInsets(
      top: 12, left: 16, bottom: 12, right: 16
    )
    button.titleLabel?.font = .systemFont(
      ofSize: 16, weight: .medium
    )
    return button
  }
}
```

We can create another helper for our filled button style.

```swift
extension UIButton {
  static var filled: UIButton {
    let button = self.base
    button.backgroundColor = .black
    button.tintColor = .white
    return button
  }
}
```

This is where the "composition" comes in. We were able to call `self.base` to derive a button with our base styles before further applying out `filled` styles on top of it.

We can then add a rounded style.


```swift
extension UIButton {
  static var rounded: UIButton {
    let button = self.filled
    button.clipsToBounds = true
    button.layer.cornerRadius = 6
    return button
  }
}
```

Now our GitHub button can use one of these static properties instead of a subclass.

```swift
let gitHubButton = UIButton.filled
```

Whoops! Our button is filled, but not rounded. What happened? Looks like our order of operations is wrong. It looks like this version has the same issues as inheritance, though it's still a bit nicer. Defining styles directly on `UIButton` is definitely more succinct, and we didn't have to define those noisy `init(coder:)` initializers. Let's see if we can find a less confusing way to compose our styles.

## Functions

Let's turn to our old, familiar friend, function. We can define a `baseButtonStyle` function that styles a given button with our base styles.

```swift
func baseButtonStyle(_ button: UIButton) {
  button.contentEdgeInsets = UIEdgeInsets(
    top: 12, left: 16, bottom: 12, right: 16
  )
  button.titleLabel?.font = .systemFont(
    ofSize: 16, weight: .medium
  )
}
```

Nice and succinct.

What about a `filledButtonStyle`?

```swift
func filledButtonStyle(_ button: UIButton)  {
  button.backgroundColor = .black
  button.tintColor = .white
}
```

Now our filled style doesn't need to inherit or invoke the base style.

How about a `roundedButtonStyle`?

```swift
func roundedButtonStyle(_ button: UIButton)  {
  button.clipsToBounds = true
  button.layer.cornerRadius = 6
}
```

There we are! Three styling functions that don't need to worry about a hierarchy of inheritance or invocation between them. They do one thing and they do it well. Let's use them.

```swift
let gitHubButton = UIButton(type: .system)
baseButtonStyle(gitHubButton)
roundedButtonStyle(gitHubButton)
filledButtonStyle(gitHubButton)
```

This is seeming a little messy. There are a lot of moving parts in this configuration and it seems like it would be easy to miss a step. We're also applying `baseButtonStyle` directly, which seems like something that we _do_ want our other styles to use. It'd be nice to be able to combine these styles into less haphazard units.

## Function Composition

In our episode on [Side Effects](/episodes/ep2-side-effects), we introduced `<>` for single type composition. We defined it twice: once for functions that take `A`s as input and return `A`s as output, and once for value mutation with functions that go from `inout A` to `Void`.

```swift
func <> <A>(
  f: @escaping (A) -> A, g: @escaping (A) -> A
) -> (A) -> A {
  return f >>> g
}
func <> <A>(
  f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void
) -> (inout A) -> Void {
  return { a in
    f(&a)
    g(&a)
  }
}
```

Our styling functions are living in the land of reference type mutation, so let's see if we can reuse this `(inout A) -> Void` shape.

```swift
func <> <A: AnyObject>(
  f: @escaping (A) -> Void, g: @escaping (A) -> Void
) -> (A) -> Void {
  return { a in
    f(a)
    g(a)
  }
}
```

We've constrained our generic `A` to `AnyObject`, a protocol that all reference types conform to. In the process, we were able to remove our `inout` annotations.

Now we can compose our `filledButtonStyle` from our `baseButtonStyle`.

```swift
let filledButtonStyle =
  baseButtonStyle
    <> {
      $0.backgroundColor = .black
      $0.tintColor = .white
    }
```

Let's do the same with our `roundedButtonStyle`.

```swift
let roundedButtonStyle =
  baseButtonStyle
    <> {
      $0.clipsToBounds = true
      $0.layer.cornerRadius = 6
    }
```

Our GitHub button no longer needs to be configured with `baseButtonStyle`. Let's finally make a decision about our hierarchy of styling, though, and make `filledButtonStyle` compose from `roundedButtonStyle`.

```swift
let filledButtonStyle =
  roundedButtonStyle
    <> {
      $0.backgroundColor = .black
      $0.tintColor = .white
    }
```

This kind of composition feels a lot more flexible. We can mix, match, and extract styles quickly as we go, and each function itself is responsible for just its styling and doesn't need to call out to other styling functions: we combine styles through function composition.

We're also now able to explore reusable styles that would've been impossible in the class and static property world! Our `roundedButtonStyle` is a function that modifies properties that exist on all `UIView`s, not just buttons. In fact, our `UITextField`s are configured the same way.

We can now write a `roundedStyle` that works on _all_ `UIView`s.

```swift
let roundedStyle: (UIView) -> Void = {
  $0.clipsToBounds = true
  $0.layer.cornerRadius = 6
}
```

And our `roundedButtonStyle` merely needs to compose with this more reusable function.

```swift
let roundedButtonStyle =
  baseButtonStyle
    <> roundedStyle
```

We can reuse this `roundedStyle` with our text fields by creating a `baseTextFieldStyle`.

```swift
let baseTextFieldStyle: (UITextField) -> Void =
  roundedStyle
    <> {
      $0.layer.borderColor = UIColor(white: 0.75, alpha: 1).cgColor
      $0.layer.borderWidth = 1
      $0.borderStyle = .roundedRect
      $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
```

And we can apply this style to both of our text fields and get rid of a lot of code.

```swift
let emailTextField = UITextField()
baseTextFieldStyle(emailTextField)
…
let passwordTextField = UITextField()
baseTextFieldStyle(passwordTextField)
```

More reuse is peeking through: our `baseTextFieldStyle` configures its border in the same way that our border button does. We should be able to write a `borderStyle` that both can use.

If we write a styling function in a very basic way, we run into a problem:

```swift
let borderStyle: (UIView) -> Void = {
  $0.layer.borderColor = <#???#>
  $0.layer.borderWidth = <#???#>
}
```

We have configuration here that is different in each case: our border button has a thick, black border, while our text field has a thin, gray border. Let's bring this configuration into the function.

```swift
func borderStyle(color: UIColor, width: CGFloat) -> (UIView) -> Void {
  return { view in
    view.layer.borderColor = color.cgColor
    view.layer.borderWidth = width
  }
}
```

In order to compose, we need our function to take configuration up front and return a brand new function that styles a view.

Let's try using it with `baseTextFieldStyle`:

```swift
let baseTextFieldStyle: (UITextField) -> Void =
  roundedStyle
    <> borderStyle(color: UIColor(white: 0.75, alpha: 1), width: 1)
    <> {
      $0.borderStyle = .roundedRect
      $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
```

We have a small gotcha.

```
Value of type 'UIView' has no member 'borderStyle'
```

We're composing a bunch of small functions that style `UIView`s generally into a function that expects `UITextField`s specifically and the type system has hit its inference limit between subtypes, supertypes, and multiline closures. This kind of error should be rare, but it's easy to fix. We need to be explicit with the closure's type signature.

```swift
let baseTextFieldStyle: (UITextField) -> Void =
  roundedStyle
    <> borderStyle(color: UIColor(white: 0.75, alpha: 1), width: 1)
    <> { (tf: UITextField) in
      tf.borderStyle = .roundedRect
      tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
```

And that works pretty nicely.

Now we have a `borderStyle` that should make it easy to create a `borderButtonStyle`!

```swift
let borderButtonStyle =
  roundedStyle
    <> borderStyle(color: .black, width: 2)
```

Another example of working fluidly with styling functions that work on any `UIView`. We've been able to solve our diamond inheritance problem with a diamond `<>`.

What does it look like if we take things further and write styling functions for everything?

```swift
// base

func autolayoutStyle<V: UIView>(_ view: V) -> Void {
  view.translatesAutoresizingMaskIntoConstraints = false
}

func aspectRatioStyle<V: UIView>(size: CGSize) -> (V) -> Void {
  return {
    $0.widthAnchor
      .constraint(
        equalTo: $0.heightAnchor, multiplier: size.width
          / size.height
      )
      .isActive = true
  }
}

func implicitAspectRatioStyle<V: UIView>(_ view: V) -> Void {
  aspectRatioStyle(size: view.frame.size)(view)
}

func roundedRectStyle<View: UIView>(_ view: View) {
  view.clipsToBounds = true
  view.layer.cornerRadius = 6
}

// buttons

let baseButtonStyle: (UIButton) -> Void = {
  $0.contentEdgeInsets = UIEdgeInsets(
    top: 12, left: 16, bottom: 12, right: 16
  )
  $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
}

let roundedButtonStyle =
  baseButtonStyle
    <> roundedRectStyle

let filledButtonStyle =
  roundedButtonStyle
    <> {
      $0.backgroundColor = .black
      $0.tintColor = .white
}

let borderButtonStyle =
  roundedButtonStyle
    <> {
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.borderWidth = 2
      $0.setTitleColor(.black, for: .normal)
}

let textButtonStyle =
  baseButtonStyle <> {
    $0.setTitleColor(.black, for: .normal)
}

let imageButtonStyle: (UIImage?) -> (UIButton) -> Void = { image in
  return {
    $0.imageEdgeInsets = UIEdgeInsets(
      top: 0, left: 0, bottom: 0, right: 16
    )
    $0.setImage(image, for: .normal)
  }
}

let gitHubButtonStyle =
  filledButtonStyle
    <> imageButtonStyle(UIImage(named: "github"))

// text fields

let baseTextFieldStyle: (UITextField) -> Void =
  roundedRectStyle
    <> {
      $0.borderStyle = .roundedRect
      $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
      $0.layer.borderColor = UIColor(white: 0.75, alpha: 1).cgColor
      $0.layer.borderWidth = 1
    }

let emailTextFieldStyle =
  baseTextFieldStyle
    <> {
      $0.keyboardType = .emailAddress
      $0.placeholder = "blob@pointfree.co"
    }

let passwordTextFieldStyle =
  baseTextFieldStyle
    <> {
      $0.isSecureTextEntry = true
      $0.placeholder = "••••••••••••••••"
    }

// labels

func fontStyle(
  ofSize size: CGFloat, weight: UIFont.Weight
) -> (UILabel) -> Void {
  return {
    $0.font = .systemFont(ofSize: size, weight: weight)
  }
}

func textColorStyle(_ color: UIColor) -> (UILabel) -> Void {
  return {
    $0.textColor = color
  }
}

let centerStyle: (UILabel) -> Void = {
  $0.textAlignment = .center
}

// hyper-local

let orLabelStyle: (UILabel) -> Void =
  centerStyle
    <> fontStyle(ofSize: 14, weight: .medium)
    <> textColorStyle(UIColor(white: 0.625, alpha: 1))

let finePrintStyle: (UILabel) -> Void =
  centerStyle
    <> fontStyle(ofSize: 14, weight: .medium)
    <> textColorStyle(UIColor(white: 0.5, alpha: 1))
    <> {
      $0.font = .systemFont(ofSize: 11, weight: .light)
      $0.numberOfLines = 0
    }

let gradientStyle: (GradientView) -> Void =
  autolayoutStyle <> {
    $0.fromColor = UIColor(
      red: 0.5, green: 0.85, blue: 1, alpha: 0.85
    )
    $0.toColor = .white
    }

// stack views

let rootStackViewStyle: (UIStackView) -> Void =
  autolayoutStyle
    <> {
      $0.axis = .vertical
      $0.isLayoutMarginsRelativeArrangement = true
      $0.layoutMargins = UIEdgeInsets(
        top: 32, left: 16, bottom: 32, right: 16
      )
      $0.spacing = 16
    }

final class SignInViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white

    let gradientView = GradientView()
    gradientStyle(gradientView)

    let logoImageView = UIImageView(image: UIImage(named: "logo"))
    implicitAspectRatioStyle(logoImageView)

    baseButtonStyle(.appearance())

    let gitHubButton = UIButton(type: .system)
    gitHubButton.setTitle("Sign in with GitHub", for: .normal)
    gitHubButtonStyle(gitHubButton)

    let orLabel = UILabel()
    orLabelStyle(orLabel)
    orLabel.text = "or"

    let emailField = UITextField()
    emailTextFieldStyle(emailField)

    let passwordField = UITextField()
    passwordTextFieldStyle(passwordField)

    let signInButton = UIButton(type: .system)
    signInButton.setTitle("Sign in", for: .normal)
    borderButtonStyle(signInButton)

    let forgotPasswordButton = UIButton(type: .system)
    forgotPasswordButton.setTitle(
      "I forgot my password", for: .normal
    )
    textButtonStyle(forgotPasswordButton)

    let legalLabel = UILabel()
    legalLabel.text = """
      By signing into Point-Free you agree to our latest \
      terms of use and privacy policy.
      """
    finePrintStyle(legalLabel)

    let rootStackView = UIStackView(arrangedSubviews: [
      logoImageView,
      gitHubButton,
      orLabel,
      emailField,
      passwordField,
      signInButton,
      forgotPasswordButton,
      legalLabel,
    ])
    rootStackViewStyle(rootStackView)

    self.view.addSubview(gradientView)
    self.view.addSubview(rootStackView)

    NSLayoutConstraint.activate([
      gradientView.topAnchor
        .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      gradientView.leadingAnchor
        .constraint(equalTo: self.view.leadingAnchor),
      gradientView.trailingAnchor
        .constraint(equalTo: self.view.trailingAnchor),
      gradientView.bottomAnchor
        .constraint(equalTo: self.view.centerYAnchor),

      rootStackView.topAnchor
        .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      rootStackView.leadingAnchor
        .constraint(equalTo: self.view.leadingAnchor),
      rootStackView.trailingAnchor
        .constraint(equalTo: self.view.trailingAnchor),
      ])
  }
}
```

We were able to derive a lot of interesting, reusable styles! We have an `autolayoutStyle` that might be a bit more easier to read and remember than `translatesAutoresizingMaskIntoConstraints = false`. We have an `aspectRatioStyle` for maintaining the aspect ratio of an image view with auto-layout.

We have an `imageButtonStyle` that can compose with `borderButtonStyle` or `filledButtonStyle` depending on our needs.

We also have a `rootStackViewStyle` that allows us to maintain consistent margins and spacing across our app.

All of these styling functions exist outside the controller, free to use and reuse anywhere.

What about our view controller? Well, it's become really concise! Each view is instantiated and then styled on a single line.

## What’s the point?

Looking at a real-world example makes it a bit easier to ask ourselves: what's the point? We've leveraged `<>` in an everyday use case and been able to wrangle the problem of UIKit styling in a really powerful and flexible way. Our functions aren't fighting UIKit. In fact, they play rather nicely!

We can even use `UIAppearance` with our styling functions!

```swift
baseButtonStyle(UIButton.appearance())
```

Or, if you're feeling fancy:

```swift
baseButtonStyle(.appearance())
```

This is the beauty of simple functions. They're flexible and leave us open to use them however we want to use them. We're not working with a layer of abstraction that prevents us from seeing what's going on.

This is something we use all the time. It's something you can introduce to your code base with no dependencies simply.
