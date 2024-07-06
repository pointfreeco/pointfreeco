> Preamble: Let's create a type-safe interface for dealing with seconds and milliseconds in our
> programs. We'll use the `Tagged` type, which allows us to construct all new types in a lightweight
> way.

![](https://d1iqsrac68iyd8.cloudfront.net/posts/0006-tagged-seconds-and-milliseconds/poster.jpg)

The [Tagged](https://github.com/pointfreeco/swift-tagged) type is a powerful way of creating new
types in a very lightweight way. It's a small package that leverages many advanced features of
Swift, including generics, generic type aliases, phantom types and conditional conformance. We've
[previously](https://www.pointfree.co/episodes/ep12-tagged) explored ways of using `Tagged` to
strengthen our types by better documenting their intentions and making accidental misuse of the
types provably impossible by the compiler.

In this [Point-Free Pointer](/blog) we will show another application: building a type-safe
abstraction for dealing with seconds and milliseconds.

## Using time in your models

It is very common to have measurements of time in your models. For example, a blog post model might
have fields for the id, title and time of publishing:

```swift
struct BlogPost: Decodable {
  typealias ID = Tagged<BlogPost, Int>

  let id: ID
  var publishedAt: Double
  var title: String
}
```

We've already made this type a little bit safer by defining a type alias `Blog.Id`, which makes a
blog post's `id` field completely different from any other `Int` in the eyes of the compiler. The
`Tagged` type made this very easy to do, and with the help of Swift's conditional conformances we
were able to make `BlogPost` decodable without any additional work.

However, the `publishedAt` field seems a little unsafe. I happen to know for a fact that this time
comes back from the API measured in seconds, but others on my team or future contributors may not
know this. And it's pretty common for APIs to send back milliseconds, so someone could easily get
this confused at some point. Worse, this `publishedAt` value might be extracted from a blog post and
then passed through a few layers of functions, so by the time I come across this value I may not
even know where it came from!

One approach to fixing this would be to rename the field to something more descriptive, like
`publishedAtInSeconds`, but now you have accidentally broken JSON decoding since the field name
won't match. This means you have to implement a custom decode initializer, which can be a pain, but
more importantly you could still misuse this type by comparing it to something measured in
milliseconds. The compiler isn't able to help you at all.

## Tagging time

Let's strengthen this field by using `Tagged`. The simplest thing would be to create two new types
that tag `Double` with two different tags:

```swift
enum SecondsTag {}
typealias Seconds = Tagged<SecondsTag, Double>

enum MillisecondsTag {}
typealias Milliseconds = Tagged<MillisecondsTag, Double>
```

We can now change our model to be more expressive in what the `publishedAt` field represents:

```swift
struct BlogPost: Decodable {
  typealias ID = Tagged<Self, Int>

  let id: ID
  var publishedAt: Seconds
  var title: String
}
```

Since `Double` is `Decodable`, the `BlogPost` type remains decodable with no other changes.

Also, `Tagged` conforms to most of the standard protocols that the raw type does (like `Numeric` and
`Comparable`), so we get to treat `publishedAt` as a plain `Double` most of the time:

```swift
// Embargo time is 1 hr before post is published
let embargoLiftedAt = breakingBlogPost.publishedAt - 60 * 60

// Sort blog posts by `publishedAt`
blogPosts.sorted { $0.publishedAt < $1.publishedAt }
```

Further, the compiler can prevent us from accidentally misusing time by, say, comparing a seconds
value to a milliseconds value:

```swift:3:fail
let futureTime: Milliseconds = 1_528_378_451_000

breakingBlogPost.publishedAt < futureTime
```

> Error: Binary operator '&lt;' cannot be applied to operands of type
> 'Tagged&lt;SecondsTag, Double>' and 'Tagged&lt;MillisecondsTag, Double>'

The compiler caught a serious bug here! Since milliseconds are much larger numbers than seconds,
this comparison would have always returned true, which could have led us to release this blog post
sooner than we expected. But instead, the compiler stopped us and made us fix the problem. This
means we don't have to remember which fields are measured in seconds and which fields are in
milliseconds. The compiler has all that information and will keep us in check!

This is incredibly powerful. We have given ourselves the ability to strengthen all uses of time in
our application with only 4 lines of code: 2 tag types and 2 type aliases. However, we can improve
it even more.

## Generalizing Tagged Time

We tagged `Double` for both the seconds and milliseconds types, but that may have been too specific.
What if we know the `publishedAt` always comes back as an integer measure of seconds. Luckily we can
leverage generic type aliases in Swift to express that:

```swift
enum MillisecondsTag {}
typealias Milliseconds<RawValue> =
  Tagged<MillisecondsTag, RawValue>

enum SecondsTag {}
typealias Seconds<RawValue> =
  Tagged<SecondsTag, RawValue>
```

Now we get to differentiate between `Seconds<Int>` and `Seconds<Double>`:

```swift
struct BlogPost: Decodable {
  typealias ID = Tagged<Self, Int>

  let id: ID
  var publishedAt: Seconds<Int>
  var title: String
}
```

The blog post model is really started to document itself just in the types!

## Converting time

It might also be nice to be able to convert freely between these two types, for example converting
seconds to milliseconds is only a matter of multiplying by 1,000. However, in order to allow
multiplication we need to know that our raw value is at least `Numeric`. This is easy enough to do
with a conditional extension of `Tagged`:

```swift
extension Tagged
where Tag == SecondsTag, RawValue: Numeric {
  var milliseconds: Milliseconds<RawValue> {
    Self(rawValue: self.rawValue * 1000)
  }
}
```

Now we can to do this:

```swift
let seconds: Seconds<Int> = 4
seconds.milliseconds  // 4000: Milliseconds<Int>
```

How about the other direction: converting milliseconds to seconds? That involves dividing by 1000,
which you can't do on `Numeric`. This is because we would need to determine how we want to handle
rounding, like converting 500 milliseconds could be either 0 seconds or 1 second. So, in order to
get access to division we need the raw value to conform to `BinaryFloatingPoint`:

```swift
extension Tagged
where Tag == MillisecondsTag, RawValue: BinaryFloatingPoint {
  var seconds: Seconds<RawValue> {
    Self(rawValue: self.rawValue / 1000)
  }
}
```

And now we get to do:

```swift
let millis: Milliseconds<Double> = 5500
millis.seconds  // 5.5: Seconds<Double>
```

More importantly, you are not allowed to perform a potentially lossy conversion:

```swift:2:fail
let millis: Milliseconds<Int> = 500
millis.seconds
```

> Error: type 'Int' does not conform to protocol 'BinaryFloatingPoint'

In order to perform these kinds of conversions you must be explicit in what you intend to happen. If
you do not want to lose information then you must lift your tagged value up into a world that
understands division. In particular, we could first `map` on the tagged milliseconds to make it a
`Double` value, and then everything goes smoothly:

```swift
let millis: Milliseconds<Int> = 500
millis.map(Double.init).seconds  // 0.5: Seconds<Double>
```

If losing information is acceptable, then you must `map` twice: once to lift to a world with
division, and again to lower back to the world you want to be in. For example:

```swift
let millis: Milliseconds<Int> = 500
millis
  .map(Double.init)  // 500.0: Milliseconds<Double>
  .seconds           // 0.5: Seconds<Double>
  .map(Int.init)     // 0: Seconds<Int>
```

We lost some information in this transformation, but at least we were very explicit with what we
intended to do.

## Conclusion

We have built a 14 line nano-library in order to increase the safety and expressiveness of time in
our applications. The `Tagged` library was the real workhorse, so let's take a moment to appreciate
just how easy this was to accomplish:

```swift
enum MillisecondsTag {}
typealias Milliseconds<RawValue> =
  Tagged<MillisecondsTag, RawValue>

enum SecondsTag {}
typealias Seconds<RawValue> =
  Tagged<SecondsTag, RawValue>

extension Tagged
where Tag == SecondsTag, RawValue: Numeric {
  var milliseconds: Milliseconds<RawValue> {
    Self(rawValue: rawValue * 1000)
  }
}

extension Tagged
where Tag == MillisecondsTag, RawValue: BinaryFloatingPoint {
  var seconds: Seconds<RawValue> {
    Self(rawValue: rawValue / 1000)
  }
}
```

This is just one small, but powerful example of how we can encode additional meaning in our
application's types, preventing bugs at compile time, and _improving_ the ergonomics of how we work
with these types in our everyday code. We'll continue to explore `Tagged` in other interesting ways
in future posts!
