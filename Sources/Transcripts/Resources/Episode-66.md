## Introduction

> Correction: This episode was recorded with Xcode 11 beta 3, and a lot has changed in recent betas. While we note these changes inline below, we also went over them in detail [on our blog](/blog/posts/30-swiftui-and-state-management-corrections).

@T(00:00:05)
OK, so we had to do a bit of plumbing to properly get our global app state inside each of our views, but the benefit of doing this work is that now the count value will persist across all screens. We can drill down into the counter, change it, go back to the main screen, and drill down again and everything is restored to how it was previously. So we have achieved persistence with very little work using the power of `@ObjectBinding` in SwiftUI.

## The prime checking modal

@T(00:00:34)
Now that we know how to express state in a view, make the view react to changes in that state, and even how to persist the state across the entire application, let's build out another screen in our app. Let's do the prime number checker modal. This appears when you tap the "Is this prime?" button, and it shows you a label that let's you know if the current counter is prime or not, and it gives you a button for saving or removing the number from your list of favorites.

@T(00:00:56)
Let's remind ourselves what the screen looks like. When we ask the counter view if a number is prime, we display a modal that tells the user if the number is prime or not, and _if it is_, we offer them the ability to add or remove the number from their favorite primes.

@T(00:01:19)
Modals are presented in SwiftUI by setting presentation information on your view:

```swift
.presentation(<#Modal?#>)
```

> Correction: This episode was recorded with Xcode 11 beta 3, and a change has been made to the presentation APIs in beta 4 and later versions of Xcode. The modal presentation API is captured in a few view modifier methods called `sheet` that present and dismiss a view given the state of a `Binding`.

@T(00:01:44)
If you provide a `nil` value here nothing will happen, and if you provide a `Modal` value it will present that modal over your current view. And then to dismiss the modal you must put `nil` back into this function.

@T(00:02:24)
So, sounds like we need some state in order to track when this modal should be shown and dismissed. But we have to decide whether or not to use this as local state via the `@State` attribute, or if we want to add it to our global `AppState`. There may be a use case for wanting this information on the global level, like perhaps we want to do some action while the modal is being presented, or we want to support deep-linking into this modal, and in that case we would want to add this information to  `AppState`. However, we currently do not have any use for this, so we will just model this as local state:

```swift
@State var isPrimeModalShown: Bool = false
```

@T(00:03:14)
And then we can use this value to determine what to hand over to the `.presentation` modal:

```swift
.presentation(
  self.isPrimeModalShown
    ? Modal(Text("I don't know if \(self.state.count) is prime"))
    : nil
)
```

@T(00:03:41)
If we run this, nothing will happen because we aren't yet mutating `isPrimeModalShown` in order to make the modal show and hide. To make it show we will simply hook into the `action` of the button:

```swift
Button(action: { self.isPrimeModalShown = true }) {
```

@T(00:04:03)
If we run this, it seems to be working, but we will find we have a bug. We can tap the button to make the modal come up, and then dismiss the modal, but the moment we change the counter (or any state in the view) the modal will suddenly come back. Why?

@T(00:04:27)
Well, we haven't reset the `isPrimeModalShown` boolean back to `false` after dismissing, so next time this view renders SwiftUI will think it needs to present another modal. It's easy enough to reset this state, we can hook into the `onDismiss` action of the `Modal` value:

```swift
.presentation(
  self.isPrimeModalShown
    ? Modal(
      Text("I don't know if \(self.state.count) is prime"),
      onDismiss: { self.isPrimeModalShown = false }
      )
    : nil
)
```

@T(00:04:52)
That will make sure the boolean gets reset, and so now when we dismiss the modal it stays dismissed.

@T(00:05:04)
So we are now correctly capturing the state of our modal, but the modal doesn't have any useful information. Currently we are showing a simple text view, but we want to showing something quite a bit more complicated: a `VStack` with a text view and button inside, along with some logic on how to render those views. Due to the complexity of this view, it would be best to create a whole new type to encapsulate it's logic:

```swift
struct IsPrimeModalView: View {
  var body: some View {
    Text("I don't know if \(self.state.count) is prime")
  }
}
```

@T(00:06:02)
And then we can update our presentation to use this view:

