The year's biggest Apple event is here, and to celebrate we are offering a 25% discount off the
first year for first-time subscribers. Click [here](/discounts/wwdc-2023) to redeem the coupon now. 
The offer will only remain valid until June 12th.

@Button(/discounts/wwdc-2023) {
  Subscribe for 25% off!
}

This is the perfect time to get full access to our videos, including these very popular series:

### [**Modern SwiftUI**][modern-swiftui]

One of our [most popular series ever][modern-swiftui]. We build a complex application with many 
forms of navigation, complex side effects (timers, speech recognizers, data persistence), using 
modern techniques, and with a focus on parent-child communication and testability.

[modern-swiftui]: /collections/swiftui/modern-swiftui 

### [**Swift Concurrency: Past, Present, Future**][concurrency]

While WWDC 2023 isn't expected to release any huge, game changing additions to Swift's concurrency 
tools, there is no time like the present to [become intimately familiar with the 
concepts][concurrency]. We devoted a 5-part series covering concurrency in Swift from the past 
(threads), through the present (dispatch queues and Combine), and into the future (cooperative 
concurrency, actors and structured concurrency). 

We also discuss an advanced and often overlooked aspect of concurrency, which is time-based
asynchrony using Swift's new [`Clock`][clock-docs] protocol. We dive deep into the protocol 
definition, we write custom implementations of the protocol, and we show how to take control over
time.

[concurrency]: /collections/concurrency
[clock-docs]: https://developer.apple.com/documentation/swift/clock 

### [**SwiftUI Navigation**][swiftui-nav]

Late last year we finished a long series of episodes covering every aspect of [navigation in 
SwiftUI][swiftui-nav]. We provided a broad definition of navigation, and showed that many things 
fall under this definition, including alerts, sheets, popovers, drill-downs and more. This allowed 
us to unify many seemingly disparate forms of navigation under a single, concise API.

We also explored some of iOS 16's newer forms of navigation, such as the 
[`navigationDestination(isPresented:)`][nav-dest-docs] view modifier that makes it possible to 
decouple a parent and child feature, as well as the powerful new 
[`NavigationStack`][nav-stack-docs] that helps fully decouple all sibling features that want to be
presented onto a stack.

[swiftui-nav]: /collections/swiftui/navigation
[nav-dest-docs]: https://developer.apple.com/documentation/swiftui/view/navigationdestination(ispresented:destination:)
[nav-stack-docs]: https://developer.apple.com/documentation/swiftui/navigationstack/

### [**Composable Architecture Navigation**][tca-nav]

And last, but not least, our most recently finished series (and most ambitious) [builds all new
navigation tools][tca-nav], from scratch, for the [Composable Architecture][tca-gh]. We were able
to unify all forms of navigation, from alerts and sheets to drill-downs and stacks, under a few
very simple APIs. We also improved the correctness and power of these tools by making sure that
child features' effects are automatically cancelled when a child feature is dismissed, and we
even provided a lightweight way for child features to dismiss themselves without communicating 
with the parent.

And on top of this, everything remained [100% testable][tca-nav-testing]. You can write deep and 
nuanced tests for how parent and child features interact with each other, and be confident that 
complex navigation flows work as you expect.  

[tca-nav]: /collections/composable-architecture/navigation
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture   
[tca-nav-testing]: /episodes/ep237-composable-stacks-testing

## Subscribe today

And that is just barely scratching the surface of what we offer on [Point-Free](/). We hope you'll 
[join us](/discounts/wwdc-2023) for all of the great material we have planned for the rest of the 
year!

@Button(/discounts/wwdc-2023) {
  Subscribe for 25% off!
}
