After more than 3 years of development, 145 contributors, and 983 closed pull requests, the
[Composable Architecture][tca-gh] has finally reached 1.0! 🎉

The library has been quite stable since its inception, but we weren't ready to put the "1.0" label 
on it until we released its [navigation tools][nav-tools-blog], which happened just a few weeks ago.
If you want to get started with the library today you have two options:

* This week are beginning to release a [brand series of episodes][1.0-tour] to tour the 1.0 library.
The first episodes build a simple application from scratch to demonstrate how to implement your
first feature, execute side effects, control dependencies, and write a full test suite.

  Next week the tour continues by rebuilding Apple's [Scrumdinger][scrumdinger] from scratch, using
the Composable Architecture. This involves composing together many isolated features, exploring
navigation patterns, dealing with complex side-effects, and writing tests to exercise all of the
subtle and nuanced logic in the application.

* The documentation has a [full tutorial][tutorial] that explores all of the fundamentals of 
building a feature in the Composable Architecture. This includes implementing the core logic and
behavior of your features with reducers, controlling dependencies, writing tests, and using the 
library's navigation tools.

## Upgrading to 1.0

In tandem with the 1.0 release we are also releasing [0.57.0][0.57.0-release], which will be the
last 0.x release in the library. It is a backwards compatible release that hard deprecates 
everything that is removed in 1.0. This provides you a soft landing for upgrading your projects. We 
recommend you first upgrade to 0.57.0, fix all deprecation warnings, and _then_ upgrade to 1.0
and fix any compiler errors for incompatible changes we made to the library.

## The future

This is only the beginning for the Composable Architecture. We have [big plans][tca-edge-tweets]
to implement all the new features of Swift 5.9 and iOS 17 into the library, such as the new 
`Observable` protocol and macros. These tools will fundamentally change the ergnomics and power of
the library, but as always we will aim to make these additions as backwards compatible as possible.

## Update today

If you use the Composable Architecture, then we highly recommend upgrading to 1.0 as soon as 
possible. And if you do not use the Composable Architecture, then there's no time like the 
present. 🥳

[0.57.0-release]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.57.0
[tca-edge-tweets]: https://twitter.com/pointfreeco/status/1669790670385721344
[tutorial]: https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/meetcomposablearchitecture
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[0.1-release]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.1.0
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture
[1.0-tour]: http://pointfree.co/collections/tours/composable-architecture-1-0
[nav-tools-blog]: http://pointfree.co/blog/posts/106-navigation-tools-come-to-the-composable-architecture
