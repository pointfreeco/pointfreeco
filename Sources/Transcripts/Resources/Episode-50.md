## Recap

@T(00:00:05)
So we're getting really close to the image we are trying to replicate, but there are a few small things that would make it even better.

@T(00:00:09)
- Right now our bumps are pretty boring and uniform. What we can do is draw multiple random bumps on each line, maybe even a random number of random bumps, and whenever two bumps overlap we will have their amplitudes add. This will give us some more interesting bumps with more variation.

@T(00:00:21)
- Next we could add a bit of noise to the curves so that they look more ripply and soundwavey. We could even get fancy and make it so that the noise is less towards the edges of the image, and more intense where the bump takes place.

@T(00:00:43)
Accomplishing this will lead us to some very complicated generators, and so once we've done that we'll probably want to add some test coverage to these generators. And that's exactly what we'll do now...

## Adding noise to our bump curves

@T(00:01:05)
We can introduce some noise into our bumps by altering the return value to not be just a plain function `(CGFloat) -> CGFloat`, but instead a function `(CGFloat) -> Gen<CGFloat>`. This will allow us to slightly perturb the output of the bump function in a random way.

@T(00:01:26)
Let's start by writing out the signature of this function and stubbing the few things we know:

```swift
func noisyBump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
  ) -> (CGFloat) -> Gen<CGFloat> {

  return { x in
  }
}
```

@T(00:01:34)
The first thing we can do is compute the bump curve we want to perturb outside the closure so that we can use it inside the closure. Since we need to return a `Gen` we can just wrap it in the `always` generator, which always returns the same value, i.e. no randomness at all:

```swift
func noisyBump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
) -> (CGFloat) -> Gen<CGFloat> {

  let curve = bump(
    amplitude: amplitude,
    center: center,
    plateauSize: plateauSize,
    curveSize: curveSize
  )

  return { x in
    let y = curve(x)
    return .always(y)
  }
}
```

@T(00:02:12)
We now need to swap out our call to `bump` with `noisyBump`.

```swift
let curve = zip4(
  with: noisyBump(amplitude:center:plateauSize:curveSize:)
)(
  Gen<CGFloat>.float(in: -30...(-1)),
  Gen<CGFloat>.float(in: -60...60)
    .map { $0 + canvas.width / 2 },
  Gen<CGFloat>.float(in: 0...60),
  Gen<CGFloat>.float(in: 10...60)
)
```

@T(00:02:18)
And because `noisyBump` returns a `Gen`, we need to make sure we run it in our `path` function.

```swift
func path(
  from min: CGFloat, to max: CGFloat, baseline: CGFloat
) -> Gen<CGPath> {
  let dx = mainArea.width / CGFloat(numSegments)
  return Gen<CGPath> { rng in

    let bump = curve.run(using: &rng)

    let path = CGMutablePath()
    path.move(to: CGPoint(x: min, y: baseline))
    stride(from: min, to: max, by: dx)
      .forEach { x in
        let y = bump(x).run(using: &rng)
        path.addLine(to: CGPoint(x: x, y: baseline + y))
    }
    return path
  }
}
```

@T(00:02:37)
So right now this is just returning the curve with no random noise being applied. To introduce the noise we can just add a random small number to the output of the curve. To do this we will `map` on an existing generator and then do the perturbation inside the `map`:

```swift
func noisyBump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
) -> (CGFloat) -> Gen<CGFloat> {

  let curve = bump(
    amplitude: amplitude,
    center: center,
    plateauSize: plateauSize,
    curveSize: curveSize
  )

  return { x in
    let y = curve(x)
    return Gen<CGFloat>.float(in: 0...2)
      .map { -$0 + y }
  }
}
```

@T(00:03:05)
Here we used a `-` because remember the y-axis increases as we go down, and so if we want to shift the curve up randomly we need to subtract.

@T(00:03:16)
This is looking good, but it is uniformly adding the same type of noise across the entire curve. It would be nice if the noise was a little noisier around the bump and a little more subdued when the curve trails off. To do that we can divide the curve's `y` value by the amplitude so that we can a value between 0 and 1, where it is 0 when the curve is flat, and 1 at the peak of its plateau, and then we can multiple the noise by that:

