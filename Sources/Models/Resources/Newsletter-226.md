Our entire [WWDC 26 series](/collections/wwdc/wwdc-2026) is now free for everyone to watch!

Across 10 episodes we take a deep look at a few of this year's biggest announcements for SwiftUI,
UIKit, and SwiftData, and compare them with tools we have been building in the Point-Free ecosystem:
[SwiftNavigation], [SQLiteData], [StructuredQueries], and our newest [Beta Preview], [LazyState].

[SwiftNavigation]: https://github.com/pointfreeco/swift-navigation
[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries
[Beta Preview]: /beta-previews
[LazyState]: /blog/posts/223-beta-preview-lazystate

The series starts with Apple's new state-driven alert APIs, moves through UIKit's latest Observation
support, spends several weeks on SwiftData's new querying and persistence features, and ends by
reverse-engineering SwiftUI's new `@State` macro in order to close a gap it still leaves behind.

Here's what we covered.

* [Episode 370: Alerts](#episode-370-wwdc26-alerts)
* [Episode 371: UIKit](#episode-371-wwdc26-uikit)
* [Episode 372: SwiftData](#episode-372-wwdc26-swiftdata)
* [Episode 373: SQLiteData Domain Modeling](#episode-373-wwdc26-sqlitedata-domain-modeling)
* [Episode 374: SQLiteData Sectioning](#episode-374-wwdc26-sqlitedata-sectioning)
* [Episode 375: SQLiteData Codability](#episode-375-wwdc26-sqlitedata-codability)
* [Episode 376: SQLiteData Advanced Domain Modeling](#episode-376-wwdc26-sqlitedata-advanced-domain-modeling)
* [Episode 377: SQLiteData Observation](#episode-377-wwdc26-sqlitedata-observation)
* [Episode 378: The @State Macro](#episode-378-wwdc26-the-state-macro)
* [Episode 379: The @LazyState Macro](#episode-379-wwdc26-the-lazystate-macro)
* [Watch for free](#watch-for-free)

## Episode-by-episode

### [Episode 370: WWDC26: Alerts](/episodes/ep370-wwdc26-alerts)

Apple's new SwiftUI alert API is a welcome move toward modeling presentation as data, but the idea
can be pushed much further. We show how SwiftNavigation lets a delete-confirmation alert's text
field be modeled by the same piece of state that drives its presentation.

For example, an alert displayed to delete an item in which you must confirm the name of the item
being deleted looks like this in vanilla SwiftUI: 

```swift
@State private var deleteAlertIsPresented = false
@State private var deleteConfirmation = ""

Button("Delete") {
  deleteAlertIsPresented = true
}
.alert("Delete", isPresented: $deleteAlertIsPresented) {
  Button("Confirm", role: .destructive) {
    …
    deleteConfirmation = ""
  }
  Button("Cancel", role: .cancel) {
    deleteConfirmation = ""
  }
  TextField("pointfreeco", text: $deleteConfirmation)
} message: {
  Text("Enter name to confirm")
}
```

Notice the improperly modeled domain leaks throughout the feature. We need two pieces of state to
model the domain, we need to clean up state when confirming and cancelling, and the confirmation
state is always available even when the alert is being displayed.

Compare this to using the tools in our [SwiftNavigation] library:

```swift
import SwiftUINavigation

@State private var deleteConfirmation: String?

Button("Delete") {
  deleteConfirmation = ""
}
.alert(item: $deleteConfirmation) { _ in
  Text("Delete")
} actions: { $deleteConfirmation in
  Button("Confirm", role: .destructive) {
    …
  }
  TextField("pointfreeco", text: $deleteConfirmation)
} message: { _ in
  Text("Enter name to confirm")
}
```

Now we have one single piece of optional state to simultaneously represent the alert being 
displayed as well as the text field in the alert. No additional clean up is necessary and the 
text field state is naturally unavailable when the alert is not presented.

### [Episode 371: WWDC26: UIKit](/episodes/ep371-wwdc26-uikit)

UIKit gets improvements each WWDC, and we feel it is far from dead. This year UIKit got a little
bit more support for the Observation framework, but we feel things could be pushed much further.

Our [SwiftNavigation] library brings tools to UIKit that behave like SwiftUI's state-driven 
navigation APIs, including bindings and even animations. For example, driving navigation to an alert
in UIKit is as simple as this:

```swift
@Observable
final class AlertsViewController: UIViewController {
  var deleteConfirmation: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    @UIBindable var `self` = self

    present(item: $self.deleteConfirmation) { $deleteConfirmation in
      let controller = UIAlertController(
        title: "Delete",
        message: "Enter name to confirm",
        preferredStyle: .alert
      )
      controller.addTextField { textField in
        textField.placeholder = "pointfreeco"
        textField.bind(text: $deleteConfirmation)
      }
      controller.addAction(
        UIAlertAction(title: "Confirm", style: .destructive) { _ in
          print(deleteConfirmation == "pointfreeco" ? "confirmed" : "rejected")
        }
      )

      return controller
    }
  }
}
```

Notice that we made the entire _view controller_ observable so that any state held in the controller
can be observed. And the `present(item:)` method is defined on `UIViewController`'s, takes a 
binding derived from the observable controller, and behaves exactly as you would expect if you are
familiar with how SwiftUI works.

And it's even possible to perform state-driven animation where you wrap state mutations in 
`withUIKitAnimation` to animate all UI elements that changed after the state was mutated:

```swift
UIAlertAction(title: "Confirm", style: .destructive) { [unowned self] _ in
  // Animate the mutation of 'status' state 
  withUIKitAnimation {
    status = deleteConfirmation == "pointfreeco"
      ? "Deleted"
      : "Confirmation failed"
  }
}

// Observe changes to 'status' to update the UI.
observe { [unowned self] in
  statusLabel.text = status
  statusLabel.alpha = status == nil ? 0 : 1
  statusLabel.isHidden = status == nil
}
```

### [Episode 372: WWDC26: SwiftData](/episodes/ep372-wwdc26-swiftdata)

We tour SwiftData's newest tools by poking around Apple's Trips sample app. This includes
model inheritance for sharing data amongst multiple similar models, storing custom data types
in models via `Codable`, sectioning results into groups, and observing SwiftData queries outside
of SwiftUI views. All of these tools are welcomed and help improve SwiftData, but we also
feel that many of these tools can be pushed further and improved, which is what the following
episodes focus on.

### [Episode 373: WWDC26: SQLiteData Domain Modeling](/episodes/ep373-wwdc26-sqlitedata-domain-modeling)

We begin by exploring how SwiftData allows sharing data amongst multiple models by using 
inheritance. For example, a `Trip` model can share its schema with a `PersonalTrip` and
`BusinessTrip` model like so:

```swift
@Model class Trip {
  var name = ""
  var destination = ""
  var startDate: Date = .now
  var endDate: Date = .now
  var color: Color { .yellow }
}

@Model class PersonalTrip: Trip {
  enum Reason: String, CaseIterable, Codable, Identifiable {
    case family, reunion, wellness, unknown
    var id: Self { self }
  }
  var reason: Reason = .unknown
  override var color: Color { .blue }
}

@Model class BusinessTrip: Trip {
  var perdiem = 0.0
  override var color: Color { .green }
}
```

However, there are some downsides to this. Inheritance is open-ended, which means we can never have
a definitive list of all subclasses and so we are forced into defensive programming for code
paths that should not be possible but cannot be proven to the compiler. Further, the base class,
`Trip` can be constructed even though it does not make sense for the app to be able to do so. And
it's not possible to convert a personal trip to a business trip, or vice-versa, and instead are 
forced into a dance of deleting data and recreating it from scratch, which means also recreating
all associations.

[SQLiteData], on the other hand, allows one to share data amongst tables by using simple enums:

```swift
@Table struct Trip: Identifiable {
  let id: UUID
  var name = ""
  var destination = ""
  var startDate: Date = .now
  var endDate: Date = .now
  var purpose: Purpose = .personal()

  @Selection
  @CaseBindable
  enum Purpose: Hashable {
    case personal(Personal = Personal())
    case business(Business = Business())

    @Selection
    struct Personal: Hashable {
      var reason: Reason = .unknown
    }

    @Selection
    struct Business: Hashable {
      var perdiem = 0.0
    }

    var color: Color {
      switch self {
      case .personal: .blue
      case .business: .green
      }
    }
  }
}
```

This fixes all of the aforementioned problems. The domain is now closed and you can exhaustively 
switch over all known types of trips. The "base" table is not constructible, and each trip _must_
be either a personal or business trip. And it's trivial to convert a personal trip to a business
trip (and vice-versa).

### [Episode 374: WWDC26: SQLiteData Sectioning](/episodes/ep374-wwdc26-sqlitedata-sectioning)

SwiftData released all new tools for sectioning results into groups, such as grouping trips by 
destination, but it's quite limited. It does not allow sectioning by computed values, controlling
the order of the sections, or grouping by data held in related models.

SQLiteData also supports sectioning results, but gives you the full power of SQL to unlock powerful
functionality. You can section results by a column like so:

```swift:3
try await $trips.load(
  Trip.order(by: \.destination),
  sectionBy: \.destination,
  animation: .default
)
```

You can also section results by a computed value, such as the first letter of the trip's name:

```swift:3
try await $trips.load(
  Trip.order(by: \.name),
  sectionBy: { trip in trip.name.substr(1, 1) }
)
```

You can also order the sectioned results like so:

```swift:3
try await $trips.load(
  Trip.order(by: \.name),
  sectionBy: { trip in trip.destination.desc() }
)
```

And you can even section results using data from joined tables:

```swift:6
@FetchAll(
  BucketListItem
    .order(by: \.title)
    .join(Trip.all) { item, trip in item.tripID.eq(trip.id) }
    .select { item, _ in item },
  sectionBy: { _, trip in trip.name }
)
var items
```

### [Episode 375: WWDC26: SQLiteData Codability](/episodes/ep375-wwdc26-sqlitedata-codability)

SwiftData allows storing custom data types in models via `Codable`, which can be handy, but also
it's a bit magical. Sometimes the custom type's fields will be stored as individual columns in the
corresponding SQLite table, and other times the type will be serialized to `Data` and stored in a 
single column. And if the type is serialized to data then one is not allowed to query against.

SQLiteData allows one to store complex data types as JSON in a single column, but thanks to the
power of SQLite, one can still query against the data in the type:

```swift
Trip
  .where {
    $0.location.jsonExtract(\.longitude) < 0
  }
```

You can construct some seriously complex queries with these tools, such as ordering trips by
the spherical distance from a particular location:

```swift
Trip
  .where {
    #sql(
      """
      3958.8 * acos(
        sin(radians(\(location.latitude)))
          * sin(radians(\($0.jsonExtract(\.latitude))))
          + cos(radians(\(location.latitude)))
          * cos(radians(\($0.jsonExtract(\.latitude))))
          * cos(radians(\($0.jsonExtract(\.longitude)) - \(location.longitude)))
      )
      """
    )
  }
```

### [Episode 376: WWDC26: SQLiteData Advanced Domain Modeling](/episodes/ep376-wwdc26-sqlitedata-advanced-domain-modeling)

We flex the powers of SQLite by exploring some advanced topics. This includes using JSONB to store
custom data types, which allows for more efficient storage and querying:

```swift:3
@Table struct Trip: Identifiable {
  // ...
  @Column(as: [Location].JSONBRepresentation.self)
  var geofence: [Location] = []
}
```

As well as an alternate way to store custom data types by using grouped columns:

```swift:9
@Selection
struct Location: Codable, Hashable {
  var latitude = 0.0
  var longitude = 0.0
}

@Table struct Trip: Identifiable {
  // ...
  var location: Location
}
```

### [Episode 377: WWDC26: SQLiteData Observation](/episodes/ep377-wwdc26-sqlitedata-observation)

SwiftData's new `ResultsObserver` observes queries outside SwiftUI views. SQLiteData also allows
for using queries outside of views, but you can continue using the exact same tools:

```swift
@Observable
final class TripsModel {
  @ObservationIgnored
  @FetchAll var trips: [Trip]

  init() {
    _trips = FetchAll(Trip.order(by: \.name))
  }
}
```

We reaped the benefits of moving complex logic out of the view and into an observable model by
writing tests. By leveraging our [DebugSnapshots] library we were able to write exhaustive tests
on the model, including computed properties:

```swift
try await expect(model) {
  model.mapTapped(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1))
  model.mapTapped(coordinate: CLLocationCoordinate2D(latitude: -1, longitude: 1))
  model.mapTapped(coordinate: CLLocationCoordinate2D(latitude: -1, longitude: -1))
  model.mapTapped(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: -1))
  try await model.$trip.load()
} changes: {
  $0.trip.geofence = [
    Location(latitude: 1, longitude: 1),
    Location(latitude: -1, longitude: 1),
    Location(latitude: -1, longitude: -1),
    Location(latitude: 1, longitude: -1),
  ]
  $0.tripInsideGeofence = true
  $0.geofenceColor = .blue
}
```

[DebugSnapshots]: https://github.com/pointfreeco/swift-debug-snapshots

### [Episode 378: WWDC26: The @State Macro](/episodes/ep378-wwdc26-the-state-macro)

SwiftUI's `@State` is now a macro, which lets state with an inline default be initialized lazily
and only once per view lifetime. We expand the macro and slowly remove all of the noise until we
find a small, powerful tool hiding in plain sight:

```swift
struct FeatureView: View {
  @State private var model = Model()

  // At its core:
  private var model: Model { _model.wrappedValue }
  private var _model: SwiftUI.LazyState<Model>
  private var $model: Binding<Model> { _model.projectedValue }
  
  …
}
```

### [Episode 379: WWDC26: The @LazyState Macro](/episodes/ep379-wwdc26-the-lazystate-macro)

The new `@State` macro still does not solve dynamic initialization from parent data. We introduce
`@LazyState`, which preserves SwiftUI's laziness without optionals, `onAppear`, or ad hoc
bindings.

```swift
import LazyState

struct LocationSearchSheet: View {
  @LazyState private var completer: LocationSearchCompleter

  init(region: MKCoordinateRegion?) {
    _completer = LazyState {
      LocationSearchCompleter(region: region)
    }
  }
}
```

## Watch for free

Every episode in the series is free! So now is a great time to catch up. And if you want to go 
deeper with the libraries featured throughout the series, check out
[SwiftNavigation], [SQLiteData], [StructuredQueries], and [LazyState].

@Button(/collections/wwdc) {
  Watch the WWDC 26 series
}
