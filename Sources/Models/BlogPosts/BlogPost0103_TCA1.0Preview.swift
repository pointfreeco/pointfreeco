import Foundation

public let post0103_TCA1_0Preview = BlogPost(
  author: .pointfree,  
  blurb: """
    We are very excited to officially share a preview of what 1.0 will bring to the Composable
    Architecture.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        We are very excited to officially share a [preview](https://github.com/pointfreeco/swift-composable-architecture/discussions/1905) of what 1.0 will bring to the [Composable Architecture](http://github.com/pointfreeco/swift-composable-architecture). We want to be clear upfront that there are *no* episode or library spoilers in this post, *and* we are not yet announcing a beta for the navigation tools even though we have [started that series](https://www.pointfree.co/collections/composable-architecture/navigation). That beta will come in a few weeks.

        The 1.0 of the library is something we outlined [4 months ago](https://github.com/pointfreeco/swift-composable-architecture/discussions/1477), and we are now officially starting the process. In a nutshell, 1.0 does not add any actual new features to the library but instead finally cleans up cruft that has accumulated over the years, such as removing most of the [1,100 lines of deprecations](https://github.com/pointfreeco/swift-composable-architecture/blob/a99024bbd171d85a92bccbcea23e7c66f05dc12b/Sources/ComposableArchitecture/Internal/Deprecations.swift) and finally renaming `ReducerProtocol` to `Reducer`.

        **We want to reiterate**: 1.0 of the Composable Architecture is *not* a grand rethinking of the library or a feature-rich release. It is merely a breaking change to get rid of tools that have been long deprecated (some of them have been deprecated for years) and to give other tools their proper names.

        So then, what is the 1.0 “preview”? It is a branch that you can target *today* if you want to get a head start on preparing for 1.0.

        ## prerelease/1.0

        The branch we are releasing is `prerelease/1.0`. It is a *mostly* backwards-compatible version of the library that we will keep up-to-date with the latest release from `main`, but it makes a few important breaking changes:

        **For reducers:**

        - `Reducer` now refers to the reducer protocol, *not* the struct that is generic over state, action and environment.
        - A soft-deprecated type alias `ReducerProtocol = Reducer` has been added.

        So, this change is only a breaking change if you are still using the old `Reducer` type alias that refers to the `AnyReducer` struct. If you are on the `ReducerProtocol`, which has been out for 4 months, then you should be good to go. Or, if you have updated your uses of `Reducer` to `AnyReducer`, you should only have deprecation warnings.

        **For effects:**

        - The `Effect` type now has one single generic for `Output`. The `Failure` generic has been removed.
        - A soft-deprecated type alias `EffectTask = Effect` has been added.

        So, this change is only a breaking change if you still refer to the old `Effect` type alias. If you are using the `EffectTask` type, which has been suggested for over 4 months, then you should be good to go.

        Even though there are some breaking changes, the fixes are usually quite simple. For example:

        - If you are still using the old `Reducer` struct type alias, you can simply rename it to `AnyReducer`. *E.g*:
            ```diff
            -Reducer<MyState, MyAction, MyEnvironment>
            +AnyReducer<MyState, MyAction, MyEnvironment>
            ```

        - If you are using the `Effect` type with two generics, you can simply rename them to `EffectPublisher`. Or, better yet, if the `Effect` type with two generics has a failure type of `Never`, you can simply rename it to `EffectTask` and remove the failure generic entirely. *E.g.*:
            ```diff
             // For effects that can fail:
            -Effect<MyAction, Error>
            +EffectPublisher<MyAction, Error>

             // For effects that cannot fail:
            -Effect<MyAction, Never>
            +EffectTask<MyAction>
            ```

        ## How should I target prerelease/1.0?

        If your project has already prepared for the two breaking changes mentioned above, you may benefit from targeting the `prerelease/1.0` branch. That is:

        - You have no references to the old `Reducer` type, and have either migrated all of your project’s reducers to take advantage of the `ReducerProtocol`, or you have at the very least renamed all instances of `Reducer` to `AnyReducer`.
        - You have no references to the old `Effect` type, and have renamed all instances to `EffectTask` or `EffectPublisher` (ideally preferring `EffectTask` when the failure type is `Never`).

        By targeting `prerelease/1.0` you will get a hard-deprecated view of all APIs that have been soft-deprecated over the past months. If you have no deprecations, you are in good shape for 1.0. If you *have* deprecations, this means you can begin to incrementally chip away at them to prepare for 1.0’s release in the coming months.
        """###,
      type: .paragraph
    ),
    .init(
      content: """
        Unless you are fully committed to living on the edge and working with beta software, we do *not* recommend fully adopting the `prerelease/1.0` branch, nor do we recommend adopting the `Reducer` and `Effect` renames that come along with it. If you are committed, though, we value your feedback! Please discuss any issues that crop up in these forums, and we’ll do our best to make the experience and smooth as possible for a beta.

        For those that *do* adopt the `prerelease/1.0` branch, we also do not recommend literally tracking `prerelease/1.0`, as that will continually track every single change to the branch. Instead, we recommend pinning to an exact Git SHA, and updating this SHA when you are prepared for the changes that come along with it.
        """,
      type: .box(.note)
    ),
    .init(
      content: ###"""
        ## Future branches and releases

        In the near future, as we get closer to the official 1.0 release, we may introduce additional branches that you can target to help you update your codebase to be 1.0 compliant. For example, we will have a branch to track all forthcoming “0.x” releases, which will include all of the new navigation tools, but will also be 100% backwards-compatible with the library today.

        ## What about navigation?

        The navigation tools that we have just [begun covering](https://www.pointfree.co/collections/composable-architecture/navigation) are coming soon, but not right now. We will be opening a public beta in the coming weeks just as we did with async/await effects and the `Reducer` protocol. This will give you a chance to play around with the tools before their final release and provide feedback.

        Our plan is for the navigation beta to work both with `main`, which means it will be 100% backwards compatible with your project today, and also work with `prerelease/1.0`. There will be more information on that soon!

        ## Try it today and give feedback!

        Please give the `prerelease/1.0` branch a spin and let us know what your [feedback is](https://github.com/pointfreeco/swift-composable-architecture/discussions/1905). Consider the branch a “beta”: it may have mistakes, deprecations may behave in strange ways, etc. If you encounter any issues, [let us know](https://github.com/pointfreeco/swift-composable-architecture/discussions/1905)!

        We are excited to finally bring the Composable Architecture to 1.0, though, and we have more big announcements coming soon.
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 103,
  publishedAt: yearMonthDayFormatter.date(from: "2023-02-13")!,
  title: "Composable Architecture 1.0 Preview"
)
