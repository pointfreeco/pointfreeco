This week we are giving a [sneak peek][modern-uikit-collection] into what our next major series of 
episodes will be on [Point-Free][pf], and it's free for everyone to watch! We will be discussing
how to build modern UIKit features, with an eye on domain modeling, bindings, and navigation!

[pf]: http://pointfree.co
[modern-uikit-collection]: todo

[[Watch now!]](todo)

### Why UIKit?

It may seem a little strange for us to devote time to "modern UIKit". After all, isn't SwiftUI
all the rage? Well, as much as we want our apps to be 100% SwiftUI, there are going to be times
we need to drop down to UIKit. It could be due to lack of functionality in SwiftUI, or perhaps
certain tools in UIKit are more performant (`UICollectionView` 👀).

And so once you have started writing your first `UIViewController` subclass in ages, the question
becomes: what is the most modern way to do this? SwiftUI completely revolutionized how we think
about building apps for Apple's platform, but its powers can be broken down into roughly two 
categories:

* SwiftUI provides a lightweight way to build view heirarchies using value types,
* and SwiftUI provides powerful state management tools that keep models in sync with what is 
visually on screen.

The former is not something we will be discussing. There are libraries out there that aim to
provide a nice interface to UIKit components, but we are going to let UIKit be UIKit when it comes
to building interfaces.

However, the latter, in particular state management, _can_ be completely revolutionized when it
comes to UIKit. 


### What is modern UIKit?

[pf]: http://pointfree.co
[modern-uikit-collection]: todo