```swift
func noiseyBump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
) -> (CGFloat) -> Gen<CGFloat> {

  let curve = bump(
    amplitude: amplitude,
    center: center,
    plateauSize: plateauSize,
    curveSize: curveSize
  )

  return { x in
    let y = curve(x)
    Gen<CGFloat>.float(in: 0...2)
      .map { -$0 * (y / amplitude) + y }
  }
}
```

@T(00:03:52)
This is closer, but it's now a bummer that we have 0 noise when the curve is flat, so let's add a little to this multiplication factor to make sure it's greater than zero:

```swift
func noisyBump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
) -> (CGFloat) -> Gen<CGFloat> {

  let curve = bump(
    amplitude: amplitude,
    center: center,
    plateauSize: plateauSize,
    curveSize: curveSize
  )

  return { x in
    Gen<CGFloat>.float(in: 0...2)
      .map { -$0 * (y / amplitude + 0.5) + curve(x) }
  }
}
```

@T(00:04:09)
This is looking pretty nice! To get here, all we needed to do was insert one more unit of work into the pipeline we've built: by changing one of our helpers from a function that returns `CGFloat`s to a function that returns `Gen<CGFloat>`s, we were able to add a bit of additional randomness every time the function is called.

## Combining multiple bumps

@T(00:04:32)
The main thing we have left to do is make the bumps a bit more interesting, as each curve only has a single bump. If we instead generated a random number of bumps per line, we could combine them to get some more variation.

@T(00:05:03)
If we go back to the `path` function, we'll see that we run `curve` once to get a single `bump`.

```swift
let bump = curve.run(using: &rng)
```

Instead, we'll want to create several bumps at once using the `array` helper, which takes any random `Gen` and returns a new `Gen` that produces a randomly sized array of the `Gen`'s values.

```swift
let bumps = curve.array(of: .int(in: 1...4))
  .run(using: &rng)
```

@T(00:06:28)
We now have an array of functions `[(CGFloat) -> Gen<CGFloat>]`.

@T(00:06:35)
We can no longer compute `y` in the way we were before, where we ran a single `bump` function.

@T(00:06:45)
Instead, we need to run _all_ of the bump functions we generate, and combine them by averaging them.

```swift
// let y = bump(x).run(using: &rng)
let ys = bumps.map { $0(x).run(using: &rng) }
let average = ys.reduce(0, +) / CGFloat(ys.count)
path.addLine(to: CGPoint(x: x, y: baseline + average))
```

@T(00:07:40)
Now we're seeing some more interesting bumps! Rather than simple bumps that curve up, plateau, and curve back down again, we see bumps combining in interesting ways.

@T(00:07:56)
In averaging a bunch of bumps, we've dulled the overall amplitude a bit, so let's increase both the initial amplitude and the random noise we added earlier.

@T(00:08:24)
This is looking even more fun!

## Testing an app with randomness

@T(00:08:38)
We've now seen how we can build very complex generative art from very simple generators by piecing them together. We started by knowing we wanted to build a `Gen<UIImage>`, which seemed very difficult, but we kept backing the problem up into bite-sized steps: first we knew we needed to build a Gen<[CGPath]>, and we knew we needed a Gen<CGPath> to get there.

@T(00:09:09)
And we've seen how nice the composable `Gen` type is, but we haven't shown what it's like to use in a real app. How would we use this generator of artwork in a real app, and even better, how would we test that app?

@T(00:09:29)
Let's do just that. We've set up a project that is basically a Joy Division poster explorer that lets users tweak all of these parameters and just need to add some deterministic tests.

@T(00:09:48)
Here's an Xcode project with all of the work we've done so far pasted in.

@T(00:10:10)
When we run the app, we're presented with a screen that lets us adjust a bunch of the parameters that affect our artwork, like amplitude, center, plateau size, and curve size.

