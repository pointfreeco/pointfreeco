import Foundation

public let ep66 = Episode(
  blurb: """
This week we finish up our moderately complex SwiftUI application by adding more screens, more state, and even sprinkle in a side effect so that we can finally ask: "what's the point!?"
""",
  codeSampleDirectory: "0066-swiftui-and-state-management-pt2",
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 199_193_552,
    downloadUrl: "https://player.vimeo.com/external/348431195.hd.mp4?s=d5927c00bec77533335c9f8525c5f24900a9715b&profile_id=175&download=1",
    streamingSource: "https://player.vimeo.com/video/348431195"
  ),
  id: 66,
  image: "https://i.vimeocdn.com/video/799121279.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0066-swiftui-and-state-management-pt2/itunes-poster.jpg",
  length: 24*60 + 26,
  permission: .free,
  previousEpisodeInCollection: 65,
  publishedAt: .init(timeIntervalSince1970: 1563775200),
  references: [
    .swiftUiTutorials,
    .insideSwiftUIAboutState
  ],
  sequence: 66,
  title: "SwiftUI and State Management: Part 2",
  trailerVideo: .init(
    bytesLength: 19_831_912,
    downloadUrl: "https://player.vimeo.com/external/348469619.hd.mp4?s=27cdcef7c5042120a302ee9e80aa2d547ae8aa60&profile_id=175&download=1",
    streamingSource: "https://player.vimeo.com/video/348469619"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  // todo
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: (0*60 + 05),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Ok, so we had to do a bit of plumbing to properly get our global app state inside each of our views, but the benefit of doing this work is that now the count value will persist across all screens. We can drill down into the counter, change it, go back to the main screen, and drill down again and everything is restored to how it was previously. So we have achieved persistence with very little work using the power of `@ObjectBinding` in SwiftUI.
""",
    timestamp: (0*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "The prime checking modal",
    timestamp: (0*60 + 34),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Now that we know how to express state in a view, make the view react to changes in that state, and even how to persist the state across the entire application, let's build out another screen in our app. Let's do the prime number checker modal. This appears when you tap the "Is this prime?" button, and it shows you a label that let's you know if the current counter is prime or not, and it gives you a button for saving or removing the number from your list of favorites.
""",
    timestamp: (0*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's remind ourselves what the screen looks like. When we ask the counter view if a number is prime, we display a modal that tells the user if the number is prime or not, and _if it is_, we offer them the ability to add or remove the number from their favorite primes.
""",
    timestamp: (0*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Modals are presented in SwiftUI by setting presentation information on your view:
""",
    timestamp: (1*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(<#T##modal: Modal?##Modal?#>)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3, and a change has been made to the presentation APIs in beta 4 and later versions of Xcode. The modal presentation API is captured in a few view modifier methods called `sheet` that present and dismiss a view given the state of a `Binding`.
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
If you provide a `nil` value here nothing will happen, and if you provide a `Modal` value it will present that modal over your current view. And then to dismiss the modal you must put `nil` back into this function.
""",
    timestamp: (1*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So, sounds like we need some state in order to track when this modal should be shown and dismissed. But we have to decide whether or not to use this as local state via the `@State` attribute, or if we want to add it to our global `AppState`. There may be a use case for wanting this information on the global level, like perhaps we want to do some action while the modal is being presented, or we want to support deep-linking into this modal, and in that case we would want to add this information to  `AppState`. However, we currently do not have any use for this, so we will just model this as local state:
""",
    timestamp: (2*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
@State var isPrimeModalShown: Bool = false
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then we can use this value to determine what to hand over to the `.presentation` modal:
""",
    timestamp: (3*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(
  self.isPrimeModalShown
    ? Modal(Text("I don't know if \\(self.state.count) is prime"))
    : nil
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
If we run this, nothing will happen because we aren't yet mutating `isPrimeModalShown` in order to make the modal show and hide. To make it show we will simply hook into the `action` of the button:
""",
    timestamp: (3*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: { self.isPrimeModalShown = true }) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
If we run this, it seems to be working, but we will find we have a bug. We can tap the button to make the modal come up, and then dismiss the modal, but the moment we change the counter (or any state in the view) the modal will suddenly come back. Why?
""",
    timestamp: (4*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Well, we haven't reset the `isPrimeModalShown` boolean back to `false` after dismissing, so next time this view renders SwiftUI will think it needs to present another modal. It's easy enough to reset this state, we can hook into the `onDismiss` action of the `Modal` value:
""",
    timestamp: (4*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(
  self.isPrimeModalShown
    ? Modal(
      Text("I don't know if \\(self.state.count) is prime"),
      onDismiss: { self.isPrimeModalShown = false }
      )
    : nil
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
That will make sure the boolean gets reset, and so now when we dismiss the modal it stays dismissed.
""",
    timestamp: (4*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So we are now correctly capturing the state of our modal, but the modal doesn't have any useful information. Currently we are showing a simple text view, but we want to showing something quite a bit more complicated: a `VStack` with a text view and button inside, along with some logic on how to render those views. Due to the complexity of this view, it would be best to create a whole new type to encapsulate it's logic:
""",
    timestamp: (5*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct IsPrimeModalView: View {
  var body: some View {
    Text("I don't know if \\(self.state.count) is prime")
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then we can update our presentation to use this view:
""",
    timestamp: (6*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(
  self.isPrimeModalShown
    ? Modal(
      IsPrimeModalView(),
      onDismiss: { self.isPrimeModalShown = false }
      )
    : nil
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
> 🛑 Value of type 'IsPrimeModalView' has no member 'state'

Now we need to introduce state to our modal.
""",
    timestamp: (6*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct IsPrimeModalView: View {
  @ObjectBinding var state: AppState
  var body: some View {
    Text("I don't know if \\(self.state.count) is prime")
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And pass it to its initializer.
""",
    timestamp: (6*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(
  self.isPrimeModalShown
    ? Modal(
      IsPrimeModalView(state: self.state),
      onDismiss: { self.isPrimeModalShown = false }
      )
    : nil
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now everything builds just as before, but we can focus on our subview in isolation.
""",
    timestamp: (6*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The layout of the modal view is pretty simple, so let's get some basics in place, a vertically-stacked set of views including text that will tell us if a number is prime or not, and a button that will allow us to add and remove prime numbers from our list of favorite primes:
""",
    timestamp: (6*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct IsPrimeModalView: View {
  @ObjectBinding var state: AppState
  var body: some View {
    VStack {
      Text("I don't know if \\(self.state.count) is prime")
      Button(action: {}) {
        Text("Save/remove to/from favorite primes")
      }
    }
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now there's some logic we want to hook up in here. In order to customize the text, we need to know if the number is prime or not. So let's introduce a handy little `isPrime` helper function:
""",
    timestamp: (7*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
private func isPrime (_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Using this value we can change the contents of that text field easily,
""",
    timestamp: (7*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
if isPrime(self.state.count) {
  Text("\\(self.state.count) is prime 🎉")
} else {
  Text("\\(self.state.count) is not prime :(")
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And when we give things a quick run, we display different text in the modal depending on if the number is prime or not.
""",
    timestamp: (7*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Next we want to figure out what to do with the button. In the case that this count value is not prime it shouldn't show, so we can at least move it into the first branch of the `if`:
""",
    timestamp: (8*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
if isPrime(self.state.count) {
  Text("\\(self.state.count) is prime 🎉")
  Button(action: {}) {
    Text("Save/remove to/from favorite primes")
  }
} else {
  Text("\\(self.state.count) is not prime :(")
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then from here we should change the label and action based on whether or not the prime is in the user's favorite list. But what favorite list? We haven't captured the idea of a favorite primes list in the app state at all. So let's add it!
""",
    timestamp: (8*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We go back to our `AppState` class and add an array field to hold all of the user's favorite primes, and we go ahead and override `didSet` so that we can notify interested parties in changes:
""",
    timestamp: (8*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var favoritePrimes: [Int] = [] {
  didSet { self.didChange.send() }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3, and a change has been made to the `BindableObject` protocol in beta 4 and later versions of Xcode. The protocol now requires a `willChange` publisher, and you are supposed to ping this publisher _before_ you make any mutations to your model.
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
This dance is always going be necessary whenever we add state to a `BindableObject`: we need to remember to tap into `didSet` and ping `didChange` by calling its `send` method.
""",
    timestamp: (9*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now that we have access to the favorites array, we can implement the necessary logic:
""",
    timestamp: (9*60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
if self.state.favoritePrimes.contains(self.state.count) {
  Button(action: {}) {
    Text("Remove from favorite primes")
  }
} else {
  Button(action: {}) {
    Text("Save to favorite primes")
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Next, how do we actually hook up the button's actions to do this work? Removing a prime is pretty easy. The standard library API for removing takes a predicate for finding all the values you want to remove:
""",
    timestamp: (9*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: { self.state.favoritePrimes.removeAll(where: { $0 == self.state.count }) }) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And adding is even simpler. We just gotta append the current `count` value to the array:
""",
    timestamp: (10*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: { self.state.favoritePrimes.append(self.state.count) }) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now when we run our application, the button text toggles when we add or remove a prime to our favorites. The state also persists, as we can see by re-invoking the modal.
""",
    timestamp: (10*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Adding a side effect",
    timestamp: (11*60 + 00),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
And we should now have a fully functioning modal! We can add and remove primes to our favorites list, and the UI just updates automatically.
""",
    timestamp: (11*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's kick the complexity of this application up a notch. There's a button on the screen that will compute the "nth" prime, where `n` is the value of the counter. Doing this work can be pretty computationally expensive, and our `isPrime` helper is pretty naive right now. Instead of figuring out how to make this stuff more efficient and doing all of the logic locally, let's leverage an API that can answer this question quite easily for us. There's a service called Wolfram Alpha that is a powerful scientific computing platform.
""",
    timestamp: (11*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I have some simple library code for interacting with the Wolfram API. It's just some structs that models the data that comes back from the API:
""",
    timestamp: (12*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult

  struct QueryResult: Decodable {
    let pods: [Pod]

    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]

      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
As well as a function that takes a query string, sends it to the Wolfram Alpha API, tries to decode the json data into our struct, and invokes a callback with the results:
""",
    timestamp: (12*60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
  var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
    URLQueryItem(name: "appid", value: wolframAlphaApiKey),
  ]

  URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
    callback(
      data
        .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
    )
    }
    .resume()
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And with that helper function we can make a more specific API request, one that asks Wolfram Alpha for the `n`th prime:
""",
    timestamp: (13*60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
  wolframAlpha(query: "prime \\(n)") { result, response, error in
    callback(
      result
        .flatMap {
          $0.queryresult
            .pods
            .first(where: { $0.primary == .some(true) })?
            .subpods
            .first?
            .plaintext
        }
        .flatMap(Int.init)
    )
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can take it for a spin by querying the thousandth prime.
""",
    timestamp: (13*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
nthPrime(1_000) { p in print(p) }
// 7919
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Leveraging this API we could even query the _millionth_ prime, something that would have been very computationally expensive to do locally.
""",
    timestamp: (14*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
nthPrime(1_000_000) { p in print(p) }
// 15485863
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now how are we supposed to use this? Well let's explain in words what we are trying to do. When we tap the "What's the nth prime?" button we want to execute this API request, process the result, and then show an alert. So before we get into all of that, let's figure out how alerts are shown.
""",
    timestamp: (14*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Alerts are done pretty similarly to modals in that you use the `.presentation` method to specify the conditions in which an alert is shown and you provide a custom view to represent the alert. However, it takes an explicit `Binding` value to control when the alert is shown and dismissed rather than taking an optional `Alert` value like how we did for modals. There are two versions of this API:
""",
    timestamp: (14*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(<#T##isShown: Binding<Bool>##Binding<Bool>#>, alert: <#T##() -> Alert#>)
.presentation(<#T##data: Binding<Identifiable?>##Binding<Identifiable?>#>, alert: <#T##(Identifiable) -> Alert#>)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3, and a change has been made to the presentation APIs in beta 4 and later versions of Xcode. The above APIs have been renamed to `alert(isPresented:content:)` and `alert(item:content:)`.
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
We can either provide a `Binding` of a boolean value such that whenever the binding turns to `true` the alert is shown and when it's `false` it is dismissed, or we can provide a `Binding` of an optional such that when a value is present the alert is shown and when it is `nil` the alert is dismissed.
""",
    timestamp: (14*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We will use the latter API, and the easiest way to get a `Binding` value is to introduce some state, either via a local `@State` value or a persistent `@ObjectBinding` value. Since the showing and dismissing of this alert seems to be a local matter that we most likely will not need access to from other screens, let's introduce some `@State`:
""",
    timestamp: (15*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
@State var alertNthPrime: Int?
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Then based on this value we can show an alert:
""",
    timestamp: (15*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(self.$alertNthPrime) { n
  Alert(
    title: Text("The \\(ordinal(self.state.count)) prime is \\(n)"),
    dismissButton: Alert.Button.default(Text("Ok"))
  )
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Notice that we are using `$alertNthPrime` in order to pass along the binding of `alertNthPrime` rather than just the plain boolean value.

The moment this state value becomes an honest integer, the closure will be executed with that integer, we can construct an alert value, and that alert will be shown to the user.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The question is now: how do we set the value of that state? Well, after tapping the button we want to fire an API request to Wolfram Alpha and when we get a response show the alert with the result we got back. So looks like we need to go back to our "What's the nth prime" button and implement its action:
""",
    timestamp: (17*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: {
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
  }
}) {
  Text("What's the \\(ordinal(self.state.count)) prime?")
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
If we run this we will see that when we tap the button there is a brief pause while the network request is being made, and then eventually we get the alert. Take note that SwiftUI is responsible for taking care of resetting this binding to `nil` when the user dismisses the alert.
""",
    timestamp: (17*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "The favorites list",
    timestamp: (18*60 + 10),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We now have a moderately complex application. We are managing and persisting state across an entire application, we are adding subtle logic to our rendering, and now we have sprinkled in a side-effect that communicates with an external service. But we need to kick up the complexity even more, because right now this is mostly just a single screen app. This screen has a lot going on, but in order to demonstrate just how powerful it is that we can share state across the entire application we should build another screen that needs access to this state. So, let's build out a final screen that can showcase all of our favorite prime numbers, and add the ability to remove the ones we no longer like.
""",
    timestamp: (18*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's remind ourselves what this screen is and how we get there. From the root navigation view, we can drill down into a list of favorite primes, and this list will be populated with whatever primes we have favorited, and we will have the ability to remove primes that have fallen out of our favor.
""",
    timestamp: (18*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's start with small steps and paste in the scaffolding for a new view.
""",
    timestamp: (19*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct FavoritePrimes: View {
  @ObjectBinding var state: AppState

  var body: some View {
    EmptyView()
      .navigationBarTitle(Text("Favorite Primes"))
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Then we can hook this view up to the root content view:
""",
    timestamp: (19*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
NavigationLink(destination: FavoritePrimes(state: self.state)) {
  Text("Favorite primes")
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now what kind of view do we want for our favorite primes? It's going to be a list of any number of rows, one for each of our favorite primes. So we may be tempted to do something like this:
""",
    timestamp: (20*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var body: some View {
  List {
    self.state.favoritePrimes.map { prime in
      Text("\\(prime)")
    }
  }
    .navigationBarTitle(Text("Favorite Primes"))
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
However, SwiftUI does not currently allow this kind of construction of views. Instead there is another view wrapper, similar to the `List` wrapper, that allows us to specify all the rows for the list. It's called `ForEach` and it's used like this:
""",
    timestamp: (20*60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var body: some View {
  List {
    ForEach(self.state.favoritePrimes) { prime in
      Text("\\(prime)")
    }
  }
    .navigationBarTitle(Text("Favorite Primes"))
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now when we add a few primes, and go back to this screen we will see all of our primes listed. Let's also add the delete functionality. This can be done by adding an `onDelete` handler to the `ForEach` element:
""",
    timestamp: (21*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.onDelete(perform: { indexSet in
  for index in indexSet {
    self.state.favoritePrimes.remove(at: index)
  }
})
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we can add a few favorite primes, go back to our list of favorites, remove the ones that are no longer favorites of ours, and to double check all of the state is in sync let's go back to the counter view and add the prime back as a favorite.
""",
    timestamp: (22*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Next time: what’s the point?",
    timestamp: (23*60 + 11),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We've now got a moderately complex application built in SwiftUI. It's honestly kind of amazing. There is absolutely no way we would have been able to build this application in the amount of time we did using UIKit. There would have been a maze of protocols to implement and delegates to set up and probably a huge number of bugs introduced along the way.
""",
    timestamp: (23*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
But as cool as this may be, at the end of each topic on Point-Free we like to ask the question "What's the point?" in order to bring things down to earth so that we can see the forest from the trees. This episode has been pretty practical already, but there are some very important lessons to take away.
""",
    timestamp: (23*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
What we want to do is list out all the things we love about SwiftUI and all the things that don't seem to be quite there yet. Finally, we'll explore what we can do to close the gaps that SwiftUI has left open.
""",
    timestamp: (24*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's start by enumerating all of the things that we really like...next time!
""",
    timestamp: (24*60 + 20),
    type: .paragraph
  ),
]
