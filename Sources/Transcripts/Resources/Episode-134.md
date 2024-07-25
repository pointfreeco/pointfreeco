## Introduction

@T(00:00:05)
We think this is pretty incredible. We only added about 50 lines of library code, consisting of a new type, a higher-order reducer, and a few helpers, and we now have a really robust solution to simple and complex forms in the Composable Architecture. We are free to add as many controls to this screen as we want, and we will not incur any additional boilerplate. The bindings will automatically update the corresponding state without us needing to do anything, but if we want to layer on some additional logic we simply need to destructure the key path we are interested in.

@T(00:01:11)
So we believe we have truly we have created the tools for dealing with forms in SwiftUI in a concise manner. But on Point-Free we like to end every series of episodes by asking "what's the point?" This gives us a chance to bring abstract concepts down to earth and show some real world applications. This time we were rooted in reality from the very beginning because we started by showing that the Composable Architecture had a boilerplate problem. Then we explored a theoretical Swift feature that could help solve the boilerplate problem, that of enum cases with generics. But, even without that theoretical feature we are able to approximate it with type-erasure, and so this is a really great, real world demonstration of how to use type-erasure.

@T(00:01:57)
But, just because this series of episodes has been rooted in reality from the beginning doesn't mean we can't dig a little deeper 😁.

