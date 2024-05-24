This week we are giving a [sneak peek][modern-uikit-collection] into what our next major series of 
episodes will be on [Point-Free][pf], and it's free for everyone to watch! We will be discussing
how to build modern UIKit features, with an eye on domain modeling, bindings, and navigation!

[pf]: http://pointfree.co
[modern-uikit-collection]: todo

[[Watch now!]](todo)

### Why UIKit??

It may seem a little strange for us to devote time to "modern UIKit". After all, isn't SwiftUI
all the rage? Well, as much as we want our apps to be 100% SwiftUI, there are going to be times
we need to drop down to UIKit. It could be due to lack of functionality in SwiftUI, or perhaps
certain tools in UIKit are more performant (`UICollectionView` 👀).

And so once you have started writing your first `UIViewController` subclass in ages, the question
becomes: what is the most modern way to do it? SwiftUI completely revolutionized how we think
about building apps for Apple's platform, but its powers can be broken down into roughly two 
categories:

* SwiftUI provides a lightweight way to build view heirarchies using value types,
* and SwiftUI provides powerful state management tools that keep models in sync with what is 
visually on screen.

The former is not something we will be discussing. There are libraries out there that aim to
provide a nice interface to UIKit components, but we are going to let UIKit be UIKit when it comes
to building interfaces.

However, the latter, in particular state management, _can_ be completely revolutionized when it
comes to UIKit. Thanks to Swift's powerful new observation tools we can bind models to UIKit
controllers and views in a very succinct syntax. And we can even drive navigation from state
using APIs that look similar to SwiftUI.

It is actually pretty incredible to see!

### What is modern UIKit?

In our series, "modern UIKit" refers to the style of building UIKit apps with concise and powerful
state management tools inspired by SwiftUI. In SwiftUI, one can model the domain of their feature
in an observable object like so:

```swift
@Observable
class CounterFeature {
  var count = 0
  var fact: Fact?
  var isLoadingFact = false
}
```

…and then construct a simple view hierarchy that accesses whatever state from the model is needed: 

```swift
Form {
  Text("\(model.count)")
  Button("Increment") { model.count += 1 }
  Button("Decrement") { model.count -= 1 }
  if model.isLoadingFact {
    ProgressView()
  }
}
.disabled(model.isLoadingFact)
.sheet(item: $model.fact) { fact in
  Text(fact.value) 
}
```

…and SwiftUI has the awesome ability to observe the minimal amount of state for the view (i.e.
only the fields accessed on `model`), _and_ drive navigation from state (i.e. sheet is presented 
when `fact` is non-`nil` and dismissed when `nil`).

What if we had the ability to minimally observe the model in UIKit in order to update UI controls?
And what if we could drive the presentation of view controllers purely from state? What if we could
do all of this in a short, concise syntax like this:

```swift
func viewDidLoad() {
  super.viewDidLoad()
  
  // Set up view hierarchy

  observe { [weak self] in
    guard let self else { return }
    
     countLabel.text = "\(model.count)"
     decrementButton.isEnabled = !model.isLoadingFact
     incrementButton.isEnabled = !model.isLoadingFact
     activityIndicator.isHidden = !model.isLoadingFact 
  }

  present(item: $model.fact) { fact in
    FactViewController(fact: fact) 
  }
}
```

This is absolutely possible, and _this_ is what we call modern UIKit.

### Don't miss the forest from the trees

While we are primarily talking about UIKit in this series, don't miss an opportunity to read 
between the lines. In this series we are _really_ showing how one can build the logic and behavior
of their app without ever thinking about view-related concerns. Your first priority in building
your app should be in concisely modeling your domain.

With that done you can let the view _flow_ from the domain. Then it doesn't matter what view 
paradigm you use. You are free to use your models in either UIKit or SwiftUI because none of the
view-specific concepts infiltrated your domain.

But even more interesting, you are also free to your domain models in other _platforms_. Cross
platform Swift is becoming more popular these days, with efforts to bring Swift applications to
Windows, Linux, and even the web using Wasm. Our explorations into modern UIKit development are
a mere shadow of what is possible when porting an application to other platforms. 

### Start learning about modern UIKit today!

There's no better time to learn about [modern UIKit](todo). We will show how a few simple tools built on
Swift's Observation framework allows one to model domains concisely and describe complex 
navigation patterns in just a few lines of code.

[pf]: http://pointfree.co
[modern-uikit-collection]: todo

[[Watch now!]](todo)