```swift
.presentation(
  self.isPrimeModalShown
    ? Modal(
      IsPrimeModalView(),
      onDismiss: { self.isPrimeModalShown = false }
      )
    : nil
)
```

> Error: Value of type 'IsPrimeModalView' has no member 'state'

@T(00:06:06)
Now we need to introduce state to our modal.

```swift
struct IsPrimeModalView: View {
  @ObjectBinding var state: AppState
  var body: some View {
    Text("I don't know if \(self.state.count) is prime")
  }
}
```

@T(00:06:26)
And pass it to its initializer.

```swift
.presentation(
  self.isPrimeModalShown
    ? Modal(
      IsPrimeModalView(state: self.state),
      onDismiss: { self.isPrimeModalShown = false }
      )
    : nil
)
```

@T(00:06:34)
Now everything builds just as before, but we can focus on our subview in isolation.

@T(00:06:46)
The layout of the modal view is pretty simple, so let's get some basics in place, a vertically-stacked set of views including text that will tell us if a number is prime or not, and a button that will allow us to add and remove prime numbers from our list of favorite primes:

```swift
struct IsPrimeModalView: View {
  @ObjectBinding var state: AppState
  var body: some View {
    VStack {
      Text("I don't know if \(self.state.count) is prime")
      Button(action: {}) {
        Text("Save/remove to/from favorite primes")
      }
    }
  }
}
```

@T(00:07:14)
Now there's some logic we want to hook up in here. In order to customize the text, we need to know if the number is prime or not. So let's introduce a handy little `isPrime` helper function:

```swift
private func isPrime (_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}
```

@T(00:07:28)
Using this value we can change the contents of that text field easily,

```swift
if isPrime(self.state.count) {
  Text("\(self.state.count) is prime 🎉")
} else {
  Text("\(self.state.count) is not prime :(")
}
```

@T(00:07:49)
And when we give things a quick run, we display different text in the modal depending on if the number is prime or not.

@T(00:08:00)
Next we want to figure out what to do with the button. In the case that this count value is not prime it shouldn't show, so we can at least move it into the first branch of the `if`:

```swift
if isPrime(self.state.count) {
  Text("\(self.state.count) is prime 🎉")
  Button(action: {}) {
    Text("Save/remove to/from favorite primes")
  }
} else {
  Text("\(self.state.count) is not prime :(")
}
```

@T(00:08:16)
And then from here we should change the label and action based on whether or not the prime is in the user's favorite list. But what favorite list? We haven't captured the idea of a favorite primes list in the app state at all. So let's add it!

@T(00:08:34)
We go back to our `AppState` class and add an array field to hold all of the user's favorite primes, and we go ahead and override `didSet` so that we can notify interested parties in changes:

```swift
var favoritePrimes: [Int] = [] {
  didSet { self.didChange.send() }
}
```

> Correction: This episode was recorded with Xcode 11 beta 3. In later betas, SwiftUI's `BindableObject` protocol was deprecated in favor of an `ObservableObject` protocol that was introduced to the Combine framework. This protocol utilizes an `objectWillChange` property of `ObservableObjectPublisher`, which is pinged _before_ (not after) any mutations are made to your model. Because of this, `willSet` should be used instead of `didSet`:
>
> ```swift
> var favoritePrimes: [Int] = [] {
>   willSet { self.objectWillChange.send() }
> }
> ```
>
> Even better, we can remove this boilerplate entirely by using a `@Published` property wrapper:
>
> ```swift
> @Published var favoritePrimes: [Int] = []
> ```

@T(00:09:01)
This dance is always going be necessary whenever we add state to a `BindableObject`: we need to remember to tap into `didSet` and ping `didChange` by calling its `send` method.

@T(00:09:13)
Now that we have access to the favorites array, we can implement the necessary logic:

```swift
if self.state.favoritePrimes.contains(self.state.count) {
  Button(action: {}) {
    Text("Remove from favorite primes")
  }
} else {
  Button(action: {}) {
    Text("Save to favorite primes")
  }
}
```

@T(00:09:42)
Next, how do we actually hook up the button's actions to do this work? Removing a prime is pretty easy. The standard library API for removing takes a predicate for finding all the values you want to remove:

```swift
Button(action: {
  self.state.favoritePrimes.removeAll(where: {
    $0 == self.state.count
  })
}) {
```

@T(00:10:08)
And adding is even simpler. We just gotta append the current `count` value to the array:

