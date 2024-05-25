!> [announcement]: We are making our [4-part series "Shared State in Practice"](/collections/composable-architecture/shared-state-in-practice) free for everyone to watch! See how we can use the new `@Shared` property wrapper to massively simplify two different, real world code bases. 

One month ago we [released][shared-state-blog] a powerful set of 
[state sharing][sharing-state-article] tools for the Composable Architecture. The tools allow you to 
share state amongst many features so that when one features makes a change to the state, all other 
features can instantly see those changes. And we even made it possible to persist shared state to 
external systems, such as user defaults, the file system, and potentially more systems such as 
SQLite, etc.

And amazingly we were able to accomplish all of this while still embracing value types as much as 
possible, _and_ allowing us to exhaustively test how shared state changes in our features. If
you are interested in learning how those tools were built you can watch 
[all 9 episodes here][shared-state-collection].

But, if you are first interested in learning how to best _use_ these tools, then today we are excited
to make our [4-part series "Shared State in Practice"][shared-state-in-practice] free for everyone!
In these episodes we analyze two different real world applications, and show how we can delete
hundreds of lines of code and minimize indirection, all thanks to the new `@Shared`
property wrapper.

[shared-state-blog]: /blog/posts/135-shared-state-in-the-composable-architecture
[shared-state-in-practice]: /collections/composable-architecture/shared-state-in-practice
[shared-state-collection]: /collections/composable-architecture/sharing-and-persisting-state
[sharing-state-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/sharingstate

[[Watch now!]](/collections/composable-architecture/shared-state-in-practice)
