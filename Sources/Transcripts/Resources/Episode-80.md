## Introduction

@T(00:00:05)
In the past few weeks we finally uncovered how we want to think about side effects in the architecture that we have been developing ([part 1](/episodes/ep76-effectful-state-management-synchronous-effects), [part 2](/episodes/ep77-effectful-state-management-unidirectional-effects), [part 3](/episodes/ep78-effectful-state-management-asynchronous-effects), [part 4](/episodes/ep79-effectful-state-management-the-point)). It was probably our most requested episode, and what we discovered is that if you want to model your application's architecture in terms of reducers, then a side effect is nothing more than returning a value that encapsulates a unit of work which is then executed by the store. This allows our reducers to be nice and understandable, and delegates the messy execution of effects to the store, where it interprets them at runtime.

@T(00:00:29)
The value that is returned from our reducer was called `Effect`, and it was really just a renaming of a type that we had encountered many times on Point-Free, previously called `Parallel`. It's simply a struct that wraps a function which takes a function as its first argument, sometimes called a "callback", and then just returns void. This allows us to represent a unit of asynchronous work as a value, for example a network request could be represented as an `Effect` value which invokes the callback when a `URLSession` data task finishes. We also saw that this `Effect` type supports a `map` operation, which gives us a lightweight way to transform effects, and we saw that this allowed us to greatly clean up the effectful code in our application.

