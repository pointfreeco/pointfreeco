Swift 5.9 brought powerful observation tools to the language, but unfortunately they only work in
iOS 17, macOS 14, tvOS 17, watchOS 10 and newer. But by some accounts, less than 50% of devices are
on iOS 17, and so most developers will not be able to make use of the tools for a few more years.

So, we have back-ported the observation tools to work on Apple's platforms going all the way back
to iOS 13, macOS 10.15, tvOS 13, watchOS 6, and we've released it as an 
[open-source library][perception-gh]. This means you can massively simplify your SwiftUI views 
_today_ by using our library. You just have to do a few things first.

Join us for a quick overview of our new library: [Perception][perception-gh].

## Using Perception

The library provides its own version of the observation tools from Swift 5.9, but they can be used 
on older Apple platforms. When designing your models, instead of using the `@Observable` macro,
you will use our `@Perceptible` macro:

```diff
+import Perception

-@Observable
+@Perceptible
 class FeatureModel {
   var count = 0
 }
```

That is all it takes for the `FeatureModel` class to track accesses to its properties and to 
broadcast when those properties are mutated.

This model can be used in a SwiftUI view, but there is one additional step that must be taken to 
guarantee that the view subscribes to the model's changes. We must wrap the view in a special
view called `WithPerceptionTracking`:

```diff
 struct FeatureView: View {
   let model: FeatureModel 
   
   var body: some View {
+    WithPerceptionTracking {
       Form {
         Text(model.count.description)
         Button("Increment") {
           model.count += 1
         }
       } 
     }
+  }
 }
```

On the one hand it's unfortunate that we have to wrap our view in this, but on the other hand it's
fantastic that we can use these observation tools _today_ without waiting for iOS 17 to have 
mass adoption.

And the library will help you out if you forget to use `WithPerceptionTracking`. If a field of a 
`@Perceptible` class is accessed in a view while _not_ inside `WithPerceptionTracking`, then a 
runtime warning will be triggered:

> 🟣 Runtime Warning: Perceptible state was accessed but is not being tracked. Track changes to 
state by wrapping your view in a 'WithPerceptionTracking' view.

This lets you instantly know when something is not set up correctly, and do so in a noticeable
yet [unobstrusive][unobstrusive-warnings] way. To debug this, expand the warning in the Issue 
Navigator of Xcode (cmd+5), and click through the stack frames displayed to find the line in your 
view where you are accessing state without being inside `WithPerceptionTracking`.

## How the Perception library works

The new Observation framework is a part of the Swift open source project, which means all of the 
[source code][observation-library-gh] is immediately available, including the 
[source for the @Observable macro][observation-macros-gh]. So, we were able to copy all of that
code to a new project, and with a few small changes we were able to get it all compiling.

We also made some major changes to the code to have it behave the way we wanted. The first major 
change we made to the code was to rename all variations of "observation" to 
"perception" (e.g. `@Observable` becomes `@Perceptible`). We did this so to make it clear that these
are tools separate from the ones that Apple ships directly in the Swift tool chain. But we also
[deprecated][percetible-deprecation-gh] all of the back-ported tools with renames so that once you
can set your minimum deployment target to iOS 17 you will have an easy way to transition off of 
our library.

Further, we wanted our tools to be able to defer to Apple's native Observation framework when 
running on an iOS 17 device. This took a bit of extra work at runtime. All of the work takes place 
in the `PerceptionRegistrar`, which wraps either a native `ObservationRegistrar` when possible, and 
if not possible it falls back to our back-port, the `_PerceptionRegistrar`:

```swift
public struct PerceptionRegistrar: Sendable {
  private let _rawValue: AnySendable
  public init() {
    if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
      #if canImport(Observation)
        self._rawValue = AnySendable(ObservationRegistrar())
      #else
        self._rawValue = AnySendable(_PerceptionRegistrar())
      #endif
    } else {
      self._rawValue = AnySendable(_PerceptionRegistrar())
    }
  }
}
```

And we expose ways to get the honest, unwrapped `ObservationRegistrar` or `_PerceptionRegistrar`
from this type:

```swift
extension PerceptionRegistrar {
  #if canImport(Observation)
    @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
    private var registrar: ObservationRegistrar {
      self._rawValue.base as! ObservationRegistrar
    }
  #endif

  private var perceptionRegistrar: _PerceptionRegistrar {
    self._rawValue.base as! _PerceptionRegistrar
  }
}
```

Note that this properties are technically unsafe since we are force casting. But we can be careful
to only invoke the properties when the underlying wrapped value is of the type of registrar we
expect.

Then we need to implement the `access`, `willSet`, `didSet` and `withMutation` methods on 
`PerceptionRegistrar`, and do so in a way that can dynamically, at runtime, choose to invoke our
back-ported tools or Apple's native tools. 

For example, `access` can be implemented as a method constrained to work with the back-ported 
`Perceptible` types rather than `Observable` types:

```swift
extension PerceptionRegistrar {
  public func access<Subject: Perceptible, Member>(
    _ subject: Subject,
    keyPath: KeyPath<Subject, Member>
  ) {
    …
  }
}
```

Then in the body of this method we can dynamically check if iOS 17 is available, and if so try
casting the object to the `Observable` protocol, as well as do some fancy manuevers to open
the existential and cast the key path to the right type:

```swift
extension PerceptionRegistrar {
  @_disfavoredOverload
  public func access<Subject: Perceptible, Member>(
    _ subject: Subject,
    keyPath: KeyPath<Subject, Member>
  ) {
    #if canImport(Observation)
      if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
        func `open`<T: Observable>(_ subject: T) {
          self.registrar.access(
            subject,
            keyPath: unsafeDowncast(keyPath, to: KeyPath<T, Member>.self)
          )
        }
        if let subject = subject as? any Observable {
          open(subject)
        }
      } else {
        perceptionCheck()
        self.perceptionRegistrar.access(subject, keyPath: keyPath)
      }
    #endif
  }
}
```

And similar tricks can be employed for the `willSet`, `didSet` and `withMutation` methods.

Those little tricks allow iOS 16 and earlier devices to use our perception framework, but iOS 17
and new devices will use the native observation tools in Swift 5.9.

## Get started today

Try out the [Perception][perception-gh] in your project today to start making use of Swift's 
amazing observation tools, even if you can't target the newest Apple platforms.

[perception-gh]: http://github.com/pointfreeco/swift-perception
[unobstrusive-warnings]: https://www.pointfree.co/blog/posts/70-unobtrusive-runtime-warnings-for-libraries
[observation-library-gh]: https://github.com/apple/swift/tree/f7f5070454850ed6bda85a9574b1759115705da4/stdlib/public/Observation
[observation-macros-gh]: https://github.com/apple/swift/tree/f7f5070454850ed6bda85a9574b1759115705da4/lib/Macros/Sources/ObservationMacros
[lock-gh]: https://github.com/apple/swift/blob/f7f5070454850ed6bda85a9574b1759115705da4/stdlib/public/Observation/Sources/Observation/Locking.cpp
[thread-local-gh]: https://github.com/apple/swift/blob/f7f5070454850ed6bda85a9574b1759115705da4/stdlib/public/Observation/Sources/Observation/ThreadLocal.cpp
[percetible-deprecation-gh]: https://github.com/pointfreeco/swift-perception/blob/92858a542c498742d51c1e736591d91a807d65a7/Sources/Perception/Perceptible.swift#L19-L23
