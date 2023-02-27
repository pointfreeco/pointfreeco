import Foundation

extension Episode {
  public static let ep221_pfLive_dependenciesStacks = Episode(
    blurb: """
      Our first ever livestream! We talk about a few new features that made it into our
      [Dependencies](http://github.com/pointfreeco/swift-dependencies) library when we extracted it
      from the Composable Architecture, live code our way through a `NavigationStack` refactor of
      our [Standups](http://github.com/pointfreeco/standups) app, and answer your questions along
      the way!
      """,
    codeSampleDirectory: "0221-pflive-dependencies-stacks",
    exercises: _exercises,
    format: .livestream,
    id: 221,
    length: 94 * 60 + 34,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-02-06")!,
    questions: [
      Question(
        answer: """
          Yes! The next series of episodes we are tackling is navigation in the
          [Composable Architecture](http://github.com/pointfreeco/swift-composable-architecture).
          After that series the library will finally be ready for a 1.0, and at that time we will
          do a brand new "tour" series of episodes, most likely rebuilding the
          [Standups](http://github.com/pointfreeco/standups) application with the library.
          """,
        question: """
          Do you plan make a series of episodes like “Modern SwiftUI,” but for the Composable
          Architecture, to show best practices for updated library?
          """,
        timestamp: .timestamp(hours: 1, minutes: 26, seconds: 45)
      ),
      Question(
        answer: """
          Yes we are, but progress on the actual implementation has been paused since we can't
          do it ourselves (C++ 🙄) and the implementor at Apple has been pulled to other projects.
          We hope that work can begin on it again someday soon, but we hope that when that day
          comes there will be a focus on the `embed` functionality and not just the `extract`.

          While the extraction of an associated value from an enum can be handy, it's only half the
          story. Just as key paths wouldn't be as useful if they only handled getting and not
          setting, so too would case paths be unnecessarily hindered if they only extraction
          capabilities without embed.
          """,
        question: """
          Are you still pursuing the idea of introducing CasePaths to Swift as a first-class
          language feature? The official Swift evolution proposal has been stalled.
          """,
        timestamp: .timestamp(hours: 1, minutes: 30, seconds: 50)
      ),
      Question(
        answer: """
          We name our observable objects this way because it's how Apple has started naming them
          in their sample code. We don't think the naming is important though, and if you feel
          more comfortable it them "view model" or something else, feel free!
          """,
        question: """
          Why do you name your observable objects “Model”?
          """,
        timestamp: .timestamp(minutes: 47, seconds: 20)
      ),
      Question(
        answer: """
          We feel that callback closures and delegates are really just two sides of the same coin.
          It is roughly equivalent for one object to delegate to another by invoking callback
          closures, versus conforming to a delegate protocol and holding onto a weak reference
          of that object. But, callback closures can be a little more lightweight and ergonomic
          than a delegate protocol.

          Further, Apple has even started shying away from the delegate protocol pattern in some
          of their more modern APIs, and instead opt for a simple collection of closures.
          """,
        question: """
          Why are you using callbacks instead of a delegate?
          """,
        timestamp: .timestamp(minutes: 54, seconds: 51)
      ),
      Question(
        answer: """
          The SwiftUINavigation library was really only built with vanilla SwiftUI in mind,
          for those times you can't use the Composable Architecture. As such, it doesn't really
          play nicely with the Composable Architecture, and that is why we are building navigation
          tools from the ground up specifically for the Composable Architecture.
          """,
        question: """
          Are there going to be episodes on best practices of using the SwiftUINavigation library
          with the Composable Architecture?
          """,
        timestamp: .timestamp(hours: 1, minutes: 30, seconds: 3)
      ),
      Question(
        answer: """
          You can try being selective with what methods and properties of your model are marked as
          `@MainActor`, but typically it ends up being most of the model, and so we just tend to
          mark the whole thing as `@MainActor`.
          """,
        question: """
          Do you see any issue with use @MainActor on models by default? Or should it only be
          added when required?
          """,
        timestamp: .timestamp(hours: 1, minutes: 2, seconds: 18)
      ),
      Question(
        answer: """
          If your application has navigation paths that create cycles, then the easiest way to
          break the cycle is to adopt a stack-based navigation, such as `NavigationStack`.
          """,
        question: """
          How can you break cycles between modules?
          """,
        timestamp: .timestamp(hours: 1, minutes: 29, seconds: 28)
      ),
      Question(
        answer: """
          This is a bit of an open question with our Dependencies library currently, but it is
          something we are actively thinking about and hope to have a better solution for someday.

          Currently there is one safe guard to help you out. If you access a dependency that does
          not have a live implementation while running your app in the simulator, a purple
          runtime warning will be generated in Xcode.
          """,
        question: """
          How can a large, modularized codebasse guard against missing `liveValue` in their
          implementation modules?
          """,
        timestamp: .timestamp(hours: 0, minutes: 27, seconds: 12)
      ),
      Question(
        answer: """
          Our library doesn't directly provide any tools to help with dependency version, other than
          getting you to think about dependencies in general. It's still on you to employ
          dependency inversion where appropriate in your application.
          """,
        question: """
          How does your Dependencies library relate to “dependency inversion”?
          """,
        timestamp: .timestamp(hours: 0, minutes: 23, seconds: 24)
      ),
      Question(
        answer: """
          It is fine to use `@Dependency` from inside another dependency. This only works for
          dependencies that form a tree or acyclic graph, and if you do have any cycles your
          app will crash at runtime. We also do not currently try detecting cycles, so it's on you
          to make sure there are none.
          detect
          """,
        question: """
          How can one dependency depend on another dependency?
          """,
        timestamp: .timestamp(hours: 0, minutes: 24, seconds: 35)
      ),
      Question(
        answer: """
          Yes, this is possible, and we have more information in [this
          article](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest#Separating-interface-and-implementation) in the library's documentation.
          """,
        question: """
          Is it possible to declare a dependency interface in one module and provide the
          implementation in another module?
          """,
        timestamp: .timestamp(hours: 0, minutes: 16, seconds: 45)
      ),
      Question(
        answer: """
          Yes, our dependencies library is powered by `@TaskLocal`s under the hood, which has a
          well-defined, though restrictive, way of mutating values. Because of this, our library
          is most suitable for "[single entry point systems](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/singleentrypointsystems)",
          but tools are also provided to propogate dependencies for longer periods of time.
          """,
        question: """
          Are TaskLocals the reason that the Dependencies library is suitable for single entry
          point systems?
          """,
        timestamp: .timestamp(hours: 0, minutes: 12, seconds: 42)
      ),
      Question(
        answer: """
          Dependencies are instantiated only when first accessed, and then they are held for the
          duration of the application lifecycle.
          """,
        question: """
          Are all dependencies held in memory during the app lifecycle? Are they all instantiated
          when the app starts or at the moment when they are needed?
          """,
        timestamp: .timestamp(hours: 0, minutes: 19, seconds: 6)
      ),
      Question(
        answer: """
          SwiftUI environment values work great for accessing values deep in a view heirarchy
          without passing those values through every layer, but also it only works for views. If
          you access an `@Environment` variable when not in a view you will get a purple runtime
          warning in Xcode letting you know that is not allowed.

          Our `@Dependency` wrapper allows you to pass values deep into your application in places
          other than views, such as observable objects.

          Further, our dependencies library supports platforms beyond just SwiftUI, such as UIKit,
          AppKit, server applications, Linux, SwiftWASM and more.
          """,
        question: """
          What is the difference between @Dependency and @Environment.
          """,
        timestamp: .timestamp(hours: 0, minutes: 9, seconds: 33)
      ),
      Question(
        answer: """
          We are excited about the new [observation
          pitch](https://forums.swift.org/t/pitch-observation/62051) as it should allow us to
          simplify the Composable Architecture and make it possible to support non-Apple platforms,
          such as Windows and SwiftWASM.

          We are also excited for the new macro system, as it may help us clean up some boilerplate
          problems in our libraries.
          """,
        question: """
          What future Swift features excite you the most and why?
          """,
        timestamp: .timestamp(hours: 1, minutes: 32, seconds: 34)
      ),
      Question(
        answer: """
          You shouldn't think of a dependency as needing an `async` initializer, and instead has
          having an `async` endpoint that can initialize it.
          """,
        question: """
          How can one define a dependency where its initializer is async?
          """,
        timestamp: .timestamp(hours: 1, minutes: 27, seconds: 27)
      ),
      Question(
        answer: """
          Actors can be useful for dependencies, but you don't need the actor itself to be the
          dependency, and instead you can use an actor for the implementation of the dependency.
          """,
        question: """
          What do actor-based dependencies look like?
          """,
        timestamp: .timestamp(hours: 1, minutes: 28, seconds: 29)
      ),
      Question(
        answer: """
          The second half of this livestream should answer this question. In order to decouple
          destinations you must use stack-based navigation instead of tree-based, such as
          `NavigationStack`.
          """,
        question: """
          State-driven navigation is great, but the Standups example is coupled closely to the
          view's model. How would you approach something like a "coordinator" or "router" pattern
          where the view doesn't know anything about the other destinations?
          """,
        timestamp: .timestamp(hours: 1, minutes: 25, seconds: 19)
      ),
    ],
    references: [
      .onTheNewPointFreeDependenciesLibrary,
      .swiftDependencies,
      .dependenciesSeparatingInterfaceAndImplementation,
      .designingDependencies,
      .standupsApp,
      .swiftUINav,
      .swiftUINavigation,
      .theComposableArchitecture,
      .isowordsGitHub,
      .isowords,
      .observationPitch,
    ],
    sequence: 221,
    subtitle: "Dependencies & Stacks",
    title: "Point-Free Live",
    trailerVideo: .init(
      bytesLength: 44_200_000,
      downloadUrls: .s3(
        hd1080: "0221-trailer-1080p-8979f93a83ee49fcad7acb291c15264c",
        hd720: "0221-trailer-720p-b434d9a0fca44f14990171929136754f",
        sd540: "0221-trailer-540p-5cd5fcac05ed4dd288f1a56a6550d01b"
      ),
      vimeoId: 795_389_609
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Fix all of the tests for the newly refactored Standups app now that it uses `NavigationStack`.
      """
  )
]

extension Episode.Video {
  public static let ep221_pfLive_dependenciesStacks = Self(
    bytesLength: 960_800_000,
    downloadUrls: .s3(
      hd1080: "0221-1080p-69767068a5104055babcf7b8993daaeb",
      hd720: "0221-720p-8449bf17411249aa8dc3f31272f779cc",
      sd540: "0221-540p-b7bbf287996d41e384a31377c633d67d"
    ),
    vimeoId: 795_040_266
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep221_pfLive_dependenciesStacks = transcript {
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 0,
      type: .title
    )
    paragraphs(
      """
      [00:00:00] **Brandon:** Okay. We are live. I hope so. We're live. Yeah. I hope people can hear us. I guess I should check the, the chat. All right, well, we'll see. Someone will let us know. But yeah, this is our first live stream. It's something we've been wanting to do for a long time. Something kind of like office hours. We have Q&amp;A at the bottom of chat.

      [00:00:34] **Brandon:** You can tap into it at any time. Ask a question, vote on it. We'll be addressing some of those things. But we also just have a few topics that we wanna talk about that we didn't really have time and episodes or didn't really fit the, the narrative arc of our episodes. So one of those things is dependencies.

      [00:00:51] **Brandon:** Wanna say something about that, right?

      [00:00:54] **Stephen:** Yeah. Dependencies is our newly released ninth library to be split out from the Composable Architecture. And even though we covered it a bit in episodes about the Composable Architecture and even in the modern Swift I series that we just finished there's a lot more that we can do and explain because there are a bunch of little features that kind of snuck in into the release.

      [00:01:14] **Brandon:** Yeah. Yeah. And then the other thing we wanna talk about is also about kind of the modern SwiftUI series that we just finished and we got a lot of questions about, so we'll ask some, but what we didn't do during that series was talk about navigation stacks. Now we did talk about navigation stacks when it came to just navigation in general, but we didn't apply navigation stacks to the standups app that we built.

      [00:01:35] **Brandon:** And so we're just gonna do that live. And it turns out that that's gonna be really important for us to understand some of the stuff we're gonna do with TCA navigation, which is coming really soon. And so we wanted to have a place to do that. And then, and then if there's time at the end, which there probably will not be, we may talk about some non-exhaustive testing stuff or maybe that'll just be the next live stream.

      [00:01:54] **Brandon:** Yeah, there's also a bunch of Q&amp;A coming in, so we'll try to answer as many as we can. And we're also new to streaming and the tech involved. We're using brand new applications like o Bs. Many of our viewers may have more experience than us. So if you notice anything weird, let us know. Give us some tips in the chat.
      """
    )
    Episode.TranscriptBlock(
      content: #"Dependencies"#,
      timestamp: 2 * 60 + 11,
      type: .title
    )
    paragraphs(
      """
      [00:02:11] **Brandon:** Yeah. Well, so I think we just start with dependencies. I think you can take over and and also share your screen with me.

      [00:02:41] **Stephen:** Yep. One second. I am taking over the stream and start the recording.

      [00:02:50] **Stephen:** Cool. All right.

      [00:02:53] **Stephen:** So dependencies is this library that we released a while back as a module inside the Composable Architecture. And we really designed it for the Composable Architecture. We even flushed out and motivated. It's designed over a few episodes where we introduced the reducer protocol and we found that revamping dependencies in the Composable Architecture could be really nice.

      [00:03:17] **Stephen:** Now that reducers were just types that conform to a protocol rather than these values. But very shortly after a release, we already had folks letting us know that they were depending on TCA for apps that didn't even use the Composable Architecture just so they could use the dependency system. And we were pretty happy with the library.

      [00:03:36] **Stephen:** We knew that we wanted to break out eventually, but we also knew it kind of was designed for TCA and it may have not been ready to be used in in other systems. And that's because we optimize it for what we like to call single entry point systems. And that basically means that there is a single code path for handling all of the logic in the application and in the Composable Architecture that is that reduce method that is on reducers.

      [00:04:05] **Stephen:** And basically you have a bunch of reducers all composed back to a single entry point in your application and it all gets fed down through that system. And so yeah, that is the perfect way of using this dependencies library. Just having that single entry point and being able to kind of scope dependencies as you go into deeper and deeper reducers and reducers aren't the only kind of single point of entry system.

      [00:04:34] **Stephen:** Server side apps are a great example because we have kind of that request response life cycle. Really we can think of a lot of server side apps as a function. and let me hop over to Xcode

      [00:04:53] **Stephen:** where we are in the dependencies project. And just to kind of sketch that out, a lot of time we can think of a request to response as just a single kind of function for every single request that hits a server and then feeds a response back to the user. This kind of system is perfect for dependencies because you can just kind of set all of your dependencies up before running the function, and then it's just be fed into whatever kind of like testing harness you have set up to override dependencies.

      [00:05:29] **Stephen:** And so another example would be maybe command line apps. You could have a single function describing the array of arguments that go in and the.

      [00:05:46] **Stephen:** This is simplified of course, cause you have streaming and, and whatnot. But for all intents and purposes, dependency management works great for this kind of system as well. And then SwiftUI views are actually a great example of one of those single entry point systems because the body requirement of the view protocol can be considered as kind of like a single code path for rendering the app's view hierarchy.

      [00:06:10] **Stephen:** And that goes all the way back into the root app or if you're using like a UI hosting controller to, to render a SwiftUI component. And if our viewers have experienced with SwiftUI, they may see some parallels between our dependencies library and the environment. And yeah, we took a lot of inspiration from the SwiftUI environment for designing this because it not only takes advantage of the same single entry point design that we have with Composable Architecture, but it also provides a really nice hierarchy to provide key scopes for where dependencies can be overridden.

      [00:06:44] **Stephen:** And we can provide the exact same thing within like a reducer hierarchy. And so we mostly model Dependencies library, API after SwiftUI and the environment both because we like to provide a familiar design to folks. Most of our libraries are kind of just a little bit of things that we think are gaps in Apple's frameworks, and we try to fill those gaps the way that we would hope Apple would fill them.

      [00:07:10] **Stephen:** but that was back when we designed it for the Composable Architecture. We wanted to be able to use it just more broadly and more generally, and so we did a lot of prep work for the actual library release to do so. And the first thing was just to make sure it has wider compatibility and the wider compatibility just means supporting non-Apple platforms, which means Linux, windows, even SwiftWASM if you're building front end apps with Swift.

      [00:07:41] **Stephen:** And this even means that you could start using it in your server side applications today. And in fact this very website is already using dependencies under the hood and it it's pretty fantastic. We've been able to iterate on the website. I know, Brandon, you've been having a lot of fun adding new features the past week or two, and it's just been a lot easier using dependencies.

      [00:08:02] **Brandon:** Yeah, there's, there's just some parts of the, like some things of data, like a current user or subscriber state of the, the user that is just ubiquitous that needs to be passed throughout the entire application, leaf nodes of views and all throughout middleware. And so yeah, just throwing those into the dependencies was, it just cleaned up a lot of stuff that we were doing, bypassing stuff manually.

      [00:08:22] **Brandon:** It's cleaned up a lot of stuff.

      [00:08:24] **Stephen:** Yep. And we're excited to maybe get back to some more server side stuff this year, maybe even switch SwiftWASM. And it'll be exciting to see how we can use dependencies on all these different platforms. But probably more useful to most of our viewers is how would you use dependencies in a more vanilla, swift way?

      [00:08:43] **Stephen:** And the problem is, even though Vanilla SwiftUI provides a great single entry point solution for views, it does not when it comes to actual behavior, because most of the time you're throwing your behavior into observable objects. And those are just classes, reference types that perform behavior over time from any number of methods that you implement.

      [00:09:01] **Stephen:** So it's definitely not a single entry point. You can just shoot at a method and it's gonna do something internally, set some state, run some effects. You just can't really control things over time in the same way. And then beyond that, many of our viewers are still probably having to dip into UIKit occasionally.

      [00:09:19] **Stephen:** And both UIKit view controllers and views are definitely not single entry point systems. They're also objects encapsulating behavior and they have many endpoints that influence that behavior.

      [00:09:34] **Brandon:** Hey, one quick thing. There's a question that we can maybe just answer real quick and we could try out this little fancy feature here.

      [00:09:40] **Brandon:** So I'm gonna throw it up.

      [00:09:41] **Stephen:** Okay.

      [00:09:41] **Brandon:** You don't know what it is, but there it is. So, just recap really quickly, why dependencies versus the environment?

      [00:09:48] **Stephen:** Sure. That's a great question. So dependencies is kind of something that can live alongside the environment. The environment was something Apple designed for the view hierarchy, and a lot of its features aren't even usable from observable objects.

      [00:10:04] **Stephen:** So if you try to use the @Environment property wrapper in an observable object it's just not gonna work the way you expect. And so dependencies kind of fills in the gap in the model side of things. So where you may use environment in your views, you're gonna want to use dependency or some other kind of solution in your model.

      [00:10:26] **Brandon:** Cool. All right. I'll hide that. All right. Sorry to interrupt.

      [00:10:29] **Stephen:** Yeah. Well also, you can't use an environment in server side apps. So all these new kinds of platforms that you can use dependencies in are available, whereas the environment is kind of a very view specific thing. And yeah. Beyond UIKit, really, we think you could use this dependencies library anywhere.
      """
    )
    Episode.TranscriptBlock(
      content: "New dependency tools",
      timestamp: (10 * 60 + 29),
      type: .title
    )
    paragraphs(
      """
      [00:10:50] **Stephen:** We wanna hear about it. We would love to know if you find gaps in the design that we can fill. And yeah, we always accept pull requests and conversation on the GitHub discussions because yeah, we, we like improving this stuff all the time. And so in order to fill those gaps, there are two main APIs that we added, and they are all based around the, the idea of scoping dependencies because. Really dependencies acts a lot like what we call the, the current world approach, which, which is something we introduced years ago.

      [00:11:28] **Stephen:** And it's the idea that putting all of your dependencies in this global kind of collection, the singleton is really not such a bad thing as long as you can control things and dependencies can work in the exact same way where you could just consider dependencies a global thing that has a bunch of the dependencies that you reach for at any given time.

      [00:11:48] **Stephen:** And then if you don't need any scoping beyond that, it'll just work. You write your test, you scope before you run them, you're good to go. But we want a deeper integration into how people build applications and spin up observable objects and UI view controllers, all that kind of thing. And so we created new tools for having more fine grain control over how you can override and control dependencies across those boundaries.

      [00:12:16] **Stephen:** And so, Hopping back over to Xcode. If we go to the, withDependencies(from:), we have documentation on it, but also we have a few versions of it. If anybody's asking questions. Brandon, you can just stop me at any time.

      [00:12:40] **Brandon:** Yeah, there's, there's a couple that you could just answer really quickly. Like just, you wanna give like a quick one or two sentence for somebody like you know, like this here.

      [00:12:49] **Brandon:** I think you'll be able to see. There you go.

      [00:12:56] **Stephen:** Yeah, so that's a great question. We do think that task locals empower a lot of what's happening both in making it so we can have type safe dependencies that are or concurrency safe dependencies, but also task locals provide the, the scoping mechanism that we use under the hood.

      [00:13:16] **Stephen:** It gives a great way for the current like task to be able to create a scope where dependencies are overridden. And so we have this core collection of dependency values modeled after environment values. And then we use the task local to scope that whenever you decide to call a method or function, like with dependencies and with dependencies, has a bunch of different versions.

      [00:13:39] **Stephen:** This one takes a model. It's the, a new version that came out with the library. , but even at the very beginning we had with dependencies that just allowed you to kind of mutate the dependencies and then within that scope and even within like tasks that shoot off from that scope, you can be sure that the dependencies are overridden with what you provide.

      [00:14:00] **Brandon:** Yeah. Yeah. The task local is what makes a global blob of dependencies a safe thing to do. And it's can be restrictive in some ways, but you're about to talk about how we allow kind of extending the lifetime of dependencies in certain cases. I think that's gonna dovetail with some of the other questions, so why don't you dive into it?

      [00:14:18] **Brandon:** Maybe I'll throw up another question at some point.

      [00:14:20] **Stephen:** Yeah.
      """
    )
    Episode.TranscriptBlock(
      content: "withDependencies(from:)",
      timestamp: (14 * 60 + 23),
      type: .title
    )
    paragraphs(
      """
      [00:14:21] **Stephen:** So withDependencies(from:), basically allows you to tie the given dependencies with a model, and you would wanna do that where you already are in some well-defined scope where you may have set some dependencies or overridden some dependencies. So that might be in your kind of root observable object for an application.

      [00:14:43] **Stephen:** That root observable object may be spinning off child observable objects when you kind of navigate to other pages. And if you did that without really thinking about your dependency model, excuse me you would get to the point where you might lose the dependencies that you've overridden in the parent.

      [00:15:03] **Stephen:** And so we need a way to basically take all those dependencies and pass them along to the model. And we do so using the same scoping mechanism that we use for overriding dependencies in general. The difference is you are allowed to take the current model. In this case that would be the root model.

      [00:15:20] **Stephen:** And then as long as the operation that basically spins up a new model, returns an object, we can tie everything to the lifecycle of that model. And so from child to grandchild, et cetera, all of your models will have a well-defined scope of dependencies so long as you use this mechanism.

      [00:15:43] **Stephen:** And so we have a few examples. We have that standups app that we built recently, and so I'm gonna switch over to that and we can even search for with dependencies.

      [00:16:02] **Stephen:** And we have a bunch of ones with from including in the standup detail that I'm in right now. And so basically whenever you are navigating to a new screen, before spinning up one of these models, we wrap it with the, withDependencies(from: self). And this kind of does the glue where it knows all the dependencies that live up on the standup detail model, but it knows that if these are overridden, either in tests or at the root, or if you have some kind of flow where you wanna override dependencies, that they propagate down to all the children.

      [00:16:42] **Brandon:** I'm gonna, I'm gonna answer one really quick question because this is very fast to answer.

      [00:16:47] **Stephen:** Sure.

      [00:16:49] **Brandon:** So just, is it possible to declare dependencies in one module and provide the live value in another module? It's definitely possible there, it's described in the documentation. I think if you look up, there's an entire article I think called live Value Test Value Preview Value, and I think it describes how you can separate interface from implementation.

      [00:17:08] **Brandon:** So definitely possible.

      [00:17:09] **Stephen:** Yep. Yeah, great question. But yeah, basically all of the child models that get spun up whenever you go across one of these boundaries uses with dependencies from self. And we spent quite a bit of time designing this. It should hopefully work wherever you expect it to. The way it kind of works under the hood is you, so long as the model itself uses the dependency property wrapper, What we actually do is the dependency proper property wrapper itself will always capture the initial values.

      [00:17:46] **Stephen:** So whenever you spin something up, it knows what the dependency values were at the time of spinning them up. So as long as you have this object that lives over time, it's gonna always hold onto these dependency values. And these dependency values can propagate down to a child. Now we do have some additional kind of, not magic, but we keep track of objects that don't have any dependencies, and we still allow you to propagate dependency values to do them just from their object identity.

      [00:18:14] **Stephen:** And so hopefully this covers most of the corner cases in people's applications, and I think that pretty much covers that aspect. Yeah. I don't know if there's anything you wanna add, Brandon, before moving on to the other new.

      [00:18:32] **Brandon:** Yeah. Yeah. Just like a high level or what is the other new feature? I forget.

      [00:18:36] **Stephen:** Oh, with the escaping.

      [00:18:39] **Brandon:** Oh, okay. Yeah. So just yeah, kind of dovetailing with all this stuff is just basically because it's built on task values, it gives us a very safe way of, of mutating dependencies, but also very restrictive.

      [00:18:51] **Brandon:** And so, yeah, these are just examples of tools of how do you extend the lifetime a little bit longer, you know, tying it to the lifetime of a class reference type and what Stephen is about to go into now with this escaping idea. But maybe there could be, there was a pretty good question about memory management that we could just chat about really quickly.

      [00:19:11] **Brandon:** And in fact I'd even put it on our sync today. So Stephen and I do a sync every day to chat about all the various issues that come up on open source and everything, and I wanted to talk about it. So, all right, let's, let's start with this one. And. I mean, I, I've been, I've been thinking about for a while, whereas you're being presented with immediately, so I, I can just jump in and you let me know.

      [00:19:35] **Brandon:** So it is just essentially, it is somewhat true that dependencies are held in memory for the entire duration of the, the app. But that's not really necessarily a problem. The, the idea is to make your dependency so that it's not this thing that is super heavyweight. You don't need to like, hold a thousand images in memory in the dependency.

      [00:19:53] **Brandon:** Rather, the dependency is an interface to the outside world where you request a thousand images. And so the fact that this dependency is like quote unquote living for the entire duration of that typically is not a problem. I dunno if you wanna add anything. Oh, Stephen, I think your video dropped out.

      [00:20:15] **Stephen:** Let me double check.

      [00:20:21] **Brandon:** Oh no, there you are.

      [00:20:22] **Stephen:** Yeah, just had to nevermind. Tab over to OBS for a second.

      [00:20:26] **Brandon:** Yeah. Or, or actually maybe it was just, it may have just been me, but yeah, I don't know if you wanna add anything to that, but,

      [00:20:31] **Stephen:** no, I think that's right. I think dependency values, and when you start working with dependencies in this way, it may seem like you're creating a bunch of objects, but really it's, it's closer to the fact that you have a bunch of globals and those globals are not very different than like the default file manager.

      [00:20:47] **Stephen:** Like it's not a heavyweight object, and we kind of expect it to live the entire life cycle. Yeah. Anyway,

      [00:20:53] **Brandon:** yeah, the, he, the heavyweight stuff should be hidden behind endpoint and the dependency. It shouldn't be just the very, the very act of creating the dependency should not be the heavyweight thing. Yeah.

      [00:21:00] **Brandon:** Okay. Yep.
      """
    )
    Episode.TranscriptBlock(
      content: "withEscapedDependencies",
      timestamp: (21 * 60 + 5),
      type: .title
    )
    paragraphs(
      """
      [00:21:04] **Stephen:** And withEscapedDependencies this was something we added pretty late, and it was a way to kind of allow folks to bridge between the modern kind of swift concurrency task local world with all of the old style of escaping closures. And so it's kind of modeled very similar to withUncheckedContinuation and that model where you are kind of bridging the old world with the new async world.

      [00:21:37] **Stephen:** And so what we did was we provide this interface where you may want to pass dependencies in a well-formed way through an escaping boundary. And this could be as common as you might have some code in your application that is using dispatch async(after:) still, but you want to be able to feed dependencies through it.

      [00:21:57] **Stephen:** And so you would want to use with escape dependencies to do so. And I think we even have an example of that. So in the documentation, basically we show that. Within whatever current scope we're living in, we can get a handle on the dependencies, then go across, do some escaping work, which is happening in this closure.

      [00:22:20] **Stephen:** And then so long as we yield the dependencies, we can even override them. But everything in here will kind of have a cascading effect of using the dependencies passed along, along with any overrides. And so this allows you to work with the old code written in Combine or Rx Swift old foundation APIs, dispatch APIs.

      [00:22:45] **Stephen:** And we even use this to start using dependencies in pointfree.co. We're using some very experimental libraries that, that you and I worked on at the very beginning, kind of modeled after deep functional programming. So we even have a type that uses this. And let me open up the pointfree.co repo so you can take a look.

      [00:23:23] **Brandon:** I'll throw up a question real quick while you find a place. Yeah. So here, I'll throw up this. I'm not, I'm not a hundred percent sure what this so, alright, so we didn't really talk about this. We, we haven't talked about, the only thing we've really talked about is just what, like some special features of the dependency library.

      [00:23:43] **Brandon:** The dependency library does allow you to kind of break the connection between the live implementation, which typically is very heavyweight and slow to build. And then the interface, which is typically very fast. So you can do that. But dependency inversion, that's more of a choice you're gonna make within your application.

      [00:24:02] **Brandon:** The library doesn't necessarily provide a tool for that other, maybe getting you to think about the dependencies in general. I'll just kinda leave it at that.

      [00:24:10] **Stephen:** Yep.

      [00:24:12] **Stephen:** Cool. So our website is a little wild and if you dive into the deep end, you'll see things that even Brandon and I have, have trouble working with few years later.

      [00:24:25] **Stephen:** But everything is powered by a type that's a lot like a kind of a future,

      [00:24:31] **Stephen:** excuse me.

      [00:24:34] **Brandon:** While you drink water. I'll answer one more question.

      [00:24:36] **Stephen:** Yeah.

      [00:24:38] **Brandon:** Yeah, it's, it's totally fine for one dependency to depend on another. You can use the @Dependency property wrapper within, like the live implementation of another dependency.

      [00:24:49] **Brandon:** We, as long as your dependencies form a tree or a graph without any cycles, then that'll totally work fine. If you do have cycles, we do nothing to help with that. We're not even trying to solve that problem. So you will just crash. But it is possible, we haven't written a ton of documentation on it because we wanted to kind of get an understanding of what exactly the implications are for doing that.

      [00:25:13] **Brandon:** But but I think over time we're, we're understanding more and more of like what it means to do that. And so we're more comfortable telling people that they can do it and we will be writing some stuff up about that. Yeah.

      [00:25:23] **Stephen:** And we've heard from folks in the forums and they're, they're using it to some success and I think we'll get more and more experience with it.
      """
    )
    Episode.TranscriptBlock(
      content: "pointfree.co",
      timestamp: (25 * 60 + 35),
      type: .title
    )
    paragraphs(
      """
      [00:25:33] **Stephen:** So just back to very brief, tour the pointfree.co website. All of our side effects are powered by this IO type and this IO type is, is a lot like a reactive swift signal or future, that kind of thing. And it just computes some value of A, and the only change that we had to do to start using dependencies throughout the entire website was to ensure that this old kind of escaping work that we were doing is being done with dependencies, kind of escaping into the, into the computation.

      [00:26:06] **Stephen:** And so this is what allows us to very deeply throughout the entire website propagate the dependencies and write tests in a very easy way. And so, yeah, whenever you decide to use dependencies and integrate with an old system that may not be using all the bells and whistles of modern swift concurrency, this tool is available and it should be able to kind of bridge the gap.

      [00:26:30] **Stephen:** and hey, I think that pretty much covers those two features. I don't know if there are any other Q&amp;A things that have come up with Dependencies.

      [00:26:42] **Brandon:** Yeah, yeah. I mean, there's a lot . So let's see. Oh boy.

      [00:26:55] **Stephen:** We, we've also migrated isowords. We, we try to keep isowords up to date with the Composable Architecture in general to, to showcase all the new features.

      [00:27:04] **Stephen:** And so that repository is still is already using dependencies as well.

      [00:27:15] **Brandon:** So, you know, I don't know if I have a great answer for this. Let's just throw it up. So yeah, so this is. Potentially a gotcha. And I don't know if we have the best answer right now. It's something that we wanna look into. The, the thing that we do right now that kind of helps is that we will, if you ever access a live or if you ever access a dependency in a running app in a simulator or on a device that it doesn't find a live value for, it throws a runtime warning or, and which shows like a little purple warning index code.

      [00:27:50] **Brandon:** So it's at least visible. But yeah, it's, it's something that happens at runtime rather than, yeah, compile time or something. But we know, we know this is a gotcha and we wanna like spend more time on it, but that's the state of it today.

      [00:28:03] **Stephen:** Yeah. That missing

      [00:28:04] **Stephen:** feature, hopefully we'll be able to kind of address maybe with some of the new swift functionality coming down the pike.
      """
    )
    Episode.TranscriptBlock(
      content: "Navigation stacks",
      timestamp: (28 * 60 + 26),
      type: .title
    )
    paragraphs(
      """
      [00:28:11] **Brandon:** Yep. Yep. All right. I mean, well that was about 30 minutes. That seems like a good time. Stop. I mean, there. How about I'll take back over the stream. Okay, there we are. Alright, so yeah, I, yeah, that was great. We do have a lot of questions, so really if you we're gonna, I think, move on to the next topic, but honestly, if you come through a Q&amp;A while, I'm doing my thing, feel free to throw it up if you want to answer it because Yeah, there's just, we got 63 questions sitting in here.

      [00:28:49] **Brandon:** Oh boy. Yeah, there's a lot. There's a lot. So yeah. Feel, feel free to throw on one, but I think, so I'm gonna start doing some sharing. So Stephen, I'm gonna share my screen with you. You got that?

      [00:29:02] **Stephen:** Yep.

      [00:29:02] **Brandon:** All right. And I'm gonna switch over to my screen share because what we're gonna talk about for the second half of this of this live stream is the, the navigation stack.

      [00:29:17] **Brandon:** Because we just finished our long series of let me see. I got something here. So, yeah, we just, we just finished our long series on Modern SwiftUI and we built it in the way that, you know, we really enjoy, we have state driven navigation and we've got dependencies controlled, and we're using tag type for type safe identifiers.

      [00:29:41] **Brandon:** We have all types of fun stuff in there. The code is all open source. We also really want people to port this code base and build it in their own way. The, the first version of this code base was Apple's Scrumdinger application. And we, it's a really great application. We just wanted to rebuild it in a way that made it seem a little bit more modern.

      [00:30:02] **Brandon:** And we would love to see if people have other ideas for navigation or dependencies or whatever. Just like fork it, rebuild it, send us the link. We'll put it in the read me of the Standups app. But for those who aren't familiar, I guess I can run it in the simulator real quick. Can show my simulator, and it's just a very basic app. Well, not very basic. It's a, it's a actually moderately complex app that ever shows up.

      [00:30:35] **Brandon:** All right, so , so we've got a standup already added. You can drill in, you can edit. I can add some attendees like Blob, blob, Jr. Blob senior. We could delete it if we want, and we could also start a new meeting. I can give access to the speech recognizer, and right now at, hopefully as I'm talking, it's actually transcribing my text.

      [00:31:01] **Brandon:** And so I'll go to the next speaker, the next speaker, and if I hit the last time, it'll, and you'll notice that the timer actually stopped. But it'll ask me, do we wanna end it early? And it'll say, save an end. We pop back. Here we are. And yeah, I got, I got all my text. So that's, it's a decently complex application and we built it in the way that like, we really like, and in particular we used.
      """
    )
    Episode.TranscriptBlock(
      content: "Tree vs. stack navigation",
      timestamp: (31 * 60 + 19),
      type: .title
    )
    paragraphs(
      """
      [00:31:25] **Brandon:** State driven navigation. But even more specifically, we use what we like to call tree based state navigation. And the tree aspect of that is the fact that each screen describes an enum of all the different places you can navigate to. So from the standups list, which is kinda like the root screen you can navigate to the add screen, which is this sheet that flies up.

      [00:31:47] **Brandon:** Oh, I still get the open. Sorry. This is the preview. So, so you've got this little sheet you can show right here. You can also go an alert can show, and we even have a preview that demonstrates as if, if data fails to load on first launch, we show this alert. So that's another destination you can navigate to.

      [00:32:06] **Brandon:** And then the detail screen, which is, let me go back to this preview. When you tap and you drill down, all right, so these are all the destinations that this one screen can go to, but then each of those screens have their own destinations that they can go to. So you go to the standup detail. Which is this drilled in screen and it's got its own enum of destination.

      [00:32:28] **Brandon:** So you can go to an alert, you can bring up an edit sheet, which is this, you can drill down to a meeting, which is this, or you can go to the record screen, which is this. All right. And the reason we call this tree based navigation is because if you go to the entry point of the application right here, you get to, Ooh, I got funny, there's a sound happening whenever speaker changes that I get.

      [00:32:58] **Brandon:** And I don't think y'all are hearing that. It's funny, the preview is going to the background, I guess. Sorry, I'll just ignore it. So you get to describe in the model, Where do you want to go if you're at a deep link into here? So you say, all right, I want to go to one of these places. I I can choose where do I want to go?

      [00:33:18] **Brandon:** And then, so say, we wanna go to the detail. All right, so here we are in the detail. And then once you're here, you get to say, where else do I want to go? And I can say, well, I further want to go into one of these places, like say the record screen. And then finally you get to the record screen and you'd be like, all right.

      [00:33:37] **Brandon:** Now, I guess additionally, where do I want to go? I guess I could see where I could go here. Looks like I can show an alert, but also I could just say, all right, I'm gonna stop. I'm gonna throw in a mock standup in here, and then that is where I will go. All right, so this is kind of a tree-like structure.

      [00:33:54] **Brandon:** You're, you're navigating this deeply nested enum. Let's see. I think I also need a standup here. Mm-hmm. You need this you construct this deeply nested, and you, at each node you get to choose what branch you wanna take, and that's what all these choices are here. And then you go to the next node and you've got branches and so on.

      [00:34:17] **Brandon:** So this is like tree based navigation. It's extremely powerful. I can just start this up and I'll be immediately, let's see. Oh, where's my simulator? So here, let me run that one more time. So here we go. I just started immediately right in the record screen. I'll just drill down two layers deep. So it's extremely powerful.

      [00:34:37] **Brandon:** We really like it. And then there's stack based navigation to contrast it with tree based. All right. And stack based is what the iOS 16 navigation stack API brought to us. And what that brought was the ability.

      [00:34:56] **Brandon:** To initialize this navigation stack stack wrapper thing with something with a binding. All right? And there's the navigation path binding. We won't talk about that. But there's this binding, which is a binding of a collection, and it allows you to provide like a flat array values that are interpreted as all the drill down layers of the navigation stack.

      [00:35:22] **Brandon:** And so that would allow you to build up or rather than thinking of, all right, I'm gonna go into a destination that is, you know, let's put one of these in. So rather than think of, all right, I'm gonna go to a destination that's a detail, and then in there I'm gonna go to a, a destination that is the record and on and on and on building up this tree-like structure.
      """
    )
    Episode.TranscriptBlock(
      content: "Tree/stack pros/cons",
      timestamp: (35 * 60 + 55),
      type: .title
    )
    paragraphs(
      """
      [00:35:46] **Brandon:** You instead think of it as just a flat array that I want go to the detail. Then I want to go to the record and then anywhere else you want to go. So this is extremely powerful. But there are pros and cons to these two styles. Alright, so the pros of the tree base is that it's extremely concise.

      [00:36:03] **Brandon:** Like you get auto complete helping you every step of the way. Where are all the places I can navigate to from here? That's like very powerful and it allows you to just describe a finite number of navigation paths. Like, you know, it may not make sense to be able to have any combination of navigation pads.

      [00:36:19] **Brandon:** You may wanna be very precise. Also these feature modules, when designed this way, are kind of more self-contained. Because if you'll notice, if I go to the detail and I start this preview and I'll hide the simulator, In this preview, I get to go to start a meeting. I get to say, all right, I wanna discard that meeting.

      [00:36:40] **Brandon:** I get to go into a, a, a previous meeting. I get to do all these flows because it's completely self-contained. All of its possible destinations are right in here, and that's extremely powerful. It's also really easy to test the integration of all these things because everything is kind of crammed together.

      [00:36:56] **Brandon:** Let's see. We got a big test suite here, so I can go to the standup detail test. Check out, maybe record with transcript, and you mock out dependencies. You start up the detail in a very specific state, actually drill down to the record screen, and you show that when the record model runs its logic that the destination is popped off the stack and a new meeting is added to the standup.

      [00:37:21] **Brandon:** So, so, because the detail screen knows about the record screen, we get to test how those two things plug together. All right? So that's powerful. And also it just kinda unifies all of navigation using tree based navigation. Get to unify all forms of navigation under one api. So if I go down to the view, These lines here I find extremely exciting and fascinating.

      [00:37:46] **Brandon:** They basically look all the same. You have, you have to point the view modifier to an optional piece of destination state and further single out one case in that state. And then that drives navigation and you do it for the meeting drill down. You do it for the record meeting, drill down for the alert for the sheet.

      [00:38:07] **Brandon:** This is like, I think this is like very fascinating stuff. So it unifies navigation. So those are great pros, but there's also a lot of cons too. You can't express complex navigation pads or recursive navigation paths. So you know, this application has well-defined paths. You can go to, you can just go to detail to record or whatever.

      [00:38:29] **Brandon:** But if you had like a wiki style application or like a film database application that needs the ability to potentially recursively navigate, you need to be able to. Navigate like to a film, then all the actors, then a particular actor, and then all the films that that actor was in. And so that can create very complex navigation pads and the tree based, it's like kind of possible, but it's also a real pain and it's just not what it excels at.

      [00:38:56] **Brandon:** And also the thing I think people most do not like about this style is that it couples navigation destinations together. So let me scroll back up. In order for us to work on the standup detail feature, we have to build all this stuff, which means we have to build the standup form model, the recording meeting model, anything we can navigate to, and anything that those things can navigate to and on and on and on.

      [00:39:19] **Brandon:** That we have to be able to build all that. So it is coupled now we get a lot of power. Like I showed a minute ago, like, I get to do this in a preview. I don't have to start up a simulator or anything. So, you know, there are positives to that, but that is a thing. And then also the biggest con, the previous ones to me or to us, I think are, are not really showstoppers.

      [00:39:41] **Brandon:** They're just kind of trade offs. Like where do you want the power in your navigation APIs? But the thing I'm about to show is just legitimately showstopper, just not great. Let me show the simulator. Oh, I'm already deep-linked in. Let me undo that. So go to here. Let's get rid of this deep link. Actually get rid of this.

      [00:40:09] **Brandon:** Alright. There's just a lot of bugs in these APIs still. And we're even using, if I go back to standup detail and navigation destination, so this is our version of this api, but under the hood, if we just keep on going through all of these layers, at the end of the day, we're just using the iOS 16 fresh brand new navigation destination that uses a binding.

      [00:40:36] **Brandon:** Yet with that, there's all types of bugs. Like if I go into here, start a meeting in the meeting, and then go into the past meeting, come back and go into the past meeting. Nothing happens. But if I tap this other meeting, it kind of went instantly. I don't know if that picked up on the live stream, but it like goes instantly, no animation.

      [00:40:56] **Brandon:** And then I hit back and we're back at the root, not back at the detail. All right. And that's just like, there's even more bugs. So, so there's just bugs. All right. There's, there's lots of bugs. And that's the main reason why it's difficult to use tree based navigation. And so the stack based, you know, all the cons of the array are pros for the stack.

      [00:41:19] **Brandon:** And all the pros are cons. Y you get what I'm saying?

      [00:41:23] **Stephen:** It's vice, vice versa.

      [00:41:24] **Brandon:** Yeah, it's vice versa. The, the pros are that it can handle complex recursive navigation paths. So, you know, we don't, let me get rid of that. We don't need that power, but. , you know, technically we could come up with a flow that you're drilled down multiple layers of detail, then the record screen, then the detail, then record screen.

      [00:41:41] **Brandon:** Now we don't need that power. That's actually probably a nonsensical thing in this application, but it's technically possible. Also the, this does allow you to decouple your screens. It means you can build a detail screen without building the record screen. The detail screen doesn't need to know anything about the record screen now.

      [00:42:00] **Brandon:** All right, well, we'll get to that in a moment. And then also the biggest pro, of course is it just has way fewer bugs. There still are some bugs, but way, way fewer bugs. So then the cons though are, it's not concise. Like this could, this is completely nonsensical, but it is technically allowed. Also you know if, oh, also, yeah.

      [00:42:19] **Brandon:** If people are interested in this idea of like nonsensical values or impossible values, we've got an entire series of episodes on algebraic data types where we talk about what it means to like, model a domain so that you try to get rid of as many impossible states as as possible. And then also when you do this, because you fully decouple these destinations, you do kind of lose some functionality in your previews and other places.

      [00:42:44] **Brandon:** So, We're gonna see this a moment, but if we did decouple these things, it just means that we couldn't possibly be running this preview, hit start meeting, test this out in the meeting, and then see that a new meeting was inserted into this, that we couldn't possibly do that. Because the whole point is to be able to build the detail screen without building the record screen.

      [00:43:04] **Brandon:** So you do lose something there. And for the exact same reason that the preview becomes a little bit less functional tests also become more difficult. So, so that's a thing. And then also at the end of the day, the tools that Apple provided, they're, it's the stack based tools for navigation drill downs only.
      """
    )
    Episode.TranscriptBlock(
      content: "Refactoring tree to stack",
      timestamp: (43 * 60 + 29),
      type: .title
    )
    paragraphs(
      """
      [00:43:22] **Brandon:** It doesn't, it's not like it helps you with sheets and popovers. It's still on you to decouple those things. So that's a little intro to this whole thing. And I'm gonna start refactoring it to a navigation stack. I don't know. Do, are there any questions you wanna throw up or anything? Or should we just dive into it?

      [00:43:39] **Stephen:** There are a bunch of questions. I think we could dive in for now and maybe as certain things come up we could answer them. Otherwise we'll answer a bunch at the end.

      [00:43:50] **Brandon:** Okay? All right. And hopefully some of the things I'm doing will also answer some questions. All right, so I think the way I'm gonna approach this is I'm just going, going to go through all these little enum destinations.

      [00:44:02] **Brandon:** I'm gonna comment out all the ones that are drilled down, navigation. So we will continue modeling alerts and sheets at, in the enum destination, because it's really great to be able to say that I either have an alert or the edit sheet is up. But clearly you can't have both of those things. So we're gonna keep those.

      [00:44:20] **Brandon:** But we're gonna get rid of the meeting drill down and the record drill down. And then also in the standups list, we will no longer have the detail drill down. All right? So we're just gonna get rid of those. There's also this really funny thing that we do in order to work around. , we already saw that there's just, there's SwiftUI bugs no matter what, but this actually was a workaround for some of that, so I'm gonna get rid of it.

      [00:44:43] **Brandon:** Basically, we have some state up in the model that when it flips to true, we listen for it in the view and then hit the dismiss in the environment. We're gonna get rid of that too, because that's not, that hack is not gonna be necessary anymore. And so I'm gonna get rid of both of those. Okay. So like, we clearly are not gonna have a building application here so we're gonna slowly fix it and, and we'll slowly convert this over to a navigation stack.

      [00:45:10] **Brandon:** So let's hop over to the entry point or, or the main root view. The thing that actually has a navigation stack. And yeah, this is the thing. We wanna be able to provide a path that has a binding here somehow. Already, there's something kind of funny with navigation stacks. They are great for decoupling all the screens in the stack.

      [00:45:32] **Brandon:** So all the screens that would appear here can be fully decoupled, compiled in isolation. That's all great, but hilariously that, that doesn't help this like the, the kinda zero-th element of the stack is going to be coupled to everything in here because of course we have to build all of this. And this is a pretty complex feature.

      [00:45:48] **Brandon:** It is the standup list feature. We have to be able to build all this in order to, you know, build this. So it doesn't help with decoupling the first element of the stack. It only decouples everything else. So we actually have to back up a layer. So I'm gonna, I'm gonna create a new files called app sort my files.

      [00:46:06] **Brandon:** And so we're gonna have first import SwiftUI, we're gonna have an app model, and we're gonna have an app view.

      [00:46:21] **Brandon:** All right. Well, this will be our navigation stack and we will have a path in here eventually. And so we will not have a navigation stack in the standups list anymore. We're gonna drop that. All right. Reindent. And now, now standups list could be built in isolation from the detail and record and stuff like that because the real integration point is gonna be here in the app.

      [00:46:49] **Brandon:** And so here, this is where we will actually create a standups list and then we have to provide a model. And so we like to integrate our models together. So we are gonna hold that model in here,

      [00:47:05] **Brandon:** and that would, and then we hold onto it as an observed object. So then we get our model app model. and we can just reach in, grab model standups list model. All right, so

      [00:47:19] **Stephen:** We do have an interesting question about why we call things models.

      [00:47:23] **Brandon:** Oh yeah, yeah.

      [00:47:23] **Stephen:** Maybe I'll put that up now.

      [00:47:29] **Stephen:** And so basically we choose the, the terminology model for these kinds of things because there are a lot of names for these things in the community. A lot of folks call them view models. Apple has called them view models in the past, but Apple has called them in all they're more like modern code samples models.

      [00:47:49] **Stephen:** And we don't like getting into the weeds with naming wars. So we kind of like following precendent that Apple sets and it's just easier. So model it is.

      [00:48:00] **Brandon:** Model it is. Alright. And so let me get a little initializer here. We need this now we're a reference type.

      [00:48:12] **Brandon:** All right, so, all right, we're getting a little bit closer. So now we have a, a standups list model being held in our route app model, and we can pass it down to standups list. Now we need this stuff here. All right. And a really fun way to model this is with another destination enum. All right? So we could have a destination enum, and we could have our detailed case.

      [00:48:32] **Brandon:** We could have our the record case and our meeting case. All right? So we could have those cases and then we could hold on to a @Published var we'll call it path Array of destinations, default it to empty, and now we can do model path, derive a binding. , and I think this screen right here compiles, I mean, the rest of the application of course, isn't compiling, but this screen compiles.

      [00:48:57] **Brandon:** But this is a good first step, but this is not how we want things. So we, we do still want, because this is our integration layer, this is what controls our stack. It controls the very first element of the stack. We do wanna integrate these things together because if we had the record screen on the stack, at some point it's gonna finish its meeting and it needs to report back to us that it finished the meeting and hey, add the meeting to the standup.

      [00:49:20] **Brandon:** There's like integration work to be done there. So we will actually be holding onto the full blown models, like we'll have the detail model in here while the record model in here, and we'll be holding onto a meeting here. And also with foresight, I happen to know that we also need the standup, so I'm just gonna go ahead and add it right from the beginning.

      [00:49:38] **Brandon:** So this is actually how we want our destination enum to be. So when you push something onto the stack, you don't just say, Hey, show the detail, because if you did that, The detail would have to be fully disconnected from our route, and we want them to be integrated. So we will say, if you wanna show detail, hand us a detail model so that it can power that view.

      [00:49:58] **Brandon:** All right? So that's great. But also that now this does not compile and I think. It doesn't show here. I don't know why. But here it will show you that it wants the destination to be Hashable. And that's what navigation stack requires. So it's kind of bizarre, but we have to throw hash ball now. That's not bizarre.

      [00:50:16] **Brandon:** What's bizarre is now all these things have to be Hashable and some of these things can be made Hashable, very easily. So, so standup can be Hashable attendee can be hash, meeting Hashable. These are just all data types. That's all just whatever The weird part is, standup detail model has to be Hashable.

      [00:50:34] **Brandon:** And it's a reference type. Reference types don't play nicely with hash ability and equability it. It's, for the most part, it doesn't make a lot of sense because you could have two. Two objects, two instances of the standup detail model with all the exact same data. But in what sense are they actually equal?

      [00:50:52] **Brandon:** Because reference types bundle up behavior too. Like maybe one of those reference types has an in-flight network request happening and the other doesn't. Does that mean they're not equal even though their data's equal? And we also had these dependencies. It's just, it's a weird question to ask if two reference types are equal.

      [00:51:08] **Brandon:** And that's why we're gonna take what we think is the safest decision you can do with this, which is that equality between reference types, yet the left hand side stand up detail model, get the right hand side. We will only consider them equal if they are just literally the same object. That's the only thing that really makes sense.

      [00:51:27] **Brandon:** And same with hashing. We are just gonna hash, we use the hasher to combine the object identifier. Object. Identifier gives us a really easy way of just getting some unique. You know, piece of data and we'll hash it in. That's just, I think just really the safest thing and really the only thing that makes sense.

      [00:51:44] **Brandon:** But then interestingly you get some main actor isolation things because we, we are main actor up here. I think I can silence that just by making this non isolated. Isolated. All right. And so then we gotta do the same. Oh, well I'll just go back to what's, oh yeah, the record. So this also has to be Hashable.

      [00:52:08] **Brandon:** Very bizarre. But it's gotta do it. And let's see. I wanna kind of feel like I'm all over the place, but over in the detail. Where was that? Yeah, I'm just gonna copy and paste because that was a pain to write. Alright, so up, way up here, we will become Hashable and Equatable, but now this is record model. All right.

      [00:52:35] **Brandon:** And so I would hope, like of course application is not building, but this is building, all right? And so we now have a list of screens we could theoretically drill down to if we fix everything. And so now what we gotta fix is, well, yeah, we gotta just fix all these problems. So let's, let's see what it takes to fix.

      [00:52:51] **Brandon:** So, so here we're in the detail. And when you tap a meeting, you used to be able to just say, point the destination to the meeting case. Here's your meeting. SwiftUI would observe that state you would drill down. That was all really great. That is no longer possible. And there's nothing because the standup detail should ideally be completely decoupled from the meeting view.

      [00:53:11] **Brandon:** It shouldn't even have meeting view symbols to even access. We have no choice but just to tell the parent, Hey, go do something. So we will tell the parent, like, on meeting tapped, we'll use one of those. Delegate closures for parent-child communication that we talked about in our Modern SwiftUI series.

      [00:53:30] **Brandon:** And so we've already got one here, so I'm gonna add another one. And we are going to default it to Unimplemented, which what that allows you to do is if this closure is called without having been overridden by the parent, oops, you will get a purple runtime warning or even a test failure if it happens in tests.

      [00:53:48] **Brandon:** So this keeps you in check to make sure that the parent is actually integrating with this, because if you don't override it, your feature will just be subtly broken. All right, so that fixes this problem down here. Oh. Oh, but yeah. Interesting. So, but, so this one did not need any arguments. This one does have an argument, so we'll just call it meeting.

      [00:54:10] **Brandon:** Okay. And that's just gonna kind of be the thing we gotta do. So, right. We can't point our destination somewhere and let's SwiftUI do the thing we instead gotta tell the parent. Let's see. So this is going down to the recording. So this is like on meeting started and we'll pass our standup along. So we gotta do that.

      [00:54:29] **Brandon:** So I'll go up and add another delegate closure, say, I'm gonna close, let see if I can get a little bit more room in here. It's kind of tight. So we'll have a stand, it'll be a function from Stand Up to Void and it will be unimplemented by default. And I mean, yeah, this is just kind of what we gotta do. So let's see what the next one is.

      [00:54:50] **Stephen:** There's a good question too.

      [00:54:52] **Brandon:** Yeah.

      [00:54:53] **Stephen:** Which we just got. And the question is, why are we using callbacks instead of a delegate?

      [00:55:01] **Brandon:** Mm.

      [00:55:01] **Stephen:** And I think we, we consider these basically two sides of the same coin. We are kind of delegating back to another object. We are just providing callback closures instead of what we used to do in UIKit, which was conform to a protocol and implement a method directly.

      [00:55:18] **Stephen:** Yeah. So we, we consider it basically the same pattern. Just it looks a little different.

      [00:55:23] **Brandon:** It's, it's also worth mentioning that Apple's even started shying away from literal delegate protocols in favor of just kind of bags of closures, like some of the newer UI collection data source or something APIs out there, you customize by just giving a bunch of closures rather than an object that conforms and hands it over.

      [00:55:42] **Brandon:** So it's just kind of a shortcut for basically the same thing. Cool. Yeah. Great. So, all right, so here's another place where we wanted to jump on over to the record meeting. But we can't, so we gotta say on meeting started. All right. We'll hand our standup. All right. So we're knocking these out. Here is a place where we had integration between the detail and the recording meeting.

      [00:56:08] **Brandon:** So when the recording meeting said it finished, we did all this work. While the detail's no longer in a position to be doing this, we're actually gonna, that's going to go all the way back to the root. So actually, I think I can just get rid of this bind entirely. Standup detail will not have to do any binding or integration logic.

      [00:56:24] **Brandon:** And I think I can then just go up and let's just remove all this stuff so we don't need this. And then we also had to call it again in the initializer, so we don't need that. All right. So, oh, that's, you know, some, some things are not so bad. Alright. And then, yeah, these view modifiers no longer make sense.

      [00:56:40] **Brandon:** This view is not gonna be responsible for drilling down. So, so I think this file is compiling and we're making progress. So let's, let's keep going. So now we're in the list and the list wants to drill down to the detail, but the list should not have any concept of what a standup detail is. So it can only just tell the parent.

      [00:56:59] **Brandon:** So we'll say onStandupTapped and pass the standup along, right. And we will default, oh, I guess there, sorry. So there are no delegate closures in this one. This is a first for this view. So it'll be a closure from standup to void. Start off as unimplemented and it will be, Stand ups list model. All right, so that should get that one compiling.

      [00:57:31] **Brandon:** All right, so here is another integration point between standups list and the detail. And it's doing stuff to delete standups and even synchronized data. None of this is gonna make sense in the navigation stack world, so we can get rid of the bind. And I think that means I can just get rid of, yeah, can get rid of it here.

      [00:57:53] **Brandon:** I can get rid of it here. All right. So not bad. Not bad. All right, now we're down here. Yep. So this view modifier does not make any sense. The, the standups list should not have any knowledge whatsoever of the detail, so we broke that. Now here, this one's kind of interesting. Now we have a compile error down the preview because in the preview we get to show off a fun little use case of being drilled down from the standups list into the detail into the record.

      [00:58:21] **Brandon:** None of that can possibly work anymore, so this preview just doesn't make any sense, so we gotta get rid of it. So that's kind of a bummer, but, all right, so now we are compiling of course doesn't work yet. We, we sort of got more to do, but at least we got rid of compilation errors. I think the main thing we gotta do is actually now that we comment out all those navigation destinations, we now just need the one main navigation destination.

      [00:58:46] **Brandon:** And we'll say when we see that you know, a new destination that's app model destination, when we see a new one come through, well, let's just grab it. Let's switch on it and let's handle it.

      [00:59:04] **Brandon:** All right, so let yeah, go do a little in. All right. I was hoping Swift would help me with this, but it doesn't look like it. So we got detail model. That's one case. What else we got? So we had a meet the meeting case, and we would have a meeting as well as a standup. And then we had the record case, and then we would have the record model.

      [00:59:26] **Brandon:** All right, so we gotta fill in these. But that should compile or I guess, I guess I have to actually return something here. So, all right, so we have the, the detail, view standup detail view. In order to do that, you need to provide a model. It's exactly what we have here. All right, so then meeting view.

      [00:59:45] **Brandon:** All right. What does it take to, we need a meeting and we need a standup, right? So it's a good thing I added that standup a moment ago, so we got the record view. In order to generate that, we need a record model. It's exactly what we have here. And, okay, so. I don't know how confident I am that this is just gonna work, but I don't know.

      [01:00:06] **Brandon:** Stephen, is there anything I'm missing, do you think? I'm not sure. Let's, I guess we could just run it and see.

      [01:00:10] **Stephen:** Let's just run it.

      [01:00:11] **Brandon:** Yeah. Sorry. We got the simulator here, so if I tap down this, yeah. Nothing is happening. I guess we probably have to check the logs and see. Oh, well, yeah, of course. Duh. Okay. So wait so we're supposed to be seeing those runtime warnings.

      [01:00:33] **Brandon:** Did I, so on standup tapped. So it's, let's figure out what's going on. So this, this is, this usually works, but yeah, I don't know. I don't know why this isn't, we should be seeing a purple runtime warning. I feel like maybe if I restarted Xcode or something, it would suddenly come up. I don't know. Stephen, has anything come to mind?

      [01:00:57] **Stephen:** I've seen them kind of come in and out in the past. Yeah, it's been a while. They're usually pretty reliable, but we're also, it's bummer. Usually not streaming, but yeah,

      [01:01:04] **Brandon:** we're not live streaming, so. All right. Well that is the problem. So we'll fix it. It really should have been a purple runtime warning, but, all right.

      [01:01:11] **Brandon:** So the thing is, is we need that little private bind that we had kind of squirreled away in each of our domains. And so this will be kind of the one main central integration point for all of the features. And so anytime a destination changes, so in a didSet, we will rebind and anytime if someone were to come in and swap in a whole new stand-ups list, we'll rebind.

      [01:01:36] **Brandon:** All right. And so that gives, oh, and also on initialization we will rebind. So what are the things we need to do in here? Well, we've got the standups list model. Here it is. And we have all of the various onXYZ on sta standup tap. There's only one here, so we gotta override this one. Then we can loop over each of the destinations in the array and switch on it and we'll see.

      [01:02:05] **Brandon:** Let's see. Oh, it's path. Hmm. Oh, also our, our whole thing just seems to be a main actor too. Let's just do that since all the models are already a main actor. Anyway,

      [01:02:16] **Stephen:** There was actually a good question from before about using main actor.

      [01:02:20] **Brandon:** Yeah.

      [01:02:20] **Stephen:** So maybe I'll bring that up right now.

      [01:02:22] **Brandon:** Yeah, let's do it.

      [01:02:26] **Stephen:** Okay.

      [01:02:30] **Stephen:** So Pat asked if we see any issues with using main actor on view models by default or, or models? Or should it only be added when required. And I think we kind of go back and forth on this, but setting things as main actor just typically makes it easier to work with views views require that these state updates happen on the main actor anyway.

      [01:02:55] **Stephen:** So pushing things in that direction always seems to be a good idea. Even though global actors do come with complications, like when you had to add non-isolated earlier.

      [01:03:04] **Brandon:** Yeah. Yeah. It just, it feels like it kinda always has to be that way. You can certainly sprinkle in where needed, but it does seem like you're just gonna sprinkling it everywhere and, and getting purple warnings in xcode.

      [01:03:17] **Brandon:** So all right. Well, while you were answering that, I, I took a moment to go ahead and just like auto complete every .onXYZ closure that is around. So these, if we implement all these closures, we would integrate all the domains together. So like this one here is a standup to void closure. So we're given a standup.

      [01:03:40] **Brandon:** All right? Now we are dealing with reference types. So I think we have to be proactive and guard self. So guard, self else return. All right? But if we do that dance, we now have the ability to say, all right, well we have a path. Let's append to the path. What can we append? Well, we can append a detail. And what does it take to create a detail?

      [01:03:59] **Brandon:** Well, we gotta create this model. We have a have to provide a standup. We provide that standup, like, just like that. So I also, we like to use a lot of new lines. So now I think hopefully they'll fix so tap. Oh, okay. So it's still not happening. So there I maybe that purple runtime warning thing was something else.

      [01:04:20] **Brandon:** So let's see. Yeah, debugging live. So standup's list model.

      [01:04:27] **Stephen:** Someone in chat mentioned checking the alert panel, maybe even without the purple runtime warnings. It shows up. There is right now you have it filtered to errors.

      [01:04:37] **Brandon:** Oh, yeah.

      [01:04:38] **Stephen:** At the bottom?

      [01:04:39] **Brandon:** Hmm.

      [01:04:40] **Stephen:** No, it looks like we're just not, we're not getting help from Xcode right now,

      [01:04:44] **Brandon:** but I also, you know, I kind of feel like I Maybe wait,

      [01:04:52] **Stephen:** Check the app entry point. I, I might have missed, but you swap that out.

      [01:04:56] **Brandon:** No, no, I didn't swap that out. Yeah. Okay. Wait. All right. All right. All right, here we go. Yeah. So this is wrong. This isn't, this isn't right. So we need the app view and we need an app model, and we need a a list model. All right. So actually now I actually want to go back to this integration point and I.

      [01:05:22] **Brandon:** you know, accidentally forget this and I wanna see that purple runtime warning. So where do I see my go? Okay, so, all right, I tap it. Nothing happens. Wait. Hmm. Hmm.

      [01:05:41] **Brandon:** All right.

      [01:05:41] **Stephen:** Do you want a break point in the there just to make sure that it is building the latest and greatest?

      [01:05:46] **Brandon:** Yeah. Okay. We are here.

      [01:05:52] **Stephen:** All right.

      [01:05:53] **Brandon:** We are here

      [01:05:55] **Stephen:** promising.

      [01:05:57] **Brandon:** And when I tap, so, so that works. When I tap this, yeah. There's something very simple we're missing. What could it be?

      [01:06:12] **Stephen:** I'm seeing if chat has any ideas. Yeah. They did have us on, are we using app model?

      [01:06:19] **Brandon:** Are we using.

      [01:06:22] **Stephen:** We are now. Yep. Maybe let's follow from the view all.

      [01:06:27] **Brandon:** So, so I think the purple warning definitely is a thing that is just not showing because Yeah, when I, when I plug it, so we're, we're getting drilldowns now, so that's good.

      [01:06:36] **Brandon:** So it, it is working. Just the purple warnings are not working, which I don't like, but you know, I bet if I were to quit Xcode and restart I bet it would work. But I don't wanna do that. All right, so here we go. So we've got that integration point and if we just complete the rest of these, like now you can drill down, but none of these things, so that doesn't do anything.

      [01:06:58] **Brandon:** That doesn't do anything. And this you get the alert because that navigation is kind of siloed inside the detail, but doing this doesn't do anything. So let's just hook them up and we can see what it looks like. So on meeting started, you are handed a standup and we got a weakify self. All right. And we got a guard.

      [01:07:17] **Brandon:** Let self else return. Ugh. and then we can go into our path and we can append again. What do we wanna append? Well, the record screen, what does it take to do that? Well, we gotta provide a standup, which we're given. And so now what I would expect is when we run this, I can drill down. I can drill down. That works.

      [01:07:42] **Brandon:** Alright, so then we've got say the confirmed deletion, right? This one is gonna be interesting. So this is a void to void closure. But we got a weak self. And so I don't know if I already mentioned this, but this is called from that alert. So if I bring up this, if you do this when you hit Yes, that says confirm deletion, that tells the parent, Hey, all right, I do want to be deleted so we can do the guard.

      [01:08:11] **Brandon:** Let self. And All right, so what can we do here? Well, so we have our detail model here. So we do have the detail model, which means we have the standup, which means we know how we know which one we wanna remove. And also on ourselves, we have the standup list model, which has the list of standups. So we wanna remove this standup from this list.

      [01:08:35] **Brandon:** And so we could just use the identified array method, remove id, and remove this ID here. But now we got another potential routine cycle here. We gotta do a weak detail model. We gotta unwrap that too. But that,

      [01:08:50] **Stephen:** There's actually a good question in chat about is it safe to use unowned versus weak in these closures?

      [01:08:56] **Stephen:** Yeah. And I think it kind of boils down to weak is gonna for sure not crash your app. There are always questions as to how is unowned gonna behave. If you want to dive in and try to figure that out. It might be worth having unowned, but in generally we find weak is probably the easy first way to go, especially if you don't control the APIs.

      [01:09:17] **Brandon:** Yeah, I think that the thing that worries us the most about using weak here is just SwiftUI. We see that SwiftUI writes to bindings, like, if you can completely go away and then still write to the binding. And so you could have done everything correct, yet SwiftUI is gonna go and erroneously write that binding, causing your model to execute and then causing something to access an unowned self.

      [01:09:39] **Brandon:** So yeah, I, you know, we think definitely unowned should be used where appropriate, but SwiftUI just kind of throws a wrench in that because it's just so unknowable sometimes. But okay, we've now removed it and then the cool thing is, is we can now go into our path and pop the last element off.

      [01:09:56] **Brandon:** So that should pop us off the stack and let's see what happens here. You know, Layers. Oh, okay. Yeah. Okay. So let's, let's see this. So we do this yes. And we go back and that that one is gone. So delete, and that one's gone. And just to show, you know, how unpredictable SwiftUI can be, let's actually show this because we, we came across, this is if you just reverse the order, if you pop and then remove you will get a crash.

      [01:10:26] **Brandon:** All right? So it crashed. All right. And this is because it just seems like the moment you pop SwiftUI starts doing the work to start popping you off. And then you go in and update the data underneath it, and it must take a snapshot of a old value and then compare it with the new value something goes wrong.

      [01:10:42] **Brandon:** And so this is just an example of, yeah, how, how difficult things can be sometimes with SwiftUI. But, all right, we're getting closer. So we just got these two more things. So on meeting tapped, this is what happens when you're on the detail screen and you tap a meeting. Let's see. It's, we're given a meeting, so there it is.

      [01:11:01] **Brandon:** Gotta guard, let self else return, and then we can take our path and append. And what do we wanna append? We wanna append a meeting screen. We have that meeting and we also have the standup for the, in the same way up here. So I'm gonna capture detail model and self weakly and unwrap detail model.

      [01:11:25] **Brandon:** And now we have detail model dot standup. All right. So with just that one little thing, oh, sorry, I, I should be hiding the simulator more proactively, but with that we should be able drill down and drill down. And there it is. Alright. So we're getting closer and closer. There is, or I'll hide it. Now, there is no integration logic in the meeting screen.

      [01:11:45] **Brandon:** Like that screen is so inert. It's just data. So there's nothing to do there. So we can not do anything there. And then we have on meeting finished. This is when you go to the record screen and you decide to end the meeting. So let's see what it takes. So we're given a string of the transcript. Got a guard.

      [01:12:07] **Brandon:** So we got a weak self. We got a guard. Let self else return. Should be a song. And then we wanna, I mean, I guess there's a bunch of things we wanna do here. So we need to edit the detail. Screen. So we need to get access to detail screen cause we wanna take that newly. Well, all right. We could try.

      [01:12:31] **Brandon:** First, let's construct one of these meetings. So, so what does it take to construct a meeting? Well, we need the transcript. We need the date. Now let's actually go ahead and control this dependency. I mean, we've been talking about dependencies, so let's add a new dependency, I guess have to import dependencies.

      [01:12:50] **Brandon:** There it is. So we have a dependency on the date.now, so that can give us the current data at any time. And we'll get a UUID generator. And so now what we get to do is say, all right, we will generate a new meeting ID with our UUID generator and we'll do self dot now. So we could, you know, write tests for the stuff at some point because those dependencies are controlled.

      [01:13:14] **Brandon:** So now we need to take that meeting and we need to put it into the detail. So how do we get the detail? Well, And this is where like the impreciseness of a stack gets a little bit complicated. because at this point what we assume our stack looks like is that we have a detail and then we have a record screen.

      [01:13:29] **Brandon:** And so this is the screen we're on right now. We're getting this delegate from it and we wanna get access to this thing. So I guess we can do like a guard case guard case. Let, all right, what is, we wanna like take our current path and basically drop the last one. So we'll, we'll drop this one. So now we're focused on, on the, or I guess like, yeah, the last drop, last dot last.

      [01:13:56] **Brandon:** And so we wanna unwrap it as an optional and then further unwrap it as a detail screen and then we would get the detail model. Okay. Whew. And if that doesn't work, then maybe we just early out, although this shouldn't happen, so maybe this is a runtime warning or a logging or pre-condition or something.

      [01:14:14] **Brandon:** But, all right, we got our detail model so we can take that detail model. It's gotta stand up, it's got meetings and we can insert into that and we will insert the meeting we just generated at index zero . Oof. Okay.

      [01:14:28] **Stephen:** And I think we also wanna maybe pop, the stack.

      [01:14:31] **Brandon:** Yeah, we wanna pop too. So we'll take our path and we'll pop last. Alright. And that should work.

      [01:14:41] **Stephen:** You wanna bring up the simulator up?

      [01:14:43] **Brandon:** Oh yeah. Thank you. All right. So I'm gonna drill down. Start a meeting. I'm talking a little bit and I'm gonna end the meeting, save an end. We go back in February 1st, 10:16 AM drill in, and there it is. Okay, so that worked.

      [01:15:00] **Stephen:** Beautiful.

      [01:15:02] **Brandon:** Yeah, not bad.

      [01:15:04] **Brandon:** I do know actually that there is something that we're missing. Actually there's two things we're missing, but this one, if we go to the record meeting and we see what happens when you discard, because I don't know if people saw this fast enough, but if I start the meeting and try to end it early, you get to say, all right, I just wanna discard that is not working.

      [01:15:25] **Brandon:** And the reason for that is when we confirm discard previously, we were just relying on that is dismissed thing that tells the view, oh, all right, I'm gonna write to the environment now to say, dismissed. So this, none of this makes sense anymore. So it's actually what we need is a whole new, like on discard meeting, delegate closure kind of thing.

      [01:15:43] **Brandon:** So this is dismissed just is not. Long for this world. So let's, is dismissed. Let's get rid of all of them. So yeah, we don't need it here. And we already have on meeting finished here. This doesn't make sense. Okay, so, so we need now a new delegate. Closure. Let's add it, I guess. Yeah, we got one here. So just avoid the void, default it and update this.

      [01:16:12] **Brandon:** All right, so now we got a way to tell the parent and, and the parent over in the app everything that integrates together. This is getting gnarly, but let's just keep on moving with it. The record now has a whole new delegate closure to override on discard meeting. We got a weak self. We got a guard. Let self else return and then we can just pop off.

      [01:16:37] **Brandon:** Just take our path. popLast. By the way, I keep on underscoring this because it actually does return something. And we don't want unused warning. So let's run it and drill down, start the meeting, try to end it early, and we discard. We go back and nothing was added. All right. Looking good. And I just happen to know, there's one other thing though.

      [01:17:05] **Brandon:** And that is we had this logic. If I search dot sink, we'll see. We had this logic that we commented out, and what it was doing was that when you're in the detail screen, if you bring up the edit sheet, make some changes, hit save. We needed to replay those changes back in the root standups list. And, and we can see this as a bug right now.

      [01:17:27] **Brandon:** If I hit edit and I changed the name, hit done. We see it changed here yet it did not change here. All right, so. Let's, let's add that integration. So what we need to do, I, I'm just gonna actually gonna copy and paste this for inspiration. I'm gonna go to the integration of everything. And so in the record detail we have, not only do we need to integrate all of these callback closures, but we further have to integrate this where we take our standup list or rather no, we take the detail model, we take the standup on the inside, listen for any changes with sink at a weak self, and we will play that change back to our standups list.

      [01:18:15] **Brandon:** So we've got standups list here, and we will update it at the ID of the standup, and then we'll just wholesale replace everything in there. All right? But we do have to now store this in some cancelable or something. So I'm actually gonna just add a detailCancellable.

      [01:18:36] **Brandon:** So put it right here. A little private var. Oops. Oh, I guess I got a import Combine.

      [01:18:49] **Brandon:** All right. There it is. And that I think will do it if I've actually just reached into the array of standups. And that will do it. So now when we run, show the simulator drill in. Make an edit. Hit done. Go back there. It's all right. I think. I think that's actually the full refactor. And so there's a, a lot of interesting things, and then there's a lot of pros and a lot of cons.
      """
    )
    Episode.TranscriptBlock(
      content: "Refactor pros/cons",
      timestamp: (1 * 60 * 60 + 19 * 60 + 20),
      type: .title
    )
    paragraphs(
      """
      [01:19:28] **Brandon:** You know, I mean, the pros are, you know, very obvious especially when you talk about like, bugs. So all the bugs that we had mentioned before are fixed. So we can drill down, we can start a meeting, we can end, we can save, I can drill down to this, go back, drill down, go back like all this. It just works.

      [01:19:45] **Brandon:** Like it, it just works. So, you know, of course that's a great, that's a positive of course. Yeah. The, the, the cons around, you know, some of the impreciseness, you know, it's just something you have to deal with. And it does manifest itself in a pretty real way. Like, you know, we're doing some gnarly stuff like this because, because we do in this application, it only makes sense to go to record screen if the detail screen came before it.

      [01:20:06] **Brandon:** So, you know, you do have to do stuff like this. But you can also still in, in the application, you can deep link into any state you want. So we could start not here, but rather. at this level. Oh, you know what? I gotta add it to the initializer.

      [01:20:21] **Stephen:** Mm-hmm.

      [01:20:22] **Brandon:** to make this more powerful. So, so let's add this and let's get rid of this default, because what we'll have is initializer here and we'll assign, and now over in the entry point, we're free to, you know, construct a path which can be really cool.

      [01:20:44] **Brandon:** We could say, yeah, let's start where we are drilled down to the detail screen and what detail screen well for the mock standup. And then further we are drilled down to like, say the meeting view. And so we got, we don't have a mock meeting, but I could just take standup dot mock dot meetings, first one and then the mark.

      [01:21:01] **Brandon:** And so if I start this up and yeah, we are just immediately drilled down to that screen. We can go back. We can go back. If you didn't wanna go into the meeting, we could do it to the record screen. So here we got this and we go to the mock. So now when we start up, we're immediately in here, we're recording and everything. We can end the meeting, go back, here's the meeting and yeah, it even transcribed what I was saying.

      [01:21:30] **Brandon:** We deep-linked right into that state, but also at the same time, you can do things that don't make a lot of sense like this. So we are technically now gonna be drilled in to a record meeting Alright? And we're gonna end it early. Oh. Huh? So what I mean, I don't know if this is a SwiftUI or if it's an US bug.

      [01:21:58] **Brandon:** So discard worked just fine yet ending the meeting did not. Hmm.

      [01:22:06] **Stephen:** Well we are doing that integration point where we are getting the array for specific things. So,

      [01:22:13] **Brandon:** That's right.

      [01:22:14] **Stephen:** And this is one of those runtime bugs that wouldn't be possible in the other style.

      [01:22:17] **Brandon:** Yeah. So I think, I guess we just gotta beef up this logic, so it's not true to look for the previous, because now we got a situation where we're in the detail in the meeting, in the record.

      [01:22:29] **Brandon:** And so what you really gotta do is just kinda start from the end and just back up until you see, find the details so that you can do that. I'm not gonna do that, but, you know.

      [01:22:39] **Stephen:** Yeah,

      [01:22:40] **Brandon:** I was hoping for a fun little win.

      [01:22:41] **Stephen:** this seems like a bug.

      [01:22:41] **Brandon:** Yeah. Yeah. This is definitely a bug on, on us, not SwiftUI, but it's, I was hoping for a fun little win there, but it's, things are a little bit more complicated.

      [01:22:51] **Brandon:** So, and then another kind of drawback is, yeah, these screens are now mostly inert. So if I'm gonna run this preview, I'll hide my simulator. So yeah, of course this doesn't do anything. This doesn't do anything. I can't possibly do anything because, you know, they, these screens have been fully decoupled.

      [01:23:13] **Brandon:** You know, so I'm thinking now, I mean, this is kind of what, you know, we wanted to show, there's kind of two ideas. You know, we've been on for an hour and a half, but I, I could see us writing some tests because we could show how the tests have changed. Or we could field more questions or, you know, I don't know.

      [01:23:33] **Stephen:** Yeah. I feel like it, it is a workday, so I don't know how long folks are gonna be able to stick around.

      [01:23:38] **Brandon:** Yeah.

      [01:23:39] **Stephen:** There's a bunch of Q&amp;A. I don't think we'll have time to get to all of it, but I think we can save some of them for future streams. They'll, they'll kinda stay there in the archive. But yeah, I don't know.
      """
    )
    Episode.TranscriptBlock(
      content: "Final Q&A",
      timestamp: (1 * 60 * 60 + 23 * 60 + 59),
      type: .title
    )
    paragraphs(
      """
      [01:23:50] **Stephen:** We could also see what chat is interested in for the next maybe five to 15 minutes.

      [01:23:57] **Brandon:** Yeah. Should we spend five to ten, you know, we could also do a poll hilariously So yeah. Do we wanna spend five to 10 minutes writing tests or five to 10 minutes? I'm gonna actually do a poll. How should we spend the last five to 10 minutes?

      [01:24:16] **Brandon:** So, write tests, answer Qs.

      [01:24:27] **Brandon:** Okay. Let's see. Does that work? Oh, wait. Oh, wow. People are

      [01:24:34] **Stephen:** overwhelmingly don't wanna write tests.

      [01:24:37] **Brandon:** Yeah. What is it? Okay. Why? Alright. Okay. Okay. Okay. Alright. I'm gonna hide it. Oh, I'll publish the results. because I guess, I guess no one or wait, let me, oh, I don't know if, oh, yeah, there they are. So, so I, that's, well,

      [01:24:51] **Stephen:** We'll leave tests as a exercise for whoever is brave enough.

      [01:24:54] **Brandon:** Yeah. All right. Let's, let's also, yeah, let's, let's do some Qs.

      [01:25:03] **Stephen:** I don't know if we wanna go back to any dependency stuff. There are a bunch like voted on, so we could do some of the higher voted ones first.

      [01:25:13] **Brandon:** Oh yeah, I guess so. That's, that's a good idea. Alright, so,

      [01:25:18] **Stephen:** so one thing that maybe would be good for you to answer, since you just gave a tour of navigation in standups is this first one.

      [01:25:26] **Brandon:** Yeah, exactly. Yeah. Okay. So yeah, I kind of hope. Basically the, this entire like little demo answered this question. But yeah, so while it can be a little bit annoying to couple destinations, it actually can be super powerful too. Now, hopefully Apple fixes some of the bugs that would really unlock that.

      [01:25:50] **Brandon:** But what you've seen, what we just did is we completely flattened it. We, we could put the detail in its own module. That doesn't depend on anything. We could put the list in its own module, the record screen in its own module, no dependencies between them, and it would all just work. And also, you'll notice that we did all that without ever mentioning the word coordinator or router.

      [01:26:08] **Brandon:** If those words, you know, mean something to you as a, as a general style of doing something, that's great. But I honestly, the, the technology is far simpler. It really is just a destination enum holding your models, a little bit of integration glue and boom, you're done. So yeah hopefully what we described here answers that.

      [01:26:29] **Stephen:** Yep. And then, yeah, there's just a whole grab bag here. I dunno if you wanna pick the next one.

      [01:26:37] **Brandon:** Yeah, sure. Yeah, I'll just sort by popular. Oh yeah, I thought this was a really fun one. So yeah, absolutely. Basically the standups application has just been a really good demo of building an application.

      [01:26:56] **Brandon:** So what our plan is, is our next series episodes is gonna be Composable Architecture navigation. It's either gonna be next week or the week after. And we, once we're done with that, we will be finally ready for a 1.0 and we Composable architecture and we will do a another tour series of episodes on the Composable Architecture using all the new things.

      [01:27:18] **Brandon:** And in our minds right now, we're thinking we'll probably just build the standups app with Composable architecture. Yeah.

      [01:27:26] **Stephen:** There are two questions that are pretty closely related to one another. on dependencies. I'll put them up one after the other. The first was this from Matthias. How would you define dependency where the init is async? And this kinda goes back to a conversation we had earlier in the stream, which is we should think of these dependencies as interfaces that kind of have a bunch of endpoints. And so if the initializer of some of your dependency is async, you would kind of hide that detail away and instead you would have an async endpoint.

      [01:28:04] **Stephen:** that happens to return whatever client that you need to do its job. And so you may have an actor that needs to have some kind of async, initialized initialization, and that actor would be long living, but the very first time you hit that endpoint, it does that in it in an async fashion. And then on future, like endpoints getting hit, it'll just call down to the existing actor.

      [01:28:27] **Stephen:** And that kind of also to this other question, Yeah. anonymous, which is what do actor based dependencies look like? . And I think when actors were first announced in Swift evolution, Brandon and I were kind of chatting, how is this gonna work? Are we gonna have actors be dependencies? And we explored that, but we inevitably found that actors are great for dependencies.

      [01:28:51] **Stephen:** But you kind of hide that detail away in the live implementation. And we still think that structs with kind of async endpoints are the way to go, the lightest weight way of actually managing the design of the dependency.

      [01:29:08] **Brandon:** All right. Let's see. Looking through,

      [01:29:18] **Stephen:** There are a bunch of Composable Architecture questions that I think we'll save for another time. Yeah, a bunch about navigation. We'll be doing episodes on that very soon, so you'll just have to wait.

      [01:29:28] **Brandon:** Yeah, I'll just throw this one up. I think maybe this yeah, this came up like right when I was starting the thing, but by the end we've kind of solved that destination cycle.

      [01:29:40] **Brandon:** It's funny, the question is covering my face, but we've co covered that topic. Hopefully by, by moving to the stack, if you do have cycles in your navigation, then then yeah, the stack is great for that. But if you don't have cycles, if you have a well-defined finite set of navigation paths, then the tree based works really well.

      [01:30:00] **Stephen:** Great. There is a adjacent question about swift navigation or SwiftUI navigation, I guess, and TCA. , and it's basically a lot of folks have tried bringing SwiftUI navigation into the Composable Architecture with varying success. I think mostly not much success, and that's just because SwiftUI navigation was designed for Vanilla SwiftUI, and in order to integrate it in the Composable Architecture, you basically lose out on all the things that we like about the Composable Architecture.

      [01:30:34] **Stephen:** And so that's why we have our own like, kind of thinking about it from the bottom up. And we'll be revisiting a lot of the topics from the vanilla episodes, but it's gonna be dedicated to just the Composable Architecture.

      [01:30:47] **Brandon:** Yep. All right. Here's, here's one, too all right. So the, the problem of case paths and you know, it's funny how the questions wait, I guess.

      [01:31:00] **Brandon:** All right. So yeah, so the case paths

      [01:31:02] **Stephen:** you can go back to the screen share and we can see your lovely face again.

      [01:31:06] **Brandon:** Okay. Yeah. Okay. So the so case paths are, yeah, they're great. They're not in the language yet. There has been a little bit of movement in the evolution forms, the person working on it. because I mean, we, we can't write the c plus plus to do it, so the person working on it has been working on some of the, the newer runtime reflection stuff and maybe some of that would, stuff will dovetail into case paths.

      [01:31:30] **Brandon:** So yeah, we hope that there will be movement on it or hopefully maybe the language will even get features that allow us to just kinda add it in the way we want on top of the language, whether it's the runtime metadata or the macros or whatever. But yeah. And, and we'll be kind of hinting at some of the stuff too in our upcoming swift or TCA navigation stuff, because the case best stuff, it's.

      [01:31:51] **Brandon:** If, if you only think of it in terms of just like an extract function, like the, the ability to extract a value from an enum, you're just missing half the story. The embed story is extremely important and the way that, it seems like the first step of getting case paths into swift, it's only gonna focus on extraction, which means we won't even be able to use it for TCA unfortunately.

      [01:32:11] **Brandon:** And so yeah, so we're hoping we can be active in that to try to push it towards getting extraction and embed, because I mean, after all, like key paths would not be nearly as powerful as they are if it wasn't for reading and writing. Like you need the writing, you need the embed. So yeah, we'll, we'll see how that goes.

      [01:32:28] **Brandon:** But yeah, we we're trying to push it forward, but of course we can't implement it.

      [01:32:33] **Stephen:** Yep. And there's another great question kind of related, which is what are the future swift features that kind of are exciting us the most right now?

      [01:32:43] **Brandon:** Oops. I think I actually got,

      [01:32:45] **Stephen:** I'll show it again.

      [01:32:46] **Stephen:** Yep. And there are a, a bunch that have just kind of flooded the forums in the past month or two that we are excited to check out.

      [01:32:57] **Stephen:** Brandon, you may have more to say, but I think the ones that kind of stood out to us were the observation proposal, which should hopefully make TCA even more powerful and even more platform agnostic. And I think the other one that is interesting, but we haven't thought about it enough are macros. I think macros will maybe unlock a bunch of interesting opportunities for us.

      [01:33:21] **Brandon:** Yep. Well, I mean, yeah, we're, I mean, could wrap up little Yeah. , I mean, yeah, there's a,
      """
    )
    Episode.TranscriptBlock(
      content: "Conclusion",
      timestamp: (1 * 60 * 60 + 33 * 60 + 26),
      type: .title
    )
    paragraphs(
      """
      [01:33:37] **Stephen:** I think, I think it would be impossible to cover all these without spending another few hours.

      [01:33:43] **Brandon:** Yeah.

      [01:33:44] **Stephen:** But I think we will. Be doing more of these. I think this was a lot of fun. I'm, I'm hoping that everyone had a good time and yeah, if you have any feedback, you can, you know, contact us directly, you can join our new Slack and leave feedback there if there are things you wanna see from future streams.

      [01:34:06] **Stephen:** And yeah, maybe we'll take some of these questions and flesh out some blog posts.

      [01:34:10] **Brandon:** Yeah. Yeah, I mean, the questions have been great for just for us figuring out other things that we may wanna do in the future. So, I dunno. Yeah, let's just wrap it up while we're ahead, before something goes wrong.

      [01:34:21] **Stephen:** All right then.

      [01:34:22] **Brandon:** All right. See you later.

      [01:34:25] **Stephen:** Yep. Till next time.

      [01:34:25] **Brandon:** Till next time.
      """
    )
  }
}