@T(00:00:56)
However, there was something a little strange about how we ended that series of episodes. There is something in the iOS community, and even directly in the Apple ecosystem, that looks a lot like the `Effect` type. There are many names for this type, but the root idea is sometimes known as "reactive streams", and there are implementations of this idea in many open source libraries, such as [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) and [RxSwift](https://github.com/ReactiveX/RxSwift), and most recently Apple threw their hat into the ring with their [Combine framework](https://developer.apple.com/documentation/combine).

@T(00:01:33)
So in this episode we want to leverage all of that great work from these communities to show how we don't have to maintain our own reactive effect library for our architecture. We truly can replace our `Effect` type with any of these libraries, and things should hum along just fine. But, for the purpose of this episode we need choose one, and we will choose `Combine` for simplicity since we don't need to bring in a dependency. I want to stress that everything that happens in this episode would work equally well for ReactiveSwift and RxSwift, and we highly encourage you to port the reactive library of your choice into the architecture to prove it.

## The Effect type: a quick recap

@T(00:02:18)
Let's begin by exploring the Combine API a bit so that we can see how it compares with the `Effect` type we previously designed.

@T(00:02:29)
We've discussed the shape of the `Effect` type many times on Point-Free, first in our exploration to understand the `map` function, then in trying to understand contravariance, then again when trying to understand the properties of `zip` and `flatMap`, and then yet again when we needed to refactor our snapshot testing library to work with asynchronous values. Most recently we gave this shape the name `Effect`, and here it is in all its glory:

```swift
public struct Effect<A> {
  public let run: (@escaping (A) -> Void) -> Void

  public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    return Effect<B> { callback in
      self.run { a in callback(f(a)) }
    }
  }
}
```

@T(00:02:41)
This is an extremely simple type. It expresses the idea of a type has the power to deliver values to you whenever it wants. This is perfect for asynchrony. For example:

```swift
import Dispatch

let anIntInTwoSeconds = Effect<Int> { callback in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    callback(42)
  }
}
```

@T(00:02:57)
This value represents an integer that can be delivered at a later time, whenever the value wants to be delivered. No work is done immediately. It only does work when we decide to run the value:

```swift
anIntInTwoSeconds.run { int in print(int) }
// 42
```

@T(00:03:31)
And this will print after 2 seconds.

@T(00:03:43)
This property, of not doing work immediately, is known as "laziness". The work is done only when requested. The opposite of this is known as "eager", and there are some small changes we could make to the `Effect` type so that the moment it is created it begins doing its work. This will be an important distinction for us to understand soon.

@T(00:04:08)
`Effect` also supports a `map` operation, which gives us a very simple way to transform the value that is held inside:

```swift
let squared = anIntInTwoSeconds.map { $0 * $0 }
// Effect<Int>
```

@T(00:04:33)
That's the basics of the `Effect` type, but we could say much, much more. For example, this type definitely supports a `zip` operation for running many effects in parallel and then gathering their values together into one value, and it supports a `flatMap` operation, which allows you to sequence asynchronous values together. And we could consider more complex "higher-order effects", which are functions that take effects as input and return effects as output. There are lots of things you can implement with such things, like cancellation and debouncing.

@T(00:05:06)
But, at its core the `Effect` type is quite simple. So, if you are comfortable with that material, then it doesn't take too much work to gain a basic understanding of Combine. Combine is like a supercharged, beefed-up `Effect` on steroids. It expresses everything that the `Effect` type can express, but also a ton more.

## The Combine-Effect Correspondence

@T(00:05:15)
At its root, the Combine framework has two concepts: publishers and subscribers. Publishers are types that can deliver values to anyone who is interested. This is exactly what `Effect` is, but Combine's publishers come with more bells and whistles. Subscribers are types that can receive values. We don't have a name for this concept in our `Effect` type world, but the closest concept is when we invoke the `run` method on an effect in order to make the effect do its work. Combine dedicates a type to the concept subscriber because they support a lot more, including cancellation and demand. Cancellation allows you to stop a subscriber from getting any future values, and demand allows subscribers to communicate to publishers how many values they want to receive.

@T(00:05:48)
That right there is the basic correspondence between Combine and our `Effect` type. When we say "publisher" just think of our `Effect` type, and when we say "subscriber" just think of us hitting `run` on an effect.

## Publishers

@T(00:05:54)
But let's get our hands a little dirtier now and show how to actually create publishers and subscribers, and see how the API relates to our `Effect` type.

@T(00:05:59)
Let's start simple. Over in the effect world we very easily created a value that was delivered after a small delay:

```swift
let anIntInTwoSeconds = Effect<Int> { callback in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    callback(42)
  }
}
```

@T(00:06:03)
How can we accomplish this with Combine? There are high level operators that will do this for us quickly, but let's start from first principles. How can we construct a publisher?

```swift
import Combine

Publisher.init
```

> Error: Protocol 'Publisher' can only be used as a generic constraint because it has Self or associated type requirements

@T(00:06:21)
Well, this brings us to our first lesson when it comes to Combine: most concepts are expressed as protocols rather than concrete types. The `Publisher` type is in fact a protocol, and it even has associated types, and so we won't be dealing directly with the `Publisher` type directly very often.

@T(00:06:47)
Because of this deficiency of protocols with associated types, Combine gives us a concrete implementation of the `Publisher` protocol, called `AnyPublisher`. It is very popular to provide "any" wrappers (also known as "type erased" wrappers) for protocols so that you can easily instantiate instances of the protocol without having to make a custom conformance yourself. So, let's see how we can create an `AnyPublisher`:

```swift
AnyPublisher.init(<#publisher: Publisher#>)
```

@T(00:07:06)
Hmmm, it only has one single initializer, which just takes a publisher. So this doesn't help us right now. We are specifically looking for ways to create publishers without needing to conform a whole new type to the `Publisher` protocol.

@T(00:07:19)
Sometimes when these "any" wrappers are provided there is a way to instantiate them with all the functionality of the underlying protocol.

@T(00:07:32)
For example, the `AnyIterator` wrapper for the `Iterator` protocol gives a simple way to create an iterator by providing a closure that represents computing the next value in an iteration:

```swift
var count = 0
let iterator = AnyIterator<Int>.init {
  count += 1
  return count
}
// AnyIterator<Int>
```

@T(00:07:57)
This represents an iterator that counts from 1 up until infinity, but we can take the first 10 values:

```swift
Array(iterator.prefix(10))
// [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

@T(00:08:17)
Unfortunately, `AnyPublisher` isn't giving us anything nice like this.

@T(00:08:29)
So, what else do we have at our disposal? Combine gives us another concrete implementation of `Publisher` called `Future`, and it comes with a callback-based initializer just like the `Effect` type:

```swift
Future.init(
  <#attemptToFulfill: (@escaping (Result<_, _>) -> Void) -> Void#>
)
```

@T(00:08:43)
This initializer gives you a callback that you can invoke with a result value. A result is used here because a future can either succeed with a value or it can fail. This means we need to specify these types before we can use this initializer. For now, let's just use `Never` for the failure generic to represent a publisher that can never fail:

```swift
Future<Int, Never>.init { callback in
  <#code#>
}
```

@T(00:09:17)
Now we can just invoke this callback once we have some data. For example:

```swift
Future<Int, Never> { callback in
  callback(.success(42))
}
```

@T(00:09:29)
We can also add a delay to our future value to make its delivery later:

```swift
let aFutureInt = Future<Int, Never> { callback in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    callback(.success(42))
  }
}
```

@T(00:09:50)
And so now creating this future value is starting to look a lot like how we created values of our `Effect` type. We just open a closure, we are handed a callback, and then we can invoke that callback with our data whenever we want.

## Subscribers

@T(00:10:22)
To get the value out of this future we have to subscribe. This is analogous to when we `run` our effect values, but instead we can `subscribe`. We have a bunch of choices when subscribing.

@T(00:10:31)
The one we are actually interested in takes a subscriber:

```swift
.subscribe(<#subscriber: Subscriber#>)
```

The others are more about which dispatch queue or run loop the publisher is subscribed on.

@T(00:10:41)
Recall that at its core Combine is primarily concerned with publishers and subscribers. A publisher, like our `Future` value here, is a type that can deliver values to anyone interested, and a subscriber is a type that can receive values. So, providing a `Subscriber` here somehow allows us to receive the value from the future and then do something with that value, like print it. So, how do we create a subscriber?

```swift
Subscriber.init
```

> Error: Protocol 'Subscriber' can only be used as a generic constraint because it has Self or associated type requirements

@T(00:11:08)
Welp, again Combine abstracted this concept to be behind a protocol. And it has associated types. So, we can't really deal with `Subscriber`'s directly.

@T(00:11:19)
But, luckily Combine gives an `AnySubscriber` wrapper type, and unlike `AnyPublisher` it is actually useful for our situation. It has 4 initializers.

@T(00:11:30)
And the first listed here is particularly interesting for us:

```swift
AnySubscriber.init(
  receiveSubscription: <#((Subscription) -> Void)?#>,
  receiveValue: <#((_) -> Subscribers.Demand)?#>,
  receiveCompletion: <#((Subscribers.Completion<_>) -> Void)?#>
)
```

@T(00:11:36)
This allows us to tap into the 3 defining events for a subscription:

@T(00:11:43)
- The moment the subscriber is attached to the publisher, which is represented by the fact that we are handed a `Subscription` object. It's like a receipt for the subscriber being connected. We can use the subscription object to signal how many values we want from the publisher.

@T(00:12:00)
- The moment a publisher delivers a value, which allows us to do something with that value, like print it. It needs to return a `Demand` value, which allows us to tell the publisher how many more values we want from them. This is a powerful feature, especially for publishers that can send a firehose of data, but we don't need this power right now.

@T(00:12:19)
- And finally, the moment the publisher finishes, and it delivers a completion value, which indicates that it either finished successfully or that it finished with a failure.

@T(00:12:29)
So, let's fill in these closures so that we can create our subscription:

```swift
aFutureInt.subscribe(
  AnySubscriber<Int, Never>(
    receiveSubscription: { subscription in
      print("subscription")
      subscription.request(.unlimited)
    },
    receiveValue: { value in
      print("value", value)
      return .unlimited
    },
    receiveCompletion: { completion in
      print("completion", completion)
    }
  )
)
```

@T(00:13:53)
And we can now run it.

```txt
subscription
value 42
completion finished
```

@T(00:14:03)
But also, it seems like a lot, certainly a lot more than just hitting `run` on an effect. But also this is packing a bigger punch. For one it has the concept of demand built in, which is powerful but is also not needed right now. It also has the ability to cancel, which can be done with the `cancel` method on the subscription:

```swift
subscription.cancel()
```

@T(00:14:23)
Again, can be powerful, but we don't exactly need it right now.

@T(00:14:28)
Luckily, there is a more convenient way to subscribe to a publisher for when you don't need the full power of demanding subscribers. There are two methods on publishers called `sink`.

@T(00:14:37)
They allow you to subscribe to a publisher by tapping only into the `receiveValue` and `receiveCompletion` events. You don't get access to the actual subscription and you don't get to control the demand. It assumes unlimited demand.

@T(00:14:49)
It's very easy to use this method, it basically looks just like `run` for effects:

```swift
aFutureInt.sink { int in
  print(int)
}
```

@T(00:15:02)
However, when we do this nothing prints. This is because `sink` actually returns something, whereas `subscribe` did not, and the return value is what allows us to cancel future values from being delivered to our sink. And since we are not holding onto that value it is getting deallocated immediately, and that cancels the subscription.

@T(00:15:23)
The type of the return value is called an `AnyCancellable`, yet another one of those "any" wrappers but this time for the `Cancellable` protocol, and if we hold onto it we will finally get our value delivered after 2 seconds:

```swift
let cancellable = aFutureInt.sink { int
  in print(int)
}
```

@T(00:15:44)
We can even cancel this `cancellable` value to prevent the value from being delivered to our sink:

```swift
cancellable.cancel()
```

@T(00:15:52)
And now this is starting to look a lot more similar to what we do when we run effects. We can just invoke one method and we get the ability to tap into any value that is delivered from the publisher. It's worth noting that the playground has some implicit behavior here that is keeping this `cancellable` value alive for a long time, which is what allows our value to be delivered. In a real application you would need to hold onto this value yourself, like stored in the instance variable of a view controller or something.

## Eagerness vs. laziness

@T(00:16:18)
We're starting to see the correspondence between the `Effect` type and the Combine framework, which might lead us to believe that we could relieve our old pal `Effect` from their duties in our architecture and instead start leaning on the Combine framework more. Maybe we just replace all instances of `Effect`  with `Future` and all instances of `run` with `sink`.

@T(00:16:34)
Unfortunately, this isn't quite true right now. There is a subtle problem with our code right now, so let's address that.

@T(00:16:51)
To see the first problem, let's add a print statement inside our future:

```swift
let aFutureInt = Future<Int, Never> { callback in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    print("Hello from inside the future!")
    callback(.success(42))
  }
}
```

@T(00:16:59)
If we run this code we get a print statement even though the future was cancelled.

@T(00:17:07)
We can even comment the entire sink out.

```swift
// let cancellable = aFutureInt.sink { int in
//   print(int)
// }
// cancellable.cancel()
```

@T(00:17:14)
We still get the print statement, even though no one even references the future anymore.

@T(00:17:21)
This is happening because the `Future` type is eager, which means that it starts doing its work the moment its created, not when it is subscribed to.

@T(00:17:30)
This is a pretty big gotcha, and certainly not something we want in our reducers. The beauty of our reducers is that they are pure functions for changing the current state of the application given some user action, and then they returned an array of effects that would be later run by the store. If instead we used these `Future` types then we would start executing this the moment the reducer is invoked. This would be especially surprising in a test if we wanted to just test how a reducer changes some state, but secretly behind the scenes effects are firing off!

@T(00:18:08)
Luckily there's a pretty easy way to turn an eager publisher into a lazy one in Combine. We can simply wrap it in a `Deferred` publisher, which has an initializer that takes a closure that returns a publisher:

```swift
let aFutureInt = Deferred {
  Future<Int, Never> { callback in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      print("Hello from inside the future!")
      callback(.success(42))
    }
  }
}
```

@T(00:18:26)
This makes it so that the future does not run immediately, but if we create a sink it will fire up:

```swift
let cancellable = aFutureInt.sink { int in
  print(int)
}
```

@T(00:18:39)
OK, that fixes the eagerness problem, and also makes for an important lesson when dealing with Combine: sometimes things in Combine are eager, but we never want eager things in our architecture. Luckily there is a nice way to turn eager publishers into lazy publishers, but it would also be nice if Combine's architecture clearly called out publishers that are eager.

## Subjects

@T(00:19:14)
The next problem with our use of `Future` is that it's actually only meant to represent a single value that can be delivered at a later time. It can't deliver multiple values:

```swift
let aFutureInt = Deferred {
  Future<Int, Never> { callback in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      print("Hello from inside the future!")
      callback(.success(42))
      callback(.success(1729))
    }
  }
}
```

@T(00:19:29)
When this runs we only we only get 42 delivered to our sink. Once the `Future` receives a value it instantly completes, and no other values will be emitted.

@T(00:19:44)
And this is `Future`'s intended design. We could definitely have effects that need to deliver multiple values. For example, what if we had an effect that represented a socket connection. We would want all of the values from that socket connection to be delivered to our reducer. We could also have an effect that represents reachability, and each time the reachability state of the app changes we could emit a value so that our reducer can react to those events.

@T(00:20:16)
Our effect type doesn't have this limitation:

```swift
let twoIntsInTwoSeconds = Effect<Int> { callback in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    callback(42)
    callback(1729)
  }
}

