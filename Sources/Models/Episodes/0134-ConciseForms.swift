import Foundation

extension Episode {
  public static let ep134_conciseForms = Episode(
    blurb: """
We've shown how to dramatically streamline forms in the Composable Architecture, but it's time to ask "what's the point?" We apply the concepts previously developed to a real world application: [isowords](https://www.isowords.xyz). It's a word game built in the Composable Architecture, launching soon.
""",
    codeSampleDirectory: "0134-concise-forms-pt4",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 373699419,
      vimeoId: 508418783,
      vimeoSecret: "21c734f3164457cd91c2b68db18d2b5defd46418"
    ),
    id: 134,
    length: 28*60 + 14,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1612764000),
    references: [
      .isowords
    ],
    sequence: 134,
    subtitle: "The Point",
    title: "Concise Forms",
    trailerVideo: .init(
      bytesLength: 59604438,
      vimeoId: 508418621,
      vimeoSecret: "c5db454d026563010c387a771b9fe16a55cef7e8"
    ),
    transcriptBlocks: .ep134_conciseForms
  )
}

private let _exercises: [Episode.Exercise] = [
]

extension Array where Element == Episode.TranscriptBlock {
  fileprivate static let ep134_conciseForms: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
We think this is pretty incredible. We only added about 50 lines of library code, consisting of a new type, a higher-order reducer, and a few helpers, and we now have a really robust solution to simple and complex forms in the Composable Architecture. We are free to add as many controls to this screen as we want, and we will not incur any additional boilerplate. The bindings will automatically update the corresponding state without us needing to do anything, but if we want to layer on some additional logic we simply need to destructure the key path we are interested in.
"""#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So we believe we have truly we have created the tools for dealing with forms in SwiftUI in a concise manner. But on Point-Free we like to end every series of episodes by asking "what's the point?" This gives us a chance to bring abstract concepts down to earth and show some real world applications. This time we were rooted in reality from the very beginning because we started by showing that the Composable Architecture had a boilerplate problem. Then we explored a theoretical Swift feature that could help solve the boilerplate problem, that of enum cases with generics. But, even without that theoretical feature we are able to approximate it with type-erasure, and so this is a really great, real world demonstration of how to use type-erasure.
"""#,
      timestamp: (1*60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But, just because this series of episodes has been rooted in reality from the beginning doesn't mean we can't dig a little deeper 😁.
"""#,
      timestamp: (1*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We are going to demonstrate how these form helpers can massively simplify and clean up a real world code base. As some of our viewers may know already, about a month ago we announced that we are working on a new project. It’s a word game called [isowords](https://www.isowords.xyz), and it’s completely built in the Composable Architecture, and even the server is built in Swift. If you are interested in learning more you can visit our website at isowords.xyz, and if you’d like beta access feel free to email us.
"""#,
      timestamp: (2*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We will live refactor the code for the settings screen in the [isowords](https://www.isowords.xyz) code base to show a real world example of just how concise forms and the Composable Architecture can be.
"""#,
      timestamp: (2*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"isowords"#,
      timestamp: (2*60 + 50),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
isowords is a word search game that takes place on an isometric cube. The full application is written in the Composable Architecture, from the menus, settings and leaderboards all the way to the engine that powers the game’s logic.
"""#,
      timestamp: (2*60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The goal is to find words, the longer the word the higher the score, and the third time a letter is used its cube is removed. This gives you more chances to find interesting words as cubes underneath are revealed.
"""#,
      timestamp: (3*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s start by opening up the [isowords](https://www.isowords.xyz) project.
"""#,
      timestamp: (3*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The project is quite large, currently consisting of about 40,000 lines of code for both the client and server and 70 Swift packages. As you may know from our past episodes on modularity, we are big proponents of breaking down applications into many small modules. There are a ton of benefits to doing so, including:
"""#,
      timestamp: (3*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Strengthens boundaries in your application by making it explicit which components have access to other components.
"""#,
      timestamp: (3*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Increases productivity because building a small feature module can be many times faster than building the full application.
"""#,
      timestamp: (4*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Decreases compile times of the full application because the build system can be smarter about how modules are built in parallel.
"""#,
      timestamp: (4*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Increases stability of Xcode previews because there is less code to build.
"""#,
      timestamp: (4*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Amongst other things.
"""#,
      timestamp: (4*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
As a concrete example, it currently takes about 40 seconds to build the isowords application from a clean state, but the `SettingsFeature` module, which holds all of the code for our settings screen, builds in about 10 seconds.
"""#,
      timestamp: (4*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s start by running the full application in the simulator and giving a quick demonstration of what settings look like in isowords.
"""#,
      timestamp: (4*60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- At the top right of the home screen we will see a settings button.
"""#,
      timestamp: (4*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Tapping that drills us into a screen with lots of setting sub-screens.
"""#,
      timestamp: (4*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- In the notifications sub-screen we have something quite similar to what we just built in these episodes
"""#,
      timestamp: (5*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Tapping on the toggle prompts us for notification permissions and it eagerly turns the toggle on.
"""#,
      timestamp: (5*60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- If we deny permissions then the toggle switches back off.
"""#,
      timestamp: (5*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Tapping the toggle again shows us a prompt to turn on notifications in iOS settings, and provides a button to do so
"""#,
      timestamp: (5*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Tapping that button takes us to iOS settings, so we can turn on notifications
"""#,
      timestamp: (5*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- And then going back to the app our notifications have been automatically enabled for us.
"""#,
      timestamp: (5*60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- So that’s already a pretty complex flow in this form. The other screens are a little simpler.
"""#,
      timestamp: (5*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- In sounds we just have a few simple sliders
"""#,
      timestamp: (5*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- In appearance we have a few pickers for deciding what color scheme or app icon you want
"""#,
      timestamp: (5*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- In accessibility we have a few settings for enabling/disabling features like motion or haptics
"""#,
      timestamp: (6*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- And finally in the developer sub-screen we have a few settings that are only pertinent to the developers of the game, such as which API we are hitting or showing statistics in the game, such as frame per second and draw calls.
"""#,
      timestamp: (6*60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Settings in isowords"#,
      timestamp: (6*60 + 27),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So there’s quite a bit in this screen. And quite a bit of Composable Architecture code backing it.
"""#,
      timestamp: (6*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Currently it does not use any of the form helpers we just wrote. It introduces an action per control, so I think we have an opportunity to clean up a lot of code here.
"""#,
      timestamp: (6*60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If we hop over to the file that holds the domain for this feature, we will find this monstrosity of an action enum:
"""#,
      timestamp: (7*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public enum SettingsAction: Equatable {
  case didBecomeActive
  case dismissAlert
  case leaveUsAReviewButtonTapped
  case onAppear
  case onDismiss
  case openSettingButtonTapped
  case productsResponse(Result<StoreKitClient.ProductsResponse, NSError>)
  case reportABugButtonTapped
  case restoreButtonTapped
  case setApiBaseUrl(DeveloperSettings.BaseUrl)
  case setAppIcon(AppIcon?)
  case setColorScheme(UserSettings.ColorScheme)
  case setMusicVolume(Float)
  case setSoundEffectsVolume(Float)
  case stats(StatsAction)
  case tappedProduct(StoreKitClient.Product)
  case toggleEnableCubeShadow(isOn: Bool)
  case toggleEnableGyroMotion(isOn: Bool)
  case toggleEnableHaptics(isOn: Bool)
  case toggleEnableNotifications(isOn: Bool)
  case toggleSendDailyChallengeReminder(isOn: Bool)
  case toggleSendDailyChallengeSummary(isOn: Bool)
  case toggleShowSceneStatistics(isOn: Bool)
  case updateCubeShadowRadius(value: CGFloat)
  case userNotificationAuthorizationResponse(Result<Bool, NSError>)
  case userNotificationSettingsResponse(UserNotificationClient.Notification.Settings)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This holds every action that can occur in the settings screen, including every button tap, every UI control binding, and every effect response. If we separate the user actions and effect actions from the binding actions we will find that half of these actions are used in UI control bindings:
"""#,
      timestamp: (7*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public enum SettingsAction: Equatable {
  case didBecomeActive
  case leaveUsAReviewButtonTapped
  case onAppear
  case onDismiss
  case openSettingButtonTapped
  case productsResponse(Result<StoreKitClient.ProductsResponse, NSError>)
  case reportABugButtonTapped
  case restoreButtonTapped
  case stats(StatsAction)
  case tappedProduct(StoreKitClient.Product)
  case userNotificationAuthorizationResponse(Result<Bool, NSError>)
  case userNotificationSettingsResponse(UserNotificationClient.Notification.Settings)

  case dismissAlert
  case setApiBaseUrl(DeveloperSettings.BaseUrl)
  case setAppIcon(AppIcon?)
  case setColorScheme(UserSettings.ColorScheme)
  case setMusicVolume(Float)
  case setSoundEffectsVolume(Float)
  case toggleEnableCubeShadow(isOn: Bool)
  case toggleEnableGyroMotion(isOn: Bool)
  case toggleEnableHaptics(isOn: Bool)
  case toggleEnableNotifications(isOn: Bool)
  case toggleSendDailyChallengeReminder(isOn: Bool)
  case toggleSendDailyChallengeSummary(isOn: Bool)
  case toggleShowSceneStatistics(isOn: Bool)
  case updateCubeShadowRadius(value: CGFloat)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s also take a look at what the reducer does with these actions.
"""#,
      timestamp: (7*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The first five actions all follow the same pattern: they mutate state with the value handed to us from the binding, and then fire off an effect.
"""#,
      timestamp: (7*60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case let .setApiBaseUrl(baseUrl):
  state.developer.currentBaseUrl = baseUrl
  return .merge(
    environment.apiClient.setBaseUrl(baseUrl.url).fireAndForget(),
    environment.apiClient.setAccessToken(nil).fireAndForget()
  )

case let .setAppIcon(icon):
  state.userSettings.appIcon = icon
  return environment.applicationClient
    .setAlternateIconName(state.userSettings.appIcon?.rawValue)
    .ignoreFailure()
    .eraseToEffect()
    .fireAndForget()

case let .setColorScheme(colorScheme):
  state.userSettings.colorScheme = colorScheme
  return environment.setUserInterfaceStyle(colorScheme.userInterfaceStyle)
    .fireAndForget()

case let .setMusicVolume(volume):
  state.userSettings.musicVolume = volume
  return environment.audioPlayer.setGlobalVolumeForMusic(volume)
    .fireAndForget()

case let .setSoundEffectsVolume(volume):
  state.userSettings.soundEffectsVolume = volume
  return environment.audioPlayer.setGlobalVolumeForSoundEffects(volume)
    .fireAndForget()
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we’ve got all the toggle bindings, which simply update state and return no effects, except for the notifications toggle:
"""#,
      timestamp: (8*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case let .toggleEnableCubeShadow(isOn):
  state.enableCubeShadow = isOn
  return .none

case let .toggleEnableGyroMotion(isOn):
  state.userSettings.enableGyroMotion = isOn
  return .none

case let .toggleEnableHaptics(isOn):
  state.userSettings.enableHaptics = isOn
  return .none

case let .toggleEnableNotifications(isOn):
  guard
    isOn,
    let userNotificationSettings = state.userNotificationSettings
  else {
    state.enableNotifications = false
    return .none
  }

  switch userNotificationSettings.authorizationStatus {
  case .notDetermined, .provisional:
    state.enableNotifications = true
    return environment.userNotifications.requestAuthorization([.alert, .badge, .sound])
      .mapError { $0 as NSError }
      .receive(on: environment.mainQueue.animation())
      .catchToEffect()
      .map(SettingsAction.userNotificationAuthorizationResponse)

  case .denied:
    state.alert = .userNotificationAuthorizationDenied
    state.enableNotifications = false
    return .none

  case .authorized:
    state.enableNotifications = true
    return .init(value: .userNotificationAuthorizationResponse(.success(true)))

  case .ephemeral:
    state.enableNotifications = true
    return .none

  @unknown default:
    return .none
  }

case let .toggleSendDailyChallengeReminder(isOn: isOn):
  state.userSettings.sendDailyChallengeReminder = isOn
  return .none

case let .toggleSendDailyChallengeSummary(isOn: isOn):
  state.userSettings.sendDailyChallengeSummary = isOn
  return .none

case let .toggleShowSceneStatistics(isOn):
  state.showSceneStatistics = isOn
  return .none

case let .updateCubeShadowRadius(value: radius):
  state.cubeShadowRadius = radius
  return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This is a ton of boilerplate for what should be something simple. All the lines that are simply updating state with the value handled to us from the binding do not need to be there, and all the cases that don’t execute effects can entirely go away.
"""#,
      timestamp: (8*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Bye bye boilerplate"#,
      timestamp: (9*60 + 12),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, let’s fix it.
"""#,
      timestamp: (9*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We will introduce a new `Forms.swift` and paste in all the code we wrote in the previous episodes.
"""#,
      timestamp: (9*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we’ll add a `.form` case to our actions, but we’ll leave the all the other actions for now:
"""#,
      timestamp: (9*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public enum SettingsAction: Equatable {
  ...

  case form(FormAction<SettingsState>)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we need to handle this action in the reducer, but for now we’ll just return no effects:
"""#,
      timestamp: (9*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
switch action {
...

case .form:
  return .none
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
To enhance the settings reducer with the form functionality we need to apply the `.form` higher-order reducer:
"""#,
      timestamp: (10*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.form(action: /SettingsAction.form)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now we can start converting our form actions over to take advantage of this form machinery. We’ll start with some of the simpler actions. For example, in the accessibility settings we can toggle gyroscope motion and haptics, and both of those bindings do the simplest kind of state mutation with no effects. We can get rid of those actions:
"""#,
      timestamp: (10*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//  case toggleEnableGyroMotion(isOn: Bool)
//  case toggleEnableHaptics(isOn: Bool)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And in the reducer, rather than having a `case` statement for each of those actions, we can instead destructure the `.form` case to match against the key path of the property that was changed. For example, instead of matching against `.toggleEnableGyroMotion` we can just check when the form updates the `\.userSettings.enableGyroMotion` key path:
"""#,
      timestamp: (10*60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .toggleEnableGyroMotion(isOn):
    case .form(\.userSettings.enableGyroMotion):
      state.userSettings.enableGyroMotion = isOn
      return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Further, the `.form` higher-order reducer has already taken care of this mutation for us, so there’s no reason to do this:
"""#,
      timestamp: (11*60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .toggleEnableGyroMotion(isOn):
    case .form(\.userSettings.enableGyroMotion):
//      state.userSettings.enableGyroMotion = isOn
      return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But now we see that this action actually has no additional logic in it. All that we need to do is update the state, so this means we can just get rid of the entire statement:
"""#,
      timestamp: (11*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .toggleEnableGyroMotion(isOn):
//    case .form(\.userSettings.enableGyroMotion):
//      state.userSettings.enableGyroMotion = isOn
//      return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we can do the same for `.toggleEnableHaptics`:
"""#,
      timestamp: (11*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .toggleEnableHaptics(isOn):
//      state.userSettings.enableHaptics = isOn
//      return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So already we are seeing that we are going to be able to remove quite a bit of code from our `settingsReducer`.
"""#,
      timestamp: (11*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We still need to update the view because currently it is using the old actions for its bindings. So let’s hop over to `AccessibilitySettingsView.swift` and use our new binding helper:
"""#,
      timestamp: (11*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Toggle(
  "Cube motion",
  isOn: self.viewStore.binding(
    keyPath: \.userSettings.enableGyroMotion,
    form: SettingsAction.form
  )
)

Toggle(
  "Haptics",
  isOn: self.viewStore.binding(
    keyPath: \.userSettings.enableHaptics,
    form: SettingsAction.form
  )
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And just like that we are in compiling order.
"""#,
      timestamp: (12*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But before moving on, let’s take advantage of the hyper modularization we have employed in this project. There’s no longer a need to to build the full app target since we are only dealing with settings-related things. Even though Swift is pretty good about incremental compilation, there are a lot of things that can cause Swift to rebuild the entire target from scratch, such as if you needed to briefly switch to another branch to check something out. Doing so will cause you to incur the full 40 second build time when you come back.
"""#,
      timestamp: (12*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So let’s just build the settings feature in isolation, which we can do by selecting the `SettingsFeature` target.
"""#,
      timestamp: (12*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We now run just this one screen as an Xcode preview, and switch these toggles on and off. The mere fact that these toggles are even changing must mean the form logic is hooked up correctly, because remember that we deleted the reducer code that was updating this state. So if the form higher-order reducer wasn’t doing its job then tapping these toggles wouldn’t do anything at all.
"""#,
      timestamp: (12*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s update a few more. There are 6 other actions that are similar to the ones we just dealt with in that they only mutate some state and don’t perform any side effects. Let’s comment out those actions and their implementations in the reducer:
"""#,
      timestamp: (13*60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//  case dismissAlert
//  case toggleEnableCubeShadow(isOn: Bool)
//  case toggleSendDailyChallengeReminder(isOn: Bool)
//  case toggleSendDailyChallengeSummary(isOn: Bool)
//  case toggleShowSceneStatistics(isOn: Bool)
//  case updateCubeShadowRadius(value: CGFloat)

//    case .dismissAlert:
//      state.alert = nil
//      return .none
//
//    case let .toggleEnableCubeShadow(isOn):
//      state.enableCubeShadow = isOn
//      return .none
//
//    case let .toggleSendDailyChallengeReminder(isOn: isOn):
//      state.userSettings.sendDailyChallengeReminder = isOn
//      return .none
//
//    case let .toggleSendDailyChallengeSummary(isOn: isOn):
//      state.userSettings.sendDailyChallengeSummary = isOn
//      return .none
//
//    case let .toggleShowSceneStatistics(isOn):
//      state.showSceneStatistics = isOn
//      return .none
//
//    case let .updateCubeShadowRadius(value: radius):
//      state.cubeShadowRadius = radius
//      return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
At the bottom of this file we have a helper on alert state that would send `.dismissAlert` on dismiss. We can update it to send a form action instead.
"""#,
      timestamp: (14*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
primaryButton: .default("Ok", send: .form(.set(\.alert, nil))),
...
onDismiss: .form(.set(\.alert, nil)))
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 Referencing static method 'set' on 'AlertState' requires that 'SettingsAction' conform to 'Hashable'

This isn't yet building because our form action initializer is currently constrained to values that are `Hashable`, but `SettingsAction` does not conform to `Hashable`. Ideally we would have a simpler `Equatable` constraint, instead, but we are currently leaning on the standard library, which provides `AnyHashable` but no such `AnyEquatable`.
"""#,
      timestamp: (14*60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In order to get things building we can conform `SettingsAction` to `Hashable`. This isn't so simple to do in practice, since `SettingsAction`s embed a whole lot of other types that don't conform to `Hashable`. We can fake out a conformance for now, but really what we are seeing is that it is important to get these conformances right, and that something as simple as a `Hashable` vs. `Equatable` difference can really impact a code base.
"""#,
      timestamp: (15*60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
public func hash(into hasher: inout Hasher) {}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Just to emphasize: this is _not_ the right solution to the problem. Ideally we would loosen our `Hashable` constraint to `Equatable` instead.
"""#,
      timestamp: (16*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And let’s fix their bindings in the view. First, over in `NotificationSettingsView.swift` we have two bindings dealing with daily challenge options. We can update these bindings to use the new form binding helper:
"""#,
      timestamp: (16*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Toggle(
  "Daily challenge reminders",
  isOn: self.viewStore.binding(
    keyPath: \.userSettings.sendDailyChallengeReminder,
    form: SettingsAction.form
  )
)

Toggle(
  "Daily challenge summary",
  isOn: self.viewStore.binding(
    keyPath: \.userSettings.sendDailyChallengeSummary,
    form: SettingsAction.form
  )
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Similarly, over in `DeveloperSettingsView.swift` we’ve got three bindings that need to be updated to use the new form binding helper:
"""#,
      timestamp: (16*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Toggle(
  "Shadows",
  isOn: self.viewStore.binding(
    keyPath: \.enableCubeShadow,
    form: SettingsAction.form
  )
)

Slider(
  value: viewStore.binding(
    keyPath: \.cubeShadowRadius,
    form: SettingsAction.form
  ),
  in: (0 as CGFloat)...200
)

Toggle(
  "Scene statistics",
  isOn: viewStore.binding(
    keyPath: \.showSceneStatistics,
    form: SettingsAction.form
  )
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now the module is building again, and we’ve gotten rid of 6 additional actions.
"""#,
      timestamp: (17*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Handling side effects"#,
      timestamp: (17*60 + 34),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s try a more complicated action, something involving effects.
"""#,
      timestamp: (17*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We have this `.setApiBaseUrl` action for updating which API endpoint is used, and it needs to fire off some effects to configure the API client. Let’s comment out this action:
"""#,
      timestamp: (18*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//  case setApiBaseUrl(DeveloperSettings.BaseUrl)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then, in the reducer, instead of matching against the `.setApiBaseUrl` action we will match against the `\.developer.currentBaseUrl` key path, which is invoked when that property is changed via a form action:
"""#,
      timestamp: (18*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .setApiBaseUrl(baseUrl):
    case .form(\.developer.currentBaseUrl):
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
In the body of this `case` we no longer need to update state, as that’s already been done for us by the `.form` higher-order reducer, and we just need to reach into the reducer’s `state` to grab the current URL instead of relying on the value passed to the action:
"""#,
      timestamp: (18*60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .form(\.developer.currentBaseUrl):
  // state.developer.currentBaseUrl = baseUrl
  return .merge(
    environment.apiClient.setBaseUrl(state.developer.currentBaseUrl.url).fireAndForget(),
    environment.apiClient.setAccessToken(nil).fireAndForget()
  )
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This is pretty cool stuff. We are hiding away the boring, repetitive work, such as updating state, in the `.form` higher-order reducer, and then our `settingsReducer` can be concerned with the more complex logic.
"""#,
      timestamp: (19*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Next, in the view we we can fix the `selection` binding that is used for the API endpoint picker:
"""#,
      timestamp: (19*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Picker(
  "",
  selection: self.viewStore.binding(
    keyPath: \.developer.currentBaseUrl,
    form: SettingsAction.form
  )
) {
  ForEach(DeveloperSettings.BaseUrl.allCases, id: \.self) {
    Text($0.description)
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s keep going. There are two bindings in the appearance settings sub-screen that also need to fire off effects. It’s the actions that update the color scheme of the application and update the application icon. Let’s comment out these actions:
"""#,
      timestamp: (19*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//  case setAppIcon(AppIcon?)
//  case setColorScheme(UserSettings.ColorScheme)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And let’s update the reducer to destructure those key paths:
"""#,
      timestamp: (19*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .setAppIcon(icon):
//      state.userSettings.appIcon = icon
    case .form(\.userSettings.appIcon):
      return environment.applicationClient
        .setAlternateIconName(state.userSettings.appIcon?.rawValue)
        .ignoreFailure()
        .eraseToEffect()
        .fireAndForget()

//    case let .setColorScheme(colorScheme):
//      state.userSettings.colorScheme = colorScheme
    case .form(\.userSettings.colorScheme):
    return environment.setUserInterfaceStyle(state.userSettings.colorScheme.userInterfaceStyle)
        .fireAndForget()
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we can hop over to `AppearanceSettingsView.swift` and fix the bindings:
"""#,
      timestamp: (20*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
ColorSchemePicker(
  colorScheme: self.viewStore.binding(
    keyPath: \.userSettings.colorScheme,
    form: SettingsAction.form
  )
)

AppIconPicker(
  appIcon: self.viewStore.binding(
    keyPath: \.userSettings.appIcon,
    form: SettingsAction.form
  )
  .animation()
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
There’s only a few bindings left. Let’s tackle the two bindings that control the sound volumes for the app. We can comment out these two actions:
"""#,
      timestamp: (21*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//  case setMusicVolume(Float)
//  case setSoundEffectsVolume(Float)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we’ll update the reducer to destructure on these key paths:
"""#,
      timestamp: (21*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .setMusicVolume(volume):
//      state.userSettings.musicVolume = volume
case .form(\.userSettings.musicVolume):
  return environment.audioPlayer.setGlobalVolumeForMusic(state.userSettings.musicVolume)
    .fireAndForget()

//    case let .setSoundEffectsVolume(volume):
//      state.userSettings.soundEffectsVolume = volume
case .form(\.userSettings.soundEffectsVolume):
  return environment.audioPlayer.setGlobalVolumeForSoundEffects(state.userSettings.soundEffectsVolume)
    .fireAndForget()
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we’ll update the view to use the new binding helper:
"""#,
      timestamp: (21*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Slider(
  value: self.viewStore.binding(
    keyPath: \.userSettings.musicVolume,
    form: SettingsAction.form
  )
  .animation(),
  in: 0...1
)

Slider(
  value: self.viewStore.binding(
    keyPath: \.userSettings.soundEffectsVolume,
    form: SettingsAction.form
  )
  .animation(),
  in: 0...1
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We are now down to one final action, and it’s the most complicated one. It is invoked when the notifications toggle is changed, and so it’s responsible for executing effects for requesting authorization. Let’s start in the same way we started with all the other actions, by first commenting it out:
"""#,
      timestamp: (22*60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//  case toggleEnableNotifications(isOn: Bool)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And in the reducer we will destructure the `\.enableNotifications` key path instead of matching on the `.toggleEnableNotifications` action:
"""#,
      timestamp: (22*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
//    case let .toggleEnableNotifications(isOn):
    case .form(\.enableNotifications):
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But then we have a compiler error because we were accessing the `isOn` variable that previously bound from the action. Instead we can now use `state.enableNotifications`:
"""#,
      timestamp: (22*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .form(\.enableNotifications):
  guard
    state.enableNotifications,
    ...
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And finally we need to update the view to use the new binding helper:
"""#,
      timestamp: (23*60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Toggle(
  "Enable notifications",
  isOn: self.viewStore.binding(
    keyPath: \.enableNotifications,
    form: SettingsAction.form
  )
  .animation()
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we have now converted all of the UI controls in our settings feature to use the new, fancy `FormAction`, which has removed 14 actions from the `SettingsAction` enum and removed more than 40 lines of code from our reducer. When we run it in the simulator it even seems to still work just as it did before.
"""#,
      timestamp: (23*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If we delete all the commented-out code and run `git diff` we can get a feel for just how much we were able to get rid of:
"""#,
      timestamp: (24*60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
$ git diff --stat
...
 Sources/SettingsFeature/Settings.swift              | 75 +++++-----------------
"""#,
      timestamp: nil,
      type: .code(lang: .plainText)
    ),
    Episode.TranscriptBlock(
      content: #"Updating tests"#,
      timestamp: (25*60 + 20),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that seems like a huge win, but we also made quite a few changes to our application, and how do we know we got everything right?
"""#,
      timestamp: (25*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Well, luckily we have a full test suite on this feature. Current the test suite fails to build because we’ve removed a bunch of actions, so let’s see what it takes to fix it.
"""#,
      timestamp: (25*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The first error we have is when trying to send the following action to the test store:
"""#,
      timestamp: (25*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.send(.toggleEnableNotifications(isOn: true)) {
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This action no longer exists in the `SettingsAction` enum, and instead we must send the equivalent `FormAction` where we specify which key path we are setting:
"""#,
      timestamp: (25*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// .send(.toggleEnableNotifications(isOn: true)) {
.send(.form(.set(\.enableNotifications, true))) {
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
That’s pretty straightforward and is only a few characters longer. We have a bunch of tests for this action, so let's update all of them.
"""#,
      timestamp: (26*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we have alert dismissal:
"""#,
      timestamp: (26*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// .send(.dismissAlert) {
.send(.form(.set(\.alert, nil))) {
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
In fact, all of these are pretty straightforward to convert, so let’s do it quickly:
"""#,
      timestamp: (26*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the test suite is building again, and if we run we see that all tests pass. This means that not only is our `.form` higher-order reducer working correctly, but the additional logic we layer on top of the simple state mutation, such as executing effects, is still working correctly too.
"""#,
      timestamp: (26*60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Conclusion"#,
      timestamp: (27*60 + 18),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
That concludes this episode and our series of episodes on concise forms. We hope that we have shown that the Composable Architecture can simultaneously handle simple forms with lots of state without incurring boilerplate, while simultaneously giving us the tools to handle much more complex forms, like when when we need to deal with effects.
"""#,
      timestamp: (27*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And we've really demonstrated this by looking at an actual, real-world application that we're building: a game built in the Composable Architecture, and it massively cleaned up its settings reducer, which had been getting to be a beast.
"""#,
      timestamp: (27*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Luckily for our viewers, they too can now take advantage of this because we've released a new version of [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) that bring all of these form helpers to the core library and they can instantly start taking advantage of these APIs.
"""#,
      timestamp: (27*60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We released this feature the week before this episode aired and made a few changes after hearing back from you! We have generalized the "form" naming to apply more generally to bindings. This means `FormAction` is now `BindingAction`, and the `form` higher-order reducer is now a `binding` higher-order reducer, as well. Thanks to the community for this feedback!
"""#,
      timestamp: nil,
      type: .correction
    ),
    Episode.TranscriptBlock(
      content: #"""
Until next time.
"""#,
      timestamp: (28*60 + 8),
      type: .paragraph
    ),
  ]
}
