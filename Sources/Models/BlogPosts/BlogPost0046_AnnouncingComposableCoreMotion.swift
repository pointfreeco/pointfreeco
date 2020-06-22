import Foundation

public let post0046_AnnouncingComposableCoreMotion = BlogPost(
  author: .pointfree,
  blurb: """
We are releasing our second mini-library for the Composable Architecture, which makes it easy to use Core Motion.
""",
  contentBlocks: [
    .init(
      content: #"""
Just over a month a month ago [we released `ComposableCoreLocation`](/blog/posts/43-core-location-support-in-the-composable-architecture), our first mini-library for the Composable Architecture, which made it easy to integrate with Core Location. We teased more support libraries coming soon, so today we're excited to release [`ComposableCoreMotion`](https://github.com/pointfreeco/swift-composable-architecture/tree/master/Sources/ComposableCoreMotion), which makes it easy to use Core Motion in the Composable Architecture.

`ComposableCoreLocation` is a wrapper around Core Motion's `CMMotionManager` that exposes its functionality through effects and actions, making it easy to use with the Composable Architecture, and easy to test.

To use in your application, you can add an action to your feature's domain that represents the type of motion data you are interested in receiving. For example, if you only want motion updates, then you can add the following action:

```swift
import ComposableCoreLocation

enum FeatureAction {
  case motionUpdate(Result<DeviceMotion, NSError>)

  // Your feature's other actions:
  ...
}
```

This action will be sent every time the motion manager receives new device motion data.

Next, add a `MotionManager` type, which is a wrapper around a `CMMotionManager` that this library provides, to your feature's environment of dependencies:

```swift
struct FeatureEnvironment {
  var motionManager: MotionManager

  // Your feature's other dependencies:
  ...
}
```

Then, create a motion manager by returning an effect from our reducer. You can either do this when your feature starts up, such as when `onAppear` is invoked, or you can do it when a user action occurs, such as when the user taps a button.

As an example, say we want to create a motion manager and start listening for motion updates when a "Record" button is tapped. Then we can can do both of those things by executing two effects, one after the other:

```swift
let featureReducer = Reducer<FeatureState, FeatureAction, FeatureEnvironment> {
  state, action, environment in

  // A unique identifier for our location manager, just in case we want to use
  // more than one in our application.
  struct MotionManagerId: Hashable {}

  switch action {
  case .recordingButtonTapped:
    return .concatenate(
      environment.motionManager
        .create(id: MotionManagerId())
        .fireAndForget(),

      environment.motionManager
        .startDeviceMotionUpdates(id: MotionManagerId(), using: .xArbitraryZVertical, to: .main)
        .mapError { $0 as NSError }
        .catchToEffect()
        .map(AppAction.motionUpdate)
    )

  ...
  }
}
```

After those effects are executed you will get a steady stream of device motion updates sent to the `.motionUpdate` action, which you can handle in the reducer. For example, to compute how much the device is moving up and down we can take the dot product of the device's gravity vector with the device's acceleration vector, and we could store that in the feature's state:

```swift
case let .motionUpdate(.success(deviceMotion)):
   state.zs.append(
     motion.gravity.x * motion.userAcceleration.x
       + motion.gravity.y * motion.userAcceleration.y
       + motion.gravity.z * motion.userAcceleration.z
   )

case let .motionUpdate(.failure(error)):
  // Do something with the motion update failure, like show an alert.
```

And then later, if you want to stop receiving motion updates, such as when a "Stop" button is tapped, we can execute an effect to stop the motion manager, and even fully destroy it if we don't need the manager anymore:

```swift
case .stopButtonTapped:
  return .concatenate(
    environment.motionManager
      .stopDeviceMotionUpdates(id: MotionManagerId())
      .fireAndForget(),

    environment.motionManager
      .destroy(id: MotionManagerId())
      .fireAndForget()
  )
```

That is enough to implement a basic application that interacts with Core Motion.

But the true power of building your application and interfacing with Core Motion this way is the ability to instantly _test_ how your application behaves with Core Motion. We start by creating a `TestStore` whose environment contains a `.mock` version of the `MotionManager`. The `.mock` function allows you to create a fully controlled version of the motion manager that does not deal with a real `CMMotionManager` at all. Instead, you override whichever endpoints your feature needs to supply deterministic functionality.

For example, let's test that we property start the motion manager when we tap the record button, and that we compute the z-motion correctly, and further that we stop the motion manager when we tap the stop button. We can construct a `TestStore` with a mock motion manager that keeps track of when the manager is created and destroyed, and further we can even substitute in a subject that we control for device motion updates. This allows us to send any data we want to for the device motion.

```swift
func testFeature() {
  let motionSubject = PassthroughSubject<DeviceMotion, Error>()
  var motionManagerIsLive = false

  let store = TestStore(
    initialState: .init(),
    reducer: appReducer,
    environment: .init(
      motionManager: .mock(
        create: { _ in .fireAndForget { motionManagerIsLive = true } },
        destroy: { _ in .fireAndForget { motionManagerIsLive = false } },
        startDeviceMotionUpdates: { _, _, _ in motionSubject.eraseToEffect() },
        stopDeviceMotionUpdates: { _ in
          .fireAndForget { motionSubject.send(completion: .finished) }
        }
      )
    )
  )
}
```

We can then make an assertion on our store that plays a basic user script. We can simulate the situation in which a user taps the record button, then some device motion data is received, and finally the user taps the stop button. During that script of user actions we expect the motion manager to be started, then for some z-motion values to be accumulated, and finally for the motion manager to be stopped:

```swift
let deviceMotion = DeviceMotion(
  attitude: .init(quaternion: .init(x: 1, y: 0, z: 0, w: 0)),
  gravity: CMAcceleration(x: 1, y: 2, z: 3),
  heading: 0,
  magneticField: .init(field: .init(x: 0, y: 0, z: 0), accuracy: .high),
  rotationRate: .init(x: 0, y: 0, z: 0),
  timestamp: 0,
  userAcceleration: CMAcceleration(x: 4, y: 5, z: 6)
)

store.assert(
  .send(.recordingButtonTapped) {
    XCTAssertEqual(motionManagerIsLive, true)
  },
  .do { motionSubject.send(deviceMotion) },
  .receive(.motionUpdate(.success(deviceMotion))) {
    $0.zs = [32]
  },
  .send(.stopButtonTapped) {
    XCTAssertEqual(motionManagerIsLive, false)
  }
)
```

This is only the tip of the iceberg. We can access any part of the `CMMotionManager` API in this
way, and instantly unlock testability with how the motion functionality integrates with our core
application logic. This can be incredibly powerful, and is typically not the kind of thing one
can test easily.

To see a more advanced usage of `ComposableCoreMotion`, check out our [demo application](https://github.com/pointfreeco/swift-composable-architecture/tree/master/Examples/MotionManager), which uses a `MotionManager` to show a sinusoidal curve of a device's motion, and tracks the direction a device is facing, reflecting this in the background color of the interface. It is also [fully tested](https://github.com/pointfreeco/swift-composable-architecture/blob/master/Examples/MotionManager/MotionManagerTests/MotionTests.swift).

## Try it out today

We're excited to release our second support library for the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), and hope it will simplify and strengthen your application's interaction with Core Motion. Get access to it today by updating to version [0.5.0](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.5.0).

Keep an eye out for future support libraries!
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 45,
  publishedAt: .init(timeIntervalSince1970: 1592798400),
  title: "Core Motion support in the Composable Architecture"
)
