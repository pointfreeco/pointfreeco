@Video(
  poster: "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/poster.jpg",
  source:
  "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/hls-playlist.m3u8"
)

In our episode on [algebraic data types](/episodes/ep4-algebraic-data-types) we
showed how there is algebra lurking in the Swift type system, and then used that knowledge to refactor
our data types so that the invalid states are unrepresentable by the compiler. You simply were not
allowed to construct invalid values, and it was proven to us by the compiler!

In today's [Point-Free Pointer](/blog) we are going to apply this to a real world
problem. In fact, we are going to analyze a [data type](https://github.com/pointfreeco/pointfreeco/blob/c3a03fda2817418cc74d66da6c21e3fede0574f7/Sources/PointFree/Episode/Show.swift#L841-L854)
that I made for a feature on this very site. I
did it completely wrong the first time, and it held lots of values that were just completely
nonsensical. I convinced myself that it wasn't going to be a problem, and just rolled with it for
awhile. But, I kept finding myself adding lil `if let`s here and lil `guard let`s there, until finally
I said enough is enough, it's time to refactor. The amazing part is that I literally used algebra to do
this refactoring, and so today I want to walk you through exactly how I dissected this problem.

## Episode Credits

But first, let me describe the feature I was working on.

While most of our episodes are for members, we wanted to give people the opportunity to see a video
of their choosing for free. All they had to do was sign up for our newsletter, and they would get
a credit that could be used on any members only episode.

Now, when a user is on the episode page, we have this module to call out that folks can become a
member to view our entire series or sign up to get a credit. The messaging in that box depends on
quite a few states.

![](https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/credits-feature.jpg)

It can change depending on whether or not you are logged in, or if you are a member already or not,
or if you've already used your credit for this episode, and finally if this episode is free to the
public or members only. Naively this would be `2^4 = 16` states, many of which don't make any sense.
Like, you can't be logged out and a member. We want to omit those states, so let's use algebra!

## First Attempt

Here is what I first started with:

```swift
struct EpisodePermission {
  let hasUsedCredit: Bool
  let isLoggedIn: Bool
  let isMember: Bool
  let isMembersOnly: Bool
}
```

It's just a simple struct with four fields of `Bool` values for each of the conditions that can
affect the messaging in the box.

This worked great for awhile. It got me making progress on the feature quickly and it was easy to
understand. But soon I was having to guard against states that I knew were not possible. Let's break
this down algebraically and see if we can whittle away the invalid states.

## Using Algebra

Here is our type algebraically:

```swift
(Is/Not)LoggedIn
  * (Is/Not)Member
  * (Has/Not)UsedCredit
  * (Is/Not)MembersOnly (16)
```

Our type is a struct, which is a product type, so we have used `*` to denote that we are multplying
the fields together. Written this way it is clear there are 16 states.

Let’s take this one step at a time. I first want to consider what states make sense when the user is
not logged in:

```swift
NotLoggedIn
  * (Is/Not)Member
  * (Has/Not)UsedCredit
  * (Is/Not)MembersOnly (8)
```

There are 8 states because `2 * 2 * 2 = 8`. Which of these are reasonable? Well, you can’t be logged out
and a member. You also can’t be logged out and have used a credit. It _is_ possible to be logged out
and for an episode to be members only, those things are completely independent.

So, we've just eliminated 6 states from the full set of 16:

```swift
// Valid states:
NotLoggedIn * NotMember * NotUsedCredit * (Is/Not)MembersOnly (2)

// Invalid states:
NotLoggedIn * IsMember  * HasUsedCredit * IsMembersOnly  (1)
NotLoggedIn * NotMember * HasUsedCredit * IsMembersOnly  (1)
NotLoggedIn * IsMember  * NotUsedCredit * IsMembersOnly  (1)
NotLoggedIn * IsMember  * HasUsedCredit * NotMembersOnly (1)
NotLoggedIn * NotMember * HasUsedCredit * NotMembersOnly (1)
NotLoggedIn * IsMember  * NotUsedCredit * NotMembersOnly (1)
```

That's pretty nice, with just a lil bit of work we've whittled the 16 states down to 10. But, we haven't even
considered the logged in case yet. Let's look at that:

```swift
LoggedIn
  * (Is/Not)Member
  * (Has/Not)UsedCredit
  * (Is/Not)MembersOnly (8)
```

Now, all of these states are technically possible, but some are redundant when it comes to what we want to
message to the user. For example, If you are a member, it doesn't really matter if you had previously
used a credit on this episode (which you may have done before you became a member), and it doesn't matter
if the episode is member only or not. Let's list them all our so that we can chip away at them one-by-one:

```swift
LoggedIn * IsMember * HasUsedCredit * IsMembersOnly  (1)
LoggedIn * NotMember * HasUsedCredit * IsMembersOnly  (1)
LoggedIn * IsMember * NotUsedCredit * IsMembersOnly  (1)
LoggedIn * NotMember * NotUsedCredit * IsMembersOnly  (1)
LoggedIn * IsMember * HasUsedCredit * NotMembersOnly (1)
LoggedIn * NotMember * HasUsedCredit * NotMembersOnly (1)
LoggedIn * IsMember * NotUsedCredit * NotMembersOnly (1)
LoggedIn * NotMember * NotUsedCredit * NotMembersOnly (1)
```

So, as we just explained, when you are a member all of the other states don't matter. So all states that
have `IsMember` should really just constitute one state:

```swift
LoggedIn
  * IsMember
  * (Has/Not)UsedCredit
  * (Is/Not)MembersOnly (4)
              ⬇️
LoggedIn
  * isMember
  * Void
  * Void                   (1)
```

So we've now gotten rid of 3 invalid states, which means we have just 7 from the original 16.

We still have 4 more states to consider, the case where you are logged in but not a member.

```swift
LoggedIn * NotMember * HasUsedCredit * IsMembersOnly  (1)
LoggedIn * NotMember * NotUsedCredit * IsMembersOnly  (1)
LoggedIn * NotMember * HasUsedCredit * NotMembersOnly (1)
LoggedIn * NotMember * NotUsedCredit * NotMembersOnly (1)
```

There are two states here that are kind of redundant. For example, if you have used a credit to see this particular
episode, then it does not matter if the episode was originally members only or not. In particular these
two states represent just one that we are actually interested in:

```swift
LoggedIn * NotMember * HasUsedCredit * IsMembersOnly  (1)
LoggedIn * NotMember * HasUsedCredit * NotMembersOnly (1)
                               ⬇️
LoggedIn * NotMember * HasUsedCredit * Void              (1)
```

So we have reduced those two states to one, which brings our original 16 down to just 6! A more than 60%
reduction in states! Let's gather all the states we are actually interested in:

```swift
NotLoggedIn * NotMember * NotUsedCredit * (Is/Not)MembersOnly (2)
LoggedIn    * IsMember  * Void          * Void                   (1)
LoggedIn    * NotMember * NotUsedCredit * IsMembersOnly       (1)
LoggedIn    * NotMember * NotUsedCredit * NotMembersOnly      (1)
LoggedIn    * NotMember * HasUsedCredit * Void                   (1)
```

## Translate into Swift

OK, this has been fun, but we've been entirely working in comments and pseudocode. It's now our job to
translate this to a Swift data type. Well, we want the sum of all these states, so I'm thinking at the root
level we want an enum. We can see that it splits first at the question of logged in or not logged in.
So let's start there!

```swift
enum EpisodePermission {
  // LoggedIn    * IsMember  * Void          * Void              (1)
  // LoggedIn    * NotMember * NotUsedCredit * IsMembersOnly  (1)
  // LoggedIn    * NotMember * NotUsedCredit * NotMembersOnly (1)
  // LoggedIn    * NotMember * HasUsedCredit * Void              (1)
  case loggedIn

  // NotLoggedIn * NotMember * NotUsedCredit * (Is/Not)MembersOnly (2)
  case loggedOut
}
```

The `loggedOut` case seems to be the simplest because we don't know anything about member state or credit
state, we only care about whether or not the episode is for members only. So we can fill that in with a
boolean:

```swift
enum EpisodePermission {
  // LoggedIn    * IsMember  * Void          * Void              (1)
  // LoggedIn    * NotMember * NotUsedCredit * IsMembersOnly  (1)
  // LoggedIn    * NotMember * NotUsedCredit * NotMembersOnly (1)
  // LoggedIn    * NotMember * HasUsedCredit * Void              (1)
  case loggedIn

  case loggedOut(isEpisodeMembersOnly: Bool)
}
```

In the `loggedIn` state we can see that we next split on the question of whether or not the user is a
member. Sounds like we can introduce a nested enum for that:

```swift
enum EpisodePermission {
  case loggedIn(memberPermission: MemberPermission)

  enum MemberPermission {
    // LoggedIn * NotMember * NotUsedCredit * IsMembersOnly  (1)
    // LoggedIn * NotMember * NotUsedCredit * NotMembersOnly (1)
    // LoggedIn * NotMember * HasUsedCredit * Void              (1)
    case isNotMember

    // LoggedIn * IsMember * Void * Void (1)
    case isMember
  }

  case loggedOut(isEpisodeMembersOnly: Bool)
}
```

Looks like the `isMember` case is already done, no other data to put there. The `isNotMember` state,
however, has a few more choices in it. Looks like we split on the question of whether or not the user has
used a credit for this episode. Sounds like a job for yet another nested enum!

```swift
enum EpisodePermission {
  case loggedIn(memberPermission: MemberPermission)

  enum MemberPermission {
    case isNotMember(creditPermission: CreditPermission)

    enum CreditPermission {
      // LoggedIn * NotMember * NotUsedCredit * NotMembersOnly (1)
      // LoggedIn * NotMember * NotUsedCredit * IsMembersOnly  (1)
      case hasNotUsedCredit

      // LoggedIn * NotMember * HasUsedCredit * Void           (1)
      case hasUsedCredit
    }

    case isMember
  }

  case loggedOut(isEpisodeMembersOnly: Bool)
}
```

OK we're so close! The `hasUsedCredit` is finished, no extra data is needed, but the `hasNotUsedCredit` needs
to further know if the episode is for members only. A simple boolean will solve that:

```swift
enum EpisodePermission {
  case loggedIn(memberPermission: MemberPermission)

  enum MemberPermission {
    case isNotMember(creditPermission: CreditPermission)

    enum CreditPermission {
      case hasNotUsedCredit(isEpisodeMembersOnly: Bool)
      case hasUsedCredit
    }

    case isMember
  }

  case loggedOut(isEpisodeMembersOnly: Bool)
}
```

And we are done! This is a bit messy, so let's clean up real quick by grouping the cases together and
putting the nested enums last:

```swift
enum EpisodePermission {
  case loggedIn(memberPermission: MemberPermission)
  case loggedOut(isEpisodeMembersOnly: Bool)

  enum MemberPermission {
    case isNotMember(creditPermission: CreditPermission)
    case isMember

    enum CreditPermission {
      case hasNotUsedCredit(isEpisodeMembersOnly: Bool)
      case hasUsedCredit
    }
  }
}
```

That is so simple! And this is precisely the [data type](https://github.com/pointfreeco/pointfreeco/blob/c3a03fda2817418cc74d66da6c21e3fede0574f7/Sources/PointFree/Episode/Show.swift#L841-L854)
we use in the code on this site! It cleaned up the
code that dealt with this permissions type a lot. I was able to delete let's of `guard`ing and `if let`ing
and instead just focus on the states I knew were valid.

So, that's it for this Point-Free Pointer. I hope you can see how understanding algebra in the Swift type
system can greatly simplify the types we work with. Also, the code for this entire website, including
everything we discussed today, is fully [open sourced](https://github.com/pointfreeco/pointfreeco)
on GitHub. If you are curious about this technique,
and any of the other things we do on Point-Free, feel free to poke around and ask us questions on
[Twitter](https://www.twitter.com/pointfreeco)!
