import Foundation

extension Episode {
  static let ep85_testableStateManagement_thePoint = Episode(
    blurb: """
      We've made testing in our architecture a joy! We can test deep aspects of our application with minimal ceremony, but it took us a whole 18 episodes to get here! So this week we ask: what's the point!? Can we write these kinds of tests in vanilla SwiftUI?
      """,
    codeSampleDirectory: "0085-testable-state-management-the-point",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 325_896_989,
      downloadUrls: .s3(
        hd1080: "0085-1080p-2e529b95f0d24b86a29b334b1c767cd9",
        hd720: "0085-720p-c5239c62083b4cdfbdaac1120606fb35",
        sd540: "0085-540p-0b752e9715c6440199b1e2b416583d28"
      ),
      vimeoId: 378_096_729
    ),
    id: 85,
    length: 33 * 60 + 35,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_576_476_000),
    references: [
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 85,
    subtitle: "The Point",
    title: "Testable State Management",
    trailerVideo: .init(
      bytesLength: 34_340_125,
      downloadUrls: .s3(
        hd1080: "0085-trailer-1080p-43d74bcc79ec48ad8b05ecbe64dc46ff",
        hd720: "0085-trailer-720p-245dc5a63de341dd8f1d3ea4f49b394c",
        sd540: "0085-trailer-540p-325ff8e207ff411ea1709b152d401f92"
      ),
      vimeoId: 378_096_707
    ),
    transcriptBlocks: _transcriptBlocks
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      Add tests for VanillaPrimeTime's `FavoritePrimesView`, starting with the logic around deleting favorite primes.
      """#,
    solution: #"""
      First, in `FavoritePrimesView`, extract the list's `onDelete` logic into a method.

      ```swift
      func deleteFavoritePrimes(_ indexSet: IndexSet) {
        for index in indexSet {
          let prime = self.favoritePrimes[index]
          self.favoritePrimes.remove(at: index)
          self.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
      }
      ```

      Next, pass this method to `onDelete`.

      ```swift
      .onDelete(perform: self.deleteFavoritePrimes)
      ```

      Finally, write a test exercising this logic!

      ```swift
      func testFavoritePrimesView_deleteFavoritePrimes() {
        let view = FavoritePrimesView(
          favoritePrimes: Binding(initialValue: [2, 3, 5]),
          activityFeed: Binding(initialValue: [])
        )

        view.deleteFavoritePrimes([1])

        XCTAssertEqual(view.favoritePrimes, [2, 5])
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      While `saveFavoritePrimes` and `loadFavoritePrimes` have been extracted to methods, what makes them difficult to test? What could be introduced to aid in testing? Consider the work done in our episode, [Testable State Management: Effects](https://www.pointfree.co/episodes/ep83-testable-state-management-effects).
      """#,
    solution: nil
  ),
]

private let _transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: #"Introduction"#,
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      So we've now demonstrated that not only is the Composable Architecture we have been developing super testable, but it can also test deep aspects of our application, and it can be done with minimal set up and ceremony. This is key if people are going to be motivated to write tests. There should be as little friction as possible to writing tests, and we should be confident we are testing some real world aspects of our application.
      """#,
    timestamp: 5,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But no matter how cool this is, we always like to end a series of episodes on Point-Free by asking "what's the point?". Because although we've built some great testing tools and gotten lots of test coverage, it also took quite a bit of work to get here. We are now on the 18th(!) episode of our architecture series, and we've built up a lot of machinery along the way. So was it necessary to do all of this work in order to gain this level of testability? And can we not do this type of testing in vanilla SwiftUI?
      """#,
    timestamp: (0 * 60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Unfortunately, we do indeed think it's necessary to do some amount of work to gain testability in a SwiftUI application. You don't necessarily need to use the Composable Architecture we've been building, but it seems that if you want to test your SwiftUI application you will be inevitably led to introducing some layers on top of SwiftUI to achieve this.
      """#,
    timestamp: (0 * 60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      To see this, let's take a look at the vanilla SwiftUI application we wrote a long time ago, which was our introduction to SwiftUI and the whole reason we embarked on this series of architecture episodes.
      """#,
    timestamp: (1 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"A tour of the vanilla SwiftUI code base"#,
    timestamp: (1 * 60 + 48),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      It begins with a class that holds our application's state:
      """#,
    timestamp: (1 * 60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      class AppState: ObservableObject {
        @Published var count = 0
        @Published var favoritePrimes: [Int] = []
        @Published var loggedInUser: User? = nil
        @Published var activityFeed: [Activity] = []

        struct Activity {
          let timestamp: Date
          let type: ActivityType

          enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
          }
        }

        struct User {
          let id: Int
          let name: String
          let bio: String
        }
      }

      struct PrimeAlert: Identifiable {
        let prime: Int
        var id: Int { self.prime }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This class conforms to the `ObservableObject` protocol so that views can automatically be notified changes are made and the view needs to be re-rendered. We also make all of the fields that should participate in this change notification process with `@Published`, which is possible thanks to some Swift runtime magic.
      """#,
    timestamp: (1 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The `count` and array of `favoritePrimes` is the core data we want to persist across screens in our application. We later added some additional state just to explore other types of problems that need to be solved in an architecture. So we added a logged-in user and activity feed, even though we don't really use that information.
      """#,
    timestamp: (2 * 60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This class is like a less opinionated, more ad hoc version of the Composable Architecture's `Store`, which also conforms to `ObservableObject` and has a single `@Published` field for its entire state.
      """#,
    timestamp: (2 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next we have the `ContentView`, which is the root view of our application, and simply shows a choice of two things that can be done in the app:
      """#,
    timestamp: (3 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct ContentView: View {
        @ObservedObject var state: AppState

        var body: some View {
          NavigationView {
            List {
              NavigationLink(destination: CounterView(state: self.state)) {
                Text("Counter demo")
              }
              NavigationLink(
                destination: FavoritePrimesView(
                  favoritePrimes: self.$state.favoritePrimes,
                  activityFeed: self.$state.activityFeed
                )
              ) {
                Text("Favorite primes")
              }
            }
            .navigationBarTitle("State management")
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can either go to the `CounterView` or we can go to the `FavoritePrimesView`. This view is wrapped in a `NavigationView` so that we can do drill-ins to sub-screens. Inside the navigation view is a list so that we can easily show a few buttons stacked on top of each other. And then in the list is a few `NavigationLink`s, which is what allows us to drill down into sub-screens.
      """#,
    timestamp: (3 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's start with the simpler of these two screens, the `FavoritePrimesView`. First take notice of how we create this view:
      """#,
    timestamp: (3 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      FavoritePrimesView(
        favoritePrimes: self.$state.favoritePrimes,
        activityFeed: self.$state.activityFeed
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This strange `self.$state` syntax allows us to get at the underlying observable object of our app state, and then further chaining on `favoritePrimes` allows us to derive read-write bindings from the observable object. By passing down bindings to the `FavoritePrimesView` we allow that view to make changes to these value and have those mutations propagate back up. If we only passed the raw values:
      """#,
    timestamp: (3 * 60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      If we only passed the raw values...
      """#,
    timestamp: (3 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      FavoritePrimesView(
        favoritePrimes: self.state.favoritePrimes,
        activityFeed: self.state.activityFeed
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      ...then the `FavoritePrimesView` wouldn't be able to mutate those values and have those mutations observable by anyone else.
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Scrolling down a bit we will find the implementation of the `FavoritePrimesView`:
      """#,
    timestamp: (4 * 60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct FavoritePrimesView: View {
        @Binding var favoritePrimes: [Int]
        @Binding var activityFeed: [AppState.Activity]

        var body: some View {
          List {
            ForEach(self.favoritePrimes, id: \.self) { prime in
              Text("\(prime)")
            }
            .onDelete { indexSet in
              for index in indexSet {
                let prime = self.favoritePrimes[index]
                self.favoritePrimes.remove(at: index)
                self.activityFeed.append(
                  .init(timestamp: Date(), type: .removedFavoritePrime(prime))
                )
              }
            }
          }
          .navigationBarTitle(Text("Favorite Primes"))
          .navigationBarItems(
            trailing: HStack {
              Button("Save", action: self.saveFavoritePrimes)
              Button("Load", action: self.loadFavoritePrimes)
            }
          )
        }

        func saveFavoritePrimes() {
          let data = try! JSONEncoder().encode(self.favoritePrimes)
            let documentsPath = NSSearchPathForDirectoriesInDomains(
              .documentDirectory, .userDomainMask, true
              )[0]
            let documentsUrl = URL(fileURLWithPath: documentsPath)
            let favoritePrimesUrl = documentsUrl
              .appendingPathComponent("favorite-primes.json")
            try! data.write(to: favoritePrimesUrl)
        }

        func loadFavoritePrimes() {
          let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            )[0]
          let documentsUrl = URL(fileURLWithPath: documentsPath)
          let favoritePrimesUrl = documentsUrl
            .appendingPathComponent("favorite-primes.json")
          guard
            let data = try? Data(contentsOf: favoritePrimesUrl),
            let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
            else { return }
          self.favoritePrimes = favoritePrimes
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Notice that this struct requires two bindings in order to be initialized, but we are using the `@Binding` property wrapper. This allows us to treat these fields as normal values, while under the hood it is actually using the machinery of bindings in order to re-render the UI when a value changes.
      """#,
    timestamp: (4 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The body is a `List` with a `ForEach` nested inside, which allows us to render a row for each item in a collection. We also have this `onDelete` action which allows us to execute some code whenever a delete action takes place on a row. And further we add some navigation bar items to hold the "Save" and "Load" buttons, and their respective actions call out to some side-effecting methods we have on this view.
      """#,
    timestamp: (4 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next, let's scroll up a bit to see the `CounterView`:
      """#,
    timestamp: (5 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct CounterView: View {
        @ObservedObject var state: AppState
        @State var isPrimeModalShown: Bool = false
        @State var alertNthPrime: PrimeAlert?
        @State var isNthPrimeButtonDisabled = false

        var body: some View {
          VStack {
            HStack {
              Button(action: { self.state.count -= 1 }) {
                Text("-")
              }
              Text("\(self.state.count)")
              Button(action: { self.state.count += 1 }) {
                Text("+")
              }
            }
            Button(action: { self.isPrimeModalShown = true }) {
              Text("Is this prime?")
            }
            Button(action: self.nthPrimeButtonAction) {
              Text("What is the \(ordinal(self.state.count)) prime?")
            }
            .disabled(self.isNthPrimeButtonDisabled)
          }
          .font(.title)
          .navigationBarTitle("Counter demo")
          .sheet(isPresented: self.$isPrimeModalShown) {
            IsPrimeModalView(
              activityFeed: self.$state.activityFeed,
              count: self.state.count,
              favoritePrimes: self.$state.favoritePrimes
            )
          }
          .alert(item: self.$alertNthPrime) { alert in
            Alert(
              title: Text("The \(ordinal(self.state.count)) prime is \(alert.prime)"),
              dismissButton: .default(Text("Ok"))
            )
          }
        }

        func nthPrimeButtonAction() {
          self.isNthPrimeButtonDisabled = true
          nthPrime(self.state.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
            self.isNthPrimeButtonDisabled = false
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Definitely the biggest and most complicated view in our app. First, note that it takes all of the application state as an observed object:
      """#,
    timestamp: (5 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      @ObservedObject var state: AppState
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      That's because it needs access to pretty much all of this state to do its job.
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      It also has all of these additional fields:
      """#,
    timestamp: (5 * 60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      @State var isPrimeModalShown: Bool = false
      @State var alertNthPrime: PrimeAlert?
      @State var isNthPrimeButtonDisabled = false
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is local state that only this view cares about. These values don't need to be passed down when this view is created, it has sensible defaults that it can start out with.
      """#,
    timestamp: (5 * 60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The body of the view itself has a lot going on. We use an `HStack` to get the main parts of the view stacked on top of each other, which includes the counter UI, the "Is this prime?" button, and the "What is the nth prime?" button. We also have logic for showing alerts and modals, both of which use the `$` syntax in order to access the `Binding` that powers the corresponding `@State` field.
      """#,
    timestamp: (5 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And finally we have the `IsPrimeModalView`:
      """#,
    timestamp: (6 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct IsPrimeModalView: View {
        @Binding var activityFeed: [AppState.Activity]
        let count: Int
        @Binding var favoritePrimes: [Int]

        var body: some View {
          VStack {
            if isPrime(self.count) {
              Text("\(self.count) is prime 🎉")
              if self.favoritePrimes.contains(self.count) {
                Button(action: {
                  self.favoritePrimes.removeAll(where: { $0 == self.count })
                  self.activityFeed.append(
                    .init(timestamp: Date(), type: .removedFavoritePrime(self.count))
                  )
                }) {
                  Text("Remove from favorite primes")
                }
              } else {
                Button(action: {
                  self.favoritePrimes.append(self.count)
                  self.activityFeed.append(
                    .init(timestamp: Date(), type: .addedFavoritePrime(self.count))
                  )
                }) {
                  Text("Save to favorite primes")
                }
              }
            } else {
              Text("\(self.count) is not prime :(")
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
      This view takes two `@Binding`s because that is state this view wants to be able to mutate and have the changes propagate up to the parent, and it takes one immutable value because that is data that will not change in this view.
      """#,
    timestamp: (6 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Everything else in this view is pretty standard, although it does contain quite a bit of logic and nuance.
      """#,
    timestamp: (6 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Testing vanilla SwiftUI"#,
    timestamp: (6 * 60 + 56),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, that's the basics of the application we built last time. Its design and architecture is based purely off the documentation Apple has given us (both online and in WWDC videos), and it is very straightforward.
      """#,
    timestamp: (6 * 60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      In contrast, the architecture we have been building over the past many weeks had quite a few opinions on how to structure things that SwiftUI alone does not. It demanded that we no longer sprinkle mutations throughout our views. Instead, we describe all of the actions a user can take as an enum, and we create a reducer to describe how state should be mutated given a user action. Then, in the view, instead of performing mutations we are only allowed to send actions to the store. Most importantly, those actions very simply described what the user did, not what we expect to happen after the action took place. They were described like `saveButtonTapped` or `incrButtonTapped`, not like `fetchNthPrime` or `incrementCount`.
      """#,
    timestamp: (7 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      As we saw in the previous 3 episodes, this set up made it very easy to write tests. It took a little bit of investment for us to get our architecture in place, but once it was there the tests were trivial to write, and they allowed us to test very deep aspects of our application's logic.
      """#,
    timestamp: (7 * 60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So the question is: what does it look like to test a vanilla SwiftUI? We've clearly saved quite a bit of work by just using plain SwiftUI and not putting an additional layer of architecture on top, but do we still have the ability to test?
      """#,
    timestamp: (8 * 60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Well, unfortunately there isn't a ton we can directly test if we keep our usage of SwiftUI as dead-simple as possible. Let's try to write some tests to see why.
      """#,
    timestamp: (8 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Testing the prime modal"#,
    timestamp: (8 * 60 + 28),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's start by writing some tests for the `IsPrimeModalView`, which has the basic functionality of allowing us to save and remove primes from our list of favorites. Let's hop over to our test file, and add a test:
      """#,
    timestamp: (8 * 60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      import XCTest
      @testable import VanillaPrimeTime

      class VanillaPrimeTimeTests: XCTestCase {
        func testIsPrimeModalView() {
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, what does it take to test our view? Well, we only have the actual view at our disposal, no other ancillary objects that we interact with. So let's try to create one:
      """#,
    timestamp: (8 * 60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let view = IsPrimeModalView(
        activityFeed: <#Binding<[AppState.Activity]>#>,
        count: <#Int#>,
        favoritePrimes: <#Binding<[Int]>#>
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Looks like we need to provide two bindings, one for the activity feed and one for the favorite primes, as well as an integer. When we created this view in the context of a SwiftUI view it was really easy to derive these bindings, because we had an observable object at our disposal, and we could just do:
      """#,
    timestamp: (8 * 60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      IsPrimeModalView(
        activityFeed: self.$state.activityFeed,
        count: self.state.count,
        favoritePrimes: self.$state.favoritePrimes
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, we don't have any of that SwiftUI machinery at our disposal in an `XCTest`, and so we gotta recreate this from scratch ourselves. The only initializer on `Binding` that is actually useful is this one:
      """#,
    timestamp: (9 * 60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Binding(
        get: <#() -> _#>,
        set: <#(_) -> Void#>
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Which allows us to provide our own getter and setter.
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So how can we use this to create, say, an activity feed binding?
      """#,
    timestamp: (9 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let activityFeed = Binding(
        get: {  },
        set: { newValue in }
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      What are we going to get and set inside these closures? Well, we need to keep some additional mutable state on the outside that we can use on the inside:
      """#,
    timestamp: (9 * 60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      var _activityFeed: [AppState.Activity] = []
      let activityFeed = Binding(
        get: { _activityFeed },
        set: { newValue in _activityFeed = newValue }
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This dance is probably just a simplified version of what the `@Binding` property wrapper does, but unfortunately we cannot use property wrappers at this scope:
      """#,
    timestamp: (10 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      @Binding var _activityFeed: [AppState.Activity] = []
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Property wrappers are not yet supported on local properties

      Further, we can't even use this as an instance variable of the test case:
      """#,
    timestamp: (10 * 60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      class FavoritePrimesTests: XCTestCase {
        @Binding var _activityFeed: [AppState.Activity] = []
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Argument labels '(wrappedValue:)' do not match any available overloads

      And this is because the `@Binding` property wrapper doesn't allow initialization with an underlying value like `@State` does. We also can't take away the initial value:
      """#,
    timestamp: (10 * 60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      class FavoritePrimesTests: XCTestCase {
        @Binding var _activityFeed: [AppState.Activity]
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Class 'FavoritePrimesTests' has no initializers

      Because then we need to provide an initializer, and we do not control initializing `XCTestCase` objects. That's something the `XCTest` framework and Xcode handle for us.
      """#,
    timestamp: (10 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So it looks like we really have no choice but to create a binding directly, not using any of SwiftUI's fancy property wrappers. Fortunately, there is one small thing we can do to clean up the two step process we have right now for creating bindings. We can provide our own initializer that hides this little local mutable value away from us:
      """#,
    timestamp: (11 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Binding {
        init(initialValue: Value) {
          var value = initialValue
          self.init(get: { value }, set: { value = $0 })
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we can simply do:
      """#,
    timestamp: (11 * 60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let activityFeed = Binding<[AppState.Activity]>(initialValue: [])
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And we can even inline it:
      """#,
    timestamp: (11 * 60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let view = IsPrimeModalView(
        activityFeed: Binding<[AppState.Activity]>(initialValue: []),
        count: 2,
        favoritePrimes: Binding<[Int]>(initialValue: [2, 3, 5])
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      That's quite a bit nicer, and if we ever want to get the value out of the view we can simply do:
      """#,
    timestamp: (12 * 60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      view.activityFeed
      view.favoritePrimes
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Phew, ok, we still haven't written any tests! We've only explored what it means to create a SwiftUI view that takes bindings in a test case.
      """#,
    timestamp: (12 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, what is there to test? Well, there is a ton of logic in this view around whether or not the current count is a prime and whether or not that prime is in our favorites:
      """#,
    timestamp: (12 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      var body: some View {
        VStack {
          if isPrime(self.count) {
            Text("\(self.count) is prime 🎉")
            if self.favoritePrimes.contains(self.count) {
              Button(action: { … }) {
                Text("Remove from favorite primes")
              }
            } else {
              Button(action: { … }) {
                Text("Save to favorite primes")
              }
            }
          } else {
            Text("\(self.count) is not prime :(")
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, all of that logic is trapped inside our `body` property, and there is nothing domain-specific in there:
      """#,
    timestamp: (12 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      view.body.
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We only see SwiftUI APIs in there for modifying this view. There's no way to actually get access on the subviews inside this view so that we can assert on what is happening. Essentially, everything that happens on the inside of these `body` properties should be thought of as a black box.
      """#,
    timestamp: (12 * 60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, if we are going to test any of the logic in here we need to extract it out somewhere else. One thing we could do is move the logic that does the saving and removing of a favorite prime to methods on the view:
      """#,
    timestamp: (13 * 60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Button(action: self.removeFavoritePrime) {
      }
      // …
      Button(action: self.saveFavoritePrime) {
      }
      // …
      func removeFavoritePrime() {
        self.favoritePrimes.removeAll(where: { $0 == self.count })
        self.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(self.count)))
      }

      func saveFavoritePrime() {
        self.favoritePrimes.append(self.count)
        self.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(self.count)))
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we are finally ready to write our first asserts:
      """#,
    timestamp: (13 * 60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      view.removeFavoritePrime()

      XCTAssertEqual(view.favoritePrimes, [3, 5])

      view.saveFavoritePrime()

      XCTAssertEqual(view.favoritePrimes, [3, 5, 2])
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And these assertions pass! We can simply invoke a few of the methods on the view for mutating the state and then assert that the state mutated the way we expected.
      """#,
    timestamp: (14 * 60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Just to make sure these tests are actually running let's demonstrate a failure:
      """#,
    timestamp: (14 * 60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      view.saveFavoritePrime()
      XCTAssertEqual(favoritePrimes.wrappedValue, [3, 5])
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 XCTAssertEqual failed: ("[3, 5, 2]") is not equal to ("[3, 5]")

      So, we are actually testing some logic in this view. However, we have lost something when compared to how we tested our architecture. When we first tested this feature a few episodes back we were able to exhaustively check every field on the state:
      """#,
    timestamp: (14 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func testRemoveFavoritesPrimesTapped() {
        var state = (count: 3, favoritePrimes: [3, 5])
        let effects = primeModalReducer(state: &state, action: .removeFavoritePrimeTapped)

        let (count, favoritePrimes) = state
        XCTAssertEqual(count, 3)
        XCTAssertEqual(favoritePrimes, [5])
        XCTAssert(effects.isEmpty)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This line in particular...
      """#,
    timestamp: (14 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let (count, favoritePrimes) = state
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      ...will fail if we ever add more fields to this state. This is excellent for making sure we continue asserting against the whole of the state, that way we don't accidentally miss something that is happening. For example, if I did something silly in the `saveFavoritePrime` method like this:
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func removeFavoritePrime() {
        self.favoritePrimes.removeAll(where: { $0 == self.count })
        self.activityFeed.append(.init(timestamp: Current.date(), type: .removedFavoritePrime(self.count)))
        self.activityFeed = []
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Our tests will still pass. If we only test the things we think will change then we miss out on unrelated state being changed on accident.
      """#,
    timestamp: (15 * 60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      There is one thing we can do to regain exhaustive assertions, but it comes with some boilerplate. We would need to introduce a new struct that holds only the state from `AppState` that we care about, and use it for our binding:
      """#,
    timestamp: (15 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct IsPrimeModalView: View {

        struct State {
          var activityFeed: [AppState.Activity]
          let count: Int
          var favoritePrimes: [Int]
        }
        @Binding var state: State

      //  @Binding var activityFeed: [AppState.Activity]
      //  let count: Int
      //  @Binding var favoritePrimes: [Int]
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then we would need to create a getter/setter property on `AppState` for deriving this substate:
      """#,
    timestamp: (15 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension AppState {
        var isPrimeModalViewState: IsPrimeModalView.State {
          get {
            IsPrimeModalView.State(
              activityFeed: self.activityFeed,
              count: self.count,
              favoritePrimes: self.favoritePrimes
            )
          }
          set {
            (
              self.activityFeed,
              self.count,
              self.favoritePrimes
            ) = (
              newValue.activityFeed,
              newValue.count,
              newValue.favoritePrimes
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
      Which would allow us to create the prime modal view like this:
      """#,
    timestamp: (16 * 60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      IsPrimeModalView(
        state: self.$state.isPrimeModalViewState
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      It's worth mentioning that this little bit of glue code we had to write is essentially identical to what we needed to write to make use of our architecture:
      """#,
    timestamp: (16 * 60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension AppState {
        var isPrimeModalViewState: IsPrimeModalView.State {
          get { … }
          set { … }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We needed to do something like this a few times in our architecture. We did it so that we could write reducers that work on just local state and actions and pull them back to work on global state and actions. So what we are seeing here is that even if we want to use SwiftUI in the plainest, most straightforward way, there are times that we are not going to be able to get around writing a bit of extra boilerplate. Here we are being forced to write this extra code if we want to squeeze out a bit of extra testability in SwiftUI.
      """#,
    timestamp: (16 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's back out of this refactor though. We just wanted to demonstrate a possible route for gaining exhaustivity, and we don't want to go update all of our tests.
      """#,
    timestamp: (16 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Testing the favorite primes view"#,
    timestamp: (17 * 60 + 13),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Although the prime modal view was not super testable out of the box, we were able to gain testability through a few helper methods. While views that take bindings are testable, we learned that testing exhaustively requires bundling up a view's state in a single, testable binding, which required a bunch of additional work.
      """#,
    timestamp: (17 * 60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's see what it takes to test the other views.
      """#,
    timestamp: (17 * 60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can start by quickly taking a look at the `FavoritePrimesView`. It is similar to the `IsPrimeModal` in that it only needs a few binding values to do its job:
      """#,
    timestamp: (17 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct FavoritePrimesView: View {
        @Binding var favoritePrimes: [Int]
        @Binding var activityFeed: [AppState.Activity]
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      So based off of our work with the prime modal, we should be able to instantiate one of these views in a test quite easily. If we look around to see what is testable we will see a bit of logic stuffed into this `onDelete` closure:
      """#,
    timestamp: (18 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .onDelete { indexSet in
        for index in indexSet {
          let prime = self.favoritePrimes[index]
          self.favoritePrimes.remove(at: index)
          self.activityFeed.append(
            .init(timestamp: Date(), type: .removedFavoritePrime(prime))
          )
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      If we want this logic to be testable we must extract it out into a method so that it can be invoked directly.
      """#,
    timestamp: (18 * 60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We also have these save and load methods on the view:
      """#,
    timestamp: (18 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func saveFavoritePrimes() {
        // …
      }

      func loadFavoritePrimes() {
        // …
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And they can be tested in much the same way too, assuming we control the side effects happening in here somehow.
      """#,
    timestamp: (18 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We're not going to write any tests for this view because testing it should go mostly the same as testing the `FavoritePrimesView`. We'll leave the tests as an exercise for the viewer.
      """#,
    timestamp: (18 * 60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, it's worth repeating the lessons we've learned. First of all, nothing done in the body of a view is testable. We should consider that a blackbox that we simply have no access to. So we have to do extra work to try to move work out of the body and into methods that can actually be tested.
      """#,
    timestamp: (19 * 60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Secondly, if we want to strengthen our tests so that they exhaustively cover the domain model of the view we seem to have no choice but to introduce intermediate structs so that we can assert against it all at once.
      """#,
    timestamp: (19 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Testing the counter view: @ObservedObject"#,
    timestamp: (19 * 60 + 36),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's now see what it takes to write tests for our `CounterView`. Here we are encountering something that we didn't see in the previous two views:
      """#,
    timestamp: (19 * 60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct CounterView: View {
        @ObservedObject var state: AppState
        @State var isPrimeModalShown: Bool = false
        @State var alertNthPrime: PrimeAlert?
        @State var isNthPrimeButtonDisabled = false
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This view has some state expressed as `@ObservedObject` and other state as `@State`. We haven't written tests for either of these types of state yet. The `@ObservedObject` is the easier part to test, it's even easier than testing `@Binding`s. However, in order for anything to be testable at all we have to make sure to move state mutations out of the view's body and into dedicated methods. Let's do that with the increment and decrement buttons:
      """#,
    timestamp: (19 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct CounterView: View {
        // …

        func incrementCount() {
          self.state.count += 1
        }

        func decrementCount() {
          self.state.count -= 1
        }

        var body: some View {
          // …
          Button(action: self.decrementCount) {
            Text("-")
          }
          // …
          Button(action: self.incrementCount) {
            Text("+")
          }
          // …
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then to test this logic we can construct a view, invoke those endpoints, and assert that state changed the way we expected. Except instead of constructing bindings we can pass along the app state directly:
      """#,
    timestamp: (20 * 60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func testCounterView() {
        let view = CounterView(state: AppState())

        view.incrementCount()

        XCTAssertEqual(view.state, AppState(count: 1))
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Argument passed to call that takes no arguments

      Unfortunately, we can't do this. `AppState` as an `ObservableObject` must be a class, and classes do not have a default memberwise initializer that we can call out to. We could create our own initializer to get access to these helpers, but we can't even have Xcode generate a memberwise initializer _for_ us because they do not play nicely with default properties.
      """#,
    timestamp: (21 * 60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      One thing we could do is create a new value and mutate it to our expectations.
      """#,
    timestamp: (21 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func testCounterView() {
        let view = CounterView(state: AppState())

        view.incrementCount()

        let expected = AppState()
        expected.count = 1
        XCTAssertEqual(view.state, expected)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Global function 'XCTAssertEqual(_:_:_:file:line:)' requires that 'AppState' conform to 'Equatable'

      Even this doesn't work, because `AppState` doesn't conform to `Equatable`. Unfortunately, we can't even automatically synthesize equatability on `AppState` because it's a class, which means we'd have to maintain our own custom conformance, which would break and we would need to remember to update it whenever we add or remove fields from our state.
      """#,
    timestamp: (22 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So none of this is right, really. The only easy step forward is to pluck the count off of state and test it directly.
      """#,
    timestamp: (22 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func testCounterView() {
        let view = CounterView(state: AppState())

        view.incrementCount()

        XCTAssertEqual(view.state.count, 1)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      It passes, but remember, we've lost that strong exhaustivity in our testing. If `incrementCount` started doing something else to `AppState`, we wouldn't have coverage keeping that in check.
      """#,
    timestamp: (23 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Regardless, let's flesh out this test by exercising its methods a bit more.
      """#,
    timestamp: (23 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func testCounterView() {
        let view = CounterView(state: AppState())

        view.incrementCount()

        XCTAssertEqual(view.state.count, 1)

        view.incrementCount()

        XCTAssertEqual(view.state.count, 2)

        view.decrementCount()

        XCTAssertEqual(view.state.count, 1)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      So this test was a bit easier to write because observable objects are quite easier to create than bindings, but unfortunately we came across other annoyances, like the fact that there's no easy way to create memberwise initializers, nor is there an easy way to make observable objects equatable, which means we're kind of forced to test slices of app state rather than the whole thing exhaustively.
      """#,
    timestamp: (23 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Testing the counter view: @State"#,
    timestamp: (24 * 60 + 15),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      We also want to be able to test those `@State` fields because there was some nuanced logic that guides their behavior. For example, as soon as you tap the "What is the nth prime?" button we disable the nth prime button, and then only when we get a response from the API do we re-enable it. We also only show the alert when we get a successful response from the API:
      """#,
    timestamp: (24 * 60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.state.count) { prime in
          self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
          self.isNthPrimeButtonDisabled = false
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We should be able to write some assertions that the nth prime button starts enabled and then toggles to disabled when the nth prime button is pressed.
      """#,
    timestamp: (24 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      XCTAssertEqual(view.isNthPrimeButtonDisabled, false)

      view.nthPrimeButtonAction()

      XCTAssertEqual(view.isNthPrimeButtonDisabled, true)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then we can run our test:
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 XCTAssertEqual failed: ("false") is not equal to ("true")

      That doesn't seem right. Literally the first thing the `nthPrimeButtonAction` method does is flip this boolean to `true`. Let's try to get some insight into what is happening inside this method by adding some `print` statements before and after the state is mutated :
      """#,
    timestamp: (25 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      func nthPrimeButtonAction() {
        print(self.isNthPrimeButtonDisabled)
        self.isNthPrimeButtonDisabled = true
        print(self.isNthPrimeButtonDisabled)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And when we run this test we will see:
      """#,
    timestamp: (25 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      false
      false
      """#,
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This seems bizarre. We are directly mutating this value on one line, and then the very next line it's as if nothing happened.
      """#,
    timestamp: (25 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      While we don't know exactly why this is happening, it almost certainly has to do with the fact that this value is stored in a `@State` field, which is what gives SwiftUI the powers to automatically re-render this view when any value is changed. However, it seems that whatever machinery powers this simply does not work unless it is run in the right context, such as a `UIHostingController`.
      """#,
    timestamp: (26 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      As far as we know, there is no way around this. Essentially any state that is modeled using the `@State` property wrapper is simply untestable. Maybe you don't care about testing this logic, but if you do, you have no choice but to move it into your application state.
      """#,
    timestamp: (26 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So let's do that real quick. We can add these fields to `AppState`:
      """#,
    timestamp: (26 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      class AppState: ObservableObject {
        // …
        @Published var alertNthPrime: PrimeAlert? = nil
        @Published var isNthPrimeButtonDisabled = false
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then remove those fields from our view, while also fixing references to those fields:
      """#,
    timestamp: (27 * 60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct CounterView: View {
        // …
      //  @State var alertNthPrime: PrimeAlert?
      //  @State var isNthPrimeButtonDisabled = false
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We just need to fix a few compiler errors along the way by reaching through the `state` property when accessing this state.
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Once we do, our test will actually pass:
      """#,
    timestamp: (27 * 60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      XCTAssertEqual(view.state.isNthPrimeButtonDisabled, false)

      view.nthPrimeButtonAction()

      XCTAssertEqual(view.state.isNthPrimeButtonDisabled, true)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, although `@State` fields were not directly testable, we could at least extract them out to the app state to make them testable.
      """#,
    timestamp: (27 * 60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, even with that done we still haven't recovered them same testing capabilities as we had with our architecture. When we wrote tests for this screen with the Composable Architecture we saw that we could easily add an integration test, that is, a test that exercises multiple independent pieces of the application at once. We were able to write a test for the prime modal logic as it is embedded in the counter logic, just to make sure that those two features play nicely together.
      """#,
    timestamp: (27 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is not possible to do currently. Since the prime modal is presented within the body of the counter view, we just have no access to it in our test. We can't invoke the methods we created earlier to simulate what would happen if they user interacted with the prime modal when presented from the counter screen.
      """#,
    timestamp: (28 * 60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We could probably recover some semblance of an integration test, but it would mean yet again moving logic out to somewhere more testable. Previously we moved logic out of the view body and into view methods, but now that isn't even enough, we probably need to move logic out into the app state directly somehow. But that also seems difficult because we aren't even using the app state in the prime modal view, we only pass down bindings, not the full observable object.
      """#,
    timestamp: (28 * 60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Conclusion"#,
    timestamp: (29 * 60 + 03),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      I think what we are seeing here is that there really is no such thing as testing a vanilla SwiftUI application. It appears that you always need to do a little bit of upfront work in order to unlock testability.
      """#,
    timestamp: (29 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - At a bare minimum you need to move as much of your logic out of the `body` property of your view as possible, and either put it in methods on the view or as methods on your state. This allows you to at the very least invoke those methods and assert that the state was changed in the way you expect.

          - But, this is quite similar to what we did in the Composable Architecture. We decided we did not want to perform mutations directly in the view, and instead described the mutations via enums and wrote reducers to actually perform the mutations.
      """#,
    timestamp: (29 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - If you want to take a step further, you should also think about what SwiftUI features you use to model your state. It is convenient to project out a few fields of your big blob of state into bindings, but if you do that you lose the ability to exhaustively assert how state changes in a test. And if you want to recover the exhaustivity you have to bundle up those fields into a struct of its own and create a computed property on your app state to derive that sub-state.

          - But again, this is quite similar to what we did in the Composable Architecture. We created little state structs to hold the state specific to a view, and created the composability tools necessary to plug it back into the global state, and because we did that we got exhaustive testing for free.
      """#,
    timestamp: (29 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - It is also convenient to use `@State` to model local state in a view. But this comes at the cost of essentially being untestable. There appears to be nothing we can do to make those values change as we invoke various methods on the view. The only way to gain testability is to move that state out of local `@State` bindings and into your app state, which means converting to either `@Binding` or `@ObservedObject`.

          - And yet again, this is exactly what we did in the Composable Architecture. We needed to move a few of these `@State` fields out of the view and into our global app state, like the alert state and button disabled state. At the time we did this because the logic that controlled that state was subtle, and we wanted to move it to our reducers. But then later we showed it gave us the ability to write some really amazing tests, including the ability to play out a full script of user actions (such as tapping a button, running an effect, triggering an alert, and dismissing the alert) and make sure the state changes how we expect.
      """#,
    timestamp: (30 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And this is the point of all the work we've been doing on the Composable Architecture for the past 18 episodes of Point-Free. We claim that there really is no such thing as a "vanilla SwiftUI" app if you want that app to be testable. Although SwiftUI solves some of the hardest problems when it comes to building an application, there are many problems it does not attempt to solve. The moment you start to solve these problems, you are inevitably led to needing to add a layer on top of SwiftUI that Apple has not officially sanctioned or provided guidance on. Further, if you do not construct that extra layer in a principled way the tests will be difficult to write, and you may not be able to write integration tests that test many layers of your application at once.
      """#,
    timestamp: (31 * 60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And so if we accept all that, then we can see that the Composable Architecture we have been building feels right at home in SwiftUI. It doesn't really go against the grain of how SwiftUI wants to handle our applications, it only enhances it. We are just preemptively moving mutations and side effects out of the view and into a dedicated, testable place.
      """#,
    timestamp: (31 * 60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Further, it gives us a nice mental model for thinking about our applications. Rather than thinking in terms of mutations, things like "increment the count", "add the favorite prime" or "fetch the nth prime from Wolfram", we instead think in terms of user actions, "user tapped increment button", "user swiped delete on a row at an index", "user tapped the nth prime button". This forces us to think about our application from the viewpoint of what the user is doing, and mutations and effects only happen as a result of a user action taking place.
      """#,
    timestamp: (32 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Ok! That actually concludes our introductory series of episodes on the Composable Architecture. I don't think we planned on spending 18 weeks on this topic when we started, but it's an incredibly deep topic. And honestly, we've only barely scratched the surface of this topic.
      """#,
    timestamp: (32 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      There are so many more questions to answers and things to explore. Things like:
      """#,
    timestamp: (32 * 60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - How to properly handle alerts, modals and popovers in the Composable Architecture?
      """#,
    timestamp: (32 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - Can we use this architecture for screens that are still built in plain UIKit?
      """#,
    timestamp: (33 * 60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - How is the performance of this architecture? Is there anything we should watch out for?
      """#,
    timestamp: (33 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - Can we improve the ergonomics of the architecture? We've done this a few times but there is still more to be done.
      """#,
    timestamp: (33 * 60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - What is the best way to handle dependencies in this architecture? We did a little bit of this with our environment, but can it be improved?
      """#,
    timestamp: (33 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And that's only the beginning of it!
      """#,
    timestamp: (33 * 60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But, we'll leave things here for now. This was our last episode of the year, so happy holidays to everyone and see you in 2020!
      """#,
    timestamp: (33 * 60 + 18),
    type: .paragraph
  ),
]
