Swift 5.5 brought first class support for concurrency to the language, including lightweight syntax
for describing when functions and methods need to perform async work, a new data type for
isolating mutable data, and all new APIs for performing non-block asynchronous work. This made it
far easier to write async code than ever before, but it also made testing asynchronous code quite
a bit more complicated.

Join us for a quick overview of what tools Swift gives us today for testing asynchronous code, as
well as examples of how these tools can fall short and how to fix them.

## Async testing tools of today

The primary tool for testing async code today is XCTest's support for async test cases. Simply mark
your test method as `async` and then you are free to perform any async work you want:

```swift
class FeatureTests: XCTestCase {
  func testBasics() async {
    …
  }
}
```

This makes it easy to invoke an async function or method and then assert on what changed after.

For example, suppose you have a feature that shows a list of users, and when the view appears you
load the users first from a local database, which is quite fast, and then from a network API, which
provides fresher data but is also considerably slower. Further, once the fresh users are loaded it
will save that fresh data back to the local database:

```swift
class UsersModel: ObservableObject {
  let api: any APIClient
  let database: any DatabaseClient
  @Published var users: [User] = []

  @MainActor
  func onAppear() async throws {
    self.users = self.database.fetchUsers()
    self.users = try await self.api.fetchUsers()
    self.database.saveUsers(self.users)
  }
}
```

That's quite simple behavior for right now, but in the future it can become a lot more complex. We
may start to track analytics events in this method, we may perform custom error handling, or we may
open a socket connection to get a live stream of user updates from the server.

So, we are going to want to get some test coverage on this method in order to get a better
understanding of its complexities in the future. Luckily it is quite straightforward to test. We can
simply create the model with some mock dependencies, invoke the `onAppear` method, and then assert
on how the model changed after:

```swift
class FeatureTests: XCTestCase {
  func testBasics() async {
    let model = UsersModel(
      api: MockAPIClient(fetchUsers: { [User(name: "Blob")] }),
      database: MockDatabaseClient()
    )

    await model.onAppear()
    XCTAssertEqual(
      model.users,
      [User(name: "Blob")]
    )
  }
}
```

With a little more work we could assert on more, such as confirming that the fresh data was indeed
saved to the database.

So, this is really great. The fact that an `XCTestCase`'s methods can be `async` is incredibly
useful for testing asynchronous code.

## The problem with today's tools

However, an async test method is not sufficient for testing all of the kinds of asynchronous code
one can write. It falls short when needing to assert on what happens between the suspension points,
such as verifying that the cached data is first fetched, as well as testing long living effects,
which is common with async sequences. Let's look at each of these problems individually.



```swift
class FeatureTests: XCTestCase {
  func testBasics() async {
    let (stream, continuation) = AsyncStream.makeStream(of: [User].self)

    let model = UsersModel(
      api: MockAPIClient(
        fetchUsers: { await stream.first(where: { _ in true })! }
      ),
      database: MockDatabaseClient(
        fetchUsers: { [User(name: "Blob")] }
      )
    )

    await model.onAppear()
    XCTAssertEqual(
      model.users,
      [User(name: "Blob")]
    )
  }
}
```

## Serial execution for tests

## Testing reality

## Try it yourself
