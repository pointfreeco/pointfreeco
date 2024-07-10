## Introduction

@T(00:00:05)
Recently we have been doing a lot of work on [the Composable Architecture](/collections/composable-architecture) to modernize many aspects of it, such as [its integration](/collections/composable-architecture/async-composable-architecture) with Swift’s [concurrency](/collections/concurrency) tools, and how one [builds and composes features and uses dependencies](/collections/composable-architecture/reducer-protocol).

@T(00:00:18)
But now we want to put a pause on the Composable Architecture and return to a topic we spoke about many, many months ago.

@T(00:00:26)
Around this time last year we embarked on an ambitious series of episodes to understand [navigation](/collections/swiftui/navigation) at a very deep level in SwiftUI, and even in UIKit. And those episodes didn’t use the Composable Architecture at all. Everything was based on plain, vanilla SwiftUI.

@T(00:00:37)
Over the course of those 9 episodes we saw that all of the different types of navigation out there can be thought of as a kind of “mode change” in the application. And in concrete, technical terms, a “mode change” is the process of some state going from not existing to existing, or the reverse.

@T(00:00:59)
This helped us frame the idea of navigation as a domain modeling problem, where the better we make use of optionals and enums, the better we can describe a tree of navigation paths in our application. That helped unify a bunch of seemingly disparate forms of navigation with a single API, such as drill-downs, sheets, popovers, alerts and more, and then complicated things such as deep linking and URL routing kinda just fell out, nearly for free, with very little additional work.

@T(00:01:17)
Then, a few months ago, some of that was upended thanks to a brand new suite of navigation tools made available in the newest platform SDKs that shipped with Xcode 14. It seems that Apple decided that the previous `NavigationLink` APIs were too problematic, and so decided to redesign how drill-down navigation is handled using what is known as “navigation stacks.”

@T(00:01:37)
So, we want to amend that past series of episodes so that we have a complete picture of how navigation works in SwiftUI. We are going to explore navigation stacks by seeing what problems `NavigationLink` had that prompted for a new API design. Then we are going to see how navigation stacks solve those problems, and finally add our own little dash of magic to the APIs to make this easier to use.

## App and inventory domains

@T(00:01:57)
And we are going to do all of that by revisiting the inventory application we built during the last series of episodes. The demo has all of the standard styles of navigation, such as drill-downs, sheets, popovers and alerts, and it demonstrates some complex interactions between parent and child features. We even modularized the entire application and layered on URL routing so that we could open to any state of the app from a deep-linking URL.

@T(00:02:24)
Let’s first take a quick tour of the application so we can remind ourselves of all it did, and then we will look at the problems it currently has. We’ll run the app in the simulator.

@T(00:02:43)
And right off the bat we see we have a 3 tab application, and the first tab shows a button that when tapped will pop us over to the 2nd tab. We did this in the very first episode of the previous navigation series in order to show how state-driven navigation works. By handing the tab view a binding that is connected to our app’s model we can make sure that the visual state of the interface is always in sync with the data in our model. So, nothing too complicated here, but it does start to hint at why state-driven navigation is so powerful.

@T(00:03:19)
On the second tab we see a list of items that represent the inventory of some stock. There are 4 items, 2 of them are in stock and 2 are not, and one of the out of stock items is on back order, whereas the other is not.

@T(00:03:30)
There are 4 different actions we can take on this screen. We can add a new item, which brings up a sheet. In that sheet we can add a name, change the color, change the quantity and change the status. Hitting “Cancel” dismisses the sheet and doesn’t add anything to the list. But if we do it again and hit “Save”, then the sheet will dismiss and the item will be added to the bottom of the list.

@T(00:03:52)
Another action we can perform on this screen is deleting an item. Tapping on the trash icon brings up an alert, and confirming that alert causes that row to animate out.

@T(00:04:00)
The double square icon corresponds to a duplicate action. Tapping that icon brings up another sheet, but actually it’s a popover. On iPhones popovers are represented as sheets, but if we were running on an iPad then this screen would be rendered in a popover.

On this screen we can make changes to the current properties of the item, such as name, color, and status, and then we can either cancel duplicating the item, or commit to it by tapping “Add”.

@T(00:04:32)
The 4th and final action we can perform on this screen is to edit an item in the list. To do that you tap the row, which causes a drill-down to the item view. In this screen you can edit any of the fields of the item, but those changes are not being made directly on the item back in the list. Instead we are operating on a draft copy of the item, and the changes are not committed until you actually hit “Save”. If you hit “Cancel” instead you will pop back to the root and no changes will be made to the item.

@T(00:04:53)
And if you hit “Save” then we see a little progress view for a moment and then we pop back to the root with the changes applied. That little progress view shown is just our way of showing that sometimes there is complex logic surrounding navigation events. In this case we simulating needing to perform some kind of side effect, like a network request, to save the item, and only when it finishes do we want to actually pop back to the root.

