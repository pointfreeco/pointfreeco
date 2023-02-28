import Foundation

extension Episode {
  public static let ep143_tourOfIsowords = Episode(
    blurb: """
      Let's dive deeper into the [isowords](https://www.isowords.xyz) code base. We'll explore how the Composable Architecture and modularization unlocked many things, including the ability to add an onboarding experience without any changes to feature code, an App Clip, and even App Store assets.
      """,
    codeSampleDirectory: "0143-tour-of-isowords-pt2",
    exercises: _exercises,
    id: 143,
    length: 57 * 60 + 1,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_619_413_200),
    references: [
      .isowords,
      .isowordsGitHub,
      .theComposableArchitecture,
      reference(
        forCollection: .composableArchitecture,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/composable-architecture"
      ),
    ],
    sequence: 143,
    subtitle: "Part 2",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 75_022_146,
      downloadUrls: .s3(
        hd1080: "0143-trailer-1080p-6291679ac8c3483fb0c4721bee70a305",
        hd720: "0143-trailer-720p-ec8c4971b8474292bd3e4ed6e193f360",
        sd540: "0143-trailer-540p-db30504eeba148a5b78d757504b89be5"
      ),
      vimeoId: 538_473_438
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 143)
  )
}

private let _exercises: [Episode.Exercise] = []