```swift
Button(action: {
  self.state.favoritePrimes.append(self.state.count)
}) {
```

@T(00:10:18)
Now when we run our application, the button text toggles when we add or remove a prime to our favorites. The state also persists, as we can see by re-invoking the modal.

## Adding a side effect

@T(00:11:00)
And we should now have a fully functioning modal! We can add and remove primes to our favorites list, and the UI just updates automatically.

@T(00:11:30)
Let's kick the complexity of this application up a notch. There's a button on the screen that will compute the "nth" prime, where `n` is the value of the counter. Doing this work can be pretty computationally expensive, and our `isPrime` helper is pretty naive right now. Instead of figuring out how to make this stuff more efficient and doing all of the logic locally, let's leverage an API that can answer this question quite easily for us. There's a service called Wolfram Alpha that is a powerful scientific computing platform.

@T(00:12:16)
I have some simple library code for interacting with the Wolfram API. It's just some structs that models the data that comes back from the API:

```swift
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
```

@T(00:12:36)
As well as a function that takes a query string, sends it to the Wolfram Alpha API, tries to decode the json data into our struct, and invokes a callback with the results:

```swift
func wolframAlpha(
  query: String,
  callback: @escaping (WolframAlphaResult?) -> Void
) -> Void {
  var components = URLComponents(
    string: "https://api.wolframalpha.com/v2/query"
  )!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
    URLQueryItem(name: "appid", value: wolframAlphaApiKey),
  ]

  URLSession.shared.dataTask(
    with: components.url(relativeTo: nil)!
  ) { data, response, error in
    callback(
      data.flatMap {
        try? JSONDecoder().decode(WolframAlphaResult.self, from: $0)
      }
    )
  }
  .resume()
}
```

@T(00:13:13)
And with that helper function we can make a more specific API request, one that asks Wolfram Alpha for the `n`th prime:

```swift
func nthPrime(
  _ n: Int, callback: @escaping (Int?) -> Void
) -> Void {
  wolframAlpha(query: "prime \(n)") { result in
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
```

@T(00:13:46)
We can take it for a spin by querying the thousandth prime.

```swift
nthPrime(1_000) { p in print(p) }
// 7919
```

@T(00:14:01)
Leveraging this API we could even query the _millionth_ prime, something that would have been very computationally expensive to do locally.

```swift
nthPrime(1_000_000) { p in print(p) }
// 15485863
```

@T(00:14:12)
Now how are we supposed to use this? Well let's explain in words what we are trying to do. When we tap the "What's the nth prime?" button we want to execute this API request, process the result, and then show an alert. So before we get into all of that, let's figure out how alerts are shown.

@T(00:14:28)
Alerts are done pretty similarly to modals in that you use the `.presentation` method to specify the conditions in which an alert is shown and you provide a custom view to represent the alert. However, it takes an explicit `Binding` value to control when the alert is shown and dismissed rather than taking an optional `Alert` value like how we did for modals. There are two versions of this API:

```swift
.presentation(<#Binding<Bool>#>, alert: <#() -> Alert#>)
.presentation(<#Binding<Identifiable?>#>, alert: <#(Identifiable) -> Alert#>)
```

> Correction: This episode was recorded with Xcode 11 beta 3, and a change has been made to the presentation APIs in beta 4 and later versions of Xcode. The above APIs have been renamed to `alert(isPresented:content:)` and `alert(item:content:)`.

@T(00:14:47)
We can either provide a `Binding` of a boolean value such that whenever the binding turns to `true` the alert is shown and when it's `false` it is dismissed, or we can provide a `Binding` of an optional such that when a value is present the alert is shown and when it is `nil` the alert is dismissed.

@T(00:15:04)
We will use the latter API, and the easiest way to get a `Binding` value is to introduce some state, either via a local `@State` value or a persistent `@ObjectBinding` value. Since the showing and dismissing of this alert seems to be a local matter that we most likely will not need access to from other screens, let's introduce some `@State`:

```swift
@State var alertNthPrime: Int?
```

@T(00:15:34)
Then based on this value we can show an alert:

```swift
.presentation(self.$alertNthPrime) { n in
  Alert(
    title: Text("The \(ordinal(self.state.count)) prime is \(n)"),
    dismissButton: Alert.Button.default(Text("OK"))
  )
}
```

