import Foundation

extension Episode {
  public static let ep113_designingDependencies_pt4 = Episode(
    blurb: """
Now that we've tackled two dependencies of varying complexity we are ready to handle our more complicated dependency yet: Core Location. We will see what it means to control a dependency that communicates with a delegate and captures a complex state machine with many potential flows.
""",
    codeSampleDirectory: "0113-designing-dependencies-pt4",
    exercises: _exercises,
    id: 113,
    image: "https://i.vimeocdn.com/video/941523768.jpg",
    length: 50*60 + 58,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1597640400),
    references: [
      .init(
        author: nil,
        blurb: #"""
A design pattern of object-oriented programming that flips the more traditional dependency pattern so that the implementation depends on the interface. We accomplish this by having our live dependencies depend on struct interfaces.
"""#,
        link: "https://en.wikipedia.org/wiki/Dependency_inversion_principle",
        publishedAt: nil,
        title: "Dependency Inversion Principle"
      )
    ],
    sequence: 113,
    subtitle: "Core Location",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 39905374,
      vimeoId: 448362098,
      vimeoSecret: "ebb9a3b273bfa765b58bda750d84b479fdc7a90c"
    )
    //https://player.vimeo.com/external/448362098.hd.mp4?s=ebb9a3b273bfa765b58bda750d84b479fdc7a90c&profile_id=175&download=1
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Because our dependencies are simple value types we can more easily transform them. We can even define "higher-order" dependencies, or functions that take a dependency as input and transform it into a new dependency returned as output.

As an example, try implementing a method on `WeatherClient` that returns a brand new weather client with all of its endpoints artificially slowed down by a second.

```swift
extension WeatherClient {
  func slowed() -> Self {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
You can create a new weather client by passing along all of the existing client's endpoints with Combine's `delay` operator attached.

```swift
extension WeatherClient {
  func slowed() -> Self {
    Self(
      weather: {
        self.weather($0)
          .delay(for: 1, scheduler: DispatchQueue.main)
          .eraseToAnyPublisher()
      },
      searchLocations: {
        self.searchLocations($0)
          .delay(for: 1, scheduler: DispatchQueue.main)
          .eraseToAnyPublisher()
      }
    )
  }
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Implement a method on `LocationClient` that can override an existing location client to behave as if it were at a specific location.

```swift
extension LocationClient {
  func located(
    atLatitude latitude: CLLocationDegrees,
    longitude: CLLocationDegrees
  ) -> Self {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
You can create a new location client by passing along each endpoint and transforming the delegate publisher to modify the `didUpdateLocations` event.

```swift
extension LocationClient {
  func located(
    atLatitude latitude: CLLocationDegrees,
    longitude: CLLocationDegrees
  ) -> Self {
    Self(
      authorizationStatus: self.authorizationStatus,
      requestWhenInUseAuthorization: self.requestWhenInUseAuthorization,
      requestLocation: self.requestLocation,
      delegate: self.delegate
        .map { event -> DelegateEvent in
          guard case .didUpdateLocations = event else { return event }
          let location = CLLocation(latitude: latitude, longitude: longitude)
          return .didUpdateLocations([location])
        }
        .eraseToAnyPublisher()
    )
  }
}
```
"""#
  )
]