extension Episode.Video {
  public static let ep143_tourOfIsowords = Self(
    bytesLength: 669_144_331,
    downloadUrls: .s3(
      hd1080: "0143-1080p-7a9c136fc3414f62a08a3188ba698c9e",
      hd720: "0143-720p-65fd415292954c0bbd695c97afe539dd",
      sd540: "0143-540p-8cd7e65c26bd4ad0b56de7de3cd5e8db"
    ),
    vimeoId: 538_473_576
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep143_tourOfIsowords: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s pretty incredible how easy it is to test such a complex and subtle flow. We are testing how our code would behave if Game Center started sending back errors, and these kinds of unhappy paths are usually the least tested in code bases because typically they are a pain to get test coverage on.
        """#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, that’s a very quick tour of how the Composable Architecture is used in isowords. We just want to iterate that indeed you can build a complex application with the Composable Architecture, and indeed a single source of truth can power the entire app. And when you do this it can be very easy to jump into any part of the application and have some idea of what is going on because the domain, logic and view are nicely separated and understandable in isolation.
        """#,
      timestamp: 21,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Onboarding design"#,
      timestamp: 51,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now that we have a broad overview of how the project is structured, let’s dive deeper into some particular features of isowords to see how they were actually built. Let’s start with one of my favorites: onboarding.
        """#,
      timestamp: 51,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Onboarding is the first thing people see when they come to the app, and it should be short and engaging so that people actually complete it because there are some tricks that one needs to know to enjoy the game, such as double tapping a cube to remove it.
        """#,
      timestamp: (1 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’ve settled on a user experience that has the player complete a few simple tasks. First we have them find 3 simple words with more and more letters revealed so that they can experience what it’s like to connect letters together, and most important, finding the last word causes a cube to remove, which is the key game mechanic behind isowords.
        """#,
      timestamp: (1 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The user experience for onboarding is very important, but so is the developer experience for building onboarding. The easier it is for us to build rich experiences like this the more likely we are to do it, and the more likely we are to not accidentally break it in the future as our application evolves.
        """#,
      timestamp: (1 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we approach this in a naive way we may be tempted to sprinkle code throughout our core game feature to get the job done. We’d add extra state to track things that are only specific to onboarding, we’d expose little escape hatches in various parts of the game so that we could hook into certain events, like when a specific word is highlighted on the cube, and we’d litter our view with additional logic to hide things not important for onboarding and show new things that are important for onboarding.
        """#,
      timestamp: (1 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, we were able to implement this onboarding feature without adding a single line of code to the core game feature. It is entirely an additional layer that is put on top of the game, and it is done using techniques that we described [in our series of episodes](/collections/swiftui/redactions) exploring SwiftUI’s redaction feature, which gave us the opportunity to show how to build an onboarding feature for a todo app.
        """#,
      timestamp: (2 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let's take a look at the onboarding feature.
        """#,
      timestamp: (2 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can start by hopping over to `OnboardingView.swift` where the majority of onboarding code resides, and we can take advantage of our hyper-modularization to switch our active target to `OnboardingFeature` so that we build only what is necessary for this feature. No need to build the entire application target anymore.
        """#,
      timestamp: (3 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The first thing we will see in the file is the `OnboardingState`:
        """#,
      timestamp: (3 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct OnboardingState: Equatable {
          public var alert: AlertState<OnboardingAction.AlertAction>?
          public var game: GameState
          public var presentationStyle: PresentationStyle
          public var step: Step
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This clearly shows that we are taking the `GameState` and just adding a bit more state on top of it. It is crucial to see that we did not let any of this additional state infect `GameState`, which should not need to care about onboarding concerns at all.
        """#,
      timestamp: (3 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The other state in here helps us implement the onboarding feature. We have some alert state for prompting the player when they try to skip just to make sure they want to do that. We have a `presentationStyle` value that determines how this onboarding is being shown:
        """#,
      timestamp: (3 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public enum PresentationStyle {
          case demo
          case firstLaunch
          case help
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Here `.demo` is used when showing onboarding from the App Clip, `.firstLaunch` is used when showing onboarding from the first time you launch the main application, and `.help` is used when you tap on the question mark icon from the home screen. We make small tweaks to onboarding depending on the value of this field.
        """#,
      timestamp: (3 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And finally we have a `Step` value, which is a big enum that describes every single step in the onboarding flow. This is exactly how we designed onboarding in our past [episodes on SwiftUI redactions](/collections/swiftui/redactions).
        """#,
      timestamp: (4 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we have the onboarding actions enum. This describes all of the things you can do in onboarding, such as interacting with the alert, tapping the next or skip button, along with all the things that happen in the game itself:
        """#,
      timestamp: (4 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public enum OnboardingAction: Equatable {
          case alert(AlertAction)
          case delayedNextStep
          case delegate(DelegateAction)
          case game(GameAction)
          case getStartedButtonTapped
          case onAppear
          case nextButtonTapped
          case skipButtonTapped

          public enum AlertAction: Equatable {
            case confirmSkipButtonTapped
            case dismiss
            case resumeButtonTapped
            case skipButtonTapped
          }

          public enum DelegateAction {
            case getStarted
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        These are all actions that would have infected our game domain had we not tried to separate them.
        """#,
      timestamp: (4 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we have the onboarding environment, which holds just a few dependencies that are necessary to run the onboarding feature:
        """#,
      timestamp: (5 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct OnboardingEnvironment {
          var audioPlayer: AudioPlayerClient
          var backgroundQueue: AnySchedulerOf<DispatchQueue>
          var dictionary: DictionaryClient
          var feedbackGenerator: FeedbackGeneratorClient
          var lowPowerMode: LowPowerModeClient
          var mainQueue: AnySchedulerOf<DispatchQueue>
          var mainRunLoop: AnySchedulerOf<RunLoop>
          var userDefaults: UserDefaultsClient
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We have a computed property on this type that is really interesting. It derives a full `GameEnvironment` from the `OnboardingEnvironment`. The game needs a lot more dependencies to do its job than onboarding does, but for the purpose of onboarding many of them are not needed.
        """#,
      timestamp: (5 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, we don’t need an `apiClient` because we don’t need to communicate with the server to do onboarding and we don’t need Game Center or Store Kit because turn-based games and in-app purchases aren’t necessary in onboarding. In fact, more than half of the dependencies are needed at all. And so we employ a technique we explored very recently on Point-Free to fill in all these unnecessary dependencies by creating lightweight “no-op” versions of the dependencies to use:
        """#,
      timestamp: (5 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var gameEnvironment: GameEnvironment {
          GameEnvironment(
            apiClient: .noop,
            applicationClient: .noop,
            audioPlayer: self.audioPlayer,
            backgroundQueue: self.backgroundQueue,
            build: .noop,
            database: .noop,
            dictionary: self.dictionary,
            feedbackGenerator: self.feedbackGenerator,
            fileClient: .noop,
            gameCenter: .noop,
            lowPowerMode: self.lowPowerMode,
            mainQueue: self.mainQueue,
            mainRunLoop: self.mainRunLoop,
            remoteNotifications: .noop,
            serverConfig: .noop,
            setUserInterfaceStyle: { _ in .none },
            storeKit: .noop,
            userDefaults: self.userDefaults,
            userNotifications: .noop
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        These `.noop` dependencies basically do nothing. They just return effects that emit no values and complete immediately. They are perfect for sticking in inert dependencies in spots you are forced to provide something.
        """#,
      timestamp: (5 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next down the file we come to the `onboardingReducer`, and this is the real workhorse of the onboarding feature:
        """#,
      timestamp: (5 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public let onboardingReducer = Reducer<
          OnboardingState,
          OnboardingAction,
          OnboardingEnvironment
        > { state, action, environment in
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Many of the actions this reducer handles are pretty straightforward. They take care of things like moving onboarding to the last step when we confirm in the alert that we want to skip onboarding:
        """#,
      timestamp: (4 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .alert(.confirmSkipButtonTapped):
          state.step = OnboardingState.Step.allCases.last!
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Or when the “Next” button is tapped we simply move us to the next step and play a little sound effect:
        """#,
      timestamp: (6 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .nextButtonTapped:
          state.step.next()
          return environment.audioPlayer.play(.uiSfxTap)
            .fireAndForget()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then there’s the spots where we tap into the `.game` actions. This allows us to peek inside the game domain and see absolutely everything that is happening. We can spy on actions coming in and decide to either allow them through or filter them out, or we can layer on additional logic before or after the core game reducer runs. This is like a super power of the Composable Architecture.
        """#,
      timestamp: (6 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, the first interception of game actions happens when we check to see if we are in a “congrats” step:
        """#,
      timestamp: (6 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .game where state.step.isCongratsStep:
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        A “congrats” step is one that happens immediately after the player accomplishes a task, such as finding a word. A message is shown for a few seconds, and then they are automatically taken to the next step.
        """#,
      timestamp: (7 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Here we are completely short-circuiting all game logic and returning no effects when we are on a congrats step, which effectively makes the entire game cube inert. No matter how much we tap or swipe on the cube nothing will happen.
        """#,
      timestamp: (7 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Sometimes we don’t want to wholesale skip the game’s logic but rather just augment it a little. For example, when a word is submitted we can check which word was submitted so that we can advance you to the next step, such as when you find “GAME”, “CUBES” or “REMOVE”:
        """#,
      timestamp: (7 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .game(.submitButtonTapped):
          switch state.step {
          case .step5_Submit where state.game.selectedWordString == "GAME",
            .step8_FindCubes where state.game.selectedWordString == "CUBES",
            .step12_CubeIsShaking where state.game.selectedWordString.isRemove,
            .step16_FindAnyWord where environment.dictionary.contains(state.game.selectedWordString, .en):

            state.step.next()

            return onboardingGameReducer.run(
              &state,
              .game(.submitButtonTapped(nil)),
              environment
            )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Here we do a little bit of logic first to advance your step, and then we run the game reducer like normal so that we the cube updates its state, sound effects play, etc.
        """#,
      timestamp: (7 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There are more simple examples of this technique where we listen for specific game actions so that we can perform additional logic, but let’s look at a more advance technique. We can also listen for changes of state in the game domain and use that to trigger new logic.
        """#,
      timestamp: (8 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, the onboarding flow will automatically move you forward a step when you select the word “GAME”. And then if you unselect a letter you will automatically be moved back a step.
        """#,
      timestamp: (8 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The way we accomplish this is to listen for state change on the selected word, and when you are on a particular step and select a particular word we advance you, and if you are on a particular step and you do not select a particular word we take you back. We do this using an experimental operator on `Reducer` called `.onChange`, which allows you to execute some additional logic and effects when a certain part of state changes:
        """#,
      timestamp: (9 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .onChange(of: \.game.selectedWordString) { selectedWord, state, _, _ in
          switch state.step {
          case .step4_FindGame where selectedWord == "GAME",
            .step11_FindRemove where selectedWord.isRemove:
            state.step.next()
            return .none
          case .step5_Submit where selectedWord != "GAME",
            .step12_CubeIsShaking where !selectedWord.isRemove:
            state.step.previous()
            return .none
          default:
            return .none
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Currently this operator only lives [in the isowords code base](https://github.com/pointfreeco/isowords/blob/c2793f4aacbbe5273062ab2a064bb743b74bf9de/Sources/TcaHelpers/OnChange.swift#L4), but we hope to bring it to everyone some day. In the meantime, if you find it useful feel free to copy and paste it into your own projects!
        """#,
      timestamp: (9 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The final part of onboarding is the view, which is quite short. All it has to do is `ZStack` the cube view, a view that renders the instructions for each step, as well as a skip button in the top right:
        """#,
      timestamp: (10 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public var body: some View {
          ZStack(alignment: .topTrailing) {
            CubeView(
              store: self.store.scope(
                state: cubeSceneViewState(onboardingState:),
                action: { .game(CubeSceneView.ViewAction.to(gameAction: $0)) }
              )
            )
            .opacity(viewStore.step.isFullscreen ? 0 : 1)

            OnboardingStepView(store: self.store)

            if viewStore.isSkipButtonVisible {
              Button("Skip") { viewStore.send(.skipButtonTapped, animation: .default) }
                .adaptiveFont(.matterMedium, size: 18)
                .buttonStyle(PlainButtonStyle())
                .padding([.leading, .trailing])
                .foregroundColor(
                  self.colorScheme == .dark
                    ? viewStore.step.color
                    : Color.isowordsBlack
                )
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And that is basically all there is to onboarding. In just about 500 lines of code we are able to build the entire feature, and most importantly we didn’t have to make a single change to the core game code. It is absolutely amazing to see the kind of separation and isolation you can achieve with the Composable Architecture.
        """#,
      timestamp: (10 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Onboarding tests"#,
      timestamp: (10 * 60 + 51),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        And even better, you can write tests for the whole thing! None of the code written to make the onboarding feature is out of reach from a simple unit test. Every time we intercept a game action so that we can layer on some additional logic we can do so with confidence because we can write an exhaustive test that proves that extra logic behaves how we expect and that it does not interfere with the core game’s logic.
        """#,
      timestamp: (10 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Don’t believe us? Let’s hop over to `OnboardingFeatureTests.swift` and see what the test looks like.
        """#,
      timestamp: (11 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s a few tests in this file, but there’s [one really loooong one](https://github.com/pointfreeco/isowords/blob/c2793f4aacbbe5273062ab2a064bb743b74bf9de/Tests/OnboardingFeatureTests/OnboardingFeatureTests.swift#L10). It tests the full flow of going through onboarding. We can even search for the string `store.` in order to see exactly how we feed actions into the system and how effects are executed. We see very clearly that:
        """#,
      timestamp: (11 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We start by emulating `.onAppear` to kick off onboarding
        """#,
      timestamp: (11 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - A few seconds later we receive the `.delayedNextStep` action because the introductory text stays on the screen for a brief moment before automatically going to the next step.
        """#,
      timestamp: (12 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We then send the `.nextButtonTapped` action a few times to emulate the user going to the next few steps.
        """#,
      timestamp: (12 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Then we get to a really meaty part of the test where we actually emulate the user tapping and selecting certain faces of the cube. In particular, we select the word “GAME”, tracking every single state change along the way. One particular cool part is the moment we find the last letter “E” we automatically advance to the next step `$0.step = .step5_SubmitGame` which updates the informational text to let the user know they tap the thumbs up button to submit.
        """#,
      timestamp: (12 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Then we submit the word. That causes a bunch of state to change.
        """#,
      timestamp: (13 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We do this kind of a thing a few more times until we get to one of the last steps where the goal is to double tap a cube to remove it. This is an important game mechanic to know about to play isowords effectively, and we can easily mimic this gesture by simply sending the `.doubleTap` action.
        """#,
      timestamp: (13 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - After all of that we progress to the end of the onboarding and tap the “Get Started” button to complete onboarding.
        """#,
      timestamp: (15 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So not only have we built a fully interactive onboarding experience on top of an existing isowords feature, we’ve done so without letting any onboarding code infect the core feature, and the entire thing was testable. We can be certain that our onboarding layer is interacting with the underlying game layer as we expect, nothing is hidden away from us as. It’s honestly pretty amazing.
        """#,
      timestamp: (15 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"App Clip modularization"#,
      timestamp: (16 * 60 + 30),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s take a look at a feature that is closely related to onboarding, but comes with a whole new set of challenges. It will gives us an opportunity to demonstrate the importance of modularizing your application and separating the lightweight interface of dependencies from the heavyweight implementations.
        """#,
      timestamp: (16 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The feature is our App Clip.
        """#,
      timestamp: (16 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If you didn’t already know App Clips are an iOS 14 feature that allow you to run very tiny applications on a user’s device from mobile Safari and Messages without having to install the application from the App Store. We use App Clips to allow people to play a 3 minute demo puzzle without needing to install the full app.
        """#,
      timestamp: (16 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Building an App Clip is mostly straightforward, except for the fact that the entire compiled binary must be less than 10 MB uncompressed. So you have to be very careful to compile only the bare minimum of code for your demo, as well as omit any unnecessary resources. This took a bit of work for us to accomplish our game has quite a few resources, including 8 MB of sounds alone.
        """#,
      timestamp: (17 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s start by switching to the `AppClip` target and build it to run in the simulator. The clip starts with the onboarding experience we just discussed so that the new user can get a quick tutorial on how to play the game. Since we’ve already seen this let’s skip it.
        """#,
      timestamp: (17 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then we are dropped into a random 3 minute timed game. You’ll notice the UI is a little different. There’s a banner at the top that allows the user to immediately jump to the App Store if they’re already sold on the game.
        """#,
      timestamp: (18 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s quickly play this game.
        """#,
      timestamp: (18 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Once the timer is out we land on the game over screen, which shows us how our score ranked against the greater isowords community and gives us a handy banner for downloading the game directly from the App Clip.
        """#,
      timestamp: (18 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, how did we build this while keeping the compiled binary under 10 MB uncompressed??
        """#,
      timestamp: (18 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Well, we can take a peek at `AppClipApp.swift` to see the entry point for the entire application. What we will find is that it looks almost identical to the entry point for the main application. There’s the main app that kicks off something called a `DemoView`, and we create it by supplying a store with some `DemoState`, a `demoReducer` and a live `DemoEnvironment`:
        """#,
      timestamp: (18 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        @main
        struct AppClipApp: App {
          init() {
            Styleguide.registerFonts()
          }

          var body: some Scene {
            WindowGroup {
              DemoView(
                store: Store(
                  initialState: DemoState(),
                  reducer: demoReducer,
                  environment: .live
                )
              )
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The live environment is mostly straightforward, just passing along live dependencies:
        """#,
      timestamp: (19 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension DemoEnvironment {
          static var live: Self {
            Self(
              apiClient: .appClip,
              applicationClient: .live,
              audioPlayer: .live(bundles: [AppClipAudioLibrary.bundle]),
              backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
              build: .live,
              dictionary: .file(),
              feedbackGenerator: .live,
              lowPowerMode: .live,
              mainQueue: .main,
              mainRunLoop: .main,
              userDefaults: .live()
            )
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Except for the `apiClient`, which is being passed an `.appClip` version of the dependency, which we will discuss in a bit.
        """#,
      timestamp: (19 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `DemoView` being referenced here is a view living in the `DemoFeature` module, which is the module that provides all of the functionality of the app clip. Remember that we try to not put any significant code in application targets and instead it all goes in an SPM module. This module is our opportunity to include only the bare essentials to implement the feature, in the hopes we stay below the 10 MB limit. If we look at how the `DemoFeature` is described in `Package.swift` we will see we depend on only the bare essentials:
        """#,
      timestamp: (19 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .target(
          name: "DemoFeature",
          dependencies: [
            "ApiClient",
            "Build",
            "GameCore",
            "DictionaryClient",
            "FeedbackGeneratorClient",
            "LowPowerModeClient",
            "OnboardingFeature",
            "SharedModels",
            "UserDefaultsClient",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          ]
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        In particular, we need the `GameCore` because the user needs to be able to play a full game. We also need `OnboardingFeature` because we start the clip with that experience. But everything else in here is super lightweight dependencies that basically compile instantly and whose compiled code should be very small. All the “client” modules we see in here are just simple structs that specify the interface of the dependency and crucially not the live implementation:
        """#,
      timestamp: (20 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `ApiClient` is what allows us to submit our score to the server when you finish your game.
        """#,
      timestamp: (20 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `DictionaryClient` contains the interface for interacting with the dictionary that tells us what words are valid and invalid, but it does not actually contain the dictionary.
        """#,
      timestamp: (20 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `FeedbackGeneratorClient` is how we execute haptics while tapping around on the cube.
        """#,
      timestamp: (20 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `LowPowerModeClient` allows us to observe changes in low power mode on the device, which we use to disable the gyro scope and shadows when on low power mode in hopes of giving your device a little extra life.
        """#,
      timestamp: (20 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `UserDefaultsClient` is our basic wrapper around `UserDefaults`, allowing us to get and set values in a shared set of storage on the device.
        """#,
      timestamp: (21 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The most important part of how these dependencies are specified is that we only use the interfaces of the dependencies, not the live implementations. This is something we have talked about a lot on Point-Free in our series of episodes entitled “[Designing Dependencies](/collections/dependencies/designing-dependencies).”
        """#,
      timestamp: (21 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We are taking advantage of this in two crucial ways here.
        """#,
      timestamp: (21 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - First, the `ApiClient` module contains just the interface of the API client, not any of the actual code for executing network requests. Now typically that network request would just be using `URLSession` under the hood, which comes for free and so incurs no additional size to compile. However, we use our experimental invertible parser printer library to simultaneously power our API client used in the iOS app and the server router that powers the API. Unfortunately that code isn’t super modularized and tidy, and so it builds a lot more than necessary and kinda bloats the code size. So, we separate that heavy stuff in an `ApiClientLive` module so that we don’t have to build any of it unless we absolutely need to. And fortunately we don’t need all that heavy stuff for the app clip because there’s only one single API endpoint that can be access, the game submission endpoint. That allowed us to shave off nearly a full megabyte from the App Clip, which was crucial to getting us under the limit.
        """#,
      timestamp: (21 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Second, the `DictionaryClient` contains only the interface to accessing the dictionary, not the actual dictionary itself. In the regular application we use a SQLite database for our dictionary because for certain functionality we need an efficient way of checking if a set of characters matches the prefix of a word. SQLite makes this easy and efficient, whereas if we had a simple array of strings we’d have to do extra work to create an index for the prefixes.

            However, the SQLite file for our dictionary is quite big, over 5 megabytes. That makes sense, after all SQLite has indices and other metadata it needs to pack in, but it also eats away at half of our allotted size for the App Clip. So, that’s why we house the SQLite implementation of the `DictionaryClient` interface in a separate module called `DictionarySqliteClient`, and have another live implementation of the dictionary called `DictionaryFileClient` which is based off a simple flat text file of words and when compressed is only 700 KB, less than 15% of the size.

            This allows us to use the file dictionary client for the App Clip to save some space at the cost of losing a bit of functionality, and use the SQLite dictionary client in the main application where it’s ok to use up a bit of extra space.
        """#,
      timestamp: (22 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, we can say with certainty that it would have been much, much, much more difficult to make an App Clip if it wasn’t for our little bit of upfront work to properly model our dependency and modularize the code base. It didn’t require a huge overhaul of our application. We had all the tools at our disposal and just needed to do a little bit more to push it over the edge.
        """#,
      timestamp: (23 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There are a few other spots we take advantage of separating the heavy stuff from the lightweight dependency interfaces, but that’s over on the server so we’ll check that out in a bit.
        """#,
      timestamp: (24 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Preview apps vs. Xcode previews"#,
      timestamp: (24 * 60 + 18),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        And making App Clips isn’t the only benefit we got from modularizing our app and separating out the heavy stuff from the lightweight stuff. It also gave us an opportunity to spin up little “preview” apps that build a subset of all the features in isowords so that we could run it in a simulator or on a device.
        """#,
      timestamp: (24 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        All of our preview apps are housed in a directory called `Previews` inside the `App` directory, which remember is where we store all of our app targets and these targets basically contain no real code. Just code for configuring and launching the application.
        """#,
      timestamp: (24 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can also press control+0 in Xcode to see all of our modules, and filter this list by searching for “preview”. This shows that we have previews for the cube, game over, home, onboarding, trailer and more.
        """#,
      timestamp: (25 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s pick one of these and give it a spin… say, the `CubeCorePreview`. This is a preview we made for rendering the cube in isolation, which was important in the early stages of building the game when we were experimenting with designs and trying to optimize the drawing code. We can switch the active target to `CubeCorePreview` and open the `CubeCorePreviewApp.swift` file to check out what the entry point looks like.
        """#,
      timestamp: (25 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s just an `App` that creates a `CubeView` by supplying a store with stubbed out data:
        """#,
      timestamp: (25 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        @main
        struct CubeCorePreviewApp: App {
          var body: some Scene {
            WindowGroup {
              CubeView(
                store: .init(
                  initialState: .init(
                    cubes: .mock,
                    isOnLowPowerMode: false,
                    nub: nil,
                    playedWords: [],
                    selectedFaceCount: 0,
                    selectedWordIsValid: false,
                    selectedWordString: "",
                    settings: .init(showSceneStatistics: true)
                  ),
                  reducer: .empty,
                  environment: ()
                )
              )
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `.mock` puzzle being used handles constructing the 3x3x3 puzzle and even removes a few cubes so that we can see how shadows are projected. If we ran this on a device we could even test out the gyroscope feature of the game, in which the cube slightly rotates based on the orientation of your device. It’s pretty cool.
        """#,
      timestamp: nil,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now you may be wondering why on earth we would take the time to create these preview apps, especially since we also use Xcode previews. Well, Xcode previews are awesome for testing out styling changes and simple behaviors in screens, but they fall short in a few certain situations:
        """#,
      timestamp: (26 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - First of all, Xcode previews don’t have all the features that the simulator has. For example, in the simulator can you enable slow animations to clearly see how things transition in your application. You can also simulate application lifecycle events such as backgrounding and foregrounding the app. You can also simulate hardware features, such as touch pressure, volume controls, keyboards and more. None of those things are possible in Xcode previews.
        """#,
      timestamp: (26 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Further, previews tend to work best in short spurts of time since editing code and navigating through files can invalidate your previews. However the simulator can stay open for a long time since it’s a whole separate process, and so is great for testing parts of your application that take a long time to experience.
        """#,
      timestamp: (27 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Also, some technologies don’t work in previews, such as CoreMotion, CoreLocation, StoreKit and more. In fact, the cube view we just demoed does not work at all in Xcode previews because it seems that SceneKit, which is what we use to render the cube, is too heavy for previews. The preview tends to timeout before anything is drawn on the screen. Also there is no gyroscope in previews, or the simulator for that matter, and so if we want an easy way to test that we have no choice but to run on a device.
        """#,
      timestamp: (27 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Xcode previews also don’t work great with the debugger. It’s supposed to be possible to attach a debugger, but we haven’t been able to get it to work in a long time. So, if you need to debug just one small part of a feature you are working on it can be great to run it in isolation in a mini app so that it builds quickly and opens immediately the screen you are most interested in. No need to login and navigate through a bunch of screens just to get to the thing you actually want to debug.
        """#,
      timestamp: (28 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And if all of that wasn’t enough, sometimes you just want to run your application on an actual device, and although Xcode previews are supposed to be runnable on devices that functionality hasn’t worked for us for a very long time. Hopefully it will be fixed sometime soon, but until then running small, focused features of your application on a device is not possible unless you build a separate mini application.
        """#,
      timestamp: (28 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, from our perspective it is simply necessary to build these little mini apps to get a complete picture of your features. And if you are going to go that route you want these preview apps to build the bare minimum necessary to get something on the screen, and you want it to compile as fast as possible. For example, the `CubeCorePreview` app compiles in just 8 seconds, whereas the full isowords app takes nearly a minute. More than 10 times faster.
        """#,
      timestamp: (28 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, now that you are hopefully convinced that these preview apps can be handy, let’s show how we can make one. We’re going to add a whole new preview app from scratch for a feature that currently doesn’t have one. And that’s leaderboards.
        """#,
      timestamp: (29 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The leaderboards screen is quite complex, showing lots of data with subtle logic and coordinating multiple API requests. We’d like to be able to run this feature on a device or simulator without having to build the entire application and manually navigating to the screen we are interested in.
        """#,
      timestamp: (29 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can build a new preview app from scratch in just a few steps:
        """#,
      timestamp: (29 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Go to Xcode project settings and add a new target, we’ll call it LeaderboardPreview.
        """#,
      timestamp: (29 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We like to keep all preview specific targets inside the `Previews` directory, so we will drag and drop the directory that Xcode created for us into that directory.
        """#,
      timestamp: (30 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Moving the files into that directory causes a few paths in the build settings to point to the wrong location. If we try to build we will immediately see the problem.
            - The first is that the preview content directory can’t be found, but honestly we don’t need that so I’m just going to delete the directory and delete it from the build settings.
            - Next the info plist can’t be find, and to fix that we just have to prepend a `Previews/` to the build setting.
        """#,
      timestamp: (30 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now the app target builds, and we can go into its frameworks to link `LeaderboardFeature` with this app target, which is the module that holds the core logic for the leaderboards
        """#,
      timestamp: (31 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we can delete the `ContentView` from the target because we aren’t going to be doing much SwiftUI work in this target. All we need to do is construct a `LeaderboardView` in the app entry point.
        """#,
      timestamp: (31 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct a `LeaderboardView` we need to supply a store with the leaderboard’s domain:
        """#,
      timestamp: (32 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import LeaderboardFeature
        …
        LeaderboardView(
          store: <#Store<LeaderboardState, LeaderboardAction>#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct the store we need to provide some leaderboard state, a leaderboard reducer and a leaderboard environment:
        """#,
      timestamp: (32 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        LeaderboardView(
          store: .init(
            initialState: <#LeaderboardState#>,
            reducer: <#Reducer<LeaderboardState, LeaderboardAction, Environment>#>,
            environment: <#Environment#>
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Supplying the state and reducer is straightforward, and we can construct the environment by providing `.noop` dependencies:
        """#,
      timestamp: (32 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        LeaderboardView(
          store: .init(
            initialState: .init(isHapticsEnabled: false, settings: .init()),
            reducer: leaderboardReducer,
            environment: .init(
              apiClient: .noop,
              audioPlayer: .noop,
              feedbackGenerator: .noop,
              lowPowerMode: .false,
              mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now when we run the app in the simulator we get something that looks like leaderboards, but unfortunately it’s just a loading indicator that doesn’t even seem to finish. This is happening because we are providing a `.noop` dependency that never produces any output and so the leaderboards don’t know to stop showing the indicator.
        """#,
      timestamp: (33 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        One thing we can do is creating a more realistic environment for the leaderboard to run in. We can do this by taking the `.noop` API client and override some of its routes to return some actual data rather than return an effect that does not emit anything. To do this we can use the `.override` helper we have defined on API client and which we used [a couple episodes ago](/episodes/ep141-better-test-dependencies-the-point) when writing tests for our daily challenge feature.
        """#,
      timestamp: (33 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s pull out a little mutable version of the `.noop` API client dependency:
        """#,
      timestamp: (34 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var apiClient = ApiClient.noop
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we can override a particular endpoint of the client to return whatever data we want:
        """#,
      timestamp: (34 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        apiClient.override(
          route: <#ServerRoute.Api.Route#>,
          withResponse: <#Effect<(data: Data, response: URLResponse), URLError>#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can simply type `.` on the route to explore the routes that are available to us:
        """#,
      timestamp: (34 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        changelog(build:)
        config(build:)
        currentPlayer
        dailyChallenge()
        games()
        leaderboard()
        push()
        sharedGame()
        verifyReceipt()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Looks like `.leaderboard` is a good place to start. We can select that and then type `.` again to see where we can go from there:
        """#,
      timestamp: (34 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        fetch(gameMode:language:timeScope:)
        vocab()
        weekInReview(language:)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Looks like `.fetch` is most likely the route that will give us back some leaderboard entries, and now we have to fill in these parameters:
        """#,
      timestamp: (35 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        route: .leaderboard(.fetch(gameMode: <#GameMode#>, language: <#Language#>, timeScope: <#TimeScope#>)),
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        These are the parameters that can be customized in the UI. The leaderboards allow you to access scores for each game mode, which is timed or unlimited, as well as multiple time scopes, such as last day, last week and all time. So let’s just choose timed games and last week:
        """#,
      timestamp: (35 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        apiClient.override(
          route: .leaderboard(
            .fetch(
              gameMode: .timed,
              language: .en,
              timeScope: .lastWeek
            )
          ),
          withResponse: <#Effect<(data: Data, response: URLResponse), URLError>#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we need to fill in an effect that returns the data for this route. We have an effect helper called `.ok` that takes any `Encodable` data and constructs an effect of a successful URL response with that data:
        """#,
      timestamp: (35 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        withResponse: .ok(<#Encodable#>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And the data that is expected to be returned from this API endpoint is known as a `FetchLeaderboardResponse`. To construct one of these we provide an array of leaderboard entries:
        """#,
      timestamp: (36 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        withResponse: .ok(
          FetchLeaderboardResponse(
            entries: <#[FetchLeaderboardResponse.Entry]#>
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And to construct one of these we gotta provide a bunch of fields:
        """#,
      timestamp: (36 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        withResponse: .ok(
          FetchLeaderboardResponse(
            entries: [
              .init(
                id: <#LeaderboardScore.Id#>,
                isSupporter: <#Bool#>,
                isYourScore: <#Bool#>,
                outOf: <#Int#>,
                playerDisplayName: <#String?#>,
                rank: <#Int#>,
                score: <#Int#>
              )
            ]
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s put in some basic data:
        """#,
      timestamp: (36 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        withResponse: .ok(
          FetchLeaderboardResponse(
            entries: [
              .init(
                id: .init(rawValue: UUID()),
                isSupporter: false,
                isYourScore: false,
                outOf: 1_000,
                playerDisplayName: "Blob",
                rank: 5,
                score: 3_000
              )
            ]
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can now stick this API client into our environment:
        """#,
      timestamp: (36 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment: .init(
          apiClient: apiClient,
          …
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And when we run the app in the simulator we now see data! It’s not a lot of data, but it’s something. And we can already see a little bit of view logic that is happening because the view inserts a little foot at the end of the results in order to say how many scores are omitted. This is because we only send back the top 20 or so scores for leaderboards, and the rest are omitted, so the footer helps reiterate how many total players participated.
        """#,
      timestamp: (36 * 60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        One thing we could do real quick is increase the amount of data shown in this view by mapping on an array of integers to create a bunch of scores:
        """#,
      timestamp: (37 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        withResponse: .ok(
          FetchLeaderboardResponse(
            entries: (1...20).map { index in
              .init(
                id: .init(rawValue: UUID()),
                isSupporter: false,
                isYourScore: false,
                outOf: 2_000,
                playerDisplayName: "Blob \(index)",
                rank: index,
                score: 4_000 - index * 100
              )
            }
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We could even simulate adding one of our own scores to the list so that we could see how the design changes:
        """#,
      timestamp: (37 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        isYourScore: index == 5,
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now when we run the app we see that our score is called out with a distinctive black background, so we are able to test some pretty subtle logic.
        """#,
      timestamp: (37 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, that’s the basics of how we build mini preview apps in isowords. There are really handy and we feel that are complementary to Xcode previews rather than one being better than the other. We use both app previews and Xcode previews depending on the situation.
        """#,
      timestamp: (38 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Another perk of using previews is they allow you to run your application in controlled or mocked environments without letting that debug code infiltrate your production code. It can be all too easy to sprinkle in a little bit of test code so that you can force a particular flow in your application, but that can be quite dangerous because you have to remember to remove that code. Since app preview targets are fully separate from your main app target they are completely quarantined, and you don’t have to worry about putting any kind of weird debug code in there.
        """#,
      timestamp: (38 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"App Store assets"#,
      timestamp: (39 * 60 + 13),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        OK, so we’ve now seen that certain choices we made early on in building isowords really paid dividends down the line. Using the Composable Architecture made it easy and straightforward to build an onboarding experience. Highly modularizing our app made it easier to build our App Clip. And modularizing also made it easy for us to build little app previews that compile super fast and allow us to test specific features in isolation.
        """#,
      timestamp: (39 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We like to think of these things as improving the developer experience. Because it wasn’t a pain to create an onboarding experience, or an App Clip, or dedicated app targets. We didn’t have any problem putting in the extra work. In fact, it was really fun and rewarding work.
        """#,
      timestamp: (39 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This idea is also important in another part of app development that can be pretty arduous and annoying. And that’s preparing assets for the App Store. These days you can upload 3 videos and I think 9 screenshots for your app, and in various device sizes, such as iPhone mini, max and iPad. These assets can take a lot of effort to create.
        """#,
      timestamp: (39 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - You either need to run the app on the device and literally take screenshots, but that comes with some downsides.
            - You are at the mercy of the live data that is currently showing in your application. Maybe you want to tweak the numbers or avatars that are showing in your app, but that’s not really possible.
            - Also some states may be really difficult to capture. Maybe there’s a screen that is only accessible at certain times of the day or when the user has just performed some action. Grabbing screenshots for those interactions will be difficult.
        """#,
      timestamp: (40 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Another approach is to have a designer mock up the screenshots in a more controlled, calculated environment like Figma or Sketch. But this also has downsides:
            - The screenshots won’t be exactly how the app looks. No matter how much you like pixel perfect designs there’s always going to be some deviation between the mock ups and what actually renders on a device.
            - It also adds a dependency between you and submitting to the app store. Every time a screen gets substantially updated and you want to update the screenshots you will have to talk to your designer to get them to update the template.
        """#,
      timestamp: (40 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Neither of these ways of creating app store screens is ideal. And luckily there’s a better way. [Snapshot testing](https://github.com/pointfreeco/swift-snapshot-testing) is a great way to test visual regressions in your views, and it’s something we’ve talked about a ton on Point-Free, and it’s also the perfect tool for automatically generating App Store screenshots. You get to capture exactly what your app looks like, you get to control the environment that it runs in so you can mock out any and all data, and with a little bit of work you can even stylize and add branding to the images.
        """#,
      timestamp: (41 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is exactly what we do in isowords. We even have a whole test target dedicated specifically to generating App Store screenshots, and it lives at `Tests/AppStoreSnapshotTests`. In this directory we also have the `Snapshots` directory which holds 15 images: 3 different device sizes and 5 images per device:
        """#,
      timestamp: (41 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We’ve first got a screenshot for what the game looks like when playing a solo game.
        """#,
      timestamp: (42 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And then when playing a multiplayer game. We are even able to mock out the avatar images used for the players.
        """#,
      timestamp: (42 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And a screenshot of the daily challenge results
        """#,
      timestamp: (43 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Then we have a screenshot of the leaderboards.
        """#,
      timestamp: (43 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And then finally a screenshot of the home screen.
        """#,
      timestamp: (43 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        One thing to notice is that these screenshots are highly stylized. The app UI is embedded inside a phone frame and titles are added to the top for context. Everything you are seeing in these screenshots is laid out with SwiftUI and then snapshot with our snapshot testing library. You can get really fancy and creating with these screenshots, no need to just do the standard full screen capture.
        """#,
      timestamp: (43 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So that’s really cool, but what about the trailer? That seems even more difficult to make that screenshots. We want record a video that is engaging, short and to the point, and demonstrates the basic game mechanics. We could of course use the screen recording feature on the iPhone and just open up the game and start playing. That won’t be super engaging without practicing a lot and you’ll probably at the very least want a special build of the app that loads a puzzle you are familiar with so that you don’t have to search around for words.
        """#,
      timestamp: (43 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But also us just tapping around on the screen may be a little confusing because the viewer won’t actually see those touches. They’ll just see parts of the screen reacting to our touches.
        """#,
      timestamp: (44 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        What if we could load up the app in a very specialized state and then play a script of user actions. We could emulate the actions of the user tapping on various cube faces and tapping the submit button, and the whole game would just play by itself autonomously. That sounds pretty cool, and also very hard to do.
        """#,
      timestamp: (44 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But, it’s totally possible with the Composable Architecture, and it’s another one of those “super powers” of the architecture. Because all user actions in the app are represented by simple data types we can construct a huge array of actions that we want to execute and then just run them one after the other. Let’s take a look.
        """#,
      timestamp: (44 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can start by switching the active target to `TrailerPreview`, which is a preview app we use for recording our trailers. Let’s run the target to remind ourselves what the trailer looks like:
        """#,
      timestamp: (44 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So that’s pretty awesome. How did we accomplish this?
        """#,
      timestamp: (45 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Well, if we hop over to the entry point for the trailer we will find that like all of our other app targets it doesn’t contain much code. Just the bare bones to initialize a `TrailerView`, which takes state, reducer and environment:
        """#,
      timestamp: (45 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        @main
        struct TrailerPreviewApp: App {
          init() {
            Styleguide.registerFonts()
          }

          var body: some Scene {
            WindowGroup {
              TrailerView(
                store: .init(
                  initialState: .init(),
                  reducer: trailerReducer,
                  environment: .init(
                    audioPlayer: .live(
                      bundles: [
                        AppAudioLibrary.bundle,
                        AppClipAudioLibrary.bundle,
                      ]
                    ),
                    backgroundQueue: .main,
                    dictionary: .init(
                      contains: { string, _ in
                        [
                          "SAY", "HELLO", "TO", "ISOWORDS",
                          "A", "NEW", "WORD", "SEARCH", "GAME",
                          "FOR", "YOUR", "PHONE",
                          "COMING", "NEXT", "YEAR",
                        ]
                        .contains(string.uppercased())
                      },
                      load: { _ in true },
                      lookup: { _, _ in nil },
                      randomCubes: { _ in .mock },
                      unload: { _ in }
                    ),
                    mainQueue: .main,
                    mainRunLoop: .main
                  )
                )
              )
              .statusBar(hidden: true)
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The environment is the only thing that takes a bit of work to construct, but we do the simplest thing to give it live dependencies, except for the dictionary. For that dependency we just implement the `contains` endpoint from scratch since there’s just a finite set of words we need to recognize for the trailer.
        """#,
      timestamp: (46 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, it looks like the majority of the trailer’s code is probably in the `TrailerView`, which lives in the `Trailer` module, which is of course handled by SPM like all of our other modules. If we hop over to `Trailer.swift` we will see yet another feature built in the Composable Architecture that follows the exact same pattern that every other feature in this application follows. We have some domain modeling for state, action and environment. The state is particularly interesting:
        """#,
      timestamp: (46 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct TrailerState: Equatable {
          var game: GameState
          var nub: CubeSceneView.ViewState.NubState
          var opacity: Double

          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It holds onto the core `GameState` but then layers on additional state that is important just for the purposes of this trailer, such as this `NubState`, which is what controls that little virtual finger nub moving around the screen, and this opacity value which is used to fade the trailer in and out. The most important part of this is it’s all additive on top of the game state. Again we didn’t need to infect the core game logic with any of this, and that’s really great. Things would start to get messy fast if the game code needed to worry about onboarding and trailer logic in addition to its core logic.
        """#,
      timestamp: (46 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We have a `trailerReducer` reducer to implement the feature’s logic, which appears to incorporate the `gameReducer`'s logic too. Then we have the `TrailerView` which takes a store to power its functionality, and the body of the view does some basic composing of views that are defined elsewhere, such as the cube view and word list at the bottom of the screen.
        """#,
      timestamp: (47 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The most interesting part of this entire file is the reducer. It all starts with an `.onAppear` action that is sent when the trailer view first appears:
        """#,
      timestamp: (48 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .onAppear:
          return .merge(
            environment.audioPlayer.load(AudioPlayerClient.Sound.allCases)
              .fireAndForget(),

            Effect(value: .delayedOnAppear)
              .delay(
                for: 1,
                scheduler: environment.mainQueue.animation(.easeInOut(duration: fadeInDuration))
              )
              .eraseToEffect()
          )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This kicks off some effects. First we need to preload all the sounds that will play in the trailer. This helps warm up the audio player so that there are no hitches when a sound is first played. We also kick off an effect to send an action back into the system after a 1 second delay. We do this because the first render of the cube can take a moment and so we want to wait a little time before we start any interactions on the cube. Notice we are also sending that action using the [animated schedulers](/episodes/ep136-swiftui-animation-the-basics) we discussed a few months ago.
        """#,
      timestamp: (48 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can see why we do that if we hop up to the `.delayedOnAppear` action above:
        """#,
      timestamp: (48 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .delayedOnAppear:
          state.opacity = 1

          …
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We make the view initially transparent and then we fade it in once we are ready to start the trailer.
        """#,
      timestamp: (48 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        After this state mutation the rest of the logic in this action deals with the construction of a massive array of effects:
        """#,
      timestamp: (48 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var effects: [Effect<TrailerAction, Never>]
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It starts off by playing some music to set the mood for the trailer:
        """#,
      timestamp: (49 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var effects: [Effect<TrailerAction, Never>] = [
          environment.audioPlayer.play(.onboardingBgMusic)
            .fireAndForget()
        ]
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then we loop through every word we want to replay on the cube:
        """#,
      timestamp: (49 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Play each word
        for (wordIndex, word) in replayableWords.enumerated() {
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This `replayableWords` array is a huge array of values that describe how to embed words in the cube:
        """#,
      timestamp: (49 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let replayableWords: [[ReplayableCharacter]] = [
          [
            .init(letter: "S", index: LatticePoint(x: 0, y: 2, z: 1)!, side: .top),
            .init(letter: "A", index: LatticePoint(x: 0, y: 2, z: 0)!, side: .top),
            .init(letter: "Y", index: LatticePoint(x: 1, y: 2, z: 0)!, side: .top),
          ],
          …
        ]
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s how we manually set the cube up so that we can spell out the message we want for the trailer. If we ever wanted a new trailer all we would have to do is edit this one single array and everything should instantly work.
        """#,
      timestamp: (49 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we iterate over each character in the word we are trying to spell:
        """#,
      timestamp: (49 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Play each character in the word
        for (characterIndex, character) in word.enumerated() {
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now comes the magic. In here we can append a bunch of effects that emulate the motions the user goes through to play this specific character on the cube. We would start by moving the nub to the cube face represented by the character we are currently focused on:
        """#,
      timestamp: (49 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Move the nub to the face being played
        effects.append(
          Effect(value: .binding(.set(\.nub.location, .face(face))))
            .delay(
              for: moveNubDelay(wordIndex: wordIndex, characterIndex: characterIndex),
              scheduler: environment.mainQueue
                .animate(withDuration: moveNubToFaceDuration, options: .curveEaseInOut)
            )
            .eraseToEffect()
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s a lot going on in this single statement, but it’s got a big punch in a small package. First we are firing off an effect to position the nub over the cube face we are currently considering, and we using the `.binding` helper that we developed in our [concise forms](/collections/case-studies/concise-forms) series of episodes from a few months ago. It gives us a really lightweight way to make a mutation to state through an action.
        """#,
      timestamp: (49 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we choose to bundle this into an effect rather than just perform the mutation immediately because we want to delay logic. We need to wait a small amount of time before each nub location update because we have to give the nub view some time to animate over to the face we want to select. Since effects are just Combine publishers we can use the `.delay` operator to do that waiting.
        """#,
      timestamp: (50 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Further, we are using an animated scheduler so that when the nub updates its location it will do so with animation rather than just snapping into place immediately. However, this animated scheduler is a little different from the one we covered in our episodes. It’s not performing a SwiftUI animation, it’s actually performing a `UIView` animation! We are doing this because the nub view actually lives in UIKit world, and that’s because the cube is drawn in SceneKit which doesn’t currently have any first class SwiftUI support. So, in order to animate it around the screen we actually have to use the `UIView.animate` class method, which we can see if we dive into the implementation of this operator:
        """#,
      timestamp: (50 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public func animate(
          withDuration duration: TimeInterval,
          delay: TimeInterval = 0,
          options animationOptions: UIView.AnimationOptions = []
        ) -> AnySchedulerOf<Self> {
          AnyScheduler(
            minimumTolerance: { self.minimumTolerance },
            now: { self.now },
            scheduleImmediately: { options, action in
              self.schedule(options: options) {
                UIView.animate(
                  withDuration: duration,
                  delay: delay,
                  options: animationOptions,
                  animations: action
                )
              }
            },
            delayed: { date, tolerance, options, action in
              self.schedule(after: date, tolerance: tolerance, options: options) {
                UIView.animate(
                  withDuration: duration,
                  delay: delay,
                  options: animationOptions,
                  animations: action
                )
              }
            },
            interval: { date, interval, tolerance, options, action in
              self.schedule(after: date, interval: interval, tolerance: tolerance, options: options) {
                UIView.animate(
                  withDuration: duration,
                  delay: delay,
                  options: animationOptions,
                  animations: action
                )
              }
            }
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s pretty awesome to see how transforming schedulers can be an important concept even when dealing with UIKit code.
        """#,
      timestamp: (51 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Continuing down the reducer we will see that after we move the nub to its location we fire off two effects:
        """#,
      timestamp: (51 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        effects.append(
          Effect.merge(
            // Press the nub on the first character
            characterIndex == 0 ? Effect(value: .binding(.set(\.nub.isPressed, true))) : .none,
            // Tap on each face in the word being played
            Effect(value: .game(.tap(.began, face)))
          )
          .delay(
            for: .seconds(
              characterIndex == 0
                ? moveNubToFaceDuration
                : .random(in: (0.3 * moveNubToFaceDuration)...(0.7 * moveNubToFaceDuration))
            ),
            scheduler: environment.mainQueue.animation()
          )
          .eraseToEffect()
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The first effect mutates the nub to put it into a pressed state. That causes the nub view to render a little differently which gives it the appearance as if a touch is actually being pressed down.
        """#,
      timestamp: (51 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then we merge that effect with another one that emits an action to run a game action. This is extremely cool. Here we are using the game’s action to simulate the user tapping on a specific face of the cube. Because we name our actions after what the user is doing in the interface rather than after what we want the reducer to accomplish, we get a very easy way to emulate what the user is doing.
        """#,
      timestamp: (51 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We also delay those effects by a little bit of time, again to give the nub enough time to move around to each face, and we insert a little bit of randomness to make the movement seem less robotic.
        """#,
      timestamp: (52 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Once we exit the `for` loop that iterated over each character of the word we are replaying we fire off an effect to set the nub’s `isPressed` state back to `false`, with a `UIView` animation:
        """#,
      timestamp: (52 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Release the  nub when the last character is played
        effects.append(
          Effect(value: .binding(.set(\.nub.isPressed, false)))
            .receive(on: environment.mainQueue.animate(withDuration: 0.3))
            .eraseToEffect()
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then we move the nub down to the submit button, also using a `UIView` animation:
        """#,
      timestamp: (52 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Move the nub to the submit button
        effects.append(
          Effect(value: .binding(.set(\.nub.location, .submitButton)))
            .delay(
              for: 0.2,
              scheduler: environment.mainQueue
                .animate(withDuration: moveNubToSubmitButtonDuration, options: .curveEaseInOut)
            )
            .eraseToEffect()
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Once we are done moving the nub down to the submit button we press the nub down with an effect, and we add in a little bit of hesitation randomness, again to make it seem less robotic:
        """#,
      timestamp: (52 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Press the nub after waiting a small amount of time
        effects.append(
          Effect(value: .binding(.set(\.nub.isPressed, true)))
            .delay(
              for: .seconds(
                .random(
                  in:
                    moveNubToSubmitButtonDuration...(moveNubToSubmitButtonDuration
                    + submitHestitationDuration)
                )
              ),
              scheduler: environment.mainQueue.animation()
            )
            .eraseToEffect()
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Once the nub is pressed we can submit the word, which we can do by sending the game action that is responsible for handling the submit button being tapped:
        """#,
      timestamp: (52 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Submit the word
        effects.append(
          Effect(value: .game(.submitButtonTapped(reaction: nil)))
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then we can release the nub after a short delay:
        """#,
      timestamp: (53 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Release the nub
        effects.append(
          Effect(value: .binding(.set(\.nub.isPressed, false)))
            .delay(
              for: .seconds(submitPressDuration),
              scheduler: environment.mainQueue.animate(withDuration: 0.3)
            )
            .eraseToEffect()
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Once we exit the `for` loop that is iterating over each word it means we’ve played all words and so we can move the nub off screen and fade the entire view out:
        """#,
      timestamp: (53 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // Move the nub off screen once all words have been played
        effects.append(
          Effect(value: .binding(.set(\.nub.location, .offScreenBottom)))
            .delay(for: .seconds(0.3), scheduler: environment.mainQueue)
            .receive(
              on: environment.mainQueue
                .animate(withDuration: moveNubOffScreenDuration, options: .curveEaseInOut)
            )
            .eraseToEffect()
        )
        // Fade the scene out
        effects.append(
          Effect(value: .binding(.set(\.opacity, 0)))
            .receive(on: environment.mainQueue.animation(.linear(duration: moveNubOffScreenDuration)))
            .eraseToEffect()
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Finally we concatenate all of those effects together and return them:
        """#,
      timestamp: (53 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return .concatenate(effects)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And that’s it! That gigantic effect, which is actually composed of 159 little effects, will autonomously drive the game so that we can sit back and let it do its thing. Then all it takes is running it in the simulator, using the `xcrun simctl` tool to record the simulator, or you can load up on a device and record with QuickTime. We choose the latter because we like to have a little bit of gyroscope motion to the cube for the trailer.
        """#,
      timestamp: (53 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Another cool thing about making this trailer programmatically is that we can be very precise with how it is paced and the overall duration. Down at the bottom of this file we have constants that determine the durations and delays for moving the nub around the screen:
        """#,
      timestamp: (53 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        private let firstCharacterDelay: DispatchQueue.SchedulerTimeType.Stride = 0.3
        private let firstWordDelay: DispatchQueue.SchedulerTimeType.Stride = 1.5
        private let moveNubToFaceDuration = 0.45
        private let moveNubToSubmitButtonDuration = 0.4
        private let moveNubOffScreenDuration = 0.5
        private let fadeInDuration = 0.3
        private let fadeOutDuration = 0.3
        private let submitPressDuration = 0.05
        private let submitHesitationDuration = 0.15
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This allowed us to get our trailer to the perfect length because App Store previews must be 30 seconds or less. This would have been very difficult if we were left to the whims of trying to play the game live on a device.
        """#,
      timestamp: (54 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So this is pretty amazing. By using the Composable Architecture we have a nice, data-oriented description of all the actions that can happen in our application, and that makes it trivial to replay a script of user actions to emulate what it’s like for someone to actually play the game. And even better, creating this autonomously running trailer looks no different than any other feature we have built in this application. It consists of some domain, a reducer for the logic, and a view. We didn’t have to hack in any escape hatches or litter our core game code with weird logic just to support the trailer. It just all came basically for free. And we could even write tests for the trailer if we really wanted to, but we haven’t gone that far yet 😁
        """#,
      timestamp: (54 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Next time: server-side isowords"#,
      timestamp: (54 * 60 + 57),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So far we’ve mostly focused on running the iOS client locally and explored some of the more interesting parts of the code base. But the client is only half of what makes isowords the game it is today. The other half is the server.
        """#,
      timestamp: (54 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The server handles a variety of tasks:
        """#,
      timestamp: (55 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - It allows the client to authenticate with the server so that the user can be associated with scores submitted to the leaderboards. Right now we heavily lean on Game Center to allow for seamless authentication, which means we don’t have to ask you for any info whatsoever.
        """#,
      timestamp: (55 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The server also handles generating a random daily challenge puzzle each day that everyone in the world plays, and it does some extra work to make sure that people can’t cheat by playing the game multiple times.
        """#,
      timestamp: (55 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The server is responsible for sending push notifications, which currently happens when a new daily challenge is available, or if it is about to end and you haven’t finished your game yet.
        """#,
      timestamp: (55 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And finally the server handles in app purchases. The game is free to play, but after you’ve played a few games we will start to show you annoying interstitials to entice you to support our development efforts. The server is used to verify those transactions.
        """#,
      timestamp: (55 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The server is built entirely in Swift using our experimental Swift web libraries, which is also what we use to build this very site. We want to devote some time on Point-Free building up those concepts from scratch, but we are waiting for the concurrency story to play out on Swift Evolution before diving too deep into those topics.
        """#,
      timestamp: (56 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There are a lot of really cool things in the server portion of this code base that we’d like to demo, such as how we share code between client and server, how we designed the API client for communicating with the server, and how we write integration tests for both client and server at the same time.
        """#,
      timestamp: (56 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s start by getting everyone running the isowords server locally...next time!
        """#,
      timestamp: (56 * 60 + 54),
      type: .paragraph
    ),
  ]
}