@T(00:10:40)
Let's write some tests for it so that we can refactor and add to our app without fear of breaking anything. We can hop over to a test file and write a snapshot test.

```swift
@testable import Joy
import SnapshotTesting
import XCTest

class JoyTests: XCTestCase {
  func testJoy() {

  }
}
```

We've already imported [our snapshot testing library](https://github.com/pointfreeco/swift-snapshot-testing), which lets us snapshot many different things, but in our case we want to snapshot test our view controller.

```swift
func testJoy() {
  let vc = ViewController()
  assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
}
```

@T(00:11:32)
When we run the test it fails:

> Error: No reference was found on disk. Automatically recorded snapshot: …
>
> open "JoyTests/__Snapshots__/JoyTests/testJoy.1.png"
>
> Re-run "testJoy" to test against the newly-recorded snapshot.

This is expected, because it's a brand new test. We can open the snapshot to verify that it recorded.

@T(00:11:45)
And there it is! We've captured the entire interface of our app: the artwork and the sliders for configuration.

@T(00:11:52)
If we run our tests again, it fails.

> Error: Snapshot does not match reference.

This failure is _not_ what we'd hope for. When we run this test we want the snapshot generated to match the reference we recorded on disk, but in this case it looks like we've generated a totally different snapshot.

@T(00:12:11)
We can hop on over to the report navigator to see the difference.

@T(00:12:41)
When we expand it we can see that a lot of the pixels in the art region are inconsistent. And if we look at the failure and the reference we indeed see that the artwork changed between test runs.

@T(00:12:57)
This is because we're using the `SystemRandomNumberGenerator` and there's no way to control it. Luckily we have a solution to this problem.

## Testing our view controller

@T(00:13:21)
Let's hop over to the main view controller and see where we're generating our artwork.

```swift
func setImage() {
  var rng = SystemRandomNumberGenerator()
  let newImage = image(
    amplitude: CGFloat(self.amplitude),
    center: CGFloat(self.center),
    plateauSize: CGFloat(self.plateauSize),
    curveSize: CGFloat(self.curveSize)
    ).run(using: &rng)
  self.imageView.image = newImage
}
```

@T(00:13:55)
Because we're using a `SystemRandomNumberGenerator`, we get true randomness and our tests are going to be unreliable and fail.

@T(00:14:07)
We've had several episodes in the past where we explored dependency injection, and we showed a very simple but powerful solution to the problem ([part 1](/episodes/ep16-dependency-injection-made-easy), [part 2](/episodes/ep18-dependency-injection-made-comfortable)). We introduce an `Environment` struct, which is a single home for all of our app's global dependencies. For example, we may introduce a mutable `rng` property that can be replaced in our tests with a controllable generator.

```swift
struct Environment {
  var rng = SystemRandomNumberGenerator()
}
```

@T(00:14:43)
And finally we define a global, mutable `Current` variable, which we'll call to whenever we need a dependency.

```swift
var Current = Environment()
```

@T(00:14:51)
And now we can replace the local `SystemRandomNumberGenerator` we were using with our global `Current.rng`.

```swift
  func setImage() {
    // var rng = SystemRandomNumberGenerator()
    let newImage = image(
      amplitude: CGFloat(self.amplitude),
      center: CGFloat(self.center),
      plateauSize: CGFloat(self.plateauSize),
      curveSize: CGFloat(self.curveSize)
    )
    .run(using: &Current.rng)
    self.imageView.image = newImage
  }
```

Everything's compiling, but we haven't yet controlled this generator for our tests.

@T(00:15:05)
The first thing we need to do is introduce a mock `Environment` for our tests.

```swift
extension Environment {
  static let mock = Environment(
    rng: <# SystemRandomNumberGenerator #>
  )
}
```

@T(00:15:35)
It would be nice to use a seedable, controllable linear congruential generator:

```swift
extension Environment {
  static let mock = Environment(
    rng: LCRNG(seed: 1)
  )
}
```

> Error: Cannot convert value of type 'LCRNG' to expected argument type 'SystemRandomNumberGenerator'

