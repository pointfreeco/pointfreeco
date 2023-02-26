import Foundation

public let post0080_TCAPerformance = BlogPost(
  author: .pointfree,
  blurb: """
    The latest release of the Composable Architecture brings a number of performance improvements to its tools, and best of all, most of the changes came from collaboration with people in the TCA community! 🤗
    """,
  contentBlocks: [
    .init(
      content: ###"""
        We are always looking for ways to improve the performance of our [Composable Architecture][tca-gh], and spurred by some fascinating recent [discussions][performance-gh-discussion], we spent most of last week looking for performance wins in the library. This has all culminated in a new release, [0.40.0][0_40_0], which brings a number of improvements to the library, and best of all, most of the changes came from collaboration with people in the community! 🤗

        ## ForEachStore performance

        The [`ForEachStore`][foreachstore-docs] type is a SwiftUI view that allows you to easily derive the behavior of a single row in a list from a domain that holds a collection of state. For example, the voice memos demo application uses this to allow [each row of a list][voice-memos-foreachstore-gh] of recorded memos to encapsulate their own logic, including playback of audio and a timer. It is an incredibly powerful tool.

        Unfortunately, it also had a performance gotcha. Under the hood it was checking for equality between two collections of data in order to skip unnecessary view recomputations. We did this by checking for equality of the elements' ids because we know that all of the elements conform to `Identifiable`. However, when those collections get big, it can start to take significant time to check for equality.

        Luckily there is a better way. [Thomas Grapperon][tgrapperon-twitter] realized that because the ids of the collections are stored in an `OrderedSet`, which has copy-on-write semantics, we could [compare the sets of ids as raw memory][memcmp-foreachstore-pr] using `memcmp`, which is a near-instant operation. Only if the `memcmp` check fails, which is in the minority of times, will we need to actually check each individual element. This will instantly give all uses of `ForEachStore` a massive performance boost.

        ## Effect performance

        We [recently][async-tca-blog] brought all new concurrency tools to the Composable Architecture, and soft-deprecated all uses of Combine. However, under the hood, the library would still convert all async effects to Combine publishers so that they could be run in the same way as non-async effects. This is problematic due to the fact that Combine requires erasing type information at each layer of the application, which can cause effects to be inefficient and can prevent us from employing certain optimizations at runtime.

        To fight this, we [merged][effect-internals-pr] a change to the library that retains more of the async effect information at runtime so that we can perform optimizations. This includes discarding `Effect.none` values when we encounter them so that they don't bloat the effect, and using `TaskGroup`s to run many effects in parallel instead of leveraging Combine's `merge` operator.

        This massively simplifies async effects that don't need to incur the baggage of Combine, and leads to noticeable speed improvements in starting the effect and when the effect emits a value.

        ## Store scoping performance

        The [`scope`][scope-docs] method defined on [`Store`][store-docs] is a powerful operator that allows you to derive a store of child behavior from a store of parent behavior. It's critical for breaking down large applications into smaller pieces, and modularization.

        A longstanding performance characteristic of the Composable Architecture is that each nested call to `Store.scope` introduces a linear performance cost for the scoped reducer. The deeper the scope, the longer it takes for the system to process actions as a stack of stores must communicate up and down along the chain.

        [Pat Brown][pat-brown-gh] figured out that the communication through the stack was more inefficient than necessary. He [showed][store-scoping-pr] how scoped stores can ultimately hold a type-erased reference to the root store, making scopes a one-time cost so that nested scoping no longer incurs an additional performance penalty.

        ## WithViewStore performance

        The `WithViewStore` SwiftUI view is a convenient tool for observing state in a lightweight way:

        ```swift
        struct FeatureView: View {
          let store: Store<FeatureState, FeatureAction>

          var body: some View {
            WithViewStore(self.store) { viewStore in
              // View will recompute whenever store's state changes
            }
          }
        }
        ```

        Up until 0.40.0, `WithViewStore` used an `@ObservedObject` under the hood. This means that whenever the parent of `FeatureView` needs to recompute its body, it will force `FeatureView` to recreate the observable object, resubscribe to publisher of state changes, and recompute `==` on `FeatureState`. None of this work needs to be performed again after the first time, and so can lead to degraded performance.

        The [fix][withviewstore-stateobject-pr] is to make `WithViewStore` use a `@StateObject` under the hood instead of a `@ObservedObject`. Unfortunately we still needed to maintain iOS 13 compatibility, and so [Thomas Grapperon][tgrapperon-twitter] [contributed][ios13-stateobject-pr] a slim backport of state objects to work with iOS 13.

        The results can be quite substantial, causing the number of view stores being created and subscribed to plummet.

        ## WithViewStore correctness

        While the above performance improvements to the library essentially come for "free" once you update to [0.40.0][0_40_0], we have also made changes to nudge you towards a more efficient way of using the existing tools.

        The `WithViewStore` view is a convenient and lightweight tool that allows you to tune the performance of your Composable Architecture view layer, but it can also be a performance pitfall when wielded incorrectly. It is quite common for us to see code that constructs a `WithViewStore` that observes _all_ of state, like this:

        ```swift
        WithViewStore(self.store) { viewStore in
          // View in here
        }
        ```

        While this might be fine for small applications or at the leaf nodes of your application, in bigger applications it can be a problem. It will cause the view to be recomputed for every little change to state, even if the view doesn't use the state, and it can cause buggy behavior in SwiftUI, especially with navigation.

        In order to mitigate the problem, 0.40.0 introduces a new interface for constructing `WithViewStore` views that makes state observation explicit:

        ```swift
        WithViewStore(self.store, observe: <#(State) -> ViewState#>) { viewStore in
          // ...
        }
        ```

        This API is intended to nudge you towards chiseling away at `State` to just the bare essentials so that you do not observe too many state changes. See our article on [view store performance][view-store-performance-article] for more information on this technique.

        We hope this will help folks identify views that may benefit from the use of dedicated view state, and encourage folks to adopt view state for their features.

        ## Compiler performance

        Runtime performance is not the only important performance metric… so is compiler performance!

        We have found that large, complex SwiftUI views that use `WithViewStore` can take a long time to compile, and can eventually lead to "complex expression" compiler errors. This is due to the fact that `WithViewStore` is highly generic with a large number of initializers that can be used in a variety of situations, such as in scenes, commands, and more.

        We have decided to [deprecate][withviewstore-deprecations-pr] all non-view uses of `WithViewStore` in order to eventually pare down the number of initializers defined. We won't be able to delete those initializers for a bit of time, but once we can we have found it greatly improves the Swift compiler's ability to handle large, complex views.

        ## Get started today

        Upgrade your applications to use [0.40.0][0_40_0] today to start taking advantage of all of these improvements. We also have future changes coming, such as the [`ReducerProtocol`][reducer-protocol-discussion], that will bring even _more_ performance enhancements to applications.

        [pat-brown-gh]: https://github.com/iampatbrown
        [effect-lol]: https://gist.github.com/mbrandonw/4c88b045cc1c161931e9be875957654a
        [async-tca-blog]: https://www.pointfree.co/blog/posts/79-async-composable-architecture
        [voice-memos-foreachstore-gh]: https://github.com/pointfreeco/swift-composable-architecture/blob/c63f32395335aca0e79294b56529c1e81df4bef9/Examples/VoiceMemos/VoiceMemos/VoiceMemos.swift#L150-L154
        [tgrapperon-twitter]: http://twitter.com/tgrapperon
        [foreachstore-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/foreachstore
        [0_40_0]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.40.0
        [tca-gh]: https://github.com/pointfreeco/swift-composable-architecture
        [better-performance-bonanza]: https://www.pointfree.co/blog/posts/61-better-performance-bonanza
        [memcmp-foreachstore-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/1307
        [effect-internals-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/1312
        [store-scoping-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/1316
        [withviewstore-deprecations-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/1323
        [withviewstore-stateobject-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/1325
        [ios13-stateobject-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/1336
        [performance-gh-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1290
        [reducer-protocol-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1282
        [store-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/store
        [scope-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/store/scope(state:action:)
        [view-store-performance-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/performance#View-stores
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 80,
  publishedAt: Date(timeIntervalSince1970: 1_662_613_200),
  title: "Improving Composable Architecture performance"
)
