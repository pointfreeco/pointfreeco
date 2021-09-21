import Foundation

extension Episode {
  public static let ep155_focusState = Episode(
    blurb: """
Let's explore another API just announced at WWDC: `@FocusState`. We'll take a simple example and layer on some complexity, including side effects and testability, and we'll see that the solution we land on works just as well in the Composable Architecture!
""",
    codeSampleDirectory: "0155-focus-state",
    exercises: _exercises,
    id: 155,
    image: "https://i.vimeocdn.com/video/1198344671-c188084702fa5e0fba620ddd46fe4798e3fe0a5e0f7d7e2d07e3126a1a2c4c16-d",
    length: 39*60 + 36,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1627880400),
    references: [
      Episode.Reference(
        author: "Matt Ricketson and Taylor Kelly",
        blurb: #"""
A WWDC session covering what's new in SwiftUI this year, including the `@FocusState` property wrapper.
"""#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10018/",
        publishedAt: referenceDateFormatter.date(from: "2021-06-08"),
        title: "What's new in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
Documentation for the `@FocusState` property wrapper.
"""#,
        link: "https://developer.apple.com/documentation/swiftui/focusstate/",
        publishedAt: nil,
        title: "`FocusState`"
      ),
    ],
    sequence: 155,
    subtitle: nil,
    title: "SwiftUI Focus State",
    trailerVideo: .init(
      bytesLength: 28971455,
      vimeoId: 577546109,
      vimeoSecret: "62d0ccf002efb825d8603c7e17648ea317d41989"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
While it is not yet possible to abstract over a property wrapper in Swift, it _is_ possible to abstract over getting and setting a value in the form of key paths! Write a version of `synchronize` that works with writable key paths instead of bindings. What does the signature look like and what are some of the caveats?
"""#,
    solution: #"""
This implementation is maybe not as straightforward as the ones that use bindings. This is because bindings are already bound to a specific instance of mutable state, but key paths are not. Because of this, we must reference this mutable state in addition to they key paths.

Maybe we would pass a `Root` along:

```swift
extension View {
  func synchronize<Root, Value>(
    _ root: Root,
    _ first: ReferenceWritableKeyPath<Root, Value>,
    _ second: ReferenceWritableKeyPath<Root, Value>
  ) -> some View
  where Value: Equatable {
    self
      .onChange(of: root[keyPath: first]) { root[keyPath: second] = newValue }
      .onChange(of: root[keyPath: second]) { root[keyPath: first] = newValue }
  }
}
```

This would work for a view with an `@ObservedObject` view model (or view store) and `@FocusState`, but would unfortunately not work for a `WithViewStore` helper. To support synchronizing state among two completely separate entities, we'd need to pass both values along:

```swift
extension View {
  func synchronize<Root, Value>(
    _ first: Root,
    _ firstKeyPath: ReferenceWritableKeyPath<Root, Value>,
    _ second: Root,
    _ secondKeyPath: ReferenceWritableKeyPath<Root, Value>
  ) -> some View
  where Value: Equatable { … }
```

But now this is looking quite verbose, and perhaps it isn't pulling its weight.
"""#
  )
]

extension Episode.Video {
  public static let ep155_focusState = Self(
    bytesLength: 374673376,
    vimeoId: 577546117,
    vimeoSecret: "ab0bc6c8bf5201ad95a9c7aded1364d43c3ab641"
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep155_focusState: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
The last two weeks we explored the new `.refreshable` API that was announced at WWDC this year, and this week we want to look at another a fancy new SwiftUI API  that was introduced. Like `.refreshable` , it is also not immediately clear how it can be used with the Composable Architecture, and that is the new `@FocusState` property wrapper.
"""#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This property wrapper helps you control which UI controls are focused, and it is the declarative successor to the `becomeFirstResponder` and `resignFirstResponder` methods in UIKit. With those UIKit APIs you could explicitly tell a UI control to become focused or give up its focus, and SwiftUI’s APIs accomplish the same thing but in a different style.
"""#,
      timestamp: 49,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"@FocusState"#,
      timestamp: (1*60 + 41),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Like many things in SwiftUI it starts with a new property wrapper. This one is called `@FocusState`. The documentation helpfully comes with some sample code, so let’s create a new SwiftUI view stub and paste this code in:
"""#,
      timestamp: (1*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import SwiftUI

struct LoginForm {
  enum Field: Hashable {
    case username
    case password
  }

  @State private var username = ""
  @State private var password = ""
  @FocusState private var focusedField: Field?

  var body: some View {
    Form {
      TextField("Username", text: $username)
        .focused($focusedField, equals: .username)

      SecureField("Password", text: $password)
        .focused($focusedField, equals: .password)

      Button("Sign In") {
        if username.isEmpty {
          focusedField = .username
        } else if password.isEmpty {
          focusedField = .password
        } else {
          handleLogin(username, password)
        }
      }
    }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This code doesn’t compile just yet because we need to also import SwiftUI, we need to make `LoginForm` conform to `View` 😬, and we need to comment out some theoretical code that will handle login:
"""#,
      timestamp: (1*60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import SwiftUI
...
struct LoginForm: View {
...
// handleLogin(username, password)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now we would hope that we could run this view in an Xcode preview or the simulator to see how the focus changes work, but unfortunately that’s not the case. We have found two major bugs when using the new focus APIs and have filed Feedback for both.
"""#,
      timestamp: (2*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
First, focus state does not appear to work when used inside a `Form`, or even a `List`. This is a bummer because the `Form` view is the easiest way to get some simple styling in place with little work. I’m sure these bugs will be fixed before the final release, but that does mean for now in order to explore the API we need to use a different container view. We’ll go with a simple `VStack` for now:
"""#,
      timestamp: (2*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct LoginForm: View {
  ...

  var body: some View {
    VStack {
      ...
    }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Further, the focus API doesn’t seem to work in Xcode previews, but it does work in the simulator. So let’s return this view from the app's entry point so that we can run the application in the simulator, and we will finally see that everything works as we expect.
"""#,
      timestamp: (2*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
self.window?.rootViewController = UIHostingController(
  rootView: LoginForm()
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So, how does this API work?
"""#,
      timestamp: (3*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It starts by enumerating all of the fields that are focusable in the view:
"""#,
      timestamp: (3*60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum Field: Hashable {
  case username
  case password
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This `Hashable` value is used by SwiftUI to figure out which view is currently focused. There is also a version of the focus APIs that deals with simple booleans rather than a dedicated `Hashable` type, but while that API is easier to use it is also more error prone since you can easily cause multiple controls to be focused at once, which is not a valid thing to do.
"""#,
      timestamp: (3*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Once you’ve enumerated the fields that are focusable you introduce some state to your view to track the focus. However, you don’t simply use `@State` or `@StateObject` or `@ObservedObject` for this. There’s a whole new property wrapper for this state:
"""#,
      timestamp: (4*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
@FocusState private var focusedField: Field?
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next, we need to mark each UI control that wants to be focusable with the `.focused` view modifier, which requires us to specify the piece of `@FocusState` that controls the focus for the view, as well as the hashable value that identifies the control:
"""#,
      timestamp: (4*60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
TextField("Username", text: $username)
  .focused($focusedField, equals: .username)

SecureField("Password", text: $password)
  .focused($focusedField, equals: .password)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then finally we can implement some logic in the sign in button that checks if a field is empty, and if it is we focus that field. If all the fields are non-empty we can run some logic to handle the login:
"""#,
      timestamp: (5*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Button("Sign In") {
  if username.isEmpty {
    focusedField = .username
  } else if password.isEmpty {
    focusedField = .password
  } else {
    // handleLogin(username, password)
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"Vanilla SwiftUI"#,
      timestamp: (5*60 + 25),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Now before we consider how to use this API with the Composable Architecture, let’s dig a little deeper in how one uses `@FocusState` with more complex interactions in a vanilla SwiftUI situation. SwiftUI is a truly amazing framework, but sometimes it’s all too easy to meticulously craft short, sweet SwiftUI code samples that don’t get to the heart of what real life code bases grapple with.
"""#,
      timestamp: (5*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, let’s begin. The first thing I notice when I look at this code sample is how there is some pretty significant logic being performed in the view. Right now we are lucky that there are only two fields and the logic to determine which one to focus is a simple `.isEmpty` check, but in the future there could be far more complicated rules dictating how we change the focus of these fields.
"""#,
      timestamp: (5*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This is problematic for a few reasons. First of all, views are already decently complicated on their own by virtue of the fact that they are responsible for building up an entire view hierarchy. Some hierarchies can be quite complicated, consisting of hundreds of lines with deep indentation, and so having little bits of logic hidden in the dark crevices of the view can greatly increase their complexity. Further, the logic in these views is very difficult to test. Basically the only tool we have at our disposal to test SwiftUI views is UI integration testing, which is a very broad tool that can be slow and difficult to get right.
"""#,
      timestamp: (6*60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, when we are ready to extract logic and behavior out of views we turn to the `ObservableObject` protocol, which allows us to design a class that can hold onto a bit of mutable state, and becomes the best place to layer behavior on top of that state.
"""#,
      timestamp: (6*60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Perhaps we can extract out the `@State` and `@FocusState` fields to a view model class. The `@State` property wrappers need to be changed to `@Published`, and I’m not really sure what to do about the `@FocusState` property wrapper so let’s leave it as-is:
"""#,
      timestamp: (7*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
class LoginViewModel: ObservableObject {
  @Published var username = ""
  @Published var password = ""
  @FocusState var focusedField: LoginForm.Field?
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we can update our view to hold onto this view model rather than the individual fields:
"""#,
      timestamp: (7*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct LoginForm: View {
  @ObservedObject var viewModel: LoginViewModel

  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We just need a few small updates to the view to use the fields in the `viewModel` rather than using the fields that were previously defined directly on the view:
"""#,
      timestamp: (7*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
VStack {
  TextField("Username", text: $viewModel.username)
    .focused(viewModel.$focusedField, equals: .username)

  SecureField("Password", text: $viewModel.password)
    .focused(viewModel.$focusedField, equals: .password)

  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Note that the view model bindings and the focus state bindings place their `$` signs at different locations, which can be confusing, but `$viewModel` returns an observed object wrapper that can yield bindings for each field, which means it would give us a `Binding<FocusField?>`, but we need a `FocusState<FocusField?>`, which is what `viewModel.$focusedField` returns.
"""#,
      timestamp: (8*60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
For the sign in button, rather than leave that logic in the view let’s now move it to a method on the view model so that we will be able to write tests later:
"""#,
      timestamp: (8*60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func signInButtonTapped() {
  if self.username.isEmpty {
    self.focusedField = .username
  } else if self.password.isEmpty {
    self.focusedField = .password
  } else {
    // handleLogin(username, password)
  }
}
...
Button("Sign In") {
  self.viewModel.signInButtonTapped()
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And to get things compiling we need to update our app entrypoint.
"""#,
      timestamp: (8*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The app is now compiling, but if we run it we are immediately met with a crash and a purple runtime warning:
"""#,
      timestamp: (9*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 SIGABRT
> 🟣 Accessing FocusState's value outside of the body of a View. This will result in a constant Binding of the initial value and will not update.

It seems that it’s not legitimate to move `@FocusState` to the view model. This says we accessed the `FocusState`’s value outside the body, but it sure does look like we are in the body. However, notice that we are accessing the wrapped value by going through the view model, `viewModel.$focusField`, and I believe this is what SwiftUI has a problem with. And we should have known better because the `FocusState` struct conforms to the `DynamicProperty` protocol, which is something that can only be used with views, not in observable objects.
"""#,
      timestamp: (9*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, looks like we gotta move the `@FocusState` field back to the view. We can start by commenting out the field in our view model:
"""#,
      timestamp: (9*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
class LoginViewModel: ObservableObject {
//  @FocusState var focusedField: LoginForm.Field?
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But doing so means we no longer have access to it in the view model, which means `signInButtonTapped` cannot be implemented as it is currently.
"""#,
      timestamp: (10*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
There is one very simple change we could make to this method to try to support the idea of changing focus. We could return a `Field` value from the `signInButtonTapped` method to represent what field should be focused after the method executes its logic.
"""#,
      timestamp: (10*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func signInButtonTapped() -> LoginForm.Field {
  if self.username.isEmpty {
    return .username
  } else if self.password.isEmpty {
    return .password
  } else {
    // handleLogin(username, password)
    return ???
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
One problem with this is that it’s not clear what we should return when all the fields are non-empty. Should we reset the focus back to the user name? Or should we remove focus from all the fields? Or should we just leave the focus where it is? Or maybe we even want to support all of these use cases depending on the situation?
"""#,
      timestamp: (10*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we can’t return a plain `LoginForm.Field`. We need something with a bit more information attached. We could make it optional, but then we could only represent one of our use cases, such as clearing focus. If we want to support all the use cases we’d probably need to introduce a dedicated enum to describe each one:
"""#,
      timestamp: (11*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum FocusChange {
  case set(LoginForm.Field)
  case unchanged
  case unfocus
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then in our view we’d have to interpret this enum to figure out what to do. This seems like a lot of work for something so simple. And remember, the whole reason we are going down this road is because `@FocusState` can’t live in our view model, which means we can’t mutate it directly, and so we are forced to communicate how we want to mutate back to the view.
"""#,
      timestamp: (11*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s not use the enum and instead just use a simple optional, even though it is not ideal, and we’ll use `nil` to represent the use case of clearing the focus from all the controls:
"""#,
      timestamp: (11*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func signInButtonTapped() -> LoginForm.Field? {
  if self.username.isEmpty {
    return .username
  } else if self.password.isEmpty {
    return .password
  } else {
    // handleLogin(username, password)
    return nil
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now the sign in button’s action can be implemented simply by calling out to the `signInButtonTapped` method and using its return value to assign the `focusedField` we hold in the view:
"""#,
      timestamp: (12*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Button("Sign In") {
  self.focusedField = self.viewModel.signInButtonTapped()
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now if we run the app in the simulator and tap the “Sign in” button we’ll be focused on the username field. Then if we fill something in for that field and tap the button again we’ll get focused on the password field. And finally, if we fill something in for that field and tap the button again both controls will lose focus.
"""#,
      timestamp: (12*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we were able to move the focus logic in a view model, which is great because we can now easily write unit tests. All we have to do is instantiate a view model, mutate the `username` and `password` fields, invoke the `signInButtonTapped` method and assert on what is returned. Such a test would run super quickly, would not require running the full app in a simulator, and will never indeterminately fail.
"""#,
      timestamp: (12*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, there are still a few things that are not quite ideal with our solution. One we’ve already mentioned, but worth mentioning again. Right now we’ve decided that returning `nil` from `signInButtonTapped` represents unfocusing all controls, but what if we wanted `nil` to instead represent leaving the focus unchanged. Then we would only reset the `focusedField` if a non-`nil` is returned from the method:
"""#,
      timestamp: (12*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Button("Sign In") {
  if let focusedField = self.viewModel.signInButtonTapped() {
    self.focusedField = focusedField
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now we keep the last focus when submitting, but also this code is quite strange. After all, `focusedField` in the view is already optional, and `nil` represents the act of unfocusing all controls, yet the `nil` that comes back from `signInButtonTapped` represents the act of not changing focus. These two differing interpretations of what `nil` means will be quite confusing in the future when we forget all the nuances of how we came up with our current code and are trying to understand why we don’t simply assign the `focusedField` with the return value of the method. Like we said before, a dedicated enum would help, but that’s a lot of boilerplate to support such a simple thing.
"""#,
      timestamp: (13*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
There’s another problem. What if we wanted to change the focus multiple times during the execution of this method. For example, when you tap the sign in button we could clear the focus from all the fields, and then if we get back a failure from the `handleLogin` request we could re-focus the username field. That doesn’t exactly work with our current model where we return a single field value from the method.
"""#,
      timestamp: (13*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
One possibility to remedy is to leverage a concept that was discussed quite a bit at WWDC, and just shipping in the most recent beta of Xcode. We can represent the idea of returning multiple values from this function over time by using `AsyncSequence`, and in particular a concrete implementation known as `AsyncStream`. If we could do that, then we could update our button action to iterate over all of those emissions and update the focus field:
"""#,
      timestamp: (14*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Button("Sign In") {
  Task {
    for await focus = self.viewModel.signInButtonTapped() {
      self.focusedField = focus
    }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So, this would theoretically work.
"""#,
      timestamp: (14*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But there’s another problem with this. This API is really weird. With the way it’s named there’s no reason to think it returns anything having to do with focus. And what if someday it needs to return some other data? Do we need to return a tuple with the sequence of focuses alongside the rest of the return data? And what if we have other methods that want to make changes to the focus field? Are they all going to return a field value that has to be interpreted by the view?
"""#,
      timestamp: (14*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Ignoring async/await, we might be able to define an API that hands control of this mutable field to the view model with `inout`:
"""#,
      timestamp: (15*60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
viewModel.signInButtonTapped(focusedField: &focusedField)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This would allow the view model to make any changes it wants to the focused field, including whether to `nil` it out or to leave it unchanged.
"""#,
      timestamp: (15*60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func signInButtonTapped(focusedField: inout LoginForm.Field?) {
  if self.username.isEmpty {
    focusedField = .username
  } else if self.password.isEmpty {
    focusedField = .password
  } else {
    // handleLogin(username, password)

//    focusedField = nil
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This builds, and would seem to solve all of our problems. However, as soon as async work comes into play, things fall apart. If we make this method async.
"""#,
      timestamp: (16*60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func signInButtonTapped(focusedField: inout LoginForm.Field?) async {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And try to invoke it from the view:
"""#,
      timestamp: (16*60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Task {
  await viewModel.signInButtonTapped(focusedField: &focusedField)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 Actor-isolated property 'focusedField' cannot be passed 'inout' to 'async' function call

We are not allowed to pass mutable data over to an asynchronous context.
"""#,
      timestamp: (16*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"View model-driven focus state"#,
      timestamp: (17*60 + 5),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So those are some of the complications around using `FocusState` in a more real-world fashion. We want to move focus state to the view model in order to make it testable, and we want to be able to change focus state over time, perhaps in some asynchronous work, but all of our attempts to do so are fraught with various issues.
"""#,
      timestamp: (17*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
The true problem with the way we are designing this API is that we are trying to describe how we want the view to update its focus rather than just being able to update the focus directly in the view model. The most ideal situation would be if we could hold onto the focus state directly in our view model so that we can mutate it whenever we want. However, since we can’t use the property wrapper `@FocusState` directly in the observable object we need some way of playing the changes that happen in the view model over to the view somehow.
"""#,
      timestamp: (17*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s start by getting the state back into the view model.
"""#,
      timestamp: (18*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This time we will hold this state as a simple `@Published` property, instead of `@FocusedState`:
"""#,
      timestamp: (18*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
class LoginViewModel: ObservableObject {
  @Published var focusedField: LoginForm.Field?
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now the `signInButtonTapped` method gets a lot simpler because we can just mutate the focus directly:
"""#,
      timestamp: (18*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func signInButtonTapped() async {
  if self.username.isEmpty {
    self.focusedField = .username
  } else if self.password.isEmpty {
    self.focusedField = .password
  } else {
    // handleLogin(username, password)
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now, because the view model owns this state, it can mutate it after performing some asynchronous work:
"""#,
      timestamp: (18*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func signInButtonTapped() async {
  if self.username.isEmpty {
    self.focusedField = .username
  } else if self.password.isEmpty {
    self.focusedField = .password
  } else {
    self.focusedField = nil
    do {
      // try await handleLogin(username, password)
    } catch {
      self.focusedField = .username
    }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
No need to support returning an asynchronous stream of field values that need to be interpreted in the view, or any of that complicated stuff.
"""#,
      timestamp: (19*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Button("Sign In") {
  Task {
    await self.viewModel.signInButtonTapped()
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So this is looking great, but of course it won’t work yet because we aren’t doing anything to actually mutate the `@FocusState` in the view. What we need to do is listen for any time the view model’s `focusedField` changes, and when it does replay that change to the `focusedField` held in the view. Thanks to SwiftUI’s `.onChange` view modifier this is as easy as:
"""#,
      timestamp: (19*60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.onChange(of: self.viewModel.focusedField) { newValue in
  self.focusedField = newValue
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now if we run the application in the simulator it works as we expect, and the code has gotten a lot simpler.
"""#,
      timestamp: (20*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So now we are holding the focus state in the view model, which makes it easy for us to sprinkle in nuanced logic in how the field changes over time, and it means this code should be easy enough to test.
"""#,
      timestamp: (20*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But sadly this is only half the story. We are replaying changes of the focus field in the view model to the view, but what if the focus field in the view changes? We should replay that to the view model so that the view model has the most up to date information. Otherwise we run the risk performing logic in the view model based on `focusedField`'s value without realizing that it doesn’t match exactly what is in the view right now.
"""#,
      timestamp: (20*60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
To see that this is currently a problem, let’s add a text view to the `VStack` that displays the currently focused field:
"""#,
      timestamp: (20*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Text("Focused field: \(String(describing: self.viewModel.focusedField))")
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If we run this in the simulator and tap the “Sign in” button we will see the text view updates to show that the username field is focused. But, if we then tap on the password field to focus it ourselves the text display does not update.
"""#,
      timestamp: (21*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, sounds like we need another `.onChange` modifier so that we can replay changes of the view’s `focusedField` back to the view model:
"""#,
      timestamp: (21*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.onChange(of: self.viewModel.focusedField) { newValue in
  self.focusedField = newValue
}
.onChange(of: self.focusedField) { newValue in
  self.viewModel.focusedField =  newValue
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now when we run the app in the simulator we get the behavior we expect.
"""#,
      timestamp: (21*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that’s a quick introduction to the concept of `@FocusState` in SwiftUI. It’s a really nice API that allows you to describe the focus of a screen as a simple piece of state, and SwiftUI takes care of the messy details of figuring out what UI control to focus. However, it does have some complexities of its own too.
"""#,
      timestamp: (22*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
`@FocusState` is a property wrapper that can only live on views, which means you can’t use it as state in your view model and therefore all logic governing its behavior must be relegated to the view layer. This may not be a big deal for really simple focus behavior, but if you are dealing with something complex, especially if asynchronous work is involved, then it can be a bummer to have all of that in the view. It makes your views more complex and makes it harder to test that logic, forcing you to turn to complex UI integration tests when simple unit tests would be more appropriate.
"""#,
      timestamp: (22*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If you decide that holding focus state only in the view is too much logic for your view, then you have to do a bit of work. You can hold the focus state in your observable object as a `@Published` field, but you have to also chain on two `.onChange` operators in order to replay changes in the view model to the view, and vice versa. There doesn’t seem to be any way around it unfortunately. If you want focus state to be a part of your view model, so that its behavior can be encapsulated and easily unit tested, then you have no choice but to play changes back and forth bidirectionally.
"""#,
      timestamp: (22*60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Focus state and the Composable Architecture"#,
      timestamp: (23*60 + 9),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Now let’s turn our attention to the Composable Architecture. How can we support this new `@FocusState` property wrapper in applications using the Composable Architecture to model its domains logic and behavior? After all, focus state is required to be defined on the view level, and the Composable Architecture likes to encapsulate its domain in simple value types and its logic in reducers.
"""#,
      timestamp: (23*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Well, turns out the pattern we just observed when trying to move focus state to an observable object also applies to the Composable Architecture. We can model the focus state in our feature’s state struct, and then we replay changes in the store to the view and vice versa.
"""#,
      timestamp: (23*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s start building this feature in the Composable Architecture by doing a little bit of domain modeling. The state consists of fields for the username, password and currently focused field:
"""#,
      timestamp: (23*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import ComposableArchitecture

struct LoginState: Equatable {
  var focusedField: Field? = nil
  var password: String = ""
  var username: String = ""

  enum Field: String, Hashable {
    case username, password
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we have an enum of actions for everything that can happen in the interface, such as changing one of the text fields, tapping the sign in button, and even changing the focus field:
"""#,
      timestamp: (24*60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum LoginAction {
  case setFocusedField(LoginState.Field?)
  case setPassword(String)
  case setUsername(String)
  case signInButtonTapped
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We also typically define an environment that holds dependencies the feature needs to do its job, but in this case we don’t need any dependencies so we’ll just use an empty struct:
"""#,
      timestamp: (24*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct LoginEnvironment {
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we implement a reducer that mutates the current state of the application when an action is received. We just have to handle each action individually, and the logic for each one isn’t too complicated:
"""#,
      timestamp: (24*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let loginReducer = Reducer<
  LoginState,
  LoginAction,
  LoginEnvironment
> { state, action, environment in
  switch action {
  case let .setFocusedField(field):
    state.focusedField = field
    return .none

  case let .setPassword(password):
    state.password = password
    return .none

  case let .setUsername(username):
    state.username = username
    return .none

  case .signInButtonTapped:
    if state.username.isEmpty {
      state.focusedField = .username
    } else if state.password.isEmpty {
      state.focusedField = .password
    }
    return .none
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now our domain for this feature is modeled, but this is all pretty verbose too. We need an enum case for each UI control that can be changed, and then we need to handle each action in the reducer, which is often just a matter of binding to the value and update the state. That’s quite a bit of boilerplate for something so simple.
"""#,
      timestamp: (25*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Luckily we can leverage something that we explored a few months ago in our series of episodes titled “[Concise Forms](/collections/case-studies/concise-forms).” In that series we showed how to remove all the boilerplate in a nice, succinct way, and we even built the tools directly into the library.
"""#,
      timestamp: (25*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We start by getting rid of all the `set` actions and replace them with a single `BindingAction`:
"""#,
      timestamp: (25*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum LoginAction {
  case binding(BindingAction<LoginState>)
//  case setFocusedField(LoginState.Field?)
//  case setPassword(String)
//  case setUsername(String)
  case signInButtonTapped
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This single action is capable of setting any field in the state to a particular value. You don’t typically send this action directly, but rather use it with the `.binding` method that is defined on `ViewStore`, which we will see in a moment.
"""#,
      timestamp: (26*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Next, in the reducer we can get rid of all the `set` actions that simply bound to a variable in order to update state. Instead of doing that we can use the `.binding` higher-order reducer at the end in order to enhance our reducer with the functionality that allows us to set any field of the state to a new value:
"""#,
      timestamp: (26*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let loginReducer = Reducer<
  LoginState,
  LoginAction,
  LoginEnvironment
> { state, action, environment in
  switch action {
  case .binding:
    return .none

//  case let .setFocusedField(field):
//    state.focusedField = field
//    return .none
//  case let .setPassword(password):
//    state.password = password
//    return .none
//  case let .setUsername(username):
//    state.username = username
//    return .none

  case .signInButtonTapped:
    if state.username.isEmpty {
      state.focusedField = .username
    } else if state.password.isEmpty {
      state.focusedField = .password
    }
    return .none
  }
}
  .binding(action: /LoginAction.binding)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
That looks much better.
"""#,
      timestamp: (27*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we can implement the view. It will hold onto a `Store` of the login domain because that’s what powers the behavior of this screen, but we also need to hold onto some `@FocusState`, because as we’ve seen before that’s the only way to interact with SwiftUI’s focus engine:
"""#,
      timestamp: (28*60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct TcaLoginView: View {
  @FocusState var focusedField: LoginState.Field?
  let store: Store<LoginState, LoginAction>

  var body: some View {
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we can construct a `ViewStore` by using the `WithViewStore` helper which allows us to observe state changes in the store and send actions into the store:
"""#,
      timestamp: (28*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
var body: some View {
  WithViewStore(self.store) { viewStore in
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Inside here we can basically put the same code as we had in the vanilla SwiftUI version but with a few small changes:
"""#,
      timestamp: (29*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
VStack {
  TextField("Username", text: viewStore.binding(keyPath: \.username, send: LoginAction.binding))
    .focused($focusedField, equals: .username)

  SecureField("Password", text: viewStore.binding(keyPath: \.password, send: LoginAction.binding))
    .focused($focusedField, equals: .password)

  Button("Sign In") {
    viewStore.send(.signInButtonTapped)
  }

  Text("\(String(describing: viewStore.focusedField))")
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Most notably we can no longer pluck a binding off the view model directly but rather derive a binding from the `viewStore` which under the hood sends actions rather than performing mutations directly to the state. There are a few ways to deriving bindings from view stores, but one way in particular plays nicely with the binding action we are using:
"""#,
      timestamp: (29*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
viewStore.binding(keyPath: \.username, send: LoginAction.binding)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
The password field is basically the same:
"""#,
      timestamp: (30*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
SecureField("Password", text: viewStore.binding(keyPath: \.password, send: LoginAction.binding))
  .focused($focusedField, equals: .password)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And for the sign in button we send an action rather than invoking a method:
"""#,
      timestamp: (30*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Button("Sign In") {
  viewStore.send(.signInButtonTapped)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So the view is mostly implemented, but of course we shouldn’t expect it to fully work. Right now there is nothing connecting the changes to the `focusedField` in the store with the `focusedField` in the view. Remember that in vanilla SwiftUI we used the `.onChange` view modifier to replay changes back and forth between the view model and view. Perhaps we can do the same here.
"""#,
      timestamp: (30*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We can start by listening for changes to the `focusedField` in the store and replay its changes to the view:
"""#,
      timestamp: (31*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.onChange(of: viewStore.focusedField) {
  self.focusedField = $0
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
That was easy enough. What about the other way around? Well, we can easily observe changes to the `focusedField` held on the view:
"""#,
      timestamp: (31*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.onChange(of: self.focusedField) {
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And inside this closure we want to somehow update the `focusedField` in the store. To do that we can use the `.binding` action which allows us to update any field of the state with a new value:
"""#,
      timestamp: (31*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.onChange(of: self.focusedField) {
  viewStore.send(.binding(.set(\.focusedField, $0)))
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If we update the app entry point to load this new view instead of the vanilla SwiftUI view we will see that the app works exactly as it did when we built it using an observable object:
"""#,
      timestamp: (32*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
self.window?.rootViewController = UIHostingController(
  rootView: TcaLoginView(
    store: .init(
      initialState: .init(),
      reducer: loginReducer,
      environment: .init()
    )
  )
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
It's worth noting that trying to understand how to make focus state more understandable and testable from the perspective of view models naturally led us to a solution that also works for the Composable Architecture, and in fact this happens a lot. If you have trouble modeling something in the Composable Architecture, often an exploration of making it work in a testable vanilla SwiftUI way will lead you to a solution that works both places.
"""#,
      timestamp: (33*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So this is all great, but also this double `.onChange` dance we are doing seems a little messy. We have to remember to observe both sides of the focus state so that we can replay it to the other side. If we leave off one of these `.onChange`s we will have a subtly broken application.
"""#,
      timestamp: (33*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
What if we could cook up a view helper that hides away these details. This helper could even be helpful in vanilla SwiftUI code. It seems that the crux of the problem is that we have two bindings that we need to keep in sync. One binding comes from the `focusedField` inside the store, and the other binding comes from the `@FocusState` property wrapper in the view.
"""#,
      timestamp: (33*60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So perhaps we need a method on `View` that allows you synchronize the changes between two bindings:
"""#,
      timestamp: (34*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
extension View {
  func synchronize<Value: Equatable>(
    _ first: Binding<Value>,
    _ second: Binding<Value>
  ) -> some View {
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
To implement this we will just utilize the `.onChange` modifier twice to listen for changes in one binding in order to play it to the other binding:
"""#,
      timestamp: (34*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
extension View {
  func synchronize<Value: Equatable>(
    _ first: Binding<Value>,
    _ second: Binding<Value>
  ) -> some View {
    self
      .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
      .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
With this helper defined we would hope that we could deriving a binding from the view store for the `focusedField` and synchronize it with the `focusedField` on the view:
"""#,
      timestamp: (35*60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.synchronize(
  self.$viewModel.focusedField
  self.$focusedField
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 Cannot convert value of type 'FocusState<LoginState.Field?>.Binding' to expected argument type 'Binding<LoginState.Field?>'

However that does not work. It turns out that the binding you get by doing `self.$focusedField` is not a true `SwiftUI` binding, but rather a `FocusState.Binding`. It’s a whole other type defined inside the `FocusState` type, and so it is completely incompatible with the SwiftUI bindings we are familiar with.
"""#,
      timestamp: (35*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We are not aware of a single abstraction that covers both regular bindings and `FocusState` bindings. One could theorize an abstraction around property wrappers:
"""#,
      timestamp: (35*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
After recording this episode, we realized that `ReferenceWritableKeyPath` _is_ an abstraction that would work here, though there are some caveats involved in defining a `synchronize` helper using them. We'll leave that exploration as an exercise for the viewer.
"""#,
      timestamp: nil,
      type: .correction
    ),
    Episode.TranscriptBlock(
      content: #"""
func synchronize<A, B>(
  _ first: Binding<Value>,
  _ second: FocusState<Value>.Binding
) -> some View
where A: PropertyWrapper, B: PropertyWrapper, A.Wrapped == B.Wrapped {
  self
    .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
    .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But instead it’s easy enough to define another overload of `synchronize`:
"""#,
      timestamp: (36*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func synchronize<Value: Equatable>(
  _ first: Binding<Value>,
  _ second: FocusState<Value>.Binding
) -> some View {
  self
    .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
    .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the application compiles and it works exactly as it did before.
"""#,
      timestamp: (37*60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Even better, we can use this same helper with the Composable Architecture SwiftUI application we built a moment ago:
"""#,
      timestamp: (37*60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
// .onChange(of: viewStore.focusedField) {
//   self.focusedField = $0
// }
// .onChange(of: self.focusedField) {
//   viewStore.send(.binding(.set(\.focusedField, newValue)))
// }
.synchronize(
  viewStore.binding(get: \.focusedField, send: LoginAction.binding),
  self.$focusedField
)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And this screen should work just as it did before.
"""#,
      timestamp: (37*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Conclusion"#,
      timestamp: (38*60 + 18),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, we have now shown how to make use of the new `@FocusState` feature introduced at WWDC this year, both for vanilla SwiftUI applications and Composable Architecture applications.
"""#,
      timestamp: (38*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
In the simplest cases vanilla SwiftUI interfaces with focus state very easily. However, once you want to control focus from a view model, so that it can encapsulate complex logic and effects and be more testable, you run into problems. We were able to solve those problems by holding focus state in both the view model and the view, and then replaying changes back and forth.
"""#,
      timestamp: (38*60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Amazingly, that same solution worked for the Composable Architecture too. We are able to hold focus in our application state’s, where it can be controlled by complex behavior implemented in the reducer, while still interfacing with the view’s focus state. And we were able to do so without any changes to the core of the library.
"""#,
      timestamp: (39*60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, at the end of the day we don’t feel like focus state and the Composable Architecture don’t play well together. Really it’s that focus state and observable objects in general that don’t play well together, and so we must cook up additional tools to allow us to model focus in a view model, like we did with the `synchronize` view modifier.
"""#,
      timestamp: (39*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
That’s it for this episode. Next week we’ll start diving into a 3rd and final new API from WWDC, which is the new `.searchable` view modifier.
"""#,
      timestamp: (39*60 + 23),
      type: .paragraph
    ),
  ]
}
