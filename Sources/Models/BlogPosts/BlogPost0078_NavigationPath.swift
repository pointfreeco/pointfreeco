import Foundation

public let post0078_NavigationPath = BlogPost(
  author: .pointfree,
  blurb: #"""
    Learn how to use Swift 5.7's new existential type super powers to encode and decode type-erased values.
    """#,
  contentBlocks: [
    .init(
      content: ###"""
        iOS 16 introduced brand new navigation tools that aim to model stack-based navigation with simple collection-based APIs. One of those tools is [`NavigationPath`][navigation-path-docs], which is a fully type-erased collection of data that allows you to drive navigation with state without coupling unrelated views together.

        An interesting feature of `NavigationPath` is that it is capable of encoding and decoding itself to JSON, even though all of its type information has been erased. This is powerful because it makes state restoration as simple as serializing and deserializing data, but how does it work?

        Join us for a deep dive into some of Swift's hidden runtime functions and Swift 5.7's new existential tools so that we can reverse engineer `NavigationPath`'s codability. A compilable [gist][gist] is available to following along too.

        ## NavigationPath codability

        `NavigationPath` is a collection-like type of fully type-erased data that exposes a few simple methods. You create one without specifying what kind of data it holds:

        ```swift
        var path = NavigationPath()
        ```

        And you are free to add any data you want to the path, as long as it is `Hashable`:

        ```swift
        path.append("hello")
        path.append(42)
        path.append(true)
        ```

        You can even append custom data types:

        ```swift
        struct User: Hashable {
          var id: Int
          var name: String
        }

        path.append(User(id: 42, name: "Blob"))
        ```

        Although `NavigationPath` exposes some collection-like methods, such as `append`, `remove` and `count`, it does not allow you to actually iterate over its elements. This may be just an oversight right now (we've filed a [feedback][navigation-path-feedback]!), but even if its elements were exposed they would be given to us as `any Hashable` values. That is, they have lost all of their type information except for the fact that they are `Hashable`.

        However, even though all of the type information has been erased, `NavigationPath` has the magical ability to encode its data to JSON, and even more magically, decode back into a fully-formed `NavigationPath` with data and static types intact!

        This is done by accessing the `codable` property on `NavigationPath`, which returns an optional value:

        ```swift
        path.codable // nil
        ```

        Currently this value is `nil` because the `User` struct we defined earlier does not conform to `Codable`, and a warning is even printed in the logs explaining as such:

        > `Cannot create CodableRepresentation of navigation path, because presented value of type "User" is not Codable.`

        `NavigationPath` requires that everything you append to it be `Codable` in order for its magic trick to work. So, let's make the `User` struct `Codable`:

        ```swift
        struct User: Codable, Hashable {
          …
        }
        ```

        Now `codable` returns something non-`nil` called `CodableRepresentation`:

        ```swift
        path.codable // NavigationPath.CodableRepresentation
        ```

        This is the thing that you can actually feed to a `JSONEncoder` to turn into JSON data:

        ```swift
        try JSONEncoder().encode(path.codable!) // 120 bytes
        ```

        And we can feed this data to a `String` initializer to see the actual JSON string representation:

        ```swift
        print(
          String(
            decoding: try JSONEncoder().encode(path.codable!),
            as: UTF8.self
          )
        )
        ```

        <blockquote>
        <pre>
        [
          "User",
          "{\"id\":42,\"name\":\"Blob\"}",
          "Swift.Bool",
          "true",
          "Swift.Int",
          "42",
          "Swift.String",
          "\"hello\""
        ]
        </pre>
        </blockquote>

        Every piece of data we added to the path was serialized into a flat array containing both a string representation of the name of the type and a string representation of its JSON. For example, our `User` value was serialized into a pair of array elements for the type name and the JSON of the id and name:

        <blockquote>
        <pre>
        "User",
        "{\"id\":42,\"name\":\"Blob\"}",
        </pre>
        </blockquote>

        It's interesting that even though `NavigationPath` has no type information about the elements it holds, it can still somehow detect when the element conforms to `Encodable` and encode it.

        Even more interesting, it can do the opposite!

        It can somehow take the nebulous blob of text and turn it back into statically typed values, such as honest strings, ints, bools and even the `User` struct. That seems a quite magical.

        To see this concretely we can take the nebulous JSON string of data and turn it back into a navigation path:

        ```swift
        let decodedPath = try NavigationPath(
          JSONDecoder().decode(
            NavigationPath.CodableRepresentation.self,
            from: Data(
              #"""
              [
                "User","{\"id\":42,\"name\":\"Blob\"}",
                "Swift.Bool","true",
                "Swift.Int","123",
                "Swift.String","\"Hello\""
              ]
              """#.utf8
            )
          )
        )
        ```

        It's pretty incredible this is possible. We can take this newly formed path, stick it into a `NavigationStack`, and then the actual, statically typed values will be passed to `navigationDestination` so that we can construct views for each destination:

        ```swift
        List {
          …
        }
        .navigationDestination(for: String.self) { string in
          Text("String view: \(string)")
        }
        .navigationDestination(for: Int.self) { int in
          Text("Int view: \(int)")
        }
        .navigationDestination(for: Bool.self) { bool in
          Text("Bool view: \(String(describing: bool))")
        }
        .navigationDestination(for: User.self) { user in
          Text("User view: \(String(describing: user))")
        }
        ```

        ## Encoding and decoding `Any`

        Is it possible to recreate this seemingly magical functionality ourselves? Can we really take a nebulous blob of stringy JSON and turn it into values with static types? Well, the answer is yes, by using a little bit of runtime magic and Swift's new existential super powers.

        Let's start with a simple wrapper around an array of fully type-erased `Any` values, as well as a method for appending an `Any` to the end of the array:

        ```swift
        struct NavPath {
          var elements: [Any] = []

          mutating func append(_ newElement: Any) {
            self.elements.append(newElement)
          }
        }
        ```

        What would it take to implement an `Encodable` conformance on this type so that it encodes as a flat array of strings that alternate between a description of a type and the JSON encoding of a value:

        ```swift
        extension NavPath: Encodable {
          func encode(to encoder: Encoder) throws {
            // ???
          }
        }
        ```

        We can start with an unkeyed container since we want to encode to an array:

        ```swift
        func encode(to encoder: Encoder) throws {
          var container = encoder.unkeyedContainer()
        }
        ```

        And we can iterate over the elements of the path, but in reverse because for whatever reason `NavigationPath` encodes its elements in reverse order:

        ```swift
        func encode(to encoder: Encoder) throws {
          var container = encoder.unkeyedContainer()
          for element in elements.reversed() {
          }
        }
        ```

        For each element in the array we need to first encode the name of the type, and then encode its JSON representation as a string.

        We can use an underscored Swift [function][_mangledTypeName-source] that is capable of turning a type into a string. Although `element` is a fully erased `Any` value, we can get its runtime type using the `type(of:)` function, and then encode its string name:

        ```swift
        try container.encode(_mangledTypeName(type(of: element)))
        ```

        Next we want to try to encode the element into a JSON string. First we need to check if the element is `Encodable` to begin with, which we can do easily thanks to Swift's new powerful existential type features:

        ```swift
        guard let element = element as? any Encodable
        else {
          throw EncodingError.invalidValue(
            element, .init(
              codingPath: container.codingPath,
              debugDescription: "\(type(of: element)) is not encodable."
            )
          )
        }
        ```

        If we get past this guard, then we can encode the element into a JSON string, and then encode that into our container:

        ```swift
        try container.encode(
          String(decoding: JSONEncoder().encode(element), as: UTF8.self)
        )
        ```

        This completes the `Encodable` conformance for `NavPath`, and amazingly it works just like `NavigationPath`'s conformance:

        ```swift
        var path = NavPath()
        path.append("Hello")
        path.append(42)
        path.append(true)
        path.append(User(id: 42, name: "Blob"))
        let data = try JSONEncoder().encode(path)
        print(String(decoding: data, as: UTF8.self))
        ```

        <blockquote>
        <pre>
        [
          "11nav_codable4UserV",
          "{\"id\":42,\"name\":\"Blob\"}",
          "Sb",
          "true",
          "Si",
          "42",
          "SS",
          "\"Hello\""
        ]
        </pre>
        </blockquote>

        We are able to encode all the values even though we are storing them as fully type-erased `Any` values internally.

        And if we try appending something that is not `Encodable`, like say `Void`:

        ```swift
        path.append(())
        ```

        Then we get an encoding error letting us know exactly what went wrong:

        <blockquote>
        <code>
        invalidValue((), Context(codingPath: [], debugDescription: <strong>"() is not encodable."</strong>, underlyingError: nil))
        </code>
        </blockquote>

        We are halfway towards our goal of reverse engineering `NavigationPath`. Next we need to make `NavPath` conform to the `Decodable` protocol:

        ```swift
        extension NavPath: Decodable {
          init(from decoder: Decoder) throws {
            // ???
          }
        }
        ```

        We can start by getting an unkeyed container since we are trying to decode a flat array of strings, and we will start the path's elements off as an empty array:

        ```swift
        init(from decoder: Decoder) throws {
          var container = try decoder.unkeyedContainer()
          self.elements = []
        }
        ```

        We can iterate over the unkeyed container while it still has elements to process:

        ```swift
        while !container.isAtEnd {
        }
        ```

        In here we can try decoding a string from the container, which should be the name of the type that we want to decode:

        ```swift
        let typeName = try container.decode(String.self)
        ```

        Just as there is an underscored Swift function for turning a type into a string, there is also [one][_typeByName-source] that goes in the reverse direction, but it is failable because the string may not represent a type known to Swift:

        ```swift
        let typeName = try container.decode(String.self)
        guard let type = _typeByName(typeName)
        else {
        }
        ```

        But we don't want to allow just any type here. We only want to consider those types that are `Decodable`, and if we encounter a non-`Decodable` type it is a decoding error. We can do this by once again using Swift's powerful existential type features by casting the `Any.Type` given to us by `_typeByName` into an `any Decodable.Type`:

        ```swift
        let typeName = try container.decode(String.self)
        guard let type = _typeByName(typeName) as? any Decodable.Type
        else {
          throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "\(typeName) is not decodable."
          )
        }
        ```

        If we get past this guard it means that the type is `Decodable`, so we can get the next string in the container, try decoding it, and then insert it at the beginning of the `elements` array since encoding was reversed:

        ```swift
        let encodedValue = try container.decode(String.self)
        let value = try JSONDecoder().decode(type, from: Data(encodedValue.utf8))
        self.elements.insert(value, at: 0)
        ```

        This completes the second half of reverse engineering `NavigationPath`. We can now decode nebulous JSON data back into `NavPath`:

        ```swift
        var path = NavPath()
        path.append(1)
        path.append("Hello")
        path.append(true)
        path.append(User(id: 42, name: "Blob"))

        let data = try JSONEncoder().encode(path)
        let decodedPath = try JSONDecoder().decode(NavPath.self, from: data)
        print(decodedPath)
        ```

        > `NavPath(elements: [1, "Hello", true, User(id: 42, name: "Blob")])`

        And we can verify that all of the type information is retained because we can cast each element in the path to the type we expect:

        ```swift
        decodedPath.elements[0] as! Int    // 1
        decodedPath.elements[1] as! String // "Hello"
        decodedPath.elements[2] as! Bool   // true
        decodedPath.elements[3] as! User   // User(id: 42, name: "Blob")
        ```

        From a string that holds onto a heterogenous array of types we were able to build up an array of `Any` values that still retain their static types if we cast them.

        ## Pre-Swift 5.7 existentials

        All of the above was accomplished in just a few lines of code thanks to Swift 5.7's greatly improved ability to handle existential types in an ergonomic way. If you are curious how we could have reverse engineered `NavigationPath` without those tools...

        <details>
        <summary>
        Follow us down the rabbit hole of pre-Swift 5.7 existentials... 🐰🕳
        </summary>

        If we try to compile the current code in Swift 5.6 we get an error on the following line:

        ```swift
        let string = try String(
          decoding: JSONEncoder().encode(element),
          as: UTF8.self
        )
        ```

        > 🛑 Protocol 'Encodable' as a type cannot conform to the protocol itself

        This is because `element` is of type `any Encodable`, not a concrete type that conforms to the `Encodable` protocol. When you write:

        ```swift
        let value: any Encodable = 1
        ```

        ...you are simultaneously doing two things: first you are choosing a particular type in the infinite expanse of all types that conform to the `Encodable` protocol, and then you are choosing a value in that type. This is different enough from concrete types, where you simply write:

        ```swift
        let value: Int = 1
        ```

        ...that it warrants a different type of syntax, `any Encodable`, and a different name, "existential type".

        In 5.7, Swift is capable of seamlessly translating from the existential type to the concrete type, but in Swift <5.7 we have to do a little bit of extra work.

        Although `element` is partially erased to just an `any Encodable`, we can still access its dynamic runtime type with [`type(of:)`][typeof-docs]. What if we could "peek" into the dynamic type of `value` and turn it into a static type `A`:

        ```swift
        peek(type(of: element)) { <A: Encodable> in
        }
        ```

        Here we using a theoretical `peek` function to peek into the dynamic type `type(of: value)` to get an actual static type `A`.

        Now this doesn't work because closures can't introduce generics in Swift. But, we can define a little local function that is capable of introducing generics:

        ```swift
        func encode<A: Encodable>(_: A.Type) {}
        peek(type(of: value), do: encode)
        ```

        Then we could perform the encoding logic inside the helper function with the generic:

        ```swift
        func encode<A: Encodable>(_: A.Type) throws -> Data {
          try JSONEncoder().encode(element as! A)
        }
        let data = try peek(type(of: value), do: encode)
        ```

        This is all still theoretical, but if this was possible we have somehow magically turned a dynamic type into a static type, albeit in a roundabout way.

        Well, this theoretical tool does exist in pre-Swift 5.7, though it is underscored and has a strange name:

        ```swift
        func encode<A: Encodable>(_: A.Type) throws -> Data {
          try JSONEncoder().encode(element as! A)
        }
        let data = try _openExistential(type(of: value), do: encode)
        ```

        This function allows us to peek into an `Any` type and get access to the actual static type of the underlying value. It's underscored because the Swift team would rather have a nicer syntax for capturing its functionality, and that is precisely what Swift 5.7's new existential tools brings to the table.

        The name is called [`_openExistential`][openexistential-source] because its job is to take a peek inside a type that we know nothing about in order to figure out its actual static type. The term "existential" is borrowed from predicate logic in mathematics, and if you want to know more how the mathematics is connected to the types, checkout [this week's][episode-0196] episode.

        We can now finish the encoding by turning the data into a string and encoding that into the container:

        ```swift
        func encode<A: Encodable>(_: A.Type) throws -> Data {
          try JSONEncoder().encode(element as! A)
        }
        let data = try _openExistential(type(of: value), do: encode)
        let string = String(decoding: data, as: UTF8.self)
        try container.encode(string)
        ```

        We can even conditionally use Swift 5.7 features using a compiler directive:

        ```swift
        #if swift(<5.7)
          func encode<A: Encodable>(_: A.Type) throws -> Data {
            try JSONEncoder().encode(element as! A)
          }
          let data = try _openExistential(type(of: value), do: encode)
          let string = String(decoding: data, as: UTF8.self)
          try container.encode(string)
        #else
          let string = try String(decoding: JSONEncoder().encode(element), as: UTF8.self)
          try container.encode(string)
        #endif
        ```

        Next, we have the `Decodable` conformance. It currently does not compile in Swift 5.6 due to this line:

        ```swift
        let value = try JSONDecoder().decode(type, from: Data(encodedValue.utf8))
        ```

        > 🛑 Cannot convert value of type 'Decodable.Type' to expected argument type 'Any.Protocol'
        >
        > 🛑 Protocol 'Any' as a type cannot conform to 'Decodable'

        The error messages aren't great, but the problem is the same as what we say for the `Encodable` conformance: Swift 5.6 can't automatically open the existential for us, so we have to do it manually.

        The work is nearly identical to what we did for `Encodable`, and so we will immediately jump to the solution:

        ```swift
        let encodedValue = try container.decode(String.self)
        #if swift(<5.7)
          func decode<A: Decodable>(_: A.Type) throws -> A {
            try JSONDecoder().decode(A.self, from: Data(encodedValue.utf8))
          }
          let value = try _openExistential(type, do: decode)
        #else
          let value = try JSONDecoder().decode(type, from: Data(encodedValue.utf8))
        #endif
        self.elements.insert(value, at: 0)
        ```

        And that is all it takes to support existential codability in Swift 5.6 and lower. It's pretty amazing to see how much more ergonomic existentials are in Swift 5.7.
        </details>

        ## Existential super powers

        It's incredible to see what Swift 5.7's existential types unlock. They allow us to create an interface that for all intents and purposes is dynamic, being an array of `Any` values, while simultaneously being able to pull static type information from it when needed. This allows for building tools that are both flexible and safe, such as `NavigationStack`, which helps decouple domains in a navigation stack while simultaneously retaining type information to pass to destination views.

        In this week's [episode][episode-0196] we explored another application of existential types, wherein we somewhat weaken result types used in the Composable Architecture while not losing the ability to maintain equatability, which is a vital feature for performance and testing in the library. Both of these use cases are only scratching the surface of what is possible with existential types in Swift.

        [episode-0196]: https://www.pointfree.co/episodes/ep196-async-composable-architecture-tasks
        [_mangledTypeName-source]: https://github.com/apple/swift/blob/c8f4b09809de1fab3301c0cfc483986aa6bdecfa/stdlib/public/core/Misc.swift#L87-L94
        [_typeByName-source]: https://github.com/apple/swift/blob/c8f4b09809de1fab3301c0cfc483986aa6bdecfa/stdlib/public/core/Misc.swift#L118-L127
        [navigation-path-docs]: https://developer.apple.com/documentation/swiftui/navigationpath
        [navigation-path-feedback]: https://gist.github.com/mbrandonw/f8b94957031160336cac6898a919cbb7#file-fb10395052-md
        [typeof-docs]: https://developer.apple.com/documentation/swift/type(of:)
        [gist]: https://gist.github.com/mbrandonw/ed5d14b86e263fa6df008329cba74142
        [openexistential-source]: https://github.com/apple/swift/blob/7cd3541c62276f53926bc6d0c9b3970d73dc2ea2/stdlib/public/core/Builtin.swift#L1003-L1016
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 78,
  publishedAt: .init(timeIntervalSince1970: 1_657_602_000),
  title: "Reverse Engineering SwiftUI’s NavigationPath Codability"
)

// TODO: make gist