twoIntsInTwoSeconds.run { print($0) }
// 42
// 1729
```

@T(00:20:35)
So, although the initializer of `Future` looks a lot like our `Effect` type, it isn't quite the same. It seems that there just is no publisher in the Combine framework that allows you to initialize it with a closure that takes a callback so that you can feed it as many values as you want, whenever you want.

@T(00:20:50)
Fortunately, there's another concept in Combine for when we need the capability of sending multiple values to a publisher, which can in turn notify its subscribers. It's known as a "subject", and it's not a concept that we had to deal with for our simple `Effect` type, but it's very useful for bridging non-Combine worlds to the Combine world.

@T(00:21:09)
Subjects are represented by the `Subject` type, which if we try to initialize:

```swift
Subject.init
```

@T(00:21:14)
`Subject`, like `Publisher` and `Subscriber` is also protocol and so not super useful on its own.

@T(00:21:23)
Luckily Combine comes with two concrete implementations of the `Subject` protocol, called passthrough and current value subjects:

```swift
let passthrough = PassthroughSubject<Int, Never>()
let currentValue = CurrentValueSubject<Int, Never>(value: 1)
```

@T(00:22:01)
The primary difference between these is that with the `CurrentValueSubject` you can access the most recent value that was emitted (which is why we have to provide an explicit value when creating it), whereas values in passthrough subjects can only be accessed by subscribing.

@T(00:22:20)
We can subscribe to a subject just like a publisher, either using the `subscriber` method or the `sink` method, and in order to get this later value we need to hold onto a cancellable so that our subscription stays alive:

```swift
let c1 = passthrough.sink { x in print("passthrough", x) }
let c2 = currentValue.sink { x in print("currentValue", x) }
```

@T(00:22:50)
When we run this, we immediately get a current value, but the passthrough subject remains idle.

```swift
// currentValue 2
```

@T(00:23:02)
And then we can send values directly to the subject, which is generally not possible with publishers:

```swift
passthrough.send(42)
currentValue.send(1729)
// passthrough 42
// currentValue 1729
```

@T(00:23:27)
We're free to send as many values as we want, unlike the `Future` type.

```swift
passthrough.send(42)
currentValue.send(1729)
passthrough.send(42)
currentValue.send(1729)
// passthrough 42
// currentValue 1729
// passthrough 42
// currentValue 1729
```

@T(00:23:36)
This certainly isn't as easy as it was for the `Effect` type, but nonetheless Combine does give us the ability to create a publisher that we can send many values so that it publishes those values to its subscribers.

## Next time: refactoring the architecture

@T(00:23:48)
So that's the basics of the Combine framework. There is a ton more to say, but we've learned just enough to be dangerous. And we've learned the correspondence between Combine and the Effect type.

@T(00:24:03)
To recap: in the Combine world we have publishers and in the Effect world we have `Effect`, and in the Combine world we have subscribers, and in the Effect world we have `run`. Luckily, Combine comes with a bunch of bells and whistles, though, like `sink`, which works just like `run` on `Effect`. And further, Combine comes with `Future`, which are created a lot like `Effect`s, but with the caveats that they are eager and need to be wrapped in a `Deferred` publisher, and that they can only receive a single value, which means we must use another Combine concept, subjects, to simply set up more long-living event streams.

@T(00:24:46)
That's the basic correspondence, so the question is can we refactor the Composable Architecture that we have been building to leverage Combine's functionality rather than building it ourselves from scratch?

@T(00:24:58)
Let's refactor away the `Effect` type so that we can leverage Combine and avoid reinventing the wheel...next time!