Notice that we are using `$alertNthPrime` in order to pass along the binding of `alertNthPrime` rather than just the plain boolean value.

The moment this state value becomes an honest integer, the closure will be executed with that integer, we can construct an alert value, and that alert will be shown to the user.

@T(00:17:11)
The question is now: how do we set the value of that state? Well, after tapping the button we want to fire an API request to Wolfram Alpha and when we get a response show the alert with the result we got back. So looks like we need to go back to our "What's the nth prime" button and implement its action:

```swift
Button(action: {
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
  }
}) {
  Text("What's the \(ordinal(self.state.count)) prime?")
}
```

@T(00:17:41)
If we run this we will see that when we tap the button there is a brief pause while the network request is being made, and then eventually we get the alert. Take note that SwiftUI is responsible for taking care of resetting this binding to `nil` when the user dismisses the alert.

## The favorites list

@T(00:18:10)
We now have a moderately complex application. We are managing and persisting state across an entire application, we are adding subtle logic to our rendering, and now we have sprinkled in a side-effect that communicates with an external service. But we need to kick up the complexity even more, because right now this is mostly just a single screen app. This screen has a lot going on, but in order to demonstrate just how powerful it is that we can share state across the entire application we should build another screen that needs access to this state. So, let's build out a final screen that can showcase all of our favorite prime numbers, and add the ability to remove the ones we no longer like.

@T(00:18:58)
Let's remind ourselves what this screen is and how we get there. From the root navigation view, we can drill down into a list of favorite primes, and this list will be populated with whatever primes we have favorited, and we will have the ability to remove primes that have fallen out of our favor.

@T(00:19:31)
Let's start with small steps and paste in the scaffolding for a new view.

```swift
struct FavoritePrimes: View {
  @ObjectBinding var state: AppState

  var body: some View {
    EmptyView()
      .navigationBarTitle(Text("Favorite Primes"))
  }
}
```

@T(00:19:55)
Then we can hook this view up to the root content view:

```swift
NavigationLink(destination: FavoritePrimes(state: self.state)) {
  Text("Favorite primes")
}
```

@T(00:20:17)
Now what kind of view do we want for our favorite primes? It's going to be a list of any number of rows, one for each of our favorite primes. So we may be tempted to do something like this:

```swift
var body: some View {
  List {
    self.state.favoritePrimes.map { prime in
      Text("\(prime)")
    }
  }
  .navigationBarTitle(Text("Favorite Primes"))
}
```

@T(00:20:50)
However, SwiftUI does not currently allow this kind of construction of views. Instead there is another view wrapper, similar to the `List` wrapper, that allows us to specify all the rows for the list. It's called `ForEach` and it's used like this:

```swift
var body: some View {
  List {
    ForEach(self.state.favoritePrimes) { prime in
      Text("\(prime)")
    }
  }
  .navigationBarTitle(Text("Favorite Primes"))
}
```

@T(00:21:48)
And now when we add a few primes, and go back to this screen we will see all of our primes listed. Let's also add the delete functionality. This can be done by adding an `onDelete` handler to the `ForEach` element:

```swift
.onDelete(perform: { indexSet in
  for index in indexSet {
    self.state.favoritePrimes.remove(at: index)
  }
})
```

@T(00:22:53)
Now we can add a few favorite primes, go back to our list of favorites, remove the ones that are no longer favorites of ours, and to double check all of the state is in sync let's go back to the counter view and add the prime back as a favorite.

## Next time: what’s the point?

@T(00:23:11)
We've now got a moderately complex application built in SwiftUI. It's honestly kind of amazing. There is absolutely no way we would have been able to build this application in the amount of time we did using UIKit. There would have been a maze of protocols to implement and delegates to set up and probably a huge number of bugs introduced along the way.

@T(00:23:35)
But as cool as this may be, at the end of each topic on Point-Free we like to ask the question "What's the point?" in order to bring things down to earth so that we can see the forest from the trees. This episode has been pretty practical already, but there are some very important lessons to take away.

@T(00:24:03)
What we want to do is list out all the things we love about SwiftUI and all the things that don't seem to be quite there yet. Finally, we'll explore what we can do to close the gaps that SwiftUI has left open.

@T(00:24:20)
Let's start by enumerating all of the things that we really like...next time!