@T(00:02:03)
We are going to demonstrate how these form helpers can massively simplify and clean up a real world code base. As some of our viewers may know already, about a month ago we announced that we are working on a new project. It’s a word game called [isowords](https://www.isowords.xyz), and it’s completely built in the Composable Architecture, and even the server is built in Swift. If you are interested in learning more you can visit our website at isowords.xyz, and if you’d like beta access feel free to email us.

@T(00:02:33)
We will live refactor the code for the settings screen in the [isowords](https://www.isowords.xyz) code base to show a real world example of just how concise forms and the Composable Architecture can be.

## isowords

@T(00:02:50)
isowords is a word search game that takes place on an isometric cube. The full application is written in the Composable Architecture, from the menus, settings and leaderboards all the way to the engine that powers the game’s logic.

@T(00:03:08)
The goal is to find words, the longer the word the higher the score, and the third time a letter is used its cube is removed. This gives you more chances to find interesting words as cubes underneath are revealed.

@T(00:03:25)
Let’s start by opening up the [isowords](https://www.isowords.xyz) project.

@T(00:03:30)
The project is quite large, currently consisting of about 40,000 lines of code for both the client and server and 70 Swift packages. As you may know from our past episodes on modularity, we are big proponents of breaking down applications into many small modules. There are a ton of benefits to doing so, including:

@T(00:03:57)
- Strengthens boundaries in your application by making it explicit which components have access to other components.

@T(00:04:04)
- Increases productivity because building a small feature module can be many times faster than building the full application.

@T(00:04:10)
- Decreases compile times of the full application because the build system can be smarter about how modules are built in parallel.

@T(00:04:18)
- Increases stability of Xcode previews because there is less code to build.

@T(00:04:24)
Amongst other things.

@T(00:04:28)
As a concrete example, it currently takes about 40 seconds to build the isowords application from a clean state, but the `SettingsFeature` module, which holds all of the code for our settings screen, builds in about 10 seconds.

@T(00:04:42)
Let’s start by running the full application in the simulator and giving a quick demonstration of what settings look like in isowords.

@T(00:04:49)
- At the top right of the home screen we will see a settings button.

@T(00:04:54)
- Tapping that drills us into a screen with lots of setting sub-screens.

@T(00:05:00)
- In the notifications sub-screen we have something quite similar to what we just built in these episodes

@T(00:05:06)
- Tapping on the toggle prompts us for notification permissions and it eagerly turns the toggle on.

@T(00:05:19)
- If we deny permissions then the toggle switches back off.

@T(00:05:26)
- Tapping the toggle again shows us a prompt to turn on notifications in iOS settings, and provides a button to do so

@T(00:05:30)
- Tapping that button takes us to iOS settings, so we can turn on notifications

@T(00:05:35)
- And then going back to the app our notifications have been automatically enabled for us.

@T(00:05:41)
- So that’s already a pretty complex flow in this form. The other screens are a little simpler.

@T(00:05:46)
- In sounds we just have a few simple sliders

@T(00:05:56)
- In appearance we have a few pickers for deciding what color scheme or app icon you want

@T(00:06:04)
- In accessibility we have a few settings for enabling/disabling features like motion or haptics

@T(00:06:11)
- And finally in the developer sub-screen we have a few settings that are only pertinent to the developers of the game, such as which API we are hitting or showing statistics in the game, such as frame per second and draw calls.

## Settings in isowords

@T(00:06:27)
So there’s quite a bit in this screen. And quite a bit of Composable Architecture code backing it.

@T(00:06:43)
Currently it does not use any of the form helpers we just wrote. It introduces an action per control, so I think we have an opportunity to clean up a lot of code here.

@T(00:07:03)
If we hop over to the file that holds the domain for this feature, we will find this monstrosity of an action enum:

```swift
public enum SettingsAction: Equatable {
  case didBecomeActive
  case dismissAlert
  case leaveUsAReviewButtonTapped
  case onAppear
  case onDismiss
  case openSettingButtonTapped
  case productsResponse(
    Result<StoreKitClient.ProductsResponse, NSError>
  )
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
  case userNotificationSettingsResponse(
    UserNotificationClient.Notification.Settings
  )
}
```

@T(00:07:14)
This holds every action that can occur in the settings screen, including every button tap, every UI control binding, and every effect response. If we separate the user actions and effect actions from the binding actions we will find that half of these actions are used in UI control bindings:

```swift
public enum SettingsAction: Equatable {
  case didBecomeActive
  case leaveUsAReviewButtonTapped
  case onAppear
  case onDismiss
  case openSettingButtonTapped
  case productsResponse(
    Result<StoreKitClient.ProductsResponse, NSError>
  )
  case reportABugButtonTapped
  case restoreButtonTapped
  case stats(StatsAction)
  case tappedProduct(StoreKitClient.Product)
  case userNotificationAuthorizationResponse(Result<Bool, NSError>)
  case userNotificationSettingsResponse(
    UserNotificationClient.Notification.Settings
  )

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
```

@T(00:07:46)
Let’s also take a look at what the reducer does with these actions.

@T(00:07:58)
The first five actions all follow the same pattern: they mutate state with the value handed to us from the binding, and then fire off an effect.

```swift
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
  return environment.setUserInterfaceStyle(
    colorScheme.userInterfaceStyle
  )
  .fireAndForget()

case let .setMusicVolume(volume):
  state.userSettings.musicVolume = volume
  return environment.audioPlayer.setGlobalVolumeForMusic(volume)
    .fireAndForget()

case let .setSoundEffectsVolume(volume):
  state.userSettings.soundEffectsVolume = volume
  return environment.audioPlayer.setGlobalVolumeForSoundEffects(volume)
    .fireAndForget()
```

@T(00:08:25)
Then we’ve got all the toggle bindings, which simply update state and return no effects, except for the notifications toggle:

```swift
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
    return environment.userNotifications
      .requestAuthorization([.alert, .badge, .sound])
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
    return .init(
      value: .userNotificationAuthorizationResponse(
        .success(true)
      )
    )

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
```

@T(00:08:56)
This is a ton of boilerplate for what should be something simple. All the lines that are simply updating state with the value handled to us from the binding do not need to be there, and all the cases that don’t execute effects can entirely go away.

## Bye bye boilerplate

@T(00:09:12)
So, let’s fix it.

@T(00:09:14)
We will introduce a new `Forms.swift` and paste in all the code we wrote in the previous episodes.

@T(00:09:27)
Next we’ll add a `.form` case to our actions, but we’ll leave the all the other actions for now:

```swift
public enum SettingsAction: Equatable {
  …

  case form(FormAction<SettingsState>)
}
```

@T(00:09:46)
And we need to handle this action in the reducer, but for now we’ll just return no effects:

```swift
switch action {
…

case .form:
  return .none
}
```

@T(00:10:08)
To enhance the settings reducer with the form functionality we need to apply the `.form` higher-order reducer:

```swift
.form(action: /SettingsAction.form)
```

@T(00:10:29)
Now we can start converting our form actions over to take advantage of this form machinery. We’ll start with some of the simpler actions. For example, in the accessibility settings we can toggle gyroscope motion and haptics, and both of those bindings do the simplest kind of state mutation with no effects. We can get rid of those actions:

```swift
// case toggleEnableGyroMotion(isOn: Bool)
// case toggleEnableHaptics(isOn: Bool)
```

@T(00:10:50)
And in the reducer, rather than having a `case` statement for each of those actions, we can instead destructure the `.form` case to match against the key path of the property that was changed. For example, instead of matching against `.toggleEnableGyroMotion` we can just check when the form updates the `\.userSettings.enableGyroMotion` key path:

```swift
// case let .toggleEnableGyroMotion(isOn):
case .form(\.userSettings.enableGyroMotion):
  state.userSettings.enableGyroMotion = isOn
  return .none
```

@T(00:11:15)
Further, the `.form` higher-order reducer has already taken care of this mutation for us, so there’s no reason to do this:

```swift
// case let .toggleEnableGyroMotion(isOn):
case .form(\.userSettings.enableGyroMotion):
  // state.userSettings.enableGyroMotion = isOn
  return .none
```

@T(00:11:22)
But now we see that this action actually has no additional logic in it. All that we need to do is update the state, so this means we can just get rid of the entire statement:

```swift
// case let .toggleEnableGyroMotion(isOn):
// case .form(\.userSettings.enableGyroMotion):
//   state.userSettings.enableGyroMotion = isOn
//   return .none
```

@T(00:11:30)
And we can do the same for `.toggleEnableHaptics`:

```swift
// case let .toggleEnableHaptics(isOn):
//   state.userSettings.enableHaptics = isOn
//   return .none
```

@T(00:11:33)
So already we are seeing that we are going to be able to remove quite a bit of code from our `settingsReducer`.

@T(00:11:38)
We still need to update the view because currently it is using the old actions for its bindings. So let’s hop over to `AccessibilitySettingsView.swift` and use our new binding helper:

```swift
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
```

@T(00:12:07)
And just like that we are in compiling order.

@T(00:12:18)
But before moving on, let’s take advantage of the hyper modularization we have employed in this project. There’s no longer a need to to build the full app target since we are only dealing with settings-related things. Even though Swift is pretty good about incremental compilation, there are a lot of things that can cause Swift to rebuild the entire target from scratch, such as if you needed to briefly switch to another branch to check something out. Doing so will cause you to incur the full 40 second build time when you come back.

@T(00:12:47)
So let’s just build the settings feature in isolation, which we can do by selecting the `SettingsFeature` target.

@T(00:12:56)
We now run just this one screen as an Xcode preview, and switch these toggles on and off. The mere fact that these toggles are even changing must mean the form logic is hooked up correctly, because remember that we deleted the reducer code that was updating this state. So if the form higher-order reducer wasn’t doing its job then tapping these toggles wouldn’t do anything at all.

@T(00:13:35)
Let’s update a few more. There are 6 other actions that are similar to the ones we just dealt with in that they only mutate some state and don’t perform any side effects. Let’s comment out those actions and their implementations in the reducer:

```swift
// case dismissAlert
// case toggleEnableCubeShadow(isOn: Bool)
// case toggleSendDailyChallengeReminder(isOn: Bool)
// case toggleSendDailyChallengeSummary(isOn: Bool)
// case toggleShowSceneStatistics(isOn: Bool)
// case updateCubeShadowRadius(value: CGFloat)
…
// case .dismissAlert:
//   state.alert = nil
//   return .none
//
// case let .toggleEnableCubeShadow(isOn):
//   state.enableCubeShadow = isOn
//   return .none
//
// case let .toggleSendDailyChallengeReminder(isOn: isOn):
//   state.userSettings.sendDailyChallengeReminder = isOn
//   return .none
//
// case let .toggleSendDailyChallengeSummary(isOn: isOn):
//   state.userSettings.sendDailyChallengeSummary = isOn
//   return .none
//
// case let .toggleShowSceneStatistics(isOn):
//   state.showSceneStatistics = isOn
//   return .none
//
// case let .updateCubeShadowRadius(value: radius):
//   state.cubeShadowRadius = radius
//   return .none
```

@T(00:14:26)
At the bottom of this file we have a helper on alert state that would send `.dismissAlert` on dismiss. We can update it to send a form action instead.

```swift
primaryButton: .default("OK", send: .form(.set(\.alert, nil))),
…
onDismiss: .form(.set(\.alert, nil)))
```

> Error: Referencing static method 'set' on 'AlertState' requires that 'SettingsAction' conform to 'Hashable'

@T(00:14:53)
This isn't yet building because our form action initializer is currently constrained to values that are `Hashable`, but `SettingsAction` does not conform to `Hashable`. Ideally we would have a simpler `Equatable` constraint, instead, but we are currently leaning on the standard library, which provides `AnyHashable` but no such `AnyEquatable`.

@T(00:15:40)
In order to get things building we can conform `SettingsAction` to `Hashable`. This isn't so simple to do in practice, since `SettingsAction`s embed a whole lot of other types that don't conform to `Hashable`. We can fake out a conformance for now, but really what we are seeing is that it is important to get these conformances right, and that something as simple as a `Hashable` vs. `Equatable` difference can really impact a code base.

```swift
public func hash(into hasher: inout Hasher) {}
```

@T(00:16:17)
Just to emphasize: this is _not_ the right solution to the problem. Ideally we would loosen our `Hashable` constraint to `Equatable` instead.

@T(00:16:37)
And let’s fix their bindings in the view. First, over in `NotificationSettingsView.swift` we have two bindings dealing with daily challenge options. We can update these bindings to use the new form binding helper:

```swift
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
```

@T(00:16:59)
Similarly, over in `DeveloperSettingsView.swift` we’ve got three bindings that need to be updated to use the new form binding helper:

```swift
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
```

@T(00:17:20)
And now the module is building again, and we’ve gotten rid of 6 additional actions.

## Handling side effects

@T(00:17:34)
Let’s try a more complicated action, something involving effects.

@T(00:18:01)
We have this `.setApiBaseUrl` action for updating which API endpoint is used, and it needs to fire off some effects to configure the API client. Let’s comment out this action:

```swift
//  case setApiBaseUrl(DeveloperSettings.BaseUrl)
```

@T(00:18:24)
Then, in the reducer, instead of matching against the `.setApiBaseUrl` action we will match against the `\.developer.currentBaseUrl` key path, which is invoked when that property is changed via a form action:

```swift
//    case let .setApiBaseUrl(baseUrl):
    case .form(\.developer.currentBaseUrl):
```

@T(00:18:44)
In the body of this `case` we no longer need to update state, as that’s already been done for us by the `.form` higher-order reducer, and we just need to reach into the reducer’s `state` to grab the current URL instead of relying on the value passed to the action:

```swift
case .form(\.developer.currentBaseUrl):
  // state.developer.currentBaseUrl = baseUrl
  return .merge(
    environment.apiClient.setBaseUrl(
      state.developer.currentBaseUrl.url
    )
    .fireAndForget(),
    environment.apiClient.setAccessToken(nil).fireAndForget()
  )
```

@T(00:19:05)
This is pretty cool stuff. We are hiding away the boring, repetitive work, such as updating state, in the `.form` higher-order reducer, and then our `settingsReducer` can be concerned with the more complex logic.

@T(00:19:19)
Next, in the view we we can fix the `selection` binding that is used for the API endpoint picker:

```swift
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
```

@T(00:19:39)
Let’s keep going. There are two bindings in the appearance settings sub-screen that also need to fire off effects. It’s the actions that update the color scheme of the application and update the application icon. Let’s comment out these actions:

```swift
// case setAppIcon(AppIcon?)
// case setColorScheme(UserSettings.ColorScheme)
```

@T(00:19:52)
And let’s update the reducer to destructure those key paths:

```swift
// case let .setAppIcon(icon):
//   state.userSettings.appIcon = icon
case .form(\.userSettings.appIcon):
  return environment.applicationClient
    .setAlternateIconName(state.userSettings.appIcon?.rawValue)
    .ignoreFailure()
    .eraseToEffect()
    .fireAndForget()

// case let .setColorScheme(colorScheme):
//   state.userSettings.colorScheme = colorScheme
case .form(\.userSettings.colorScheme):
  return environment
    .setUserInterfaceStyle(
      state.userSettings.colorScheme.userInterfaceStyle
    )
    .fireAndForget()
```

@T(00:20:41)
Then we can hop over to `AppearanceSettingsView.swift` and fix the bindings:

```swift
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
```

@T(00:21:02)
There’s only a few bindings left. Let’s tackle the two bindings that control the sound volumes for the app. We can comment out these two actions:

```swift
//  case setMusicVolume(Float)
//  case setSoundEffectsVolume(Float)
```

@T(00:21:12)
And we’ll update the reducer to destructure on these key paths:

```swift
// case let .setMusicVolume(volume):
//   state.userSettings.musicVolume = volume
case .form(\.userSettings.musicVolume):
  return environment.audioPlayer.setGlobalVolumeForMusic(
    state.userSettings.musicVolume
  )
  .fireAndForget()

// case let .setSoundEffectsVolume(volume):
//   state.userSettings.soundEffectsVolume = volume
case .form(\.userSettings.soundEffectsVolume):
  return environment.audioPlayer
    .setGlobalVolumeForSoundEffects(
      state.userSettings.soundEffectsVolume
    )
    .fireAndForget()
```

@T(00:21:41)
And we’ll update the view to use the new binding helper:

```swift
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
```

@T(00:22:02)
We are now down to one final action, and it’s the most complicated one. It is invoked when the notifications toggle is changed, and so it’s responsible for executing effects for requesting authorization. Let’s start in the same way we started with all the other actions, by first commenting it out:

```swift
//  case toggleEnableNotifications(isOn: Bool)
```

@T(00:22:38)
And in the reducer we will destructure the `\.enableNotifications` key path instead of matching on the `.toggleEnableNotifications` action:

```swift
//    case let .toggleEnableNotifications(isOn):
    case .form(\.enableNotifications):
```

@T(00:22:52)
But then we have a compiler error because we were accessing the `isOn` variable that previously bound from the action. Instead we can now use `state.enableNotifications`:

```swift
case .form(\.enableNotifications):
  guard
    state.enableNotifications,
    …
```

@T(00:23:06)
And finally we need to update the view to use the new binding helper:

```swift
Toggle(
  "Enable notifications",
  isOn: self.viewStore.binding(
    keyPath: \.enableNotifications,
    form: SettingsAction.form
  )
  .animation()
)
```

@T(00:23:26)
And we have now converted all of the UI controls in our settings feature to use the new, fancy `FormAction`, which has removed 14 actions from the `SettingsAction` enum and removed more than 40 lines of code from our reducer. When we run it in the simulator it even seems to still work just as it did before.

@T(00:24:42)
If we delete all the commented-out code and run `git diff` we can get a feel for just how much we were able to get rid of:

```txt
$ git diff --stat
…
 Sources/SettingsFeature/Settings.swift              | 75 +++++-----------------
```

## Updating tests

@T(00:25:20)
So, that seems like a huge win, but we also made quite a few changes to our application, and how do we know we got everything right?

@T(00:25:27)
Well, luckily we have a full test suite on this feature. Current the test suite fails to build because we’ve removed a bunch of actions, so let’s see what it takes to fix it.

@T(00:25:37)
The first error we have is when trying to send the following action to the test store:

```swift
.send(.toggleEnableNotifications(isOn: true)) {
```

@T(00:25:49)
This action no longer exists in the `SettingsAction` enum, and instead we must send the equivalent `FormAction` where we specify which key path we are setting:

```swift
// .send(.toggleEnableNotifications(isOn: true)) {
.send(.form(.set(\.enableNotifications, true))) {
```

@T(00:26:00)
That’s pretty straightforward and is only a few characters longer. We have a bunch of tests for this action, so let's update all of them.

@T(00:26:17)
Next we have alert dismissal:

```swift
// .send(.dismissAlert) {
.send(.form(.set(\.alert, nil))) {
```

@T(00:26:27)
In fact, all of these are pretty straightforward to convert, so let’s do it quickly:

@T(00:26:48)
Now the test suite is building again, and if we run we see that all tests pass. This means that not only is our `.form` higher-order reducer working correctly, but the additional logic we layer on top of the simple state mutation, such as executing effects, is still working correctly too.

## Conclusion

@T(00:27:18)
That concludes this episode and our series of episodes on concise forms. We hope that we have shown that the Composable Architecture can simultaneously handle simple forms with lots of state without incurring boilerplate, while simultaneously giving us the tools to handle much more complex forms, like when when we need to deal with effects.

@T(00:27:37)
And we've really demonstrated this by looking at an actual, real-world application that we're building: a game built in the Composable Architecture, and it massively cleaned up its settings reducer, which had been getting to be a beast.

@T(00:27:53)
Luckily for our viewers, they too can now take advantage of this because we've released a new version of [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) that bring all of these form helpers to the core library and they can instantly start taking advantage of these APIs.

> Correction: We released this feature the week before this episode aired and made a few changes after hearing back from you! We have generalized the "form" naming to apply more generally to bindings. This means `FormAction` is now `BindingAction`, and the `form` higher-order reducer is now a `binding` higher-order reducer, as well. Thanks to the community for this feedback!

@T(00:28:08)
Until next time.
