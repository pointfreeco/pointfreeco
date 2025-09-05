In our most recent episode we performed a direct, apples-to-apples comparison of SwiftData's
query tools to our SQL building tools. Let's just say the results were eye-opening. 😳

To celebrate WWDC 2025, we've decided to make this episode free for all to watch! You can view
the episode in its entirety below, or you can read the transcript of the episode 
[here](/episodes/ep327-modern-persistence-reminders-detail-part-2).

<div style="padding-bottom: 56.25%; position: relative; width: 100%; margin: 1rem;">
  <iframe 
    class="c98 c99 c100 c101 c0 c102" 
    style="border: none; height:100%; width: 100%; position: absolute; left: 0, top: 0;"
    src="https://customer-1wj3kl26hvlz1r1i.cloudflarestream.com/912d7fc3d0197a80cf3790fa2fa3c2db/iframe?poster=https://d3rccdn33rt8ze.cloudfront.net/episodes/0327.jpeg&startTime=182" 
    loading="lazy" 
    allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;" 
    allowfullscreen
  >
  </iframe>
</div>

And for the tldr/tldw; crowd, here's a quick synopsis of our findings…

## The comparison

In our [Modern Persistence](/collections/modern-persistence) series we have rebuilt many parts of 
Apple's Reminders app, including some of its most complex querying functionality. One such query 
needs to display all reminders belonging to a list, along with the option to show just incomplete 
reminders or all reminders, as well as the option to be able to sort by due date, priority, or 
title. And in all combinations of these options, the incomplete reminders should always be put 
before completed ones.

The query we built with our 
[Structured Queries](http://github.com/pointfreeco/swift-structured-queries) library weighs in at a 
meager 23 lines and can be read linearly from top-to-bottom:

```swift
func query(
  showCompleted: Bool, 
  ordering: Ordering, 
  detailType: DetailType
) -> some SelectStatementOf<Reminder> {
  Reminder
    .where {
      if !showCompleted {
        !$0.isCompleted
      }
    }
    .where {
      switch detailType {
      case .remindersList(let remindersList):
        $0.remindersListID.eq(remindersList.id)
      }
    }
    .order { $0.isCompleted }
    .order {
      switch ordering {
      case .dueDate:
        $0.dueDate.asc(nulls: .last)
      case .priority:
        ($0.priority.desc(), $0.isFlagged.desc())
      case .title:
        $0.title
      }
    }
}
```

In comparison, the equivalent query in SwiftData is a bit more complex. It cannot be composed in
a top-down fashion because predicates and sorts cannot be combined easily. We are forced to define
predicate and sort helpers upfront, and then later compose them into the query. And due to these
gymnastics, and a more verbose API, this query is 32 lines long:

```swift
@MainActor
func remindersQuery(
  showCompleted: Bool,
  detailType: DetailTypeModel,
  ordering: Ordering
) -> Query<ReminderModel, [ReminderModel]> {
  let detailTypePredicate: Predicate<ReminderModel>
  switch detailType {
  case .remindersList(let remindersList):
    let id = remindersList.id
    detailTypePredicate = #Predicate {
      $0.remindersList.id == id
    }
  }
  let orderingSorts: [SortDescriptor<ReminderModel>] = switch ordering {
  case .dueDate:
    [SortDescriptor(\.dueDate)]
  case .priority:
    [
      SortDescriptor(\.priority, order: .reverse),
      SortDescriptor(\.isFlagged, order: .reverse)
    ]
  case .title:
    [SortDescriptor(\.title)]
  }
  return Query(
    filter: #Predicate {
      if !showCompleted {
        $0.isCompleted == 0 && detailTypePredicate.evaluate($0)
      } else {
        detailTypePredicate.evaluate($0)
      }
    },
    sort: [
      SortDescriptor(\.isCompleted)
    ] + orderingSorts,
    animation: .default
  )
}
```

Further, this query is not actually an exact replica of the SQL query above. It has 4 major 
differences:

* SwiftData is not capable of sorting by `Bool` columns in models, and so we were forced to
use integers for the `isCompleted` and `isFlagged` properties of `ReminderModel`. This means we
are using a type with over 9 quintillion values to represent something that should only have 2 
values.
* SwiftData is not capable of filtering or sorting by raw representable enums. So again we had
to use an integer for `priority` when an enum with three cases (`.low`, `.medium`, `.high`) would
have been better.
* And finally, SwiftData does not expose the option of sorting by an optional field and deciding
where to put `nil` values. In this query we want to sort by `dueDate` in an ascending fashion,
but also place any reminders with no due date last. There is an idiomatic way to do this in SQL,
but that is hidden from us in SwiftData.
* It is possible to write code that compiles in SwiftData but actually crashes at runtime.
There are ways to force Swift to compile a query that sorts by booleans and filters by raw
representable enums, but because those tools are not really supported by SwiftData (really
CoreData), it has no choice but to crash at runtime.

And so we feel confident saying that there is a clear winner here. Our library embraces SQL,
an open standard for data querying and aggregation, and gives you a powerful suite of tools
for type-safety and schema-safety. If you're interested in learning more, be sure to check
out our [Modern Persistence](/collections/modern-persistence) series, as well as our 
open source, [lightweight replacement for SwiftData](http://github.com/pointfreeco/sqlite-data).
