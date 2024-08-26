Ever since Swift was open sourced in 2015 it has been possible to deploy Swift on non-Apple 
platforms, though it was mostly restricted to just Linux. Even this very site was built in Swift 
from the first day it launched in 2018 (and 
[open-sourced!](http://github.com/pointfreeco/pointfreeco)). 

Over the years the developer experience for building server-side applications in Swift has greatly
improved, thanks to a combination of effort from Apple and the greater Swift community. However,
it wasn't until relatively recently that building Swift apps for non-Apple and non-Linux platforms
has become more of a possibility.

Thanks to herculean effects of
[Saleem Abdulrasool](https://github.com/compnerd) (and 
[the Browser Company](http://thebrowser.company)),
[Max Desiatov](https://github.com/MaxDesiatov),
[@yonihemi](https://github.com/yonihemi),
[Yuta Saito](https://github.com/kateinoigakukun),
[Carson Katri](https://github.com/carson-katri), and many others, Swift can now be 
[deployed on Windows](https://www.swift.org/blog/swift-on-windows/) and 
[WebAssembly](https://github.com/swiftwasm/). And each year there are more platforms being explored,
such as [embedded Swift](https://www.swift.org/blog/embedded-swift-examples/).

However, we aren't going to sugar coat things. Building Swift applications for non-Apple platforms
can be quite difficult. The tools are not as polished as they are for Apple's platforms, most 
frameworks that we know and love are not available (e.g. SwiftUI 😢), and it takes significant
work to prepare an app for sharing code across multiple platforms.

That is the topic of the 
[new series of episodes](https://www.pointfree.co/collections/cross-platform-swift) we have just
started, but in this blog post we want to describe the very basics of getting a simple Swift app
running on a non-Apple platform, in particular in a browser.

## WebAssembly

We are going to use [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly), and in particular the
[SwiftWasm](https://github.com/swiftwasm/) project, to compile a Swift project for the web and run 
it in the browser. WebAssembly is a binary format that can be embedded directly in a web browser, 
and other platforms, that allows one to run any language in the browser, not just JavaScript. 
Many languages support Wasm, including Python, Ruby, Rust, and C++, and even Swift has experimental 
support for Wasm. 


We'll start by creating
a new Swift executable in a package and opening it in Xcode: 

> Important: In order to run the code in this article you must be on **beta 4** of Xcode 16. The 
version of Swift that shipped in newer versions of Xcode unfortunately have a bug that needs to be 
[fixed](https://github.com/swiftlang/swift/pull/75902).

```
mkdir WasmCounter
cd WasmCounter
swift package init --type executable 
open Package.swift
```

Next we will add some dependencies to the Package.swift of this package. In order to build a Wasm 
application we will use the [carton](http://github.com/swiftwasm/carton) plugin from the
[SwiftWasm](http://github.com/swiftwasm) organization: 

```swift
dependencies: [
  .package(url: "https://github.com/swiftwasm/carton", from: "1.0.0")
],
```

`carton` is a Swift plugin that can be run from the command line. But, before we can do that we must
use a very specific snapshot of the Swift compiler. We can't use the one that is included with 
Xcode.

Luckily `carton` makes this very easy to manage. Simply create a `.swift-version` file at the root
of the package that describes the snapshot we want to use. The latest one we have found that works
well is the following: 

```
wasm-DEVELOPMENT-SNAPSHOT-2024-07-16-a
```

…but there may be other snapshots that work too.

With that done, we can run `carton` from the command line:

```
swift run carton dev
```

…and then `carton` will download and install the Swift snapshot, compile your executable, and
automatically open a browser with the executable running. And it may not seem like much, but there
is in fact a Swift executable running in the browser. In fact, if you open your browsers developer
console (cmd+option+I in Safari), then you will see that "Hello, world!" is printed, and that's 
because the executable currently prints that message:

```swift
// The Swift Programming Language
// https://docs.swift.org/swift-book

print("Hello, world!")
``` 

So, Swift is indeed running in the browser, but there isn't much functionality… yet. 

## A cross-platform counter feature

Let's build a tiny Swift feature that can run in the browser, but that can also run on Apple's
platforms such as iOS. The feature will need to be pure Swift and it can't use any
Apple-specific frameworks (no SwiftUI or UIKit). Luckily Swift comes with a powerful observation
framework that is built in pure Swift, and so is instantly available on all platforms supported
by Swift.

So, let's create a simple `CounterModel` feature that holds onto an integer and exposes some 
methods for incrementing and decrementing the count. And further, we will mark the class as 
`@MainActor` to make it safe to use concurrently, and we will mark it with the `@Observable`
macro to make it possible to observe changes to the `count` state: 

```swift
import Observation 

@MainActor
@Observable
class CounterModel {
  var count = 0
  func decrementButtonTapped() {
    count -= 1 
  }
  func incrementButtonTapped() {
    count += 1 
  }
}
```

This is 100% pure Swift code and can compile on _any_ platform that Swift supports, including
Linux, Windows, Wasm, and more. And now we would like to build out the HTML view that actually
implements this model.

## JavaScriptKit

WebAssembly does get direct access to the Document Object Model (DOM) in the browser for adding
and removing HTML nodes in the view. One must go through JavaScript to do this, and there is an
additional library from the SwiftWasm organization to make this easier, called 
[JavaScriptKit](https://github.com/swiftwasm/javascriptkit).

So, let's add that to the Package.swift file:

```swift:3
dependencies: [
  .package(url: "https://github.com/swiftwasm/carton", from: "1.0.0"),
  .package(url: "https://github.com/swiftwasm/javascriptkit", exact: "0.19.2")
],
```

> Important: You must depend on exactly version 0.19.2 of JavaScriptKit to work around some 
compilation issues.

Next we will add the JavaScriptKit and JavaScriptEventLoop products to our WasmCounter executable
so that we can access those libraries:

```swift:3-5
.executableTarget(
  name: "WasmCounter",
  dependencies: [
    .product(name: "JavaScriptKit", package: "javascriptkit"),
  ]
),
```

Now we can write some Swift code that will generate DOM elements for display in the browser. To
do this we will use the JavaScriptKit library:

```swift
import JavaScriptKit
```

The JavaScriptKit library allows you to write Swift code that secretly calls invokes JavaScript
in the browser. For example, in JavaScript one can create a DOM element to hold the count value
and append it to the document's body like so: 

```javascript
let countLabel = document.createElement("div")
countLabel.innerText = "Count: 0"
document.body.appendChild(countLabel)
```

It's simple enough, but also at the end of the day we don't want to write JavaScript. Since we 
want to reuse Swift code across platforms we want to keep as much of our code in Swift as possible.
And this is where JavaScriptKit comes into play.

Thanks to a novel use of the 
[string-based dynamic member lookup](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0195-dynamic-member-lookup.md),
JavaScriptKit allows us to write Swift code that looks very similar to JavaScript, and invokes 
actual JavaScript APIs under the hood:

```javascript
let document = JSObject.global.document

var countLabel = document.createElement("div")
countLabel.innerText = "Count: 0"
_ = document.body.appendChild(countLabel)
```

With that little bit of code written you can refresh the browser to see "Count: 0" showing. This 
means that our Swift code is running in the browser _and_ manipulating the DOM.

Next we will create and custom a button that when clicked invokes the `decrementButtonTapped`
method on the model:

```swift
let model = CounterModel()

var decrementButton = document.createElement("button")
decrementButton.innerText = "-"
decrementButton.onclick = .object(
  JSClosure { _ in
    model.decrementButtonTapped()
    return .undefined
  }
)
_ = document.body.appendChild(decrementButton)
```

And we will do the same for the increment button:

```swift
var incrementButton = document.createElement("button")
incrementButton.innerText = "+"
incrementButton.onclick = .object(
  JSClosure { _ in
    model.incrementButtonTapped()
    return .undefined
  }
)
_ = document.body.appendChild(incrementButton)
```

And with that little bit of work done we now have a rudimentary view implemented in the browser:

![](https://pointfreeco-blog.s3.amazonaws.com/posts/0151-cross-platform/wasm-counter-static.png)

It isn't the prettiest view in the world, but it gets the job done, and of course it's possible
to put in extra work to make it look better. And it's worth mentioning that the work it takes
to build this HTML view isn't much different from the work it takes to build the equivalent
UIKit view:

```swift
let countLabel = UILabel()
view.addSubview(countLabel)

let decrementButton = UIButton(type: .system, primaryAction: UIAction { _ in
  model.decrementButtonTapped() 
})
decrementButton.setTitle("-", for: .normal)
view.addSubview(decrementButton)

let incrementButton = UIButton(type: .system, primaryAction: UIAction { _ in
  model.incrementButtonTapped() 
})
incrementButton.setTitle("+", for: .normal)
view.addSubview(incrementButton)
```

This shows that one could approach building a Swift app in the browser much like one would approach
building a UIKit app on iOS. It of course would take more work to be able to build HTML views in a 
style similar to SwiftUI, but it is technically possible with some hard work.

## Updating the DOM when the model changes

We now have a basic view displayed in the browser, but there's no behavior. Clicking on the "-" and
"+" button doesn't cause the count label to update. To implement this functionality we need to
make use of Swift's powerful observation tools.

Unfortunately, the tools in the Observation framework are quite barebones right now. It takes a 
little extra work to make them usable outside of SwiftUI, and that is where our powerful
[Swift Navigation](http://github.com/pointfreeco/swift-navigation) library comes into play. It 
provides a suite of tools that can be used to power any Swift application, even ones being deployed
on non-Apple platforms.

So, let's add a dependence on Swift Navigation in the Package.swift:

```swift:4
dependencies: [
  .package(url: "https://github.com/swiftwasm/carton", from: "1.0.0"),
  .package(url: "https://github.com/swiftwasm/javascriptkit", exact: "0.19.2"),
  .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.1.0"),
],
```

…and add the SwiftNavigation produce to the WasmCounter executable:

```swift:6
.executableTarget(
  name: "WasmCounter",
  dependencies: [
    .product(name: "JavaScriptEventLoop", package: "javascriptkit"),
    .product(name: "JavaScriptKit", package: "javascriptkit"),
    .product(name: "SwiftNavigation", package: "swift-navigation"),
  ]
),
```

Now we can import Swift Navigation:

```swift
import SwiftNavigation
```

…and make use of its most powerful tool, `observe`:

```swift
observe {

}
```

This tool automatically tracks changes to any field accessed from an observable model. When it
detects a change, the trailing closure is immediately invoked again, giving us the chance to update
the UI with the freshest state. 

And so all we have to do is update the `countLabel`'s `innerText` to display the freshest `count`
from the model: 

```swift:2
observe {
  countLabel.innerText = .string("Count: \(model.count)")
}
```

However, there are two things to be mindful of with this code. First, to keep the observation alive
we must store the token that is returned from `observe`:

```swift:1,5
var tokens: Set<ObserveToken> = []
observe {
  countLabel.innerText = .string("Count: \(model.count)")
}
.store(in: &tokens)
```

And second, in order for us to be able to continue executing logic after the last line of this
file has finished executing we need to install a run loop in the executable: 

```swift
JavaScriptEventLoop.installGlobalExecutor()
```

This line should be the very first thing executed in this file. And with that done we now have a 
dynamic counter running in a browser that is powered by 100% pure Swift code"

![](https://pointfreeco-blog.s3.amazonaws.com/posts/0151-cross-platform/wasm-counter.mov)

It is absolutely incredible to see!

## Swift Navigation 2.2

The primary reason it was so easy to use the `CounterModel` observable class in a WebAssembly
app is thanks to the `observe` function that comes with our Swift Navigation library. It provides
many foundational tools that can be used in _any_ Swift app deployed to _any_ platform. But it
also provides specific tools for SwiftUI, UIKit, and starting today with the 2.1 release, we are
now providing some rudimentary tools for AppKit.

The `observe` tool now works on macOS, and further it has been integrated with AppKit's animation
APIs.

## Explore cross-platform Swift today

We hope that you have found the prospects of cross-platform Swift as exciting as we have! If you
want to learn more, then be sure to check out our 
[new series of episodes](https://www.pointfree.co/collections/cross-platform-swift) that covers more 
advanced topics, such as networking, dependencies, navigation, bindings, and a lot more.
