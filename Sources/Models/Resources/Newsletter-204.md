We are excited to announce a new feature of Point-Free: [Beta Previews]. It's
a great way for our most dedicated members to help shape the future of our libraries and the
greater Point-Free ecosystem. And we are launching today with two betas already: a brand new
library for exhaustively testing reference types, and a preview of ComposableArchitecture 2.0.

[Beta Previews]: /beta-previews

# What are Beta Previews?

When we're working on a major new release or building a brand new library, there's a period where
the code is functional but not yet ready for the public. During that time we're iterating on APIs, fixing
edge cases, and stress-testing ideas against real-world usage.

Historically we have used the development of [episodes](/episodes) to help finalize APIs and
features of these libraries, but now [Beta Previews] give _you_ access to our experimental work before
it goes public. You get a private GitHub invitation to the pre-release repo, where you can:

- Pull the library into your own projects and try it out
- Open issues and give feedback on API design
- Influence the direction of the library before it's locked in

We're launching with two betas today, and we plan to add more as new projects take shape.

---

# DebugSnapshots

The first beta is a brand new library: **DebugSnapshots**. It solves a problem that comes up
constantly when building apps with reference types, such as `@Observable` classes: how do you test
them?

The `@DebugSnapshot` macro generates an equatable, value-type snapshot of your class's data, and
the `expect` function lets you exhaustively assert how that data changes after any operation. You
get exhaustive testing even for classes. Something that was previously only possible with value 
types.

Read the full details in our dedicated blog post:
**[Beta Preview: DebugSnapshots](/blog/posts/205-beta-preview-debugsnapshots)**

---

# ComposableArchitecture 2.0

The second beta is the one many of you have been waiting for: **ComposableArchitecture 2.0**. This
is our biggest release ever. A fundamental redesign of how features are built, how side effects
are managed, how features communicate, how features are tested, and a lot more.

Highlights include the `@Feature` macro, implicit `store` access for async work, lifecycle hooks,
four new communication patterns (preferences, events, triggers, delegate closures), spawned stores,
and deep integration with DebugSnapshots for testing.

Read the full details in our dedicated blog post:
**[Beta Preview: ComposableArchitecture 2.0](/blog/posts/206-beta-preview-composablearchitecture-2-0)**

---

# How to get access

Beta Previews are available exclusively to members of our
[Point-Free Max](/pricing) tier. Max members can visit the
[Beta Previews](/beta-previews) page and join any open beta with a single click. You'll receive a GitHub
invitation to the private repo, and from there you can pull the library into your projects
immediately.

If you're already a Max member, head over to [Beta Previews](/beta-previews) now to get started. If
you're not yet a member, check out our [plans](/pricing) to see everything that's included.

We have more betas planned, and Max members will automatically get access to every new one as
it opens. We can't wait to hear what you think.
