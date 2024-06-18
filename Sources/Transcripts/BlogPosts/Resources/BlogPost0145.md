A few weeks ago we previewed what [peak UIKit][peek-uikit-blog] looks like, and we even released 
[two free episodes][modern-uikit-collection] to show off these tools. These announcements generated
a surprising amount of interested from the community, and now we are ready to share a beta of these
tools so that everyone can give them a spin and share their feedback.

[peek-uikit-blog]: /blog/posts/140-this-is-what-peak-uikit-looks-like
[modern-uikit-collection]: /collections/uikit

[[Go to the beta on GitHub]](https://github.com/pointfreeco/swiftui-navigation/discussions/168)

## What is UIKitNavigation?

UIKitNavigation is a new library that provides powerful state management and navigation tools for 
UIKit that are heavily inspired by the tools we have in SwiftUI. The library currently lives in
our [SwiftUINavigation][swiftu-nav-repo] package, but soon that package will be generalized and
renamed to simply SwiftNavigation, and it will house a variety of tools for all of Apple's 
platforms (SwiftUI, UIKit, AppKit, _etc._), as well as tools that can be used cross-platform. 

[swiftu-nav-repo]: https://github.com/pointfreeco/swiftui-navigation

## How do you use it?

The tools from the library broadly fall into 3 main categories:

* ### State observation

  SwiftUI makes use of the `@Observable` macro to allow one to encapsulate the logic and behavior of 
  a feature in a reference type, and the view will minimally observe changes to the model depending
  on what fields it accesses. It was clear from the beginning that Swift's observation tools were
  designed with primarily SwiftUI in mind, but that doesn't mean we can't make use of those tools in
  UIKit.
  
  The library provides a powerful state observation tool, aptly named [`observe`][observe-gh-code]. \
  It allows you to use the `@Observable` macro to power UIKit features. For example, if you \
  designed an observable model like so:
  
  [observe-gh-code]: https://github.com/pointfreeco/swiftui-navigation/blob/e9b13608a4f8ef1f094586ac77103531920862ab/Sources/UIKitNavigation/Observe.swift#L5-L111
  
  ```swift
  @Observable
  class FeatureModel {
    var count = 0
    var isLoadingFact = false
    var fact: String?
    …
  }
  ```
  
  …then in a view controller you can observe changes to the model and update the UI like so:
  
  ```swift
  func viewDidLoad() {
    super.viewDidLoad()
    
    let countLabel = …
    let activityIndicator = …
    let factLabel = …
    
    observe { [weak self] in
      guard let self else { return }
      
      countLabel.text = "\(model.count)"
      activityIndicator.isHidden = !model.isLoadingFact
      factLabel.isHidden = model.fact == nil
      factLabel.text = model.fact
  }
  ```
 
  We are omitting the creation and layout of the UI components because it is up to you how you want 
  to do that. You can either do it in code, or with a storyboard, or by using a 3rd party library. 
  But our library does not aim to try to solve this problem, and instead lets UIKit be UIKit. 
  
  The `observe` closure automatically observes changes to any field accessed, and when one of those
  fields is mutated the trailing closure will be invoked again, thus updating the UI with the 
  freshest data.
  
  And more importantly, if any field changes in the model that is _not_ accessed, then the trailing
  closure of `observe` will not be invoked. This means only the bare essentials of state will be
  observed, and you don't have to think about it at all. 

* ### 2-way bindings

  Bindings in SwiftUI are a powerful tool for allowing two independent features to share a bit of 
  state. They are so powerful that it is easy to take for granted these days, and to forget how
  difficult UI controls used to be in UIKit.
  
  In UIKit, controls by default hold onto their own "source of truth" for their value. For example,
  when you create a text field like so:
  
  ```swift
  let nameTextField = UITextField()
  ```
  
  …the value of `nameTextField.text` is the "true" value of the text field. It has no connection
  to anything outside the control. In order to "connect" the text field to something else, such as
  a feature's model, you need to use a `UIAction` to be notified of changes in the text field so
  that you can play them back to the model, _and_ you should listen for changes in the model so that
  you can play them back to the text field.
  
  It's honestly quite a mess to get right, and it has historically been the source of a great 
  number of bugs and spaghetti code in UIKit apps. And so SwiftUI greatly improved upon this, but
  that doesn't mean it wasn't possible to achieve in UIKit.
  
  To begin, you annotate your model with the [`@UIBindable`][uibindable-gh-code] property wrapper, \
  which is like `@Bindable` from SwiftUI but made to work with UIKit:
  
  [uibindable-gh-code]: https://github.com/pointfreeco/swiftui-navigation/blob/e9b13608a4f8ef1f094586ac77103531920862ab/Sources/SwiftNavigation/UIBindable.swift#L7-L47
  
  ```swift
  @UIBindable var model: FeatureModel
  ``` 
  
  And then you can derive binding to the model using the familiar `$` syntax:
  
  ```swift
  let nameTextField = UITextField(text: $model.name)
  ```
  
  That single line is packing a punch. Any changes made to the text field are played back to 
  `model.name`, and any changes to the model will be automatically played back to the text field.
  That makes the model the "source of truth", and you never have to worry about the UI getting 
  out of sync with the model.

* ### Navigation

  State-driven navigation is probably one of the most powerful concepts that SwiftUI introduced to
  developers on Apple's platforms. It allows you to write complex code in a concise and correct
  manner, it instantly unlocks deep-linking capabilities, and makes it possible to unit test 
  the integration of many features.
  
  However, and this is the 3rd time we are going to say this, there's no reason for this power
  to be relegated to SwiftUI alone. State-driven navigation can absolutely work in UIKit, and it's
  quite amazing.
  
  The UIKitNavigation library provides tools that mimic UIKit's `present` and `pushViewController`
  methods, but they are powered by bindings instead of being "fire-and-forget". For example, if
  your feature can navigate to a "detail" feature, then you could design that in your model layer
  as an optional: 
  
  ```swift
  @Observable 
  class FeatureModel {
    var detail: DetailModel?
    …
  }
  ```
  
  And then in the view you can use [`navigationDestination(item:)`][nav-destination-gh-code] in \
  order to drive the navigation from the optionality of `detail`:
  
  [nav-destination-gh-code]: https://github.com/pointfreeco/swiftui-navigation/blob/01d03e2a366a1323acfd912a15909f08b6558d3e/Sources/UIKitNavigation/Navigation/Presentation.swift#L310-L347
  
  ```swift
  navigationDestination(item: $model.detail) { detail in
    DetailViewController(model: detail) 
  }
  ```
  
  When `detail` becomes non-`nil` the trailing closure will be invoked causing the 
  `DetailViewController` to be created, and the drill-down will occur. Also, when `detail` 
  becomes `nil` the detail controller will automatically be popped off the stack.
  
  _Further_, if the user manually dismisses the detail, _e.g._ by tapping the "Back" button or
  swiping from the left edge of the screen, then `nil` will automatically be written to the
  `$model.detail` binding. That guarantees that the model and UI always state in sync.
  
  And if all of that wasn't amazing enough, we also have support for a state-driven
  `UINavigationController`, and it's called `NavigationStackController`. It allows you to control
  which features are pushed onto the stack and popped off of the stack from a flat array of data.
  We even have support for `UINavigationPath`, a type-erased list of data, for powering navigation,
  which gives you maximum flexibility and decoupling in your apps.  
  
So, all of that seems pretty great, but things get even better. The `@Observable` macro is 
unfortunately iOS 17+, and all of the tools mentioned above heavily rely on the observation 
machinery in Swift. However, we previously have back-ported Observation in our 
[swift-perception][perception-gh] library, and that means all of these tools are available as
far back as iOS 13! And so you can start using them _today_.

[perception-gh]: http://github.com/pointfreeco/swift-perception

## A cross-platform dream

And let's not miss the forest from the trees.

While the library we have developed primarily deals with UIKit, there is something a lot more 
interesting happening behind the scenes. The foundational tools built by the library, such as 
`observe`, `@UIBinding` and `@UIBindable`, are all built in 100% pure Swift. That means these tools
compile for Linux, Windows, Wasm, and more, and so theoretically they could be used to build
state management and navigation tools for non-Apple platforms.

It is possible for you to implement the logic and behavior of your features using pure Swift code
and Swift's Observation framework without a care in the world for how the feature will actually
be displayed. This has the added benefit of allowing you to fully concentrate on your business
domain without being sidetracked by view-level concerns.

And then when you are ready to build the view you can do so with the powerful tools of our library
regardless of view paradigm (SwiftUI vs UIKit) or platform (Apple vs Windows vs Linux vs …). Things
can make your features more isolatable and easier to understand, and brings you one step closer
to a cross-platform application.

## How did you accomplish this?

This is the topic of our newest series of episodes, [Modern UIKit][modern-uikit-collection]. The
tools are largely powered by Swift's amazing Observation framework, but there is a lot of additional
work that must be done to make it all work correctly. Follow along in the series to learn about 
advanced Swift topics (existentials, sendability, …), receive a masterclass in API design and 
ergonomics, watch us build SwiftUI's `@Binding` _from scratch_, and a lot more. 

[modern-uikit-collection]: /collections/uikit

## Try out the beta today and give feedback!

And unbelievably, we have barely scratched the surface of what the library provides and what is in
store for the future. Be sure to [check out the beta][beta-gh-discussion] today, and please give
feedback by [opening a GitHub discussion][swift-nav-discussions].

[beta-gh-discussion]: https://github.com/pointfreeco/swiftui-navigation/discussions/168
[swift-nav-discussions]: https://github.com/pointfreeco/swiftui-navigation/discussions
