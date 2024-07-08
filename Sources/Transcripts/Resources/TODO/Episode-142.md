## Introduction

@T(00:00:05)
As most of our viewers know we’ve been working on a new project called [isowords](https://www.isowords.xyz), a word game built in SwiftUI and [the Composable Architecture](/collections/composable-architecture), and just a few weeks ago we simultaneously released the game and [open sourced](/blog/posts/55-open-sourcing-isowords) the entire [code base](https://github.com/pointfreeco/isowords), including the server that powers the backend.

@T(00:00:21)
We’ve given a few peeks at the code in recent episodes to show how to apply some of the concepts we’ve covered. For example, we showed [how we employ animated schedulers](/episodes/ep136-swiftui-animation-the-basics) to be very focused in what kinds of things we want to animate when effects execute. This allowed us to fix a lot of glitches that would have occurred if we could only use implicit SwiftUI animations. And we looked at how we make use of [failing](/episodes/ep139-better-test-dependencies-failability), [immediate](/episodes/ep140-better-test-dependencies-immediacy) and [no-op](/episodes/ep141-better-test-dependencies-the-point) schedulers when writing expressive tests and creating SwiftUI previews that exercise more of the view’s logic than just simple transformations of data into view hierarchy.

@T(00:00:55)
But there’s a lot more packed into this repo, so much we’ll probably never be able to cover it in its entirety on Point-Free, but that doesn’t mean we won’t try. Today we will start taking a leisurely tour through the code base to point out a few particularly interesting parts, some of which we will be doing dedicated deep dives in future Point-Free episodes.

## Checking out the project

@T(00:01:26)
Well, first things first. Let’s get everyone set up with the isowords code base. We can begin by cloning the repo onto our computer and opening the workspace:

!> [correction]: The isowords code base has changed [recently](https://github.com/pointfreeco/isowords/pull/122), and there's no longer an Xcode workspace at the root directory. Instead, open the Xcode project at `App/isowords.xcodeproj`.
> To make sure you are following the newest directions for setting up the project, please see the [README](https://github.com/pointfreeco/isowords#readme) for the project.

```bash
$ git clone https://github.com/pointfreeco/isowords
$ cd isowords
$ open isowords.xcworkspace
```

@T(00:01:40)
This will start downloading all of the packages we depend on, which mostly consists of libraries that we have built and open sourced, along with packages for our server code, such as Swift NIO.

@T(00:01:52)
One of the first things you might notice about this Xcode workspace is that at its root it only contains two things other than the README: an `isowords` Xcode project and an `isowords` Swift package.

@T(00:02:14)
- The `isowords` Xcode project holds all app targets for the project, such as the main iOS client target, the app clip target, and something we call “preview” targets, which we will get into more later. The cool thing here is that these targets contain no “real” code. They act as the entry point for the targets, serving only to construct views to kick off the application. In fact, the entire project only contains 700 lines of Swift code spread across 10 app targets, so that’s an average of 70 lines of code per target.

@T(00:02:48)
- The “real” code all lives in the `isowords` SPM package. This package currently holds 91 modules for both the iOS client and server, and contains nearly 50k lines of code. The `Package.swift` is big and it’s structured a little strangely, but that’s simply because we need to support libraries that build only for iOS along side some that build only for Mac and Linux, as well as some that build for both. So we have the `Package.swift` split into 3 sections for those three styles of target.

    This may seem extreme, but it comes with a ton of benefits. Most of these modules have very few dependencies and so build very quickly. Further, the smaller a module the better the build tools behave, such as SwiftUI previews, syntax highlighting and more. Also, by hyper-modularizing the code base we were able to easily develop an App Clip experience by just including the small bits of functionality we needed, which is very important since App Clips have a 10 MB size limit, uncompressed.

@T(00:04:06)
This Xcode project structure may seem a little odd to you, but in practice it’s actually pretty great. We have found it to be the easiest way to offload a lot of responsibilities from Xcode and give them to SPM. For example, we no longer fiddle with Xcode targets anytime we want a shareable library. With just a few small edits to the `Package.swift` file we can create a new library and have other libraries depend on it, and then immediately start writing code for the library.

@T(00:04:38)
If you’re interested in trying something like this for your own project or a future project, it’s as simple as initializing an SPM package somewhere in your app’s directory, creating an Xcode workspace, and dragging the SPM package and your Xcode project into the workspace.

@T(00:04:54)
For example, we have our mega SPM package in the root of our project, along with the workspace, and then we have the app target files and Xcode project in the `App` directory.

@T(00:05:15)
As soon as you drag the SPM package and Xcode project into a workspace it all just starts to magically work. You can have any app target depend on any library inside the SPM module.

@T(00:05:28)
For example, the main isowords app target depends on the following libraries in order to kick off the entry point of the app:

@T(00:05:42)
All that is needed to kick off the app is the `AppFeature` module and a couple of live dependencies, in particular the live API client and the modules that hold some audio resources.

@T(00:05:55)
We want to iterate that this is a pretty awesome way to develop iOS applications.

@T(00:05:59)
- It gets Xcode out of the way for a lot of things, reduces friction to modularizing, and does so without any external tools. There are other ways to achieve something like this, such as using an Xcode project generator, but it’s nice that we do a lot just with what Xcode gives us today.

@T(00:06:16)
- We very rarely need to resolve diffs between Xcode project files when merging code, which is often inscrutable and difficult to get right. In fact, the Xcode project shows up in PR diffs so infrequently that it now catches our eye and we further scrutinize the diff to make sure it was intended.

    Instead of Xcode project changes we now simply see changes in the Package.swift file, which is easy to understand, or we see changes in any shared Xcode schemes, which are a simple file format with one small file for each target.

@T(00:06:49)
However, not everything is perfect in the world of SPM, there are some caveats that we’d like to mention:

@T(00:06:56)
- First, in order for Xcode to automatically generate a scheme for each of our SPM modules, which are the things listed up in the top picker (ctrl+0), we must describe [show this in Package.swift] the module as a library at the top level and then again as a target down below. I’m sure there’s a good reason for this duplication, but it is a little unfortunate.

@T(00:07:28)
- Further, there is a little bit of manual management necessary when it comes to creating test targets. It is easy enough to create a test target, you simply add a new `.testTarget` line to your `Package.swift` and SPM will take care of creating that target. However, if you want to be able to work in your main feature target and be able to hit cmd+U to run the corresponding tests you have to open up the feature’s scheme and explicitly add that test target. It would be great if SPM could do this automatically for us since it seems to have all the information necessary.

@T(00:08:28)
- Next, SPM specifies the platforms that can be built at the package level, not the target level. So, for us to develop iOS-only modules, Mac/Linux-only modules, and shared modules we technically should be splitting into at least 3 packages. But that is a little annoying to manage 3 separate packages since it’s additional directory structures to maintain. Even worse, we actually have integration tests that exercise both iOS code and server code at the same time, which means we’d also need a 4th package just for integration tests. We decided it was not worth that trouble, and so we choose to go a little bit against the grain of SPM and house everything in a single package and then use environment variables to selectively add targets to the package.

@T(00:09:54)
- Because we house everything in a single package, and because platforms is specified at the package level, we technically can build targets on platforms that aren’t supported. For example, we can try building the `SettingsFeature` for macOS, but that of course will fail instantly because it has iOS-specific code. So, we have to be a little extra vigilant about keeping an eye on which platform is being built.

@T(00:10:31)
- Next, by keeping the SPM package at the root of the project we run the risk of exposing things in Xcode that we do not expect. For example, if we simply create a directory at the root, call it `blob`. it will suddenly show up in the Xcode side bar. We do not want this. All we want to show in the `isowords` package is just the `Sources` and `Tests`.

    However, you will notice that we have an `App`, `Assets` and `Bootstrap` directory at the root of the project and yet those directories do not appear in the side bar. The way we accomplish this is by dropping a stub of a `Package.swift` in the directory, which is enough to tell Xcode not to display that directory since it thinks it is its own SPM package:

```swift
// swift-tools-version:5.2

// Leave blank. This is only here so that Xcode doesn't display it.

import PackageDescription

let package = Package(
  name: "client",
  products: [],
  targets: []
)
```

@T(00:11:37)
- Another caveat is that as of Xcode 12.4 the symbols inside an SPM package are not properly symbolicated, and so crashes from code in an SPM package may not produce helpful stack traces. This bug is supposed to be [fixed in Xcode 12.5](https://forums.swift.org/t/incomplete-crash-log-symbolication-for-bitcode-enabled-apps-linked-with-packages-containing-resources/42696/4).

@T(00:11:58)
- Certain localization tools are Xcode specific and do not work with SPM. For example, you cannot “Export for Localization...” from an SPM package in order to get an .xliff file that can be shipped to translators and then plugged back into your code base.

@T(00:12:28)
- And finally, for some reason, probably related to how Xcode detects SPM packages vs. Xcode projects, the isowords workspace does not get picked up as a “recent” project, so we must manually open it up each time.

@T(00:12:54)
However, despite these caveats we are still immensely happy with the set up. We just think things could be better in the future, and hopefully certain parts of SPM will improve!

## Bootstrapping the client

@T(00:13:05)
From here if we select the `isowords` target and build for an iOS simulator we will get some instant errors of not being able to find `Bundle.module`:

@T(00:13:25)
> Error: Type 'Bundle' has no member 'module'

This is happening because some resources are too large to store in the repo, such as audio, and other resources we need to keep private due to licensing, such as fonts. This means we need a bootstrapping process to pull down those resources, as well as various other setup tasks:

```bash
$ make bootstrap-client

  ⚠️ Checking for Git LFS...
  ✅ Git LFS is good to go!
```

@T(00:14:31)
This did a few things:

@T(00:14:32)
- It makes sure you have Git LFS installed, and if not gives you instructions for how to install it

@T(00:14:38)
- It stubs out resources that you do not have access to, such as audio and fonts

@T(00:14:43)
- It bootstraps an English dictionary that is used to determine which words are valid in the game

@T(00:14:50)
With that done the app should now build! We can even run it in the simulator and we will have a mostly functional app. It starts off by showing us the onboarding experience. You may notice that this looks a little different from what is on the App Store right now, but that’s because we don’t have the custom font and so it is defaulting to Apple’s SF font.

@T(00:15:22)
But this onboarding flow is completely functional, we could even complete a few steps, like finding the first word “GAME” on the cube. We’ll have more to say about onboarding a bit later, so let’s just skip for now.

@T(00:15:48)
Now we’ve landed on the home screen of the application, which typically shows us how many people have played the daily challenge so far, but right now it’s just showing a gray rectangle. This is because by default the API is trying to interact with a server running on `localhost`, but we haven’t yet gotten a local server running. So, the app can’t talk to our server, but that’s ok. A lot of the application is still functional.

@T(00:16:17)
For example, we can drill down to the solo screen and start up an unlimited game. We can even find a few words real quick, and then let’s end the game. The game over screen shows us a summary of how we did. The ranks are also blocked out like the Home Screen, and again it’s due to not having a locally running server.

@T(00:16:58)
So, that’s the basics of getting the client running locally. We haven’t yet gotten the server running, but we will look at that a bit later.

## App delegate and onward

@T(00:17:05)
Let’s start digging into some code! We’ll begin by answering the question that has been asked to us the most number of times, and I’m sure it’s been in the back of the mind of nearly everyone who has taken a look at the Composable Architecture. Can you really build a large, real world app using the Composable Architecture, and is the entire app really powered by a single `Store`??

@T(00:17:28)
Well, the answer to both of those questions is yes! We don’t have to look any further than the app’s entry point to see how everything is kicked off. In `App.swift` we will see that we have an `AppDelegate`, and this is because we need access to certain applications lifecycle events that are not yet made available to purely SwiftUI apps, such as launching, receiving a push token, etc.

@T(00:17:55)
But right at the top of the `AppDelegate` we will see the root store being created which powers the entire application:

```swift
final class AppDelegate: NSObject, UIApplicationDelegate {
  let store = Store(
    initialState: .init(),
    reducer: appReducer,
    environment: .live
  )

  …
}
```

@T(00:18:04)
The initial state is a value from `AppState`, and all of its properties have defaults which is why we can do the abbreviated `.init()` syntax here. All of the application’s logic is contained in the `appReducer`, and all of the app’s dependencies are provided by the `.live` static we have defined on the `AppEnvironment` type down below, which we will see in a moment.

@T(00:18:24)
Then we override the delegate methods that we actually care about, and just send those actions to the store without performing any logic whatsoever in the app delegate:

```swift
func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
) -> Bool {
  self.viewStore.send(.appDelegate(.didFinishLaunching))
  return true
}

func application(
  _ application: UIApplication,
  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
  self.viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
}

func application(
  _ application: UIApplication,
  didFailToRegisterForRemoteNotificationsWithError error: Error
) {
  self.viewStore.send(
    .appDelegate(.didRegisterForRemoteNotifications(.failure(error as NSError)))
  )
}
```

@T(00:18:41)
This is a very important principle for the Composable Architecture. We should not perform any logic in the view because it is very difficult to test that logic. Pretty much the only way to test a view is with a [snapshot test](/episodes/ep86-swiftui-snapshot-testing), and those are very broad tests that are hard to focus on one small aspect. By thoughtlessly sending all view actions to the store we allow the reducer to handle all business logic, and reducers are very easy to test, even when they involve side effects.

@T(00:19:09)
Next we’ve got the true entry point of the application, and all it does is show a window with the `AppView` and send scene phase changes to the store:

```swift
@main
struct IsowordsApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @Environment(\.scenePhase) private var scenePhase

  init() {
    Styleguide.registerFonts()
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: self.appDelegate.store)
    }
    .onChange(of: self.scenePhase) {
      self.appDelegate.viewStore.send(.didChangeScenePhase($0))
    }
  }
}
```

@T(00:19:24)
And finally, at the bottom of the file we construct the live environment of dependencies that the application needs to do its job:

```swift
extension AppEnvironment {
  static var live: Self {
    …
  }
}
```

@T(00:19:32)
Most of everything in this value is pretty straightforward. To create a live `AppEnvironment` we just create the live versions of all of its constituents.

@T(00:19:40)
There’s quite a few dependencies, but also this is a pretty big app. We’ve got dependencies for handling the API client which communicates to our server, an audio client that we use for playing sound effects and music, we’ve got some dependencies for wrapping Apple frameworks such as Game Center, User Notifications, Store Kit, and more.

@T(00:19:55)
So, it is indeed true: the Composable Architecture can power a large, complex application, and do so with a single source of truth.

## The app's domain model

@T(00:20:14)
Let’s get a better look at the domain. If we hop over to `AppView.swift` we’ll see the state, actions and environment that defines the entire application’s domain.

@T(00:20:28)
For example, the root app state consists of only a few fields:

```swift
public struct AppState: Equatable {
  public var game: GameState?
  public var onboarding: OnboardingState?
  public var home: HomeState

  …
}
```

@T(00:20:44)
This is because the root only has 3 main jobs. On first launch we show onboarding, and that’s why we have some optional `OnboardingState`. Also the root view is responsible for launching and closing the game modal, and so that’s why we have some optional `GameState` in here. And then finally `HomeState` is always present because it’s what is always shown at the root.

@T(00:21:06)
A little down the file we will see the `AppAction` enum that holds all actions for the entire application. Of course they aren’t listed in one long enum but rather we break down independent features into their own domains so that we get a big nested action enum:

```swift
public enum AppAction: Equatable {
  case appDelegate(AppDelegateAction)
  case currentGame(GameFeatureAction)
  case didChangeScenePhase(ScenePhase)
  case gameCenter(GameCenterAction)
  case home(HomeAction)
  case onboarding(OnboardingAction)
  case paymentTransaction(StoreKitClient.PaymentTransactionObserverEvent)
  case savedGamesLoaded(Result<SavedGamesState, NSError>)
  case verifyReceiptResponse(Result<ReceiptFinalizationEnvelope, NSError>)
}
```

@T(00:21:21)
In total the nested enums probably hold nearly a hundred more cases, but at this high level we don’t have to care about any of that. We can just see they are broadly organized into a few categories. There’s the cases that deal with application lifecycle and app delegate concerns:

```swift
case appDelegate(AppDelegateAction)
case didChangeScenePhase(ScenePhase)
```

@T(00:21:40)
There’s the cases that deal with screens that are displayed:

```swift
case currentGame(GameFeatureAction)
case home(HomeAction)
case onboarding(OnboardingAction)
```

@T(00:21:48)
And we have some cases for dealing with events that are handled at the root level, such as game center events and store kit purchases:

```swift
case gameCenter(GameCenterAction)
case paymentTransaction(StoreKitClient.PaymentTransactionObserverEvent)
case verifyReceiptResponse(Result<ReceiptFinalizationEnvelope, NSError>)
```

@T(00:21:57)
The third piece to the app domain is the `AppEnvironment`, which is held in another file because it’s quite long. Not only does it hold all of the dependencies necessary for the application:

```swift
public struct AppEnvironment {
  public var apiClient: ApiClient
  public var applicationClient: UIApplicationClient
  public var audioPlayer: AudioPlayerClient
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var build: Build
  public var database: LocalDatabaseClient
  public var deviceId: DeviceIdentifier
  public var dictionary: DictionaryClient
  public var feedbackGenerator: FeedbackGeneratorClient
  public var fileClient: FileClient
  public var gameCenter: GameCenterClient
  public var lowPowerMode: LowPowerModeClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var mainRunLoop: AnySchedulerOf<RunLoop>
  public var remoteNotifications: RemoteNotificationsClient
  public var serverConfig: ServerConfigClient
  public var setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
  public var storeKit: StoreKitClient
  public var timeZone: () -> TimeZone
  public var userDefaults: UserDefaultsClient
  public var userNotifications: UserNotificationClient
}
```

@T(00:22:12)
But it also holds `.failing` and `.noop` instances of the environment, which as we saw from our last series of episodes are incredibly handy for writing more succinct tests, and can even be handy for SwiftUI previews and actual application logic:

```swift
public static let failing = Self(
  apiClient: .failing,
  applicationClient: .failing,
  audioPlayer: .failing,
  backgroundQueue: .failing("backgroundQueue"),
  build: .failing,
  database: .failing,
  deviceId: .failing,
  dictionary: .failing,
  feedbackGenerator: .failing,
  fileClient: .failing,
  gameCenter: .failing,
  lowPowerMode: .failing,
  mainQueue: .failing("mainQueue"),
  mainRunLoop: .failing("mainRunLoop"),
  remoteNotifications: .failing,
  serverConfig: .failing,
  setUserInterfaceStyle: { _ in
    .failing("\(Self.self).setUserInterfaceStyle is unimplemented")
  },
  storeKit: .failing,
  timeZone: {
    XCTFail("\(Self.self).timeZone is unimplemented")
    return TimeZone(secondsFromGMT: 0)!
  },
  userDefaults: .failing,
  userNotifications: .failing
)

public static let noop = Self(
  apiClient: .noop,
  applicationClient: .noop,
  audioPlayer: .noop,
  backgroundQueue: DispatchQueue.main.eraseToAnyScheduler(),
  build: .noop,
  database: .noop,
  deviceId: .noop,
  dictionary: .everyString,
  feedbackGenerator: .noop,
  fileClient: .noop,
  gameCenter: .noop,
  lowPowerMode: .false,
  mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
  mainRunLoop: RunLoop.main.eraseToAnyScheduler(),
  remoteNotifications: .noop,
  serverConfig: .noop,
  setUserInterfaceStyle: { _ in .none },
  storeKit: .noop,
  timeZone: { .autoupdatingCurrent },
  userDefaults: .noop,
  userNotifications: .noop
)
```

@T(00:22:30)
And then there’s one single reducer that glues all of this domain together to implement the business logic of the entire application. It’s called `appReducer`:

```swift
public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  …
)
```

@T(00:22:41)
Although it is one single reducer it is not all implemented in one single spot. The reducer is composed of many reducers, all of which live in their own modules, that are combined together to form the big app reducer. We can see that we are using the `.combine` operator to combine many reducers into one, and we are combining:

@T(00:22:57)
- an `appDelegateReducer` which is responsible for handling all of the logic for the app delegate methods, such as receiving push notifications

@T(00:23:05)
- `gameFeatureReducer` which powers all the logic for the game

@T(00:23:10)
- `homeReducer` which handles the Home Screen

@T(00:23:14)
- `onboardingReducer` which handles the logic for onboarding

@T(00:23:17)
- and finally `appReducerCore`, which handles the rest of the application logic, such as deciding if to show onboarding on launch, setting up a listeners for Game Center and Store Kit events, and more.

@T(00:23:29)
And the final piece of the puzzle of how the app is started up is the `AppView`. This is the view that sits at the root of the application and decides what is shown. The body of the view is remarkably short. It first checks to make sure we are not in the onboarding experience or in a game, and if so we show the `HomeView`.

```swift
if !self.viewStore.isOnboardingPresented && !self.viewStore.isGameActive {
  NavigationView {
    HomeView(store: self.store.scope(state: \.home, action: AppAction.home))
  }
  .navigationViewStyle(StackNavigationViewStyle())
  .zIndex(0)
}
```

@T(00:23:51)
And then in the `else` branch we decide to show either the `GameFeatureView` or the `OnboardingView` depending on which piece of state is non-`nil`:

```swift
} else {
  IfLetStore(
    self.store.scope(
      state: { appState in
        appState.game.map {
          (
            game: $0,
            nub: nil,
            settings: .init(
              enableCubeShadow: appState.home.settings.enableCubeShadow,
              enableGyroMotion: appState.home.settings.userSettings.enableGyroMotion,
              showSceneStatistics: appState.home.settings.showSceneStatistics
            )
          )
        }
      }
    ),
    then: { gameAndSettingsStore in
      GameFeatureView(
        content: CubeView(
          store: gameAndSettingsStore.scope(
            state: CubeSceneView.ViewState.init(game:nub:settings:),
            action: { .currentGame(.game(CubeSceneView.ViewAction.to(gameAction: $0))) }
          )
        ),
        store: self.store.scope(state: \.currentGame, action: AppAction.currentGame)
      )
    }
  )
  .transition(.game)
  .zIndex(1)

  IfLetStore(
    self.store.scope(state: \.onboarding, action: AppAction.onboarding),
    then: OnboardingView.init(store:)
  )
  .zIndex(2)
}
```

@T(00:24:02)
Some of this code can definitely be cleaned up, and we’ll be doing that in future Point-Free episodes where we explore more ways to work with enums in SwiftUI and we explore navigation patterns.

## Consistency and the Composable Architecture: a feature's domain model

@T(00:24:13)
So that’s the entry point to the app, but also the great thing about the Composable Architecture is that literally every screen of the app is basically built in the exact same way. You have the domain, consisting of state, actions, and environment; you’ve got the reducer that glues up the domain in order to implement your feature’s logic; and then you have the view that holds onto a store of the domain so that it can observe state changes and send actions. Literally every feature of isowords that you will find in this code base follows this pattern.

@T(00:24:42)
I can sense that some of our viewers may be skeptical, so let’s check it out. We can pick any feature module target (bring up target picker) in this application to see this pattern play out, whether it be the home feature, settings feature, daily challenge feature, game feature, game over feature, multiplayer feature, any of them!

@T(00:25:02)
Let’s just choose one… say… the multiplayer feature.

@T(00:25:05)
This module holds the functionality of the multiplayer screen that you can drill down to from the home screen. It’s not the actual multiplayer game logic, it’s just the UI that allows you to start a new multiplayer game or view your past games.

@T(00:25:19)
The first thing I want to point out is that building this module is super fast, taking only about 11 seconds, whereas the full app takes more than 51 seconds to build. That’s a 500% difference, and that makes all the difference when it comes to quickly iterating on a feature. Because while Swift has gotten much better at incremental builds, it still happens quite often that we need to build a whole module from scratch. Whether it be because you switched branches on git, or you merged the main branch into your branch, or maybe you just made a bunch of changes that Swift could not incrementally compile. The fact is that the faster our feature modules build the better developer experience we will have.

@T(00:26:28)
Let’s run the SwiftUI preview to see what this screen is all about. We see that it starts with a prompt asking us to start a game with a friend. And it definitely is a lot of fun so we recommend everyone do it. If you have played and completed any multiplayer games in the past we also show this button at the bottom, and if we tap it we go to a screen where all our past games would be if we had any.

@T(00:26:57)
So, what’s the domain look like that powers this feature? It’s a pretty simple struct:

```swift
public struct MultiplayerState: Equatable {
  public var hasPastGames: Bool
  public var route: Route?

  public enum Route: Equatable {
    case pastGames(PastGamesState)

    public enum Tag: Int {
      case pastGames
    }

    var tag: Tag {
      switch self {
      case .pastGames:
        return .pastGames
      }
    }
  }
}
```

@T(00:27:06)
It holds a boolean that determines whether or not the current player has any past games because that’s what drives the visibility of the bottom button.

@T(00:27:13)
We also have this value called a `route` which is an enum with a single case that represents the screen we can drill down to, the past games. If there were more screens we could navigate to there would be more cases in this enum. We’re not going to talk too much about this enum right now because soon we will have a lot to say about navigation in SwiftUI.

@T(00:27:33)
Next we have the actions:

```swift
public enum MultiplayerAction: Equatable {
  case pastGames(PastGamesAction)
  case setNavigation(tag: MultiplayerState.Route.Tag?)
  case startButtonTapped
}
```

@T(00:27:36)
There’s only 3 things that happen in this screen: all the actions from the child screen of past games, the navigation can change (which means we either drill down or drill out of past games), and finally we can tap the start button.

@T(00:27:53)
Next we have the environment, which only contains a few basic dependencies:

```swift
public struct MultiplayerEnvironment {
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var gameCenter: GameCenterClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>
}
```

@T(00:27:57)
Perhaps the only surprising one here is the `backgroundQueue`, which is actually used by the past games screen because it does a decent amount of data processing for pulling all your past multiplayer games out of Game Center. Even if you’ve played as few as 10 games it can be a decent amount of data to process on the main queue.

@T(00:28:12)
Next we have the reducer that implements all of this screen’s logic:

```swift
public let multiplayerReducer = Reducer<
  MultiplayerState,
  MultiplayerAction,
  MultiplayerEnvironment
>.combine(
  …
)
```

@T(00:28:18)
It’s a combination of two reducers, first the reducer for the past games that has been pulled back to the multiplayer reducer’s domain:

```swift
pastGamesReducer
  ._pullback(
    state: (\MultiplayerState.route).appending(path: /MultiplayerState.Route.pastGames),
    action: /MultiplayerAction.pastGames,
    environment: {
      PastGamesEnvironment(
        backgroundQueue: $0.backgroundQueue,
        gameCenter: $0.gameCenter,
        mainQueue: $0.mainQueue
      )
    }
  ),
```

@T(00:28:29)
This is what allows the past games screen to be functional while being embedded inside the multiplayer domain. Also you might notice this strange `._pullback` operator. We’re not ready to talk about that just yet, but we will very soon.

@T(00:28:43)
After the past games reducer runs we run the main reducer for the multiplayer functionality, which doesn’t need to do much.

@T(00:28:48)
And then finally we have the view:

```swift
public struct MultiplayerView: View {
  let store: Store<MultiplayerState, MultiplayerAction>
  @ObservedObject var viewStore: ViewStore<ViewState, MultiplayerAction>
  …
}
```

@T(00:28:52)
It just holds the store for the domain, and then a view store for observing a small subset of the multiplayer. In fact, all it needs to observe is just a single boolean and the tag of the route enum:

```swift
struct ViewState: Equatable {
  let hasPastGames: Bool
  let routeTag: MultiplayerState.Route.Tag?

  init(state: MultiplayerState) {
    self.hasPastGames = state.hasPastGames
    self.routeTag = state.route?.tag
  }
}
```

@T(00:29:03)
Every single screen of this application follows the exact same pattern. You always specify the state for the screen, the actions that can occur on the screen, the environment of dependencies necessary to drive the logic, a reducer to implement the logic, and the view to observe state changes and send actions.

@T(00:29:21)
It doesn’t matter which file you are looking at, this is how it always happens. In fact, stores are used in 50 different views spread across 45 files, and it’s great to have this kind of consistency so that you can drop yourself into any feature and immediately have a compass to help you navigate.

## Testing in isowords

@T(00:29:41)
But even better, testing features in the Composable Architecture is also super consistent. Every feature is tested exactly the same, no matter what kind of functionality it has. Let’s see this by taking a look at what tests are written for the multiplayer feature.

@T(00:29:54)
If we hop over to `MultiplayerFeatureTests.swift` we’ll see three test cases that all follow the same pattern. Take for example the first test, `testStartGame_GameCenterAuthenticated`. This tests what happens when the current player is already authenticated with Game Center and decides to tap the “Start a game” button on the screen.

@T(00:30:12)
There’s a little bit of set up work to craft the environment of dependencies for the test:

```swift
var environment = MultiplayerEnvironment.failing
environment.gameCenter.localPlayer.localPlayer = { .authenticated }
environment.gameCenter.turnBasedMatchmakerViewController.present = { _ in
  …
}
```

@T(00:30:18)
We always start with a failing environment. That is, an environment such that if any of its dependencies are ever executed it will immediately fail the test suite. We do this because we want to explicitly and exhaustively describe the bare minimum of dependencies necessary to test a particular slice of a feature, which is a topic we discussed in depth in our recent series of episodes covering [better test dependencies](/collections/dependencies/better-test-dependencies).

@T(00:30:40)
With the failing environment declared we then override just the endpoints that we think are going to be used in this test. In this case it looks like we need only for the local Game Center player to be authenticated and we need to provide an effect for presenting the matchmaker controller.

@T(00:30:57)
Once the environment is set up we set up the test store so that we can assert on how actions cause the state to change, as well as how effects are executed in the system:

```swift
let store = TestStore(
  initialState: MultiplayerState(hasPastGames: false),
  reducer: multiplayerReducer,
  environment: environment
)
```

@T(00:31:00)
And then we send an action that emulates something the user did, such as tapping on the “Start a game” button:

```swift
store.send(.startButtonTapped)
```

@T(00:31:07)
Now tapping this button doesn’t cause state to change, and so that’s why there is nothing else on this line. It also doesn’t execute any effects that feed data back into the system, and so that’s why we don’t have any `store.receive` statements either. All that happens when this button is tapped is a fire-and-forget effect is executed in order to show some Game Center UI for starting a turn-based game, and so the only way to verify that happened is by checking that the corresponding effect in the environment was executed:

```swift
XCTAssertEqual(didPresentMatchmakerViewController, true)
```

@T(00:31:39)
It may not seem like we are testing much here, but it’s also about as much as we could hope for considering that ultimately we need to send the user off to some Game Center UI that we do not control.

@T(00:31:48)
A little further down the file there’s a test that shows what happens when we tap on the “View past games” button:

```swift
func testNavigateToPastGames() {
  let store = TestStore(
    initialState: MultiplayerState(hasPastGames: true),
    reducer: multiplayerReducer,
    environment: .failing
  )

  store.send(.setNavigation(tag: .pastGames)) {
    $0.route = .pastGames(.init(pastGames: []))
  }
  store.send(.setNavigation(tag: nil)) {
    $0.route = nil
  }
}
```

@T(00:31:58)
An important aspect of this test is the fact that the environment is fully stubbed out to be failing. That means this part of the feature is not executing effects or using any part of the environment and not executing any side effects. This means the test is quite simple. The more dependencies that are overridden the more complex you can expect a test to be.

@T(00:21:15)
The test simply shows how navigation causes the state’s `route` to change to the `.pastGames` route, which will cause the view to trigger a drill down event. And then when we set navigation to `nil` it causes the `route` to be cleared, which will trigger a drill out.

@T(00:32:30)
If we hop over to `PastGamesTests.swift` we’ll see some slightly more complicated tests, but still following the same pattern as the other tests. For example, the `testRematch_Failure` test shows what happens when someone taps the “Rematch” button on a past match and the Game Center request to perform a rematch fails.

@T(00:32:48)
First we set up the environment by overriding just the endpoints necessary to test the feature, in this case we need a scheduler and to override the `rematch` endpoint with an effect that fails immediately:

```swift
struct RematchFailure: Error, Equatable {}

var environment = PastGamesEnvironment.failing
environment.mainQueue = .immediate
environment.gameCenter.turnBasedMatch.rematch = { _ in .init(error: RematchFailure()) }
```

@T(00:33:01)
Then we set up our test store which already has a past game in its state:

```swift
let store = TestStore(
  initialState: PastGamesState(pastGames: [pastGameState]),
  reducer: pastGamesReducer,
  environment: environment
)
```

@T(00:33:07)
Then we send the action that says we are tapping on the “Rematch” button for a particular past game:

```swift
store.send(.pastGame(.init(rawValue: "id"), .rematchButtonTapped)) {
  try XCTUnwrap(&$0.pastGames[id: .init(rawValue: "id")]) {
    $0.isRematchRequestInFlight = true
  }
}
```

@T(00:33:14)
After sending this action we have to assert how the state changed. In this case a boolean inside a past game has been flipped to true indicating that we are currently making the rematch request.

@T(00:33:25)
Now we can’t stop here. Tapping that button caused an effect to be executed, which fed data back into the system, and we have to assert on that or else the test will fail. In fact, let’s comment out the rest of the test just to make sure that happens:

@T(00:33:46)
> Error: The store received 1 unexpected action after this one: …
>
> Unhandled actions: [
>   PastGamesAction.pastGame(
>     Tagged&lt;TurnBasedMatch, String>(
>       rawValue: "id"
>     ),
>     PastGameAction.rematchResponse(
>       Result&lt;TurnBasedMatch, NSError>.failure(
>         MultiplayerFeatureTests.PastGamesTests.RematchFailure()
>       )
>     )
>   ),
> ]

And indeed we see that the store received an action that we did not assertion should be received.

@T(00:33:54)
So, we need to bring back the `store.receive`, which allows us to explicitly tell the test store that we expect an action to be fed back into the system, in particular a response from the Game Center rematch request:

```swift
store.receive(.pastGame("id", .rematchResponse(.failure(RematchFailure() as NSError)))) {
  …
}
```

@T(00:34:01)
And we further have to assert on how the state changed after we got this action from the effect. In particular, the boolean that indicates if the request is in flight flips back to `false`, and we show an alert to communicate to the user that we couldn’t start the rematch:

```swift
try XCTUnwrap(&$0.pastGames[id: "id"]) {
  $0.isRematchRequestInFlight = false
  $0.alert = .init(
    title: .init("Error"),
    message: .init("We couldn’t start the rematch. Try again later."),
    primaryButton: .default(.init("OK"), send: .dismissAlert),
    secondaryButton: nil
  )
}
```

@T(00:34:21)
It’s pretty incredible how easy it is to test such a complex and subtle flow. We are testing how our code would behave if Game Center started sending back errors, and these kinds of unhappy paths are usually the least tested in code bases because typically they are a pain to get test coverage on.

@T(00:34:37)
So, that’s a very quick tour of how the Composable Architecture is used in isowords. We just want to iterate that indeed you can build a complex application with the Composable Architecture, and indeed a single source of truth can power the entire app. And when you do this it can be very easy to jump into any part of the application and have some idea of what is going on because the domain, logic and view are nicely separated and understandable in isolation.

## Next time: client features galore

@T(00:35:07)
Now that we have a broad overview of how the project is structured, let’s dive deeper into some particular features of isowords to see how they were actually built. Let’s start with one of my favorites: onboarding.

@T(00:35:21)
Onboarding is the first thing people see when they come to the app, and it should be short and engaging so that people actually complete it because there are some tricks that one needs to know to enjoy the game, such as double tapping a cube to remove it.

@T(00:35:33)
We’ve settled on a user experience that has the player complete a few simple tasks. First we have them find 3 simple words with more and more letters revealed so that they can experience what it’s like to connect letters together, and most important, finding the last word causes a cube to remove, which is the key game mechanic behind isowords.

@T(00:35:58)
The user experience for onboarding is very important, but so is the developer experience for building onboarding. The easier it is for us to build rich experiences like this the more likely we are to do it, and the more likely we are to not accidentally break it in the future as our application evolves.

@T(00:36:14)
If we approach this in a naive way we may be tempted to sprinkle code throughout our core game feature to get the job done. We’d add extra state to track things that are only specific to onboarding, we’d expose little escape hatches in various parts of the game so that we could hook into certain events, like when a specific word is highlighted on the cube, and we’d litter our view with additional logic to hide things not important for onboarding and show new things that are important for onboarding.

@T(00:36:43)
However, we were able to implement this onboarding feature without adding a single line of code to the core game feature. It is entirely an additional layer that is put on top of the game, and it is done using techniques that we described [in our series of episodes](/collections/swiftui/redactions) exploring SwiftUI’s redaction feature, which gave us the opportunity to show how to build an onboarding feature for a todo app.

@T(00:37:07)
Let's take a look at the onboarding feature...next time!
