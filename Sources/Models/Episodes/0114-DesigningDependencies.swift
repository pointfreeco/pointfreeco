import Foundation

extension Episode {
  public static let ep114_designingDependencies_pt5 = Episode(
    blurb: """
So, what's the point of forgoing the protocols and designing dependencies with simple data types? It can be summed up in 3 words: testing, testing, testing. We can now easily write tests that exercise every aspect of our application, including its reliance on internet connectivity and location services.
""",
    codeSampleDirectory: "0114-designing-dependencies-pt5",
    exercises: _exercises,
    id: 114,
    image: "https://i.vimeocdn.com/video/945462024.jpg",
    length: 50*60 + 47,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1598245200),
    references: [
      // TODO
    ],
    sequence: 114,
    subtitle: "The Point",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 65252462,
      vimeoId: 450835485,
      vimeoSecret: "a7da4563bf1e7e2766112a7a57756c878685a3df"
    )
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
  ),
]