@T(00:05:31)
So, that’s all the main functionality in this app. Let’s remind ourselves what the code looks like. We have made a few small changes to the code to modernize it a bit since the navigation episodes first aired a year ago. The biggest changes are that we got rid of the SwiftUIHelpers module that held all of the navigation tools we built during that series of episodes because we ended up open sourcing a dedicated library called [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) with all of those tools. So now this application just depends on that library. Also since the original airing of those episodes we released some big updates to our parsing library, such as [parser builders](https://www.pointfree.co/collections/parsing/builders) and [URL routing](https://github.com/pointfreeco/swift-url-routing), and so we updated the application to make use of all of those new tools.

@T(00:06:13)
Let’s start right at the beginning: the entry point of the entire application. The most important thing it does is construct an `AppModel` with some mock data, in particular the 4 items we saw in the simulator a moment ago, and then constructs a `AppView` with that model. A secondary thing, but also important, is it uses the `onOpenURL` view modifier to listen for when the application is opened from a URL, in which case we need to parse the URL and figure out where to route the user. That is all done inside the model, so we just invoke a method with a URL:

```swift
.onOpenURL { url in
  self.model.open(url: url)
}
```

@T(00:06:47)
So, this means the real meat of the application is in the `AppModel` and `AppView`, so let’s check those out. Because the application has been modularized, those types aren’t sitting directly in the application target. Instead, there is an `AppFeature` module that holds onto the model and view, as well as logic for the URL routing.

@T(00:07:14)
The `AppModel` is quite simple. It just holds onto some state for the currently selected tab, as well as the `InventoryModel`, which holds the state and behavior for the middle inventory tab:

```swift
public final class AppModel: ObservableObject {
  @Published public var inventoryModel: InventoryModel
  @Published var selectedTab: Tab
  …
}
```

If the first and third tabs had some actual logic implemented, then we would also hold onto their models here too.

@T(00:07:35)
And the only other thing really in this model is the `open(url:)` method that uses the `appRouter` to parse an incoming URL and figure out where we should route the user, but that’s not really important to us right now. If you are interested in how that code works then we highly recommend you watch our previous episodes.

@T(00:07:55)
The only thing left in this file is the `AppView`, which is also pretty straightforward. It needs to hold onto an `AppModel` to get access to state, and it constructs a `TabView` with an `InventoryView` for the 2nd tab.

@T(00:08:06)
So, that means the `InventoryView` and `InventoryModel` must have most of the actual functionality of the app. It lives in its own module separate from the `AppFeature`, and it’s called `InventoryFeature`. This allows us to build it in isolation without worry about building the full app feature, which means if the first and third tab start to become bloated and take a long time to compile, we wouldn’t have to worry about that while working on the inventory feature.

@T(00:08:37)
The `InventoryModel` holds onto a few pieces of state in order to do its job. It has an array of items as well as something called a `destination`:

```swift
public final class InventoryModel: ObservableObject {
  @Published public var destination: Destination?
  @Published public var inventory: IdentifiedArrayOf<
    ItemRowModel
  >
  …
}
```

@T(00:08:53)
The array of items is what powers the list of items on the inventory screen. We are using an `IdentifiedArray`, which is a type from our [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) library. It gives us performant and ergonomic access to an array of identified elements, and helps us eliminate a large class of bugs that happen while working with collections in SwiftUI. Further, the element in the identified array is an `ItemRowModel`, which is an observable object conformance that encapsulates the logic and behavior of each row of the list, such as showing the delete alert and duplicate popover.

@T(00:09:41)
The `Destination` is an enum that represents all of the places we can navigate to from here. In the previous series of episodes we actually called this `Route`, but in order to fit in well with SwiftUI’s navigation APIs we have decided to rename this to `Destination`. And it’s optional because `nil` will represent being on the inventory screen and not navigating anywhere else.

@T(00:10:12)
There is currently just one places we can navigate to from the inventory. We can go to the add item screen, which is shown in a sheet:

```swift
public enum Destination: Equatable {
  case add(ItemModel)
}
```

@T(00:10:20)
In the future we may add more destinations to this screen, so modeling it as an enum gives us a spot to add more cases.

@T(00:10:26)
And `ItemRowModel.Destination` is also an enum with a case for each destination that the row can navigate to, which we will take a look at in a moment.

@T(00:10:33)
Because the `ItemRowModel` encapsulates the logic and behavior of the row and purposefully does not have access to the great inventory domain, it exposes delegate-like callbacks for the inventory to hook into specific events of the row. For example, when the row confirms that it should be deleted, that needs to be communicated back to the inventory which is the thing with the collection of inventory and so it is responsible for doing the actual deletion.

@T(00:11:07)
The way we handle this is by having a `bind()` method that is responsible for hooking into those delegate callbacks:

```swift
private func bind() {
  for itemRowModel in self.inventory {
    …
  }
}
```

@T(00:11:17)
For example, when deletion is confirmed we can just delete the item from the inventory and animate it:

```swift
itemRowModel.commitDeletion = {
  [weak self, itemID = itemRowModel.item.id] in

  withAnimation {
    _ = self?.inventory.remove(id: itemID)
  }
}
```

@T(00:11:27)
Something similar happens with duplication:

```swift
itemRowModel.commitDuplication = { [weak self] item in
  self?.confirmAdd(item: item)
}
```

@T(00:11:36)
And then we just make sure to bind the view models whenever the inventory collection changes:

```swift
@Published public var inventory:
  IdentifiedArrayOf<ItemRowModel> {
    didSet { self.bind() }
  }
```

@T(00:11:42)
As well as when the model is first created:

```swift
public init(
  destination: Destination? = nil,
  inventory: IdentifiedArrayOf<ItemRowModel> = []
) {
  self.destination = destination
  self.inventory = inventory
  self.bind()
}
```

@T(00:11:51)
And then the last responsibility of the `AppModel` is to provide some endpoints that are called from the UI, such as when the add button is tapped or the cancel button on the add sheet is tapped or when we confirm to add an item to inventory:

```swift
func confirmAdd(item: Item) {
  withAnimation {
    self.inventory.append(ItemRowModel(item: item))
    self.destination = nil
  }
}

func addButtonTapped() {
  self.destination = .add(
    ItemModel(
      item: Item(
        name: "",
        color: nil,
        status: .inStock(quantity: 1)
      )
    )
  )
}

func cancelAddButtonTapped() {
  self.destination = nil
}
```

@T(00:12:19)
Adding an item is a multi-step process. First the “Add” button is tapped, which should cause the sheet to come up, and we handle that at the domain level by changing the `destination` to point to the `add` case of the enum. Then, if later the user confirms adding, the item will be bound which means adding to the collection and setting up delegates, and then finally the destination will be `nil`'d out causing the sheet to go away. Or if the user cancels we can just `nil` out the `destination`.

@T(00:12:34)
Next we have the view. It holds onto an `InventoryModel` to get access to state, and provides a public initializer since this feature has been modularized:

```swift
public struct InventoryView: View {
  @ObservedObject var model: InventoryModel

  public init(model: InventoryModel) {
    self.model = model
  }

  …
}
```

@T(00:12:48)
In the body of the view we construct the list that has a row for each item in the inventory:

```swift
List {
  ForEach(
    self.model.inventory,
    content: ItemRowView.init(model:)
  )
}
```

@T(00:12:56)
We attach a toolbar to this screen so that we can have an “Add” button in the top-right which just needs to call out to the model’s endpoint:

```swift
.toolbar {
  ToolbarItem(placement: .primaryAction) {
    Button("Add") { self.model.addButtonTapped() }
  }
}
```

@T(00:13:03)
And then the only interesting thing left in this view is how we handle the `sheet`. This API is the one that comes with our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library that builds upon the tools that SwiftUI gives us, but makes it so that we can better model our state with enums.

@T(00:13:22)
Before diving into the specifics, let’s remind ourselves what the standard `sheet` view modifier looks like in SwiftUI.

```swift
func sheet<Item: Identifiable, Content: View>(
    item: Binding<Item?>,
    onDismiss: (() -> Void)? = nil,
    content: @escaping (Item) -> Content
) -> some View
```

@T(00:13:29)
This takes a binding of some optional, identifiable piece of state, and when SwiftUI detects the state switching from `nil` to a non-`nil` value, it invokes the `content` closure, passes the non-`nil` data long to get a view, and then that is the view slides up in a sheet. Further, when SwiftUI detects the data switching back to `nil` it will automatically dismiss the sheet.

@T(00:13:59)
This API embodies what it means for navigation to be driven off of state, in particular the existence or non-existence of state. APIs designed in this style can guarantee that the navigation the user sees on screen correctly matches what your model says, and it makes it possible to easily deep-link into any state of your application. All you have to do is construct some state, hand it over to SwiftUI, and let it do the real heavy lifting of restoring the UI.

@T(00:14:26)
So, while modeling navigation with optionals and using this API to handle state-driven navigation is really great, it isn’t the best we can do. What if we wanted to show multiple sheets, say 3 different sheets? We would need to hold onto 3 optionals, which represents 8 different states of being `nil` or non-`nil`, of which only 4 states are actually legitimate: either all are `nil`, representing no sheet is up, or exactly 1 is non-`nil`, representing one sheet is up. But 3 optionals allows for non-sensical situations such as 2 or 3 being non-`nil` at the same time, which should not be allowed because SwiftUI does not allow presenting 2 sheets from the same base view. That behavior is undefined and can sometimes even lead to crashes in your application.

@T(00:15:13)
And beyond strange SwiftUI crashes, modeling data in that way just infects all of your feature’s logic with uncertainty. Say you wanted to perform some logic but only if no sheet is displaying. You would need to check that all 3 optionals are `nil`, and if someday you decide to add another sheet you will need to remember to update that logic to check all 4 optionals.

@T(00:15:37)
Both of these problems are just pointing to the fact that this domain is modeled incorrectly. Enums are a tool Swift gives us that is perfect for modeling mutually exclusive state, but sadly none of SwiftUI’s are designed in a way that plays nicely with enums. This is exactly what our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library brings to the table.

We would like to show the sheet when the `destination` state becomes non-`nil` and matches the `add` case. Further, when that happens, we would like to get access to the associated data, which is the `ItemModel`. This is what the `.sheet(unwrapping:case:)` helper that ships in our library accomplishes:

```swift
.sheet(
  unwrapping: self.$model.destination,
  case: /InventoryModel.Destination.add
) { $itemToAdd in
  …
}
```

@T(00:16:05)
First you specify the piece of optional state you want to listen to, and then you specify the case of the enum you want to further listen for, and if SwiftUI detects that all of the state matches up it will invoke the content closure and hand a binding to the associated data.

@T(00:16:46)
Now, to specify the case you have to do something seemingly funky by prefixing the case with a forward slash. This is creating what is known as a “[case path](https://github.com/pointfreeco/swift-case-paths)”, which is a concept [we introduced](/episodes/ep90-composing-architecture-with-case-paths) for the Composable Architecture, but since then it has found plenty of use cases in [other areas](/episodes/ep108-composable-swiftui-bindings-case-paths) of Swift.

@T(00:17:05)
If you don’t like prefix operators you can always do it in a more verbose fashion:

```swift
case: CasePath(InventoryModel.Destination.add)
```

@T(00:17:14)
A case path is like a key path, except tuned specifically for enums. It allows you to isolate a single case in an enum so that you can abstractly do things such as extracting associated values and embedding associated values. This is exactly what one needs to in order to transform bindings of enums into bindings of their cases.

@T(00:17:36)
SwiftUI leans heavily on key paths for its expressive APIs, and so it’s not too surprising that we need the analogous concept for enums if we want to embrace enums in our APIs.

@T(00:17:47)
Inside that content closure we are free to construct our `ItemView` since we have access to the `ItemModel`, and we can attach some toolbar items for cancelling and saving:

```swift
NavigationView {
  ItemView(model: itemToAdd)
    .navigationTitle("Add")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          self.model.cancelAddButtonTapped()
        }
      }
      ToolbarItem(placement: .primaryAction) {
        Button("Save") {
          self.model.confirmAdd(item: itemToAdd.item)
        }
      }
    }
}
```

@T(00:18:04)
One thing to note here is how we have decided to attach the toolbar items here in the parent view that is presenting the `ItemView` rather than baking it into the `ItemView`. We do this because it frees up the `ItemView` to be used in a variety of contexts. For example, it can be used for adding a new item, editing an existing item, or duplicating an item. The `ItemView` doesn’t need to know about any of that, it can just focus on the core behavior of mutating little local `Item` and it can let the parent feature decide how it wants to interpret that.

@T(00:18:36)
So, that’s the `InventoryModel` and `InventoryView`, and it may seem intense, but there is some real power in this code. Because we have taken the time to properly model our domain, it becomes incredibly easy to add new destinations to this view, and we will always have a precise way of knowing exactly what screen is being navigated to at any moment.

@T(00:18:55)
For example, let’s quickly add a help screen to this view. We can start by adding a new case to our `Destination` enum:

```swift
public enum Destination: Equatable {
  …
  case help
}
```

@T(00:19:06)
Then we can add a new endpoint to our model for when a “Help” button is tapped, and all it has to do is point the `destination` state to the `.help` case:

```swift
func helpButtonTapped() {
  self.destination = .help
}
```

@T(00:19:15)
Then we can add a new tool bar button for accessing help:

```swift
.toolbar {
  …
  ToolbarItem(placement: .secondaryAction) {
    Button("Help") { self.model.helpButtonTapped() }
  }
}
```

@T(00:19:30)
And finally add a new `.sheet` modifier to the bottom of the view, but this time focusing on the `.help` case of the destination instead of the `.add` case:

```swift
.sheet(
  unwrapping: self.$model.destination,
  case: /InventoryModel.Destination.help
) { _ in
  Text("Help!")
}
```

@T(00:19:56)
In those 4 simple steps we have added a new destination and hooked it up in the view, and the domain has remained modeled in the most concise way possible. We have just one single piece of state to check if we want to see if anything is currently presented.

## Row and item domains

@T(00:20:21)
OK, that’s everything we need to know about the `InventoryModel` and `InventoryView`, and it is by far the most complex feature in the app since it needs to coordinate and synchronize multiple domains.

@T(00:20:34)
The other features are quite a bit simpler. Let’s look at them real quick, starting with the item row feature.

@T(00:20:48)
This feature has been put into its own feature module just like the other features so that it can be built and tested in isolation. The `ItemRowModel` is the observable object that encapsulates the state and behavior of the feature:

```swift
public final class ItemRowModel:
  Hashable, Identifiable, ObservableObject
{
  @Published public var item: Item
  @Published public var destination: Destination?
  @Published var isSaving = false
  …
}
```

@T(00:21:00)
It holds onto the item that populates the row, as well as an optional `destination`. The `isSaving` state is some internal state used to show the loading indicator we saw when we demo’d the app, and we will understand more of why this is here in a moment.

@T(00:21:14)
But the `destination` state is a lot more interesting. This follows the exact same pattern that we saw over in the `InventoryModel`. It represents all of the places one can navigate to from this screen, and it's optional because `nil` represents to not navigate anywhere.

@T(00:21:28)
The `Destination` type is an enum, just like over in the InventoryModel`, and it’s got 3 cases:

```swift
public enum Destination: Equatable {
  case deleteConfirmationAlert
  case duplicate(ItemModel)
  case edit(ItemModel)
}
```

@T(00:21:32)
The first represents the alert that shows when we want to confirm deleting the item, the second represents the popover we show when duplicating the item, and the third represents the drill-down to the edit screen for the item. None of the destinations can be shown simultaneously, and so it’s not optimal to model this as 3 different optional values. It is far better to use an enum as we have done here.

@T(00:21:57)
Next, the `ItemRowModel` holds 2 closures that are meant to be customized by whoever creates this model, which we saw back in the inventory model. Remember that this is because the row is not responsible for doing the actual deleting or duplicating of an item. After all, it doesn’t even have access to the inventory collection, so it couldn’t possibly accomplish those tasks. Instead, it invokes these delegate closures when its time to actually delete or duplicate an item, and let’s the parent feature figure out the actual details of what that means:

```swift
public var commitDeletion: () -> Void =
  unimplemented("ItemRowModel.commitDeletion")
public var commitDuplicate: () -> Void =
  unimplemented("ItemRowModel.commitDuplicate")
```

@T(00:22:26)
We are also employing a fun detail here. We have marked these closures as initially being “unimplemented”, which means if these default closures are ever invoked in a simulator or on device it will trigger a runtime warning, and if they are called in a test it will trigger a test failure.

@T(00:22:41)
This helps us catch times that one does not properly configure the model. An alternative would be to force providing these closures when creating the model, but in practice that is too restrictive. There are multiple places that we want to be able to create the model and then have these closures bound at a later time.

@T(00:22:55)
The logic and behavior of the row is quite straightforward. For example, there are two endpoints for the delete user flow, one for when the delete button is tapped and another for when the user confirms deleting:

```swift
public func deleteButtonTapped() {
  self.destination = .deleteConfirmationAlert
}

func deleteConfirmationButtonTapped() {
  self.commitDeletion()
  self.destination = nil
}
```

When the delete button is tapped all we have to do is point the destination to the `deleteConfirmationAlert` case of the `Destination` enum. And when the deletion is confirmed we just have to tell the parent to delete and `nil` out the `destination` state to get rid of the alert.

@T(00:23:18)
The duplication behavior follows the same pattern. Tapping the button causes the `destination` state to point to the `.duplicate` case, and then confirming duplication notifies the parent and clears out the `destination`:

```swift
public func duplicateButtonTapped() {
  self.destination = .duplicate(
    ItemModel(item: self.item.duplicate())
  )
}

func commitDuplicate() {
  guard
    case let .some(.duplicate(itemModel)) =
      self.destination
  else { return }
  self.commitDuplicate(itemModel.item)
  self.destination = nil
}
```

@T(00:23:39)
The edit behavior is basically the same, but made a little more complicated due to how navigation links work and due to us wanting to emulate a saving process that takes a little time. First, when the navigation link is tapped we call a `setEditNavigation` method but we supply an `isActive` boolean:

```swift
public func setEditNavigation(isActive: Bool) {
  …
}
```

@T(00:23:56)
This is necessary because navigation links are a bit different from all the other forms of navigation we have seen so far. They don’t only listen for state to change in order to drive a drill-down navigation. They also allow for the user to interact directly with the link in order to start a drill-down. This external influence of state from the user means state can change in our model without us actually doing anything directly in the model, and it’s why a boolean must be passed to `setEditNavigation`.

@T(00:24:21)
The actual implementation of `setEditNavigation` just needs to branch of the `isActive` boolean: if it is true then we point the `destination` state to the `.edit` case, and otherwise we can `nil` out the `destination`:

```swift
public func setEditNavigation(isActive: Bool) {
  self.destination = isActive
    ? .edit(ItemModel(item: self.item))
    : nil
}
```

@T(00:24:35)
Then, once the edit is confirmed we can actually do the work to update our state, but we simulate a saving process by performing a short sleep, and this is where we toggle the `isSaving` state to true and then false:

```swift
@MainActor
func edit(item: Item) async {
  self.isSaving = true
  defer { self.isSaving = false }

  do {
    // NB: Emulate an API request
    try await Task.sleep(nanoseconds: NSEC_PER_SEC)
  } catch {}

  self.item = item
  self.destination = nil
}
```

@T(00:24:53)
And the final bit of functionality in this model is an endpoint to call when a cancel button is tapped, which means we can just `nil` out the destination and not do anything else:

```swift
public func cancelButtonTapped() {
  self.destination = nil
}
```

@T(00:25:00)
So, that’s the model. Let’s move on to the view. It starts just like all the other views we’ve seen. It holds onto the model as an observed object, and it has a public initializer since the view lives in its own module:

```swift
public struct ItemRowView: View {
  @ObservedObject var model: ItemRowModel

  public init(model: ItemRowModel) {
    self.model = model
  }

  …
}
```

@T(00:25:14)
Next we have the body of the view. Right off the bat we have a navigation link because the entire row acts as a button that can drill down to the edit screen:

```swift
NavigationLink(…)
```

@T(00:25:23)
But this navigation link initializer is a little different from the ones you will find in SwiftUI. It’s provided by our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library, and like we saw with sheets, its aim is to allow you to model navigation state using an enum so that you can have one single, concise source of navigation state in your feature.

@T(00:25:42)
Its usage is basically the same as `.sheet` where you first provide a binding to the optional destinations enum, and then specify the case you want to recognize from that enum:

```swift
NavigationLink(
  unwrapping: self.$model.destination,
  case: /ItemRowModel.Destination.edit
)
```

@T(00:25:54)
The moment that the `destination` state becomes non-`nil` and matches the `edit` case, a drill-down animation will happen.

@T(00:26:01)
But, before specifying the actual destination view we first provide an action closure, which is the thing executed when the user interacts with the navigation link. It is passed a boolean that lets us know whether the navigation link is being activated or deactivated, and we can just pass that data along to the model:

```swift
{ isActive in
  self.model.setEditNavigation(isActive: isActive)
}
```

@T(00:26:17)
A value of `true` is passed in when the user taps on the link, and a value of `false` is passed in when the user taps the back button or performs a swipe gesture on the edge of the screen to pop the screen off.

@T(00:26:26)
And remember that this `setEditNavigation` method is what takes care of setting the `destination` state in the model, which is the thing that ultimately drives the navigation.

@T(00:26:34)
After the action closure we provide another trailing closure for the destination. It is handed a binding to the associated data of the enum case, which is the `ItemModel` that we can actually hand to the `ItemView`:

```swift
destination: { $itemModel in
  ItemView(model: itemModel)
    .navigationBarTitle("Edit")
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          self.model.cancelButtonTapped()
        }
      }
      ToolbarItem(placement: .primaryAction) {
        HStack {
          if self.model.isSaving {
            ProgressView()
          }
          Button("Save") {
            Task {
              await self.model.edit(
                item: itemModel.item
              )
            }
          }
        }
        .disabled(self.model.isSaving)
      }
    }
}
```

@T(00:26:46)
Note that we followed a similar pattern as we saw in the `InventoryView` where we attach the toolbar items here rather than making that the responsibility of the `ItemView`. And it’s a good thing we did that because here we can see that there is some super custom logic happening. When the “Save” button is tapped we fire up a task to perform some asynchronous work, and while that asynchronous work is inflight we show a progress view.

@T(00:27:12)
It would have been a bummer to bake that into the `ItemView`, especially since it’s only this one single usage of `ItemView` that needs this complex behavior. It makes far more sense for this responsibility to be put with the row, and then other usages of `ItemView` can manage the toolbar and actions however they want.

@T(00:27:27)
And finally, the last trailing closure given to the navigation link is the label that is actually displayed in the row, and there isn’t much interesting in this. It’s just an `HStack` with a bunch of views inside to represent the various buttons and interfaces:

```swift
label: {
  HStack {
    …
  }
}
```

@T(00:27:47)
Tacked onto the very end of this `NavigationLink` is some really interesting things. Remember that our `Destination` enum as 3 cases for 3 different places we can navigate, and so far we have only handled a single one: the edit screen.

@T(00:27:56)
So, at the end of the `NavigationLink` we have an `.alert` modifier for handling the `.deleteConfirmationAlert` case and a `.popover` modifier for handling the `.duplicate` case. But of course we can’t use any of vanilla SwiftUI’s APIs because they don’t speak the language of enums. We have to use the APIs that ship with our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library.

@T(00:28:15)
The first is the `alert`, which mostly looks like the vanilla SwiftUI API, but allows us to drive the alert off of a piece of optional enum state with a particular case singled out:

```swift
.alert(
  title: Text(self.model.item.name),
  unwrapping: self.$model.destination,
  case:
    /ItemRowModel.Destination.deleteConfirmationAlert,
  actions: {
    Button("Delete", role: .destructive) {
      self.model.deleteConfirmationButtonTapped()
    }
  },
  message: {
    Text("Are you sure you want to delete this item?")
  }
)
```

@T(00:28:36)
This alert will show only if the `destination` is non-`nil` and if the enum further matches the `deleteConfirmationAlert` case.

@T(00:28:42)
Next is the `.popover`, which looks nearly identical to what we did for the `sheet` in the inventory feature. Using the APIs that ship with our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library we can decide to show a sheet precisely when the `destination` state becomes non-`nil` and when the enum matches the `.duplicate` case:

```swift
.popover(
  unwrapping: self.$model.destination,
  case: /ItemRowModel.Destination.duplicate
) { $itemModel in
  …
}
```

@T(00:28:56)
It’s pretty incredible that this one view has 3 seemingly different forms of navigation, a drill down, an alert and a popover, yet all 3 call sites for expressing those navigations look nearly the same. We just specify the piece of optional enum state that drives navigation, and further pinpoint the case of the enum we are interested in.

And then inside this content closure we construct the `ItemView`, which we want to customize by attaching our own toolbar to it to provide “Add” and “Cancel” buttons:

```swift
NavigationView {
  ItemView(model: itemModel)
    .navigationBarTitle("Duplicate")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          self.model.cancelButtonTapped()
        }
      }
      ToolbarItem(placement: .primaryAction) {
        Button("Add") {
          self.model.duplicate(item: itemModel.item)
        }
      }
    }
}
```

@T(00:29:15)
Note that this is now the 3rd place we have made use of this single view, and because we didn’t even attempt to make it customizable from the outside as having either adding or editing or duplicating behavior we allow the `ItemView` to be super simple and give ourselves infinite flexibility in how we want to layer on that additional logic from the parent feature.

@T(00:29:34)
So, this is pretty amazing, but speaking of the `ItemView`… that is the last domain for us to check out, but before we do, we should admit that the `NavigationLink` driving the row is deprecated, because we are targeting iOS 16. With iOS 16 many if not most of the `NavigationLink` initializers were deprecated as Apple completely revamped its navigation tools. Even though this `NavigationLink` initializer comes from our library, it uses Apple's deprecated initializer under the hood, and so we have no choice but to deprecate it ourselves. We'll explore the new tools soon.

@T(00:30:14)
Let’s start with the `ItemModel`, which is an observable object that, just like all the ones before it, holds onto the core state it needs to do its job, as well as a `destination`:

```swift
public final class ItemModel:
Equatable, Identifiable, ObservableObject {
  @Published public var item: Item
  @Published public var destination: Destination?
  …
}
```

@T(00:30:26)
This time the model only needs the item being viewed, and the `Destination` type is an enum of all the different places one can navigate to from this screen. It just so happens that this screen only has a single place we can navigate to, so we could just represent this as a single optional or even a boolean, but in order to be consistent with the other features and to be set up for the future where we might have more destinations, we go ahead and model it as a dedicated enum:

```swift
public enum Destination {
  case colorPicker
}
```

This case corresponds to drilling down to the color picker view where we can change the color of the item.

@T(00:30:51)
The only logic in this model for right now is an endpoint that is called whenever the navigation link is interacted with, and it’s implemented in basically the same way that the edit link was handled in the row view:

```swift
func setColorPickerNavigation(isActive: Bool) {
  self.destination = isActive ? .colorPicker : nil
}
```

@T(00:31:10)
Then there’s the view, which mostly looks like what we have done in the past, but with a few new twists. First there’s a text field for changing the name, and that can be hooked up to the model thanks to the magic of SwiftUI and derived bindings:

```swift
TextField("Name", text: self.$model.item.name)
```

@T(00:31:23)
Any change to the model’s item’s name will be immediately reflected in the UI, and similarly any change in the UI will immediately update the model.

@T(00:31:32)
Then there’s a navigation link that works much like the other one we encountered in the row view. We are again using the API that ships with our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library, which allows us to express a navigation link that targets a specific case inside an optional enum:

```swift
NavigationLink(
  unwrapping: self.$model.destination,
  case: /ItemModel.Destination.colorPicker
) { isActive in
  self.model.setColorPickerNavigation(
    isActive: isActive
  )
} destination: { _ in
  ColorPickerView(color: self.$model.item.color)
} label: {
  HStack {
    Text("Color")
    Spacer()
    if let color = self.model.item.color {
      Rectangle()
        .frame(width: 30, height: 30)
        .foregroundColor(color.swiftUIColor)
        .border(Color.black, width: 1)
    }
    Text(self.model.item.color?.name ?? "None")
      .foregroundColor(.gray)
  }
}
```

@T(00:31:50)
And just like that we have a link such that when `destination` becomes non-`nil` and matches the `colorPicker` case it will trigger a drill-down navigation.

@T(00:31:58)
The only thing new and interesting is the view is what we find below the navigation link. It provides the UI for something that seems simple enough, but sadly SwiftUI’s default tools fall a little short.

@T(00:32:10)
Let’s run the application in the simulator real quick so that we can remember what the UI represents. It allows us to switch between the `.inStock` and `.outOfStock` statuses, and in each of those kinds of statuses we have some further data we can change. If we are in stock then we can modify the quantity, and if we are out of stock then we can toggle whether the item is on back order or not.

@T(00:32:36)
The most optimal way of modeling these mutually exclusive states is via an enum:

```swift
public enum Status: Equatable {
  case inStock(quantity: Int)
  case outOfStock(isOnBackOrder: Bool)
  …
}
```

@T(00:32:51)
This just makes the most sense because these two states are incompatible with each other, and so we should first decide which state we are in, and then within each state we can further customize the data however we want.

@T(00:33:01)
However, as we’ve seen over and over in this episode, enums and SwiftUI just don’t play nicely together. It’s not possible to deriving a binding to the `quantity` sitting inside the `inStock` case of this enum so that we can hand it off to the `Stepper` component. Nor can we derive a binding to the `isOnBackOrder` boolean in the `outOfStock` case so that we can hand it to the `Toggle` component.

@T(00:33:22)
Instead we are forced to model our domain in a less than ideal way if all we have are the tools that SwiftUI gives us:

```swift
var quantity: Int
var isOnBackOrder: Bool
```

@T(00:33:40)
This allows us to construct some really non-sensical states, such as having non-zero `quantity` but `isOnBackOrder` being `true`. This imprecision in our domain is going to leak throughout all of our logic, where we can never be truly sure whether we are in stock or out of stock because maybe we just forgot to clean up the data at some point.

@T(00:34:00)
So, we far prefer to use enums, and that’s why our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library ships with a `Switch` view for “switching” over a binding of an enum, as well as a `CaseLet` view for “destructuring” that enum for each of its cases. You use it much like you would use regular `switch` and `case let` statements in Swift:

```swift
Switch(self.$model.item.status) {
  CaseLet(/Item.Status.inStock) { $quantity in
    Section(header: Text("In stock")) {
      Stepper("Quantity: \(quantity)", value: $quantity)
      Button("Mark as sold out") {
        self.model.item.status = .outOfStock(
          isOnBackOrder: false
        )
      }
    }
  }
  CaseLet(/Item.Status.outOfStock) { $isOnBackOrder in
    Section(header: Text("Out of stock")) {
      Toggle("Is on back order?", isOn: $isOnBackOrder)
      Button("Is back in stock!") {
        self.model.item.status = .inStock(quantity: 1)
      }
    }
  }
}
```

@T(00:34:21)
The `Switch` view takes a binding to the enum, and the `CaseLet` takes a case path that isolates a particular case of that enum. Then the `CaseLet` hands you a binding to just the associated data of that case, which can then be handed to various UI controls, such as a `Stepper` or `Toggle`.

@T(00:34:42)
An important feature of `switch` statements in Swift is that they are exhaustive. You must destructure each case of the enum, or provide a default, otherwise you can’t compile. We can’t offer compile-time exhaustivity with the `Switch` view, but we can provide runtime exhaustivity.

@T(00:34:57)
If you accidentally forget a `CaseLet` inside the `Switch` view, and the state mutates into that case, you will get a loud warning in the view as well as an Xcode runtime warning. To see this, let’s comment out the `outOfStock` case.

@T(00:35:02)
And now when we run the application and change an item to be out of stock we get a loud red warning in the view as well as a purple warning in Xcode.

## Deep linking and testing

@T(00:35:24)
So, we have now walked through all of the code in the navigation demo we built during the last series of episodes. Amazingly we have supported many seemingly different forms of navigation, such as sheets, navigation links, alerts and popovers, and all have used roughly the exact same API shape. We get to specify all of our navigation destinations as a single route enum, and then when constructing the sheet, nav link, or what have you, we simplify point to the bit of optional destination state, as well as which case we want to use to drive navigation. It’s super powerful.

@T(00:35:57)
But, some of our viewers may think that we are doing some wild stuff here.

@T(00:36:03)
- We are eschewing some of Apple’s most powerful and well-thought out APIs, such as sheets, popovers, alerts and navigation links, and creating our own versions of them. Are we going too against the grain of what Apple provides?

@T(00:36:17)
- There’s also a whole slew of APIs that Apple provides that we aren’t making use of, such as the `@State` and `@StateObject` property wrappers. Why are we avoiding those APIs?

@T(00:36:28)
- And we have also created a dedicated observable object model for every single view, including the row of the list. Is that a bit overboard?

@T(00:36:37)
Well, there are very good reasons we did all of this, and it all has to do with deep linking and testing.

@T(00:36:43)
Deep linking is the process of being able to put your application in any state imaginable. Just think of a leaf node feature of your application that requires multiple steps to get to.

@T(00:36:54)
Suppose your application has an “edit” screen for which the only way to get there is to switch to a tab, drill down and then open a modal sheet. And then ask yourself: does the way you have built your application allow you to launch your app directly to that specific edit screen?

@T(00:37:09)
If the answer to that question is “yes”, then you have fully modeled navigation off of state, and it means you can easily support URL routing, and push notification routing, and more.

@T(00:37:18)
And somewhat related to deep-linking is testing the integration of many features. We want to easily test how features interact with each other. In the inventory app we have already seen that actions in a row can cause things to be added or removed from the list. We would love to be able to get test coverage on that integration.

@T(00:37:41)
In general, we think deep linking and testing is a great way to see just how well built your app is. You should be able to open your application in any state, and you should be able to test how multiple features integrate with each other.

@T(00:37:55)
So deep-linking and tests are great things to be able to have in an application, but unfortunately the `@State` and `@StateObjects` completely destroy our ability to do so. They create islands of functionality that stand on their own and cannot be influenced from the outside. This prevents you from launching your application so that you are automatically drilled down to a screen with a modal sheet opened on that screen. So, even if you are using all of SwiftUI’s fancy, state-driven navigation APIs, if you are using them with `@StateObject` you unfortunately will not have easy deep-linking capabilities. And it prevents you from writing integration tests between multiple features since `@StateObject` are installed at the view layer and never interact with each other.

@T(00:38:38)
That’s a bummer, but our inventory application does not suffer from these problems. We have full deep-linking capabilities and we can write integration tests. Let’s take a look at that now.

@T(00:38:52)
Deep linking can be done quite simply. We just have to construct a piece of state, hand it off to SwiftUI, and let SwiftUI do its thing. Constructing the state can even be fun. It’s like having a conversation with the compiler.

@T(00:39:07)
For example, constructing an `InventoryModel` consists of specify an optional destination:

```swift
inventoryModel: InventoryModel(
  destination: <#InventoryModel.Destination?#>,
  …
)
```

@T(00:39:23)
…and if we just type `.` then Xcode will give us a list of destinations we can navigate to.

@T(00:39:27)
So, let’s navigate to the `add` sheet:

```swift
inventoryModel: InventoryModel(
  destination: .add(<#ItemModel#>),
  …
)
```

@T(00:39:36)
Now we need to provide an `ItemModel`, and in order to do that you need to provide another optional destination and an item:

```swift
inventoryModel: InventoryModel(
  destination: .add(
    ItemModel(
      destination: <#ItemModel.Destination?#>,
      item: <#Item#>
    )
  ),
  …
)
```

The `item` represents what data will be pre-filled in the sheet when it appears, and so we can just put in a little bit of stub data:

```swift
inventoryModel: InventoryModel(
  destination: .add(
    ItemModel(
      destination: <#ItemModel.Destination?#>,
      item: Item(
        name: "Keyboard",
        color: .blue,
        status: .inStock(quantity: 100)
      )
    )
  ),
  …
)
```

@T(00:39:58)
And for the destination we can have that conversation with the compiler again. We can type “.” to see all the places we can navigate to, and the only choice is the color picker, so let’s go there:

```swift
inventoryModel: InventoryModel(
  destination: .add(
    ItemModel(
      destination: .colorPicker,
      item: Item(
        name: "Keyboard",
        color: .blue,
        status: .inStock(quantity: 100)
      )
    )
  ),
  …
)
```

@T(00:40:30)
And that now ends our conversation with the compiler. We have gotten to a leaf node of the navigation tree specified by all of our `Destination` enums, and so there is no where else to go.

@T(00:40:49)
And amazingly, if we run the application in the simulator we will see it starts in a state where the “Add” sheet is presented and we are drilled down to the color picker. This is the power of driving as much navigation as possible from state. You get to just construct state and let SwiftUI do the rest.

@T(00:41:10)
Absolutely incredible. The kind of deep linking we are seeing here is incredibly handy for testing flows of the app while developing. Why should we have to launch the app, switch to the inventory tab, tap on an item, and then further tap on a color picker if we want to test something in this specific flow? Why not just open the application in that exact state? You will save a ton of time if you can do this.

@T(00:41:36)
But another kind of deep linking that is important is URL deep linking. We dedicated an entire episode to showing how to build a URL router for this application, so we aren’t going to spend any time looking at that code. Instead we are just going to demo what it looks like.

@T(00:41:53)
We can open Safari in the simulator, and navigate to a URL like:

```
nav:///inventory/add/colorPicker
```

@T(00:42:12)
That should launch the application, switch to the inventory tab, open up the “Add” sheet, and further drill down to the color picker. And amazingly it does just that.

@T(00:42:15)
And with a little bit more work we can also set up push notification routing in this application. When we detect a notification is opened, we just have to pick apart the data to figure out where to route the user, construct a piece of data that represents that destination, and then hand it over to SwiftUI and let it do its thing.

@T(00:42:32)
And the only reason this is possible is because we have modeled all of navigation in state, and because all the features are integrated together. If we had used `@StateObject` at any layer of our application then we would not be able to link into a specific state of that layer.

@T(00:42:40)
So, we see that when it comes to deep linking our application is definitely up to the challenge. What about testing?

@T(00:42:46)
It’s of course easy enough to test a single feature in isolation because each feature has its own observable object. All we have to do is construct the model, hit some endpoints on it to emulate something that the user is doing, and then assert on how the data inside the model changed.

@T(00:43:00)
For example, in the `ItemRowFeature` we can test what happens when we try to delete the item. To test this flow we can create a model, invoke the `deleteButtonTapped` method to emulate the user tapping the button, confirm that the `destination` flipped to `.deleteConfirmationAlert`, and then invoke `deleteConfirmationButtonTapped` to emulate the user confirming and then making sure that the `destination` flipped back to `nil`:

```swift
func testDelete() {
  let model = ItemRowModel(item: .headphones)

  let expectation = self
    .expectation(description: "commitDeletion")
  model.commitDeletion = {
    expectation.fulfill()
  }

  model.deleteButtonTapped()
  XCTAssertEqual(
    model.destination, .deleteConfirmationAlert
  )

  model.deleteConfirmationButtonTapped()
  XCTAssertEqual(model.destination, nil)

  self.wait(for: [expectation], timeout: 0)
}
```

@T(00:43:29)
We’ve even further confirmed that the `commitDeletion` delegate method is called. In fact, if we did not override that closure with the expectation we would have gotten a different failure:

> Failed: testDelete(): Unimplemented: ItemRowModel.commitDeletion

@T(00:44:27)
This is thanks to the “unimplemented” closure we used as the default for the `commitDeletion` endpoint. It is forcing us to write a test to prove that it is called in the way we expect.

@T(00:44:47)
And as long as we believe that SwiftUI will do the correct thing with alerts when state changes, we can have faith that this test is actually testing what the user will see on the screen.  The fact that the `destination` becomes `.deleteConfirmationAlert` after tapping the delete button is proof that an alert will show, and the fact that the `destination` becomes `nil` after tapping the confirmation button is proof that the alert will go away. There’s no need to run UI tests, which are slow and flakey, and introduce a lot of instability into a testing environment.

@T(00:45:27)
So we truly are getting test coverage on all of the behavior in this view model. And there are similar tests for the edit and duplication flows.

@T(00:45:35)
But more interesting is to back up a level and consider the parent feature that has its own logic, but also integrates the logic of the row feature. This is the `InventoryFeature`, which manages a collection of items, allows adding an item, but also is the one that lists for the `commitDeletion` and `commitDuplicate` events in order to actually remove and append things to the collection.

@T(00:46:05)
We would love to be able to get test coverage on the interaction between these two features, and luckily it’s totally possible. Consider the delete flow. We just saw that testing deletion in isolation definitely works, but how do we know that when the row model invokes its `commitDeletion` closure that it makes it way up to the `InventoryModel` and causes the item to actually be removed?

@T(00:46:12)
Well, we have a unit test to confirm this. It starts by constructing a model with a single row in the list:

```swift
func testDelete() throws {
  let headphones = Item.headphones
  let model = InventoryModel(
    inventory: [ItemRowModel(item: headphones)]
  )

  …
}
```

@T(00:46:13)
Then we emulate the user tapping on the delete button by reaching directly into the first element of the inventory collection and invoking its `deleteButtonTapped` method:

```swift
model.inventory[0].deleteButtonTapped()
```

@T(00:46:24)
At this point we have two things we can assert. We expect the destination of the row to flip to `.deleteConfirmationAlert`:

```swift
XCTAssertEqual(
  model.inventory[0].destination,
  .deleteConfirmationAlert
)
```

But also due to the synchronization work between the inventory feature and row feature we expect the inventory’s `destination` to also flip to `.deleteConfirmationAlert`:

```swift
XCTAssertEqual(
  model.destination,
  .row(
    id: headphones.id,
    destination: .deleteConfirmationAlert
  )
)
```

@T(00:46:31)
Then we emulate the user confirming deleting by invoking the `deleteConfirmationButtonTapped` method:

```swift
model.inventory[0].deleteConfirmationButtonTapped()
```

@T(00:46:36)
And now we can assert that the inventory collection has been emptied out and the `destination` has gone back to `nil`:

```swift
XCTAssertEqual(model.inventory, [])
XCTAssertEqual(model.destination, nil)
```

@T(00:46:43)
This test passes, and if we believe SwiftUI will do the right thing with state, we can be very confident that when the user taps the delete button an alert comes up, when the user confirms in that alert it goes away, and that the list will animate away.

@T(00:46:50)
And this test really is capturing a bunch of the integration logic between the inventory feature and the row feature. For example, suppose that 6 months from now someone did some refactoring in the `bind` method and accidentally delete the code that hooked into the `commitDeletion` event:

```swift
private func bind(itemRowModel: ItemRowModel) {
  self.inventory.append(itemRowModel)

  // itemRowModel.commitDeletion = {
  //   [weak self, item = itemRowModel.item] in
  //   withAnimation {
  //     self?.delete(item: item)
  //   }
  // }

  …
}
```

@T(00:47:26)
The test now fails with two failures:

> Failed: testDelete(): Unimplemented: ItemRowModel.commitDeletion
>
> Failed: testDelete(): XCTAssertEqual failed: ("[ItemRowFeature.ItemRowModel]") is not equal to ("[]")

One of these we expect, which is that the inventory collection is not empty. Since we removed the `commitDeletion` hook we of course are not removing anything from the inventory.

@T(00:47:35)
But the really amazing part is the first error that lets us know that the `commitDeletion` closure is unimplemented. Without that error we would have had only a single error saying that the array is not empty. In isolation that error may be a little confusing and it may not be clear where the true bug lies. In fact, the test we are looking at only invokes methods on `ItemRowModel`'s that are inside the array, such as `deleteButtonTapped` and `deleteConfirmationButtonTapped`, and so we may erroneously think the bug lies in that class.

That would lead us to hop over to that class and investigate. But everything looks correct in `ItemRowModel`. So, what gives?

Well, the first error gives us a little bread crumb of information that will lead us to where the true bug lies. It helpfully lets us know that the `ItemRowModel` was not properly configured when it was created. In particular, its `commitDeletion` was never overridden, which means when the row model invokes that closure it is just going out into the void and no one is listening.

So, our test is leading us to the point of configuring the `ItemRowModel`, which happens in the `bind()` method, and lo and behold we not properly setting the `commitDeletion` closure.

## Next time: the problem

@T(00:48:27)
So, this is absolutely incredible. By making use of the powerful domain modeling tools that Swift gives us, such as enums, and by integrating all of our features together, we have an application that can deep link into any state in an instant, and we can write powerful, nuanced tests for features in isolation or the integration of multiple features.

@T(00:48:47)
So, we just wanted to take the time to show how our [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library can allow you to write a modern, vanilla SwiftUI application with precise domain modeling.

@T(00:48:57)
Just really, really cool stuff.

@T(00:48:59)
So, what’s the problem then? Why did Apple go and completely revamp the way navigation links work in SwiftUI?

@T(00:49:06)
Well, there were a few problems. Some things were very in-your-face and obvious, such as numerous bugs, especially when it came to deep linking multiple levels. Other things were not as obvious at first blush, but became apparent as applications grow bigger and more complex, such as a tight coupling of the source of navigation with the destination being navigated to.

@T(00:49:27)
Let’s take a look at both of these problems so that we can understand why they are so pernicious, and then that will help us understand why the navigation link APIs were changed the way they were.

@T(00:49:38)
Let’s start with the bugs. There are plenty of navigation bugs, but the one that would get everyone sooner or later is that you cannot deep link in a navigation view more than 2 layers. We haven’t run into that problem in our inventory app because so far the maximum number of levels you can drill down is two: first to the item screen, and then to the color picker.

@T(00:49:58)
It may seem lucky that we didn’t have to drill down 3 levels in the app, but honestly we consciously engineered the app specifically to avoid that problem. So, we can’t see the problem in the app currently, but let’s quickly stub a view into the application that clearly shows something going wrong...next time!
