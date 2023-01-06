import Foundation

extension Episode {
  public static let ep156_searchable = Episode(
    blurb: """
      Let's develop a new application from scratch to explore SwiftUI's new `.searchable` API. We'll use MapKit to search for points of interest, and we will control this complex dependency so that our application can be fully testable.
      """,
    codeSampleDirectory: "0156-searchable-pt1",
    exercises: _exercises,
    id: 156,
    length: 41 * 60 + 11,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_628_485_200),
    references: [
      Episode.Reference(
        author: "Harry Lane",
        blurb: #"""
          A WWDC session exploring the `.searchable` view modifier.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10176/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-06-09"),
        title: "Craft search experiences in SwiftUI"
      ),
      .init(
        author: "Sarun Wongpatcharapakorn",
        blurb: """
          A comprehensive article explaining the full `.searchable` API, including some things we did not cover in this episode, such as the `.dismissSearch` environment value and search completions.

          > SwiftUI finally got native search support in iOS 15. We can add search functionality to any navigation view with the new searchable modifier. Let's explore its capability and limitation.
          """,
        link: "https://sarunw.com/posts/searchable-in-swiftui/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-07-07"),
        title: "Searchable modifier in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
          Documentation for the `.searchable` view modifier.
          """#,
        link:
          "https://developer.apple.com/documentation/swiftui/view/searchable(_:text:placement:suggestions:)-7g7oo",
        publishedAt: nil,
        title: "`searchable(_:text:placement:suggestions:)`"
      ),
    ],
    sequence: 156,
    subtitle: "Part 1",
    title: "Searchable SwiftUI",
    trailerVideo: .init(
      bytesLength: 31_309_457,
      downloadUrls: .s3(
        hd1080: "0156-trailer-1080p-836a72236461459ebf40f5b17bb3fef5",
        hd720: "0156-trailer-720p-373e109ac9324227b64e362d6c1a8159",
        sd540: "0156-trailer-540p-c8a285e9b8ab4c1f80ae2209074dfa21"
      ),
      vimeoId: 582_736_899
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Episode.Video {
  public static let ep156_searchable = Self(
    bytesLength: 335_953_333,
    downloadUrls: .s3(
      hd1080: "0156-1080p-1c2b6ae09e1447d6afc08e5e37e4d66b",
      hd720: "0156-720p-64a722c881eb4630b347e1d92a5559ad",
      sd540: "0156-540p-4fa66c888ec64c41aca8d47657d7f0f2"
    ),
    vimeoId: 582_736_915
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep156_searchable: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’re now going to change gears a bit to talk about one more new API that was introduced at WWDC this year, but this time it isn’t something that we have to do extra work in order to make it compatible with the Composable Architecture. Instead, it’s just a fun API that we want to use as an opportunity to build a fun application that shows off some complex behaviors.
        """#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We are going to take a look at the new `.searchable` API that makes it super easy to introduce custom search experiences to almost any screen. We are going to explore this API by building a simple application that allows us to search for points of interest on a map. This will give us the opportunity to play with some interesting frameworks that we haven’t touched in Point-Free yet, such as the search completer API for getting search suggestions and the local search API for searching a region of the map.
        """#,
      timestamp: 31,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Often when building demo applications in the Composable Architecture we like to start with a domain modeling exercise first and then build out the logic and view. However this time we are going to do the opposite by starting with the view first. We are doing this because it isn’t entirely clear what all we need to hold in the domain, and by stubbing out a basic view and making use of MapKit’s APIs it will become very clear.
        """#,
      timestamp: 58,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Getting our views in place"#,
      timestamp: (1 * 60 + 23),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’ll start by creating a new blank project that has a simple view stubbed in:
        """#,
      timestamp: (1 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import SwiftUI

        struct ContentView: View {
          var body: some View {
            Text("Hello, world!")
              .padding()
          }
        }

        struct ContentView_Previews: PreviewProvider {
          static var previews: some View {
            ContentView()
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        As of iOS 14, SwiftUI comes with a `Map` view that can be used to show maps and annotations. We get access to it by importing `MapKit`:
        """#,
      timestamp: (1 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import MapKit
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Which gives us access to the following large initializer:
        """#,
      timestamp: (1 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var body: some View {
          Map(
            coordinateRegion: <#Binding<MKCoordinateRegion>#>,
            interactionModes: <#MapInteractionModes#>,
            showsUserLocation: <#Bool#>,
            userTrackingMode: <#Binding<MapUserTrackingMode>?#>,
            annotationItems: <#RandomAccessCollection#>,
            annotationContent: <#(Identifiable) -> MapAnnotationProtocol#>
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Only one of these parameters is required, and that’s `coordinateRegion`, which is a binding that determines what area on Earth is being displayed in the map view:
        """#,
      timestamp: (1 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        coordinateRegion: <#Binding<MKCoordinateRegion>#>,
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s a binding because it needs two way communication between our domain and its domain. If we want to programmatically change the region then we just have to mutate the binding, and if the map needs to change the region, like if the user pans or zooms, then it can also write to the binding.
        """#,
      timestamp: (2 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For now we can stub out a constant binding that starts things out over New York City.
        """#,
      timestamp: (2 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        coordinateRegion: .constant(
          .init(
            center: .init(latitude: 40.7, longitude: -74),
            span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
          )
        ),
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The other options allow us to configure how a map can be interacted with, whether or not we show and/or follow the user’s current location, as well as any annotations we want rendered over specific map locations. We won’t worry about these for now, though we’ll reintroduce some of them soon.
        """#,
      timestamp: (2 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        //interactionModes: <#MapInteractionModes#>,
        //showsUserLocation: <#Bool#>,
        //userTrackingMode: <#Binding<MapUserTrackingMode>?#>,
        //annotationItems: <#RandomAccessCollection#>,
        //annotationContent: <#(Identifiable) -> MapAnnotationProtocol#>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we run the preview we see New York City, and we can pan, and zoom around. Nothing too exciting yet.
        """#,
      timestamp: (3 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s enhance this with searchability. Adding search to a SwiftUI application means adding the `searchable` view modifier to the hierarchy. So we can tack one of its 12 (!) overloads onto our `Map` view.
        """#,
      timestamp: (3 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .searchable(
          text: <#Binding<String>#>,
          placement: <#SearchFieldPlacement#>,
          prompt: <#Text#>,
          suggestions: <#() -> View#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It takes a binding to a query, where the search field should display, a customizable placeholder prompt, and a closure that can return search suggestions while search is active.
        """#,
      timestamp: (3 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Again to get things on the screen we can stub out a constant binding for now.
        """#,
      timestamp: (3 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        text: .constant("")
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we will hold off on customizing things further.
        """#,
      timestamp: (4 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        //placement: <#SearchFieldPlacement#>,
        //prompt: <#Text#>,
        //suggestions: <#() -> View#>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 'searchable(text:placement:prompt:)' is only available in iOS 15.0 or newer

        We get an error that `.searchable` is only available in iOS 15, so let’s update the deployment target of the app.
        """#,
      timestamp: (4 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we re-run the preview everything looks the same, and that’s because the view still needs a place to put the search field.
        """#,
      timestamp: (4 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        In iPhone apps this will typically be in the navigation bar, so we can wrap things in a navigation view.
        """#,
      timestamp: (4 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        NavigationView {
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We now get a search bar floating at the top of the screen.
        """#,
      timestamp: (4 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s make one quick, small cosmetic change to this UI. There’s a lot of whitespace for where a navigation title should be. It doesn’t seem to be possible to hide the navigation title at this time and still have a search bar:
        """#,
      timestamp: (5 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .navigationBarHidden(true)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So to make things look nice we can add a title instead:
        """#,
      timestamp: (5 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .navigationTitle("Places")
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we can even change the title’s display mode to save a bit of screen real estate.
        """#,
      timestamp: (5 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .navigationBarTitleDisplayMode(.inline)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The last argument of the `.searchable` method is a closure that returns a view, and that view is displayed while the search field is in focus. For example, we can put in a few text views inside the closure to see that appear as a list when we focus the field:
        """#,
      timestamp: (5 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .searchable(
          text: .constant("")
        //  placement: <#SearchFieldPlacement#>,
        //  prompt: <#Text#>,
        //  suggestions: <#() -> View#>
        ) {
          Text("Apple Store")
          Text("Cafe")
          Text("Library")
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Finally, the map is only covering the safe area, so we see some white margins. I think it’d be nice to have more of a “full screen” feel by ignoring the bottom area.
        """#,
      timestamp: (6 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .ignoresSafeArea(edges: .bottom)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We now have something that looks pretty nice!
        """#,
      timestamp: (6 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Introducing the Composable Architecture"#,
      timestamp: (6 * 60 + 46),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        We now have something that looks nice but is completely non-functional.
        """#,
      timestamp: (6 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        What we want is to build an app where, when the search query changes, we fire off a request to Apple for points of interest on the map. We’ll do so with the Composable Architecture, which means starting a domain modeling exercise, but this time influenced by what we’ve seen in the view layer.
        """#,
      timestamp: (7 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can start by describing all the mutable state on the screen, which we’ll model in a struct.
        """#,
      timestamp: (7 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppState {
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Currently we have 2 constant bindings that represent the current region and query that represent our mutable app state so far. We can add those two fields to our `AppState` as well as using the values we were previously passing to be their defaults:
        """#,
      timestamp: (7 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppState {
          var query = ""
          var region = MKCoordinateRegion(
            center: .init(latitude: 40.7, longitude: -74),
            span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we have our actions, which we’ll represent in an enum with a case for every single way an app can be interacted with.
        """#,
      timestamp: (8 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction {
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And the first two actions we’ll introduce are for the bindings that need to be able to mutate the underlying values.
        """#,
      timestamp: (8 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction {
          case queryChanged(String)
          case regionChanged(MKCoordinateRegion)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Finally we need an environment to hold all of our dependencies. We’ll start with an empty struct, but will be filling it out with dedicated clients for interacting with MapKit soon.
        """#,
      timestamp: (8 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppEnvironment {
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can get a reducer going for our app’s logic so far, but to get access to the `Reducer` type we must finally import the Composable Architecture.
        """#,
      timestamp: (8 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import ComposableArchitecture
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 No such module 'ComposableArchitecture'
        > Search package collections?

        We haven't added this package to the project yet, but that gives us the chance to explore another new feature of Xcode 13, which is package collections. If we configure Xcode with Point-Free’s package collection on the Swift Package Index, importing things becomes just a few clicks away from the fix-it.
        """#,
      timestamp: (8 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now we can define a reducer:
        """#,
      timestamp: (10 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let appReducer = Reducer<
          AppState,
          AppAction,
          AppEnvironment
        > { state, action, environment in
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Where we’ll switch over each action so we can update the associated binding state and return the `.none` effect, since we’re not ready to kick off any side effects yet.
        """#,
      timestamp: (10 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        switch action {
        case let .queryChanged(query):
          state.query = query
          return .none

        case let .regionChanged(region):
          state.region = region
          return .none
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’re now ready to update our view. We’ll introduce a store that will hold onto our app’s state and logic, and can process actions to mutate it over time.
        """#,
      timestamp: (11 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct ContentView: View {
          let store: Store<AppState, AppAction>
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And in the body of the view we need to use `WithViewStore` to observe the store’s state and send it actions.
        """#,
      timestamp: (11 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var body: some View {
          WithViewStore(self.store) { viewStore in
            …
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The default `WithViewStore` initializer requires that state is equatable in order to de-dupe and minimize the number of times it evaluates its body.
        """#,
      timestamp: (11 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can hopefully synthesize a conformance:
        """#,
      timestamp: (11 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppState: Equatable {
          var query = ""
          var region = MKCoordinateRegion(
            center: .init(latitude: 40.7, longitude: -74),
            span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 Type 'AppState' does not conform to protocol 'Equatable’

        But unfortunately, despite being a simple struct with a few value type fields, `MKCoordinateRegion` does not conform to `Equatable`.
        """#,
      timestamp: (11 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        One thing we could do is simply conform `MKCoordinateRegion` to the `Equatable` protocol ourselves. After all the implementation is quite straightforward:
        """#,
      timestamp: (11 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension MKCoordinateRegion: Equatable {
          public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.center == rhs.center && lhs.span == rhs.span
          }
        }

        extension CLLocationCoordinate2D: Equatable {
          public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
          }
        }

        extension MKCoordinateSpan: Equatable {
          public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, this kind of conformance is only appropriate for an application target. It should never be used for a library that could be reused in many places because Apple or someone else may someday define their own conformance, and there is no mechanism in Swift to decide which conformance to use. In general it’s a bad idea to conform 3rd party types to 3rd party protocols, and so we will not do this.
        """#,
      timestamp: (12 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Instead we are going to put in the work to implement the correct way of doing this, even though it is a bit arduous. We will define brand new `Equatable` types that mirror `MKCoordinateRegion`, `CLLocationCoordinate2D` and `MKCoordinateSpan`, and expose ways to convert between the two types:
        """#,
      timestamp: (12 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct CoordinateRegion: Equatable {
          var center = LocationCoordinate2D()
          var span = CoordinateSpan()
        }

        extension CoordinateRegion {
          init(rawValue: MKCoordinateRegion) {
            self.init(
              center: .init(rawValue: rawValue.center),
              span: .init(rawValue: rawValue.span)
            )
          }

          var rawValue: MKCoordinateRegion {
            .init(center: self.center.rawValue, span: self.span.rawValue)
          }
        }

        struct LocationCoordinate2D: Equatable {
          var latitude: CLLocationDegrees = 0
          var longitude: CLLocationDegrees = 0
        }

        extension LocationCoordinate2D {
          init(rawValue: CLLocationCoordinate2D) {
            self.init(latitude: rawValue.latitude, longitude: rawValue.longitude)
          }

          var rawValue: CLLocationCoordinate2D {
            .init(latitude: self.latitude, longitude: self.longitude)
          }
        }

        struct CoordinateSpan: Equatable {
          var latitudeDelta: CLLocationDegrees = 0
          var longitudeDelta: CLLocationDegrees = 0
        }

        extension CoordinateSpan {
          init(rawValue: MKCoordinateSpan) {
            self.init(latitudeDelta: rawValue.latitudeDelta, longitudeDelta: rawValue.longitudeDelta)
          }

          var rawValue: MKCoordinateSpan {
            .init(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is definitely a lot more code, and it’s a bummer to maintain, but it’s boilerplate that is straightforward. Ideally, the underlying types will be equatable in the future. (Everyone file feedbacks!)
        """#,
      timestamp: (13 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now if we update `AppState` to use this new `CoordinateRegion` we get a type that can automatically synthesize its `Equatable` conformance:
        """#,
      timestamp: (13 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppState: Equatable {
          var query = ""
          var region = CoordinateRegion(
            center: .init(latitude: 40.7, longitude: -74),
            span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And let’s also update the `AppAction` to use `CoordinateRegion` instead of `MKCoordinateRegion`:
        """#,
      timestamp: (13 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction {
          …
          case regionChanged(CoordinateRegion)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now `WithViewStore` is happy.
        """#,
      timestamp: (13 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now that we have constructed a `viewStore` we can derive bindings that interact with the store. For the coordinate region:
        """#,
      timestamp: (14 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        coordinateRegion: viewStore.binding(
          get: \.region.rawValue,
          send: { .regionChanged(.init(rawValue: $0)) }
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s a bummer that we have to do extra work for wrapping and unwrapping the coordinate region, but it’s important to have the `Equatable` conformance so that `WithViewStore` can be efficient, and at the end of the day `MKCoordinateRegion` should really be `Equatable` already.
        """#,
      timestamp: (15 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The query binding is a little simpler:
        """#,
      timestamp: (15 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .searchable(
          text: viewStore.binding(
            get: \.query,
            send: AppAction.queryChanged
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The only errors we have left are in our preview and app entry point, because `ContentView` now takes a store. We can construct one in each place:
        """#,
      timestamp: (15 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        ContentView(
          store: Store(
            initialState: .init(),
            reducer: appReducer,
            environment: .init()
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"Using and controlling MKLocalSearchCompleter"#,
      timestamp: (16 * 60 + 33),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we re-run things, they work exactly as before, but now our view is communicating with the store, and if we were to add a `.debugActions()` modifier to our reducer, we would see that as we pan and zoom the map, and as we type a query, actions are being sent through our business logic, which means we’re finally in a position to start executing some side effects when the query changes using APIs from MapKit.
        """#,
      timestamp: (16 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The effect we want to execute while the user types is a request to get search suggestions based on the query entered. So for example, if you type “Cafe” into the search field you get an option that allows you to see all cafes nearby, along with a list of actual cafes with their addresses.
        """#,
      timestamp: (17 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Turns out MapKit ships with an API that does this just, and it’s called `MKLocalSearchCompleter`. This means we will be introducing this object to our domain as a dependency in the environment.
        """#,
      timestamp: (18 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        First, to get a feel for how the API works let’s open up a playground, import `MapKit` and instantiate a completer:
        """#,
      timestamp: (18 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import MapKit

        let completer = MKLocalSearchCompleter()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Completers are initialized without any parameters. The way you interact with them is by mutating some fields. To search for nearby Apple Stores, we could update the `queryFragment` property.
        """#,
      timestamp: (18 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        completer.queryFragment = "Apple Store"
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then, we can access search results from the `results` property.
        """#,
      timestamp: (19 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        completer.results // []
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is empty, which is to be expected, because completers do their work asynchronously, and it can take some time to fire off the request and receive a response.
        """#,
      timestamp: (19 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Completers communicate back to us when results are ready by using the delegate pattern. This is a great example of an API that will someday fit in nicely with Swift’s new `async`/`await` functionality, but in the meantime we can introduce a simple delegate that just prints out its results:
        """#,
      timestamp: (19 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        class LocalSearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
          func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            print("succeeded")
            dump(completer.results)
          }

          func completer(
            _ completer: MKLocalSearchCompleter, didFailWithError error: Error
          ) {
            print("failed", error)
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We just have to create one and assign it:
        """#,
      timestamp: (20 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let delegate = LocalSearchCompleterDelegate()
        completer.delegate = delegate
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And when we run the playground, we get a bunch of things printed to the console:
        """#,
      timestamp: (20 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        succeeded
        ▿ 12 elements
          - <MKLocalSearchCompletion 0x…> Apple Store (Search Nearby) #0
            - super: NSObject
          - …
        """#,
      timestamp: nil,
      type: .code(lang: .plainText)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Each of these `MKLocalSearchCompletion` values are something we could show to the user in the suggestions list. And they should live update as they type into the search field.
        """#,
      timestamp: (20 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So it seems like we know enough about this dependency to introduce it to our environment.
        """#,
      timestamp: (21 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        In order to control this dependency in tests, previews, and more, we will introduce a lightweight wrapper type that can hold the live implementation under the hood. We’ve done this a number of times before on Point-Free, and did the deepest dive in our series on “[designing dependencies](/collections/dependencies/designing-dependencies),” where we showed how to control a number of increasingly complex dependencies, from simple API requests to a complex location manager that used delegates.
        """#,
      timestamp: (21 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Here we also have a dependency that uses delegates, which are among the more complicated dependencies to control. We’ll start by hopping back over to the application target and creating a struct wrapper that will hold a field for each endpoint that we want to access in the completer:
        """#,
      timestamp: (21 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompleter {}
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We might distill the work down to sending a new search query into the completer and then returning the results in an effect:
        """#,
      timestamp: (22 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompleter {
          var search: (String) -> Effect<[MKLocalSearchCompletion], Error>
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is not an uncommon way of capturing this kind of work. We could then lean on Combine’s APIs in our reducer to debounce this work and manage cancellation.
        """#,
      timestamp: (22 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `MKLocalSearchCompleter` API, however, has already been designed to take care of all of the affordances of debouncing, cancellation, and more. All you have to do is keep updating the `queryFragment` field and the framework just notifies you when it receives some results. So it’s not necessary for us to do any of that work. Instead, we should introduce endpoints more analogous to the endpoints on the search completer.
        """#,
      timestamp: (23 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So far in the playground we hit an endpoint to update the `queryFragment`. This is an in-place mutation of a string that returns no data, so we can model it with a function that takes a `String` and returns an effect that never outputs nor fails.
        """#,
      timestamp: (23 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var search: (String) -> Effect<Never, Never>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then we need an endpoint that returns a long-living effect for all of the delegate methods. In our case we have a very simple delegate with 2 endpoints: 1 that returns updated completion results, and 1 that handles failure.
        """#,
      timestamp: (24 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now, at first we may think we should model this as an effect that can deliver an array of `MKLocalSearchCompletion`s or an error:
        """#,
      timestamp: (24 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var completions: () -> Effect<[MKLocalSearchCompletion], Error>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, this represents a long-living effect that can fail, but once it does fail it ends the effect forever. That isn’t how the delegate system works. With the delegate the `MKLocalSearchCompleter` can ping the success and failure endpoints as many times as it wants. For example, maybe due to intermittent network problems the completer emits an error, but then a moment later things start working normally and delivers a success. The effect as written here cannot accomplish that.
        """#,
      timestamp: (24 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, we need to change the type of effect so that it can deliver as many completions or errors as it wants, which we can do by using a result type as the output:
        """#,
      timestamp: (25 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var completions: () -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is the interface that we will deal with in order to work with search completers.
        """#,
      timestamp: (25 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now we can start defining an implementation of this interface. We’ll start with the live client, which uses an actual, real life `MKLocalSearchCompleter` under the hood in order to implement these endpoints. We like to house these implementations as statics inside the client type:
        """#,
      timestamp: (25 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchCompleter {
          static let live = Self(
            completions: <#() -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>#>,
            search: <#(String) -> Effect<Never, Never>#>
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        In order to implement these two endpoints we need to construct an `MKLocalSearchCompleter` somewhere. We could define one in the global module scope, but it would be better to scope it locally so that only the internals of this live client has access to it. To do this we can make the `live` static field a computed field, which then gives us the opportunity to construct a locally scoped `MKLocalSearchCompleter`:
        """#,
      timestamp: (26 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchCompleter {
          static var live: Self {
            let completer = MKLocalSearchCompleter()

            return Self(
              completions: <#() -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>#>,
              search: <#(String) -> Effect<Never, Never>#>
            )
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `search` endpoint is the simplest one to implement because it’s just a matter of mutating the `completer`'s `queryFragment` field. However, we don’t want to just do it immediately. We want to only perform that mutation when the effect is executed, which we can do by return a `.fireAndForget`, which is one that can run but never emits output or failures:
        """#,
      timestamp: (26 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return Self(
          completions: <#() -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>#>,
          search: { query in
            .fireAndForget {
              completer.queryFragment = query
            }
          }
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `completions` endpoint is a little more difficult to implement because it needs to construct a long-living effect that can emit lots of data, and it does so by using a delegate. Let’s get the basics into place first. To return a long-living effect we can use the `.run` static function on `Effect`, which takes a closure that is handed a `subscriber` which can be used to send as many outputs to the subscriber as we need. We also need to return a cancellable from this `.run` method, which will be useful in a moment for cleaning up resources when the effect is cancelled:
        """#,
      timestamp: (27 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        completions: {
          .run { subscriber in
            return AnyCancellable {

            }
          }
        },
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        In order to receive completer results we need to construct a delegate. We can even define it directly in the scope of the `.run` closure, which means its only accessible inside this hyperlocal scope:
        """#,
      timestamp: (28 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        class Delegate: NSObject, MKLocalSearchCompleterDelegate {
          func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
          }

          func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now what we want do is send the `subscriber` data in each of these delegate methods. We can just hold onto the subscriber inside the `Delegate` itself:
        """#,
      timestamp: (29 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let subscriber: Effect<Result<[MKLocalSearchCompletion], Error>, Never>.Subscriber

        init(subscriber: Effect<Result<[MKLocalSearchCompletion], Error>, Never>.Subscriber) {
          self.subscriber = subscriber
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then its easy to implement the delegate methods:
        """#,
      timestamp: (29 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
          self.subscriber.send(.success(completer.results))
        }

        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
          self.subscriber.send(.failure(error))
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can now set the delegate for the completer:
        """#,
      timestamp: (30 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let delegate = Delegate(subscriber: subscriber)
        completer.delegate = delegate
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, the `delegate` property on `MKLocalSearchCompleter` is defined as `weak`, which means that unless something else is holding onto the delegate it will be deallocated.
        """#,
      timestamp: (30 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is where the cancellable comes into play. We can capture the delegate in that closure to make sure it lives for as long as the publisher lives:
        """#,
      timestamp: (31 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let delegate = Delegate(subscriber: subscriber)
        completer.delegate = delegate
        return AnyCancellable {
          _ = delegate
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And that completes the live implementation of the search completer. It may seem complex, but remember that the dependency itself is quite complex since it uses delegates.
        """#,
      timestamp: (31 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Displaying search results"#,
      timestamp: (31 * 60 + 49),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s now make use of this new dependency to get some actual search completions when the query changes. We’ll start by adding the client to the `AppEnvironment`:
        """#,
      timestamp: (31 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppEnvironment {
          var localSearchCompleter: LocalSearchCompleter
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And let’s go ahead and update all the places we create the environment to use the live one for now:
        """#,
      timestamp: (32 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        ContentView(
          store: .init(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
              localSearchCompleter: .live
            )
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        With the dependency now in our environment we can make use of it in the reducer. For example, when the query we can fire off a `.search` effect from the completer:
        """#,
      timestamp: (32 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .queryChanged(query):
          state.query = query
          return environment.localSearchCompleter.search(query)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        But remember that `.search` is an `Effect<Never, Never>`, and so it does not feed and data back into the system. So, in order to get this to compile we have to coalesce the `<Never, Never>` effect into a `<AppAction, Never>` effect, which can be done with the `.fireAndForget()` operator:
        """#,
      timestamp: (32 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return environment.localSearchCompleter.search(query)
          .fireAndForget()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This automatically casts the output and failure to what the reducer needs to return.
        """#,
      timestamp: (33 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The only purpose of the `.search` endpoint is to communicate to the underlying `MKLocalSearchCompleter` that the query fragment changed, which then will cause results to be propagated to the delegate. In order to get the results from the delegate we must execute the long-living `.completions` effect to get a stead stream of suggestions as the query changes.
        """#,
      timestamp: (33 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        A good place to kick off long-living effects like this are by hooking into an `.onAppear` action that is invoked a single time when the view appears. So, let’s add the action to `AppAction`:
        """#,
      timestamp: (33 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction: Equatable {
          case onAppear
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then we can handle this action in the reducer by starting up the long-living effect of completions:
        """#,
      timestamp: (33 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .onAppear:
          return environment.localSearchCompleter.completions()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This effect does feed data back into the system, unlike the `.search` endpoint, which means we need an action for receiving the data. The action will hold onto the exact data emitted by the effect, which is a result of either a successful array of completion results or an error:
        """#,
      timestamp: (33 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case completionsUpdated(Result<[MKLocalSearchCompletion], Error>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then, when the `completions` effect emits data we can pipe that into this `AppAction` in order to send it back into the system:
        """#,
      timestamp: (34 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return environment.localSearchCompleter.completions()
          .map(AppAction.completionsUpdated)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Since we now have a new action we have to handle it in the reducer. We can stub out the implementation by breaking up the success and failure cases and returning no effects:
        """#,
      timestamp: (34 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .completionsUpdated(.success(completions)):
          return .none

        case .completionsUpdated(.failure):
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To properly handle these cases we need to start holding completions in state so that we can keep track of the ones returned to us from the effect, which would then allow us to populate the suggestions list in the view. So, we’ll add a field to `AppState`:
        """#,
      timestamp: (35 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppState: Equatable {
          var completions: [MKLocalSearchCompletion] = []
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Interestingly, `MKLocalSearchCompletion` is `Equatable`, but this is just because it’s actually an `NSObject` which is always `Equatable`.
        """#,
      timestamp: (35 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now we can hold onto completions when they are delivered to us by the effect:
        """#,
      timestamp: (35 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .completionsUpdated(.success(completions)):
          state.completions = completions
          return .none

        case .completionsUpdated(.failure):
          // TODO: error handling
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s also make sure to send the `.onAppear` action in the view:
        """#,
      timestamp: (35 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .onAppear { viewStore.send(.onAppear) }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Things are now compiling, but we’re not doing anything with the completions we hold in state yet.
        """#,
      timestamp: (36 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We want to show these completions in the suggestions part of the search, which you will remember is handled by providing a trailing closure to the `.searchable` API:
        """#,
      timestamp: (36 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .searchable(
          text: viewStore.binding(
            get: \.query,
            send: AppAction.queryChanged
          )
        ) {
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can `ForEach` over our completions in this closure in order to render the suggestions for the user to choose from:
        """#,
      timestamp: (36 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .searchable(
          text: viewStore.binding(
            get: \.query,
            send: AppAction.queryChanged
          )
        ) {
          if viewStore.query.isEmpty {
            Text("Apple Store")
            Text("Cafes")
            Text("Library")
          } else {
            ForEach(viewStore.completions) { completion in
              Text(completion.title)
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 Referencing initializer 'init(_:content:)' on 'ForEach' requires that 'MKLocalSearchCompletion' conform to 'Identifiable'

        It looks like `MKLocalSearchCompletion` is not `Identifiable`, and so it cannot be passed to `ForEach` directly. One thing we could do is pass a key path to an identifier, like maybe its title:
        """#,
      timestamp: (36 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        ForEach(viewStore.completions, id: \.title) { completion in
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Instead we can use the `id` argument of `ForEach` to compute an identifier to be used. `MKLocalSearchCompletion` only has a `title` and `subtitle` field, neither of which uniquely identify a completion, but put together it should be unique. So let’s add a computed property:
        """#,
      timestamp: (37 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension MKLocalSearchCompletion {
          var id: [String] { [self.title, self.subtitle] }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now this compiles:
        """#,
      timestamp: (37 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        ForEach(viewStore.completions, id: \.id) { completion in
          Text(completion.title)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Even better, if we run the Xcode preview we can see lives search suggestions appearing as we type in the field. It’s even super responsive, nearly changing instantly with each key stroke.
        """#,
      timestamp: (37 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s improve the experience a little bit, because if I type something like “Apple Store” into the query I get what look like a bunch of duplicate entries. The `subtitle` of a completion provides more context, which would be nice to display.
        """#,
      timestamp: (38 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        ForEach(viewStore.completions, id: \.id) { completion in
          VStack(alignment: .leading) {
            Text(completion.title)
            Text(completion.subtitle)
              .font(.caption)
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now things look really nice.
        """#,
      timestamp: (38 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Finally, let's also improve the default suggestions experience. I'm going to paste in a whole bunch of code just to show how rich of an experience is possible to define here. We can even get something that looks a lot like Apple's official Maps experience with just a little bit of work:
        """#,
      timestamp: (38 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        if viewStore.query.isEmpty {
          HStack {
            Text("Recent Searches")
            Spacer()
            Button(action: {}) {
              Text("See all")
            }
          }
          .font(.callout)

          HStack {
            Image(systemName: "magnifyingglass")
            Text("Apple • New York")
            Spacer()
          }
          HStack {
            Image(systemName: "magnifyingglass")
            Text("Apple • New York")
            Spacer()
          }
          HStack {
            Image(systemName: "magnifyingglass")
            Text("Apple • New York")
            Spacer()
          }

          HStack {
            Text("Find nearby")
            Spacer()
            Button(action: {}) {
              Text("See all")
            }
          }
          .padding(.top)
          .font(.callout)

          ScrollView(.horizontal) {
            HStack {
              ForEach(1...2, id: \.self) { _ in
                VStack {
                  ForEach(1...2, id: \.self) { _ in
                    HStack {
                      Image(systemName: "bag.circle.fill")
                        .foregroundStyle(Color.white, Color.red)
                        .font(.title)
                      Text("Shopping")
                    }
                    .padding([.top, .bottom, .trailing],  4)
                  }
                }
              }
            }
          }

          HStack {
            Text("Editors’ picks")
            Spacer()
            Button(action: {}) {
              Text("See all")
            }
          }
          .padding(.top)
          .font(.callout)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"Next time: annotating the map view"#,
      timestamp: (39 * 60 + 49),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        OK, so we’re now about halfway to implementing our search feature. We’ve got a map on the screen that we can pan and zoom around, and we’re getting real time search suggestions as we type, all powered by MapKit’s local search completer API.
        """#,
      timestamp: (39 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The final feature we want to implement is to allow the user to tap a suggestion in the list and place a marker on the map corresponding to that location. Even better, sometimes the suggestions provided by the search completer don’t correspond to a single location, but rather a whole collection of collections. For example, if we search for “Apple Store” then the top suggestion has the subtitle “Search Nearby”, which should place a marker on every Apple store nearby.
        """#,
      timestamp: (40 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But, where are we going to get these search results from? As we saw a moment ago, the `MKLocalSearchCompletion` object has only a title and subtitle, so we don’t get an address or geographic coordinates for the location. Well, there is another API in MapKit that allows you to make a search request for points-of-interest, which means we have yet another dependency we need to control and add to our environment.
        """#,
      timestamp: (40 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s start by explore this API a little bit in a playground like we did for the search completer…next time!
        """#,
      timestamp: (41 * 60 + 2),
      type: .paragraph
    ),
  ]
}
