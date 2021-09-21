import Foundation

extension Episode {
  static let ep16_dependencyInjectionMadeEasy = Episode(
    blurb: """
Today we're going to control the world! Well, dependencies to the outside world, at least. We'll define the \
"dependency injection" problem and show a lightweight solution that can be implemented in your code base \
with little work and no third party library.
""",
    codeSampleDirectory: "0016-dependency-injection",
    exercises: _exercises,
    id: 16,
    image: "https://i.vimeocdn.com/video/804927879-97ee0bd9099d105488975a5fcda0361ec06eb43d8133307adb21ffe085fe68d5-d",
    length: 35*60 + 14,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_526_896_623),
    references: [
      .structureAndInterpretationOfSwiftPrograms,
      .howToControlTheWorld,
    ],
    sequence: 16,
    title: "Dependency Injection Made Easy",
    trailerVideo: .init(
      bytesLength: 30335465,
      vimeoId: 352747419,
      vimeoSecret: "0580507d35ddda1226333ab6f7c62f56e27550f6"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Today's episode was powered by playground-driven development, but we're talking about real-world code and that kind of code usually lives in an application target. The following exercises explore how to apply playground-driven development to actual application code.

1. [Download the episode code](https://github.com/pointfreeco/episode-code-samples/tree/main/0016-dependency-injection) and copy it into a new iOS project called "Repos". The app should display the repos navigation controller as the window's root view controller.

1. Add a framework target to the project called "ReposKit" and embed it in the Repos app. Move all of our application code (aside from the app delegate) to ReposKit. Make sure that the source files are members of the framework target, not the app target. Repos should `import ReposKit` into the app delegate in order to access and instantiate the `ReposViewController`. Build the application to make sure everything still works (you will need to make some types and functions `public`).

1. Create an iOS playground and drag it into your app project. Import ReposKit, instantiate a `ReposViewController`, and set it as the playground's live view. You can use our original playground code as a reference.

1. Swap out the `Current`, live world for our `mock` one. This playground page can now act as a living reference for this screen! You can modify the `mock` to test different states, and to test changes to the view controller, you can rebuild ReposKit.
"""),
  Episode.Exercise(problem: """
There are a few dependencies in the application that we didn't cover. Let's explore controlling them over a couple exercises.

1. The analytics client is calling out to several singletons: `Bundle.main`, `UIScreen.main`, and `UIDevice.current`. Extract these dependencies to `Environment`. What are some advantages of controlling these dependencies?

1. `DateComponentsFormatter` can produce different strings for different languages and locales, but defaults to the device locale. Extract this dependency to `Environment`, control it on the formatter, and demonstrate how mocking `Current` allows you to test formatting over different languages and locales.
"""),
]