@T(00:15:46)
But we can't do this because `Environment`'s `rng` property is pinned to the `SystemRandomNumberGenerator` type.

@T(00:15:56)
This is a problem we've encountered before. We wanted to solve it by using a protocol:

```swift
struct Environment {
  var rng: RandomNumberGenerator = SystemRandomNumberGenerator()
}
```

But Swift protocols do not conform to themselves, so we can't actually use these generators in this way.

@T(00:16:15)
Instead, we needed to introduce a wrapper type, `AnyRandomNumberGenerator`, which is a consistent type that we can use throughout our application, but where we can swap out the internal generator in our tests.

```swift
struct Environment {
  var rng = AnyRandomNumberGenerator(
    rng: SystemRandomNumberGenerator()
  )
}
```

@T(00:16:32)
With this in place, our mock environment can now use a seedable `LCRNG`.

```swift
extension Environment {
  static let mock = Environment(
    rng: AnyRandomNumberGenerator(rng: LCRNG(seed: 1))
  )
}
```

@T(00:16:43)
Now that we have a mock value defined, we need to use it. A good place to set up all of our mock global dependencies is in a `setUp` function in our tests.

```swift
class JoyTests: XCTestCase {
  override func setUp() {
    super.setUp()
    Current = .mock
  }
```

@T(00:17:03)
Now when we run our tests, they'll be using this mock environment, which has controlled the `rng` we use to generate artwork.

> Failed: Snapshot does not match reference.

@T(00:17:10)
The test fails, which makes sense because our reference was generated with an uncontrollable `SystemRandomNumberGenerator`. Let's record a new reference using the `LCRNG`.

```swift
func testJoy() {
  let vc = ViewController()
  record=true
  assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
}
```

> Failed: Record mode is on. Turn record mode off and re-run "testJoy" to test against the newly-recorded snapshot.

@T(00:17:30)
It failed again, this time because we _always_ fail when record mode is left on. Now that we've recorded a new reference, we can turn off record mode.

```swift
func testJoy() {
  let vc = ViewController()
  // record=true
  assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
}
```

And when we re-run our tests, they pass!

@T(00:17:47)
And it's no fluke! By controlling our artwork with a consistently-seeded `LCRNG`, it should always produce the same snapshot.

@T(00:17:55)
This is really cool! We were able to write tests for our generative artwork app and it was really easy to do so. This is why we really love `Environment` and add it to every code base we encounter. It makes it super easy to make existing code that's hard to test and make it testable.

@T(00:18:17)
And all the generator work we did can be extracted out to its own module because it doesn't care which `RandomNumberGenerator` we're using, and then in our application we can use `Environment` to use a `SystemRandomNumberGenerator` in production, and an `LCRNG` in our tests.

## Adding an easter egg

@T(00:18:40)
Now that we have a test, we should be more confident to make changes without fear of breaking anything, so let'd add a small feature to our application.

@T(00:18:57)
Let's add an easter egg to our drawing code: when it's Point-Free's anniversary, we want the curves to render using the Point-Free colors.

@T(00:19:33)
What we need to do is update the stroke color in the loop that renders each line. We have the Point-Free colors ready in an array of `UIColor`s:

```swift
let pointFreeColors = [
  UIColor(red: 0.47, green: 0.95, blue: 0.69, alpha: 1),
  UIColor(red: 1, green: 0.94, blue: 0.5, alpha: 1),
  UIColor(red: 0.3, green: 0.80, blue: 1, alpha: 1),
  UIColor(red: 0.59, green: 0.30, blue: 1, alpha: 1)
]
```

And we need to use the index of the path to determine which color we pluck out of our array.

```swift
paths.enumerated().forEach { idx, path in
  ctx.setStrokeColor(
    pointFreeColors[pointFreeColors.count * idx / paths.count]
      .cgColor
  )
  ctx.addPath(path)
  ctx.drawPath(using: .fillStroke)
}
```

@T(00:20:48)
When we run our app, we get the Point-Free colors on our generative art!

@T(00:21:03)
But we _only_ want these colors to render on Point-Free's anniversary, so in order to add this date-driven logic, we need to add some dependencies to `Environment`.

@T(00:21:19)
We need to add the date and calendar as dependencies.

```swift
struct Environment {
  var calendar = Calendar.current
  var date = { Date() }
  var rng = AnyRandomNumberGenerator(
    rng: SystemRandomNumberGenerator()
  )
}
```

And throughout our application, we should be calling to these dependencies rather than the singletons we're used to.

@T(00:22:20)
Now we can cook up a helper that determines if it's Point-Free's anniversary or not.

```swift
extension Date {
  var isPointFreeAnniversary: Bool {
    let components = Current.calendar.dateComponents(
      [.day, .month], from: self
    )
    return components.day == 29 && components.month == 1
  }
}
```

@T(00:22:36)
Now we need to feed this information to our artwork generator. We can introduce a new argument, `isPointFreeAnniversary` to do just that.

```swift
func image(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat,
  isPointFreeAnniversary: Bool
) -> Gen<UIImage> {
```

@T(00:22:50)
And with this we can make sure we only render the Point-Free colors on this day.

```swift
if isPointFreeAnniversary {
  ctx.setStrokeColor(
    pointFreeColors[pointFreeColors.count * idx / paths.count]
      .cgColor
  )
}
```

@T(00:23:00)
In the view controller, we need to pass this in by using the `Current` environment.

```swift
func setImage() {
  // var rng = SystemRandomNumberGenerator()
  let newImage = image(
    amplitude: CGFloat(self.amplitude),
    center: CGFloat(self.center),
    plateauSize: CGFloat(self.plateauSize),
    curveSize: CGFloat(self.curveSize),
    isPointFreeAnniversary: Current.date().isPointFreeAnniversary
    ).run(using: &Current.rng)
  self.imageView.image = newImage
}
```

@T(00:23:23)
Things build and run, and we no longer see the Point-Free colors because today's date is not January 29. But just to make sure things are working, we can fake it for a moment by mutating `Current` to always return the right date.

```swift
func setImage() {
  Current.date = { Date.init(timeIntervalSince1970: 1517202000) }
  // var rng = SystemRandomNumberGenerator()
  let newImage = image(
    amplitude: CGFloat(self.amplitude),
    center: CGFloat(self.center),
    plateauSize: CGFloat(self.plateauSize),
    curveSize: CGFloat(self.curveSize),
    isPointFreeAnniversary: Current.date().isPointFreeAnniversary
    ).run(using: &Current.rng)
  self.imageView.image = newImage
}
```

@T(00:23:54)
And when we run things, we get the bright colors, as expected.

@T(00:24:10)
Before we can run our tests, we need to update our mock environment to account for our new dependencies with some constants that we control.

```swift
extension Environment {
  static let mock = Environment(
    calendar: Calendar(identifier: .gregorian),
    date: { Date.init(timeIntervalSince1970: 1234567890) },
    rng: AnyRandomNumberGenerator(rng: LCRNG(seed: 1))
  )
}
```

@T(00:24:48)
With our mock dependencies in place, we can run our tests and they still pass! Even though we added a bunch of new logic to our drawing logic, our snapshot reference ensured that we didn't break anything.

@T(00:25:11)
So let's write a new test that tests our generative art on the Point-Free anniversary. We'll use the existing anniversary and add a year.

```swift
func testJoy_PointFreeAnniversary() {
  Current.date = {
    Date.init(timeIntervalSince1970: 1517202000 + 60*60*24*365)
  }
  let vc = ViewController()
  assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
}
```

@T(00:25:46)
When we run it, it records a brand new reference, this time with Point-Free's colors! And if we re-run this test, it passes.

## Conclusion

@T(00:26:06)
We've now fully controlled the date and calendar and were able to add pretty complicated logic to our app and test it!

@T(00:26:51)
It's been a lot of fun playing with the `Gen` type and showing how one may use it and control it in an app, but we haven't open sourced it...yet! Next week we'll be shipping a polished version of the `Gen` type and we can't wait to see what our viewers come up with!
