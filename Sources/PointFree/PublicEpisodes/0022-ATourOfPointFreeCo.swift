import Foundation

let ep22 = Episode(
  blurb: """
Join us for a tour of the code base that powers this very site and see what functional programming can look like in a production code base! We'll walk through cloning the repo and getting the site running on your local machine before showing off some of the fun functional programming we do on a daily basis.
""",
  codeSampleDirectory: "",
  id: 22,
  exercises: exercises,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0022-tour-of-pointfreeco/poster.jpg",
  length: 39*60 + 21,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1531735023),
  sequence: 22,
  sourcesFull: [
    "https://d1hf1soyumxcgv.cloudfront.net/0022-tour-of-pointfreeco/tour-de-pointfree.m3u8",
    "https://d1hf1soyumxcgv.cloudfront.net/0022-tour-of-pointfreeco/tour-de-pointfree.webm"
  ],
  sourcesTrailer: [
    "https://d1hf1soyumxcgv.cloudfront.net/0022-tour-of-pointfreeco/trailer/hls-trailer.m3u8",
    "https://d1hf1soyumxcgv.cloudfront.net/0022-tour-of-pointfreeco/trailer/webm-trailer.webm",
  ],
  title: "A Tour of Point-Free",
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [

]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Today we're going to take a small break from the regular format. We're not going to be covering any new functional programming concepts or doing any deep dives or refactorings. Instead, we're going to take a little tour of the code base that runs [this very site](https://www.pointfree.co). It's all written in Swift! Server-side Swift!
""",
    timestamp: (0*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
From the very beginning we knew we wanted to make this website using Swift, doing so in a functional way, as open source. You can still go back and see [the very first commit](https://github.com/pointfreeco/pointfreeco/commit/548dc6bffcb01cb0e0ec07559e5d33dece24c686) we pushed.
""",
    timestamp: (0*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We knew we wanted to do this because of our work at Kickstarter where we [open sourced the app](https://github.com/kickstarter/ios-oss) to show people how a real production code base can be written in a functional style. Open sourcing a real code base was one of the best tools we could think of for showing folks what functional programming could do!
""",
    timestamp: (0*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It showed us how new features could be built simply, tests could be written simply, and it continued to open up doors left and right.
""",
    timestamp: (1*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We want to use the Point-Free website as _another_ example of how functional programming can work in a production code base, and we want to show some of the cool things we're doing. Some of these ideas we've already covered in various episodes of Point-Free!
""",
    timestamp: (1*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We'll start by showing our viewers how they can pull down the site and get it running locally.
""",
    timestamp: (1*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Cloning the repo",
    timestamp: (1*60 + 30),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
The first thing you need to do is open up GitHub to <https://github.com/pointfreeco/pointfreeco>. This is the repo that holds the entire site's source code. We can copy the clone URL, open a terminal, and pull it down!
""",
    timestamp: (1*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
$ git clone https://github.com/pointfreeco/pointfreeco.git
Cloning into 'pointfreeco'...
""",
    timestamp: nil,
    type: .code(lang: .other("sh"))
  ),
  Episode.TranscriptBlock(
    content: """
It takes a little while to download because it's a fairly large repo. We do [snapshot testing](https://www.stephencelis.com/2017/09/snapshot-testing-in-swift) and store all of those artifacts in the repo itself.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now that we have things cloned, let's `cd` into the repo and check things out.
""",
    timestamp: (1*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
$ cd pointfreeco
$ ls
CC-LICENSE.md         OSS.xcconfig          README.md
Development.xcconfig  Package.resolved      Sources
Dockerfile            Package.swift         Tests
Dockerfile.local      PointFree.playground  database
LICENSE               PointFree.xcodeproj   docker-compose.yml
Makefile              PointFree.xcworkspace
""",
    timestamp: nil,
    type: .code(lang: .other("sh"))
  ),
  Episode.TranscriptBlock(
    content: """
There's a bunch of stuff, in particular a `Makefile` that holds a whole bunch of commands that do common things for us, including a `bootstrap` command that should hopefully set up your local environment.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's run `make`!
""",
    timestamp: (2*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
$ make
  ⚠️ Bootstrapping open-source Point-Free...
  ⚠️ Preparing local configuration...
  ✅ .env file copied!
  ⚠️ Checking on cmark...
  ✅ cmark is installed!
  ⚠️ Checking on PostgreSQL...
  ✅ PostgreSQL is up and running!
  ⚠️ Generating PointFree.xcodeproj...
  ✅ Generated!
  ⚠️ Point-Free installs module maps into your Xcode SDK path to enable
     playground support. If you don't want to run playgrounds, bootstrap with:

       $ make bootstrap-oss-lite

     You can undo this at any time by running the following:

       $ make uninstall-mm

  🔒 Please enter your password:
""",
    timestamp: nil,
    type: .code(lang: .other("sh"))
  ),
  Episode.TranscriptBlock(
    content: """
The bootstrap has already done a few things. It's copied over an environment (`.env`) file to set up environment variables for the server. It's checked if [`cmark`](https://github.com/commonmark/cmark) is installed, which is what we use for rendering Markdown. It's checked if [PostgreSQL](https://www.postgresql.org) is installed. If neither one of these is installed it gives instructions on how you can go set them up. The script then generates an Xcode project for you, before we finally get a prompt to enter our user password.
""",
    timestamp: (2*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In order to run our playgrounds, we need them to be able to access to our dependencies. Our dependencies include `CommonCrypto`, which we used to encrypt our cookies. We also use `cmark` and Postgres, as we mentioned earlier. Playgrounds only have access to modules in the SDK path. Providing a password here will copy local module maps for these dependencies so that playgrounds can access them. If you don't want to install these module maps, you can alternatively run `make bootstrap-oss-lite`. We like playgrounds, so we're going to authenticate.
""",
    timestamp: (2*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
  ✅ Module maps installed!
  ✅ Bootstrapped! Opening Xcode...
""",
    timestamp: (3*60 + 20),
    type: .code(lang: .other("sh"))
  ),
  Episode.TranscriptBlock(
    content: """
The script even conveniently opens Xcode for us!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
A quick word of warning: if you have multiple Xcodes installed, this may open the wrong one as so right now it may be a good time to check that you are on Xcode 9.4 or earlier. At this moment we don't yet support Xcode 10.
""",
    timestamp: (3*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[We now support Xcode 10](https://github.com/pointfreeco/pointfreeco/pull/262), but be sure to have `xcode-select` pointed to the right Xcode when you run `make`!
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
If we look at all of the project targets we'll see that something called `PointFree-Package` is selected by default. There are many more packages below it, which the Swift Package Manager is generating for whatever reason. Hopefully they'll clean this up in the future.
""",
    timestamp: (3*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's start by selecting `PointFree-Package`, which contains the bulk of the app logic, and let's run Command-B (⌘B) to get things building.
""",
    timestamp: (4*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
That was pretty quick and that just built the vast majority of the code that runs our website. While we're here, let's also type Command-U (⌘U) to run the entire test suite.
""",
    timestamp: (4*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
OK, they passed! In the Report Navigator we can see all the tests listed. This includes a fun mixture of unit tests, HTTP request-to-response tests, even screen shot tests.
""",
    timestamp: (4*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now for the real reason you're here: let's run the app! If you select the `Server` target, you can hit Command-R (⌘R) to spin up a server.
""",
    timestamp: (4*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And it's running! If you check out the log output, you'll see some text output that describes the process of starting up and bootstrapping the Point-Free website.
""",
    timestamp: (4*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
⚠️ Bootstrapping PointFree...
  ⚠️ Loading environment...
  ✅ Loaded!
  ⚠️ Connecting to PostgreSQL...
  ✅ Connected to PostgreSQL!
  -----------------------------
✅ PointFree Bootstrapped!
Listening on 0.0.0.0:8080...
""",
    timestamp: nil,
    type: .code(lang: .other("sh"))
  ),
  Episode.TranscriptBlock(
    content: """
And now we can switch over to a web browser and go to <http://localhost:8080>.
""",
    timestamp: (5*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's the Point-Free website running on your local machine!
""",
    timestamp: (5*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The open source build brings in [all the episodes that are currently free](https://github.com/pointfreeco/pointfreeco/tree/master/Sources/PointFree/PublicEpisodes). We have a private repo for the subscriber-only episodes, but all the public ones are just sitting right here so you can browse around, click on one, see the entire episode and its transcript. You can even go to the blog and read a blog post. You can go to the subscribe screen and see all of the subscription options. We can't log in, but that's because we have a GitHub application that we use for our authentication. Now, if you wanted to, you could go create your own GitHub app and plug it in, but we're not going to get into that here.
""",
    timestamp: (5*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now that the site is up and running, let's take a quick tour of the project's structure. At the top-level we have a couple Markdown files that contain information about the site. We then have a playground (we'll get to that in a moment), and we have the Xcode project.
""",
    timestamp: (6*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We also have a [`Package.swift`](https://github.com/pointfreeco/pointfreeco/blob/592f71175e01de1609f2c349d6301be360fdf132/Package.swift) file. We use the [Swift Package Manager](https://github.com/apple/swift-package-manager) to manage all of our dependencies. If we view this file, we'll find a couple of libraries and executables that ship with our site.

- We have the `PointFree` library, which contains all the actual, real code that runs our site.
- We have a `PointFreeTestSupport` library, which holds code that is very helpful for testing. The reason we pulled this into library is because we get access to it and playgrounds.
- We have a `Runner` executable, which is how we're gonna do cron jobs, but we actually haven't done that yet it's just kind of sitting there waiting for us to use it.
- We have the actual `Server` executable, which uses NIO to fire everything up and hand everything off to the `PointFree` library.
- We have `Styleguide`, which is a fun little library that has all of our CSS styling, components, and colors. The vast majority of styling exist in that framework, and that framework knows nothing about the rest of our website. It's fully extracted and put away.
""",
    timestamp: (6*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Listed after our targets are all of our dependencies.

- We have [`swift-prelude`](https://github.com/pointfreeco/swift-prelude), which we wrote and love.
- We've got our [`swift-snapshot-testing`](https://github.com/pointfreeco/swift-snapshot-testing) library that we use for snapshot testing.
- We've got our [`swift-web`](https://github.com/pointfreeco/swift-web) library, which has all of our web infrastructure for doing views and CSS and middleware and routing.
- We've got [`cmark`](https://github.com/commonmark/cmark), which we use for rendering Markdown.
- We also use [a Postgres library](https://github.com/vapor-community/postgresql) from the [Vapor community](https://github.com/vapor-community).
""",
    timestamp: (7*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
At the end of this file we describe how all of these targets and dependencies fit together.
""",
    timestamp: (7*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
If you expand our [`Sources`](https://github.com/pointfreeco/pointfreeco/tree/592f71175e01de1609f2c349d6301be360fdf132/Sources) directory you'll see there's a subdirectory for every single one of the products we defined in `Package.swift`.
""",
    timestamp: (8*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The only one we're really going to talk about is `PointFree`. If we expand `PointFree` we'll see a bunch of source files. It's a little bit messy and maybe not the best way of organizing these things, but we're not super interested in figuring out a deep hierarchy of directories and folders to put things in. Still, you can click around and explore. If you select [`Bootstrap.swift`](https://github.com/pointfreeco/pointfreeco/blob/592f71175e01de1609f2c349d6301be360fdf132/Sources/PointFree/Bootstrap.swift) you'll see the logging that we saw earlier upon starting the server. It's all contained right here: loading up environment variables, episodes that we want to show to the user, and connecting to Postgres!
""",
    timestamp: (8*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Everything in the `PointFree` directory is application code: the business logic that runs our site. If we open up the the `Server` directory we'll see just a single file, [`main.swift`](https://github.com/pointfreeco/pointfreeco/blob/592f71175e01de1609f2c349d6301be360fdf132/Sources/Server/main.swift). This file is super short and merely executed the bootstrap code and runs the server by attaching to something called `siteMiddleware`.
""",
    timestamp: (8*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is the entirety of [Swift NIO](https://www.github.com/apple/swift-nio) in our application: `run` is a helper that we've written that sits in the [`swift-web`](https://github.com/pointfreeco/swift-web) library. It connects what we call middleware to what their lower-level library. This is all the server is! And it's our entire dependence on NIO.
""",
    timestamp: (9*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Just a few months ago we ran the entire server off Kitura. When NIO came out, [we were able to swap it in](https://github.com/pointfreeco/pointfreeco/pull/206) for Kitura by changing this one file.
""",
    timestamp: (9*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Preach & practice: playgrounds",
    timestamp: (9*60 + 40),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
On this series, we've said a couple of times that we like to "practice what we preach". What this means is that we're not talking about functional programming and wild ideas just to seem cool and smart. We talk about functional programming because we think it has real-world application: we use these things! We don't want to push anything on anyone that we don't use ourselves.
""",
    timestamp: (9*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's talk about a few things on the site that we've talked about in the series and elsewhere and show how we practice what we preach!
""",
    timestamp: (10*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We're all about [playground driven development](https://www.pointfree.co/episodes/ep21-playground-driven-development). When we started doing server-side Swift we immediately came face-to-face with the fact that we didn't have a good development cycle for running our code. Very early on we started exploring how server-side Swift mixed with playgrounds.
""",
    timestamp: (10*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
At the top-level of our project we have a playground, and inside it are a whole bunch of playground pages that deal with various screens and logic of our site.
""",
    timestamp: (10*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example I can go to the [`Episode Page`](https://github.com/pointfreeco/pointfreeco/blob/592f71175e01de1609f2c349d6301be360fdf132/PointFree.playground/Pages/Episode%20Page.xcplaygroundpage/Contents.swift) playground, run it, and bring up the live view: there's the website, running right here! Not the actual website, but we can see this particular page!
""",
    timestamp: (10*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's kind of big right, but we can bring it down to an iPhone size.
""",
    timestamp: (11*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is the episode page _when you're logged-out_: you can see that there's a "Login" button in the header. When you're logged-out it also means you're not a subscriber, so we have a bunch of copy and buttons that try to entice you to subscribe. One thing I can do is tweak the request that serves this page to make it look like I _am_ logged-in, and not only logged-in, but also a subscriber. This little request helper we have has a `session` parameter that I can provide a logged-in value.
""",
    timestamp: (11*60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
When I run the playground, we see that the "Login" button went away and I now have an "Account" link there instead. Even better, I now have access to the whole transcript! I didn't have to play around with a GitHub connection or log into GitHub! We don't even _have_ GitHub set up yet I'm still able to log in! How amazing is that? We completely removed our dependency on GitHub in this playground.
""",
    timestamp: (11*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's check out the [`Account`](https://github.com/pointfreeco/pointfreeco/blob/592f71175e01de1609f2c349d6301be360fdf132/PointFree.playground/Pages/Account.xcplaygroundpage/Contents.swift) page. We instantly get to see what it looks like for someone who is clearly a subscriber but has also unsubscribed from some of our emails 😞
""",
    timestamp: (12*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We don't only use playgrounds for web pages. We also use playgrounds to poke at library code to get comfortable with it and explore it when we see weird behavior. For example, we have a playground set up for the router!
""",
    timestamp: (12*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is a place for us to explore how the router works and make sure we're using it correctly. I can run it and we get a printout.
""",
    timestamp: (12*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let urlString = "https://localhost:8080/account/subscription/change"

router.match(string: urlString)!
// .account(.subscription(.change(.show)))
""",
    timestamp: (13*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What's happening here in this line here we're telling the router to match against a URL string. It routes the string to a first-class value: `.account(.subscription(.change(.show))).
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
What's really cool about our router is that it not only routes a string to a first-class Swift type, but it can also generate a request from a first-class route.
""",
    timestamp: (13*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
router.request(
  for: .account(.subscription(.change(.show)))
  base: URL(string: "https://www.pointfree.co")
)
""",
    timestamp: (13*60 + 32),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here I'm saying: take the router and generate a request to the `.account(.subscription(.change(.show)))` page using "pointfree.co" as the base URL. What I get back is essentially what our router used earlier in the page.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's pretty amazing that we get to play with the router like this.
""",
    timestamp: (13*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I'm going to try using it:
""",
    timestamp: (13*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
router.match(string: "/")
// .home
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It matches our `.home` route!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I can also route to the blog.
""",
    timestamp: (14*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
router.match(string: "/blog")
// .blog(.index)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This goes to the blog's index.
""",
    timestamp: (14*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
router.match(string: "/blog/1")
// nil
""",
    timestamp: (14*60 + 09),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This one fails because we didn't provide a proper slug!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
router.match(string: "/blog/1-hello-world")
// nil
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's it _still_ fails because this slug doesn't exist!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
router.match(string: "/blog/1-announcing-point-free-pointers")
// .blog(.show(BlogPost))
""",
    timestamp: (14*60 + 33),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we get an actual value: it's the route to the blog's show page with an associated blog post attached!
""",
    timestamp: (14*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This router is really fascinating! Not only is it type-safe, it's _invertible_: you get to route a string to a first-class value, but then you also get to print a route to a string so that you can link to parts of your site. We're going to have lots of episodes about it in the future.
""",
    timestamp: (14*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Preach & practice: dependencies",
    timestamp: (15*60 + 11),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We saw a familiar face in these playgrounds: our [`Current` environment](https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy). We practice what we preach! We use `Environment` in this code and other code bases. Let's take a look!
""",
    timestamp: (15*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is the environment for the Point-Free website.
""",
    timestamp: (15*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
public var Current = Environment()

public struct Environment {
  public private(set) var assets = Assets()
  public private(set) var blogPosts = allBlogPosts
  public private(set) var cookieTransform = CookieTransform.encrypted
  public private(set) var database = Database.live
  public private(set) var date: () -> Date = Date.init
  public private(set) var envVars = EnvVars()
  public private(set) var episodes = { [Episode]() }
  public private(set) var features = [Feature].allFeatures
  public private(set) var gitHub = GitHub.live
  public private(set) var logger = Logger()
  public private(set) var mailgun = Mailgun.live
  public private(set) var stripe = Stripe.live
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It looks very similar in format to [the one that we defined in the series](https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy). This is also the entirety of the file!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We have our global, mutable `Current` and we have a bunch of `private(set) var`s. We do this to keep ourselves honest: we don't want to be mutating our environment in our production code base. It's something we omitted from [the episode](https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy), but it's a nice tip and we'll be covering it in the future.
""",
    timestamp: (15*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Here we have a bunch of interesting dependencies. We have our good, old friend, `date`. We also have a live database, a live GitHub client for managing login, a live Mailgun client for sending email, a live Stripe client for payment processing.
""",
    timestamp: (16*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And we have a bunch of other values that are nice to mock out when we're in our tests.
""",
    timestamp: (16*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Speaking of tests, if we go over to [`PointFreeTestSupport.swift`](https://github.com/pointfreeco/pointfreeco/blob/592f71175e01de1609f2c349d6301be360fdf132/Sources/PointFreeTestSupport/PointFreeTestSupport.swift) we immediately see our mock `Environment`. It's also going to look pretty familiar. All these subdependencies have mocks. You can hop on over to the `Database` mock, and there is a lot going on there, but it gives us nice defaults for all these different queries that we make to our Postgres database.
""",
    timestamp: (16*60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We have a bunch of functions to fetch users by id or by GitHub login. And in each mock version we return a default, mock value.
""",
    timestamp: (16*60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And just below out mock `Database` we have our mock `Database.User`. We've gotten so many benefits from making sure that we have mock versions of all of our data structures because it allows us to effortlessly pluck data in various forms out of thin air, making testing a breeze.
""",
    timestamp: (17*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
All of our mocks live in this one file, which may seem scary to people because it's a decently long file, but there's _zero_ behavior in it! It's _just data_. We create mock values of structs and enums and write it all here in one place. It actually works out quite nicely! It's not complex and really doesn't need to feel scary, and it's helped us achieve some very good test coverage!
""",
    timestamp: (17*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
If we go back to the `Episode Page` playground, we can see that we swap out `Current` with a `.mock` environment and everything just works! We're able to very simply replace the whole live world with a mock world, which is incredibly handy in both playgrounds and tests. It's as simple as that!
""",
    timestamp: (18*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
There's no chance of accidentally sending off an email, tracking analytics, or hitting Stripe. You use a mock environment and you don't have to worry about making live changes to the world.
""",
    timestamp: (18*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Meanwhile, we still have access to the live environment when we want it! We have another playground for our database! This playground does not replace our environment with a mock version because we _want_ to be able to test that our database is working as we expect when developing against a local setup. We're not worried about dropping production data, so it's pretty safe to run.

It's truly amazing the range and flexibility that playgrounds afford us, and `Current` environment makes it all that much better!
""",
    timestamp: (18*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Playgrounds replace REPLs and things like `rails console`. In Rails, `rails console` allows you to fire up a REPL and the entire environment of your app, where you can do database queries and the like. We've replaced all of that with a playground!
""",
    timestamp: (19*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Preach & practice: operators",
    timestamp: (19*60 + 24),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Another thing that we preach a lot but also practice is the use of operators. We think that operators are key to unlocking function composition. We've spent a lot of time [giving names to operators](https://www.pointfree.co/episodes/ep11-composition-without-operators) to help people who can't use operators embrace function composition, but there's still a limitation to those named functions.
""",
    timestamp: (19*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's check out a couple places where we use operators and think we unlock some interesting compositions.
""",
    timestamp: (19*60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Over in `main.swift` we noticed that we are running this `siteMiddleware` value on some port.
""",
    timestamp: (19*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
run(siteMiddleware, on: Current.envVars.port, gzip: true)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We said that `run` is library code that exists outside of the Point-Free code base, but `siteMiddleware` is a value that lives right here in the `PointFree` library, so let's check it out!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
public let siteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  requestLogger { Current.logger.info($0) }
    <<< requireHerokuHttps(allowedInsecureHosts: allowedInsecureHosts)
    <<< redirectUnrelatedHosts(isAllowedHost: { isAllowed(host: $0) }, canonicalHost: canonicalHost)
    <<< route(router: router, notFound: routeNotFoundMiddleware)
    <| currentUserMiddleware
    >=> currentSubscriptionMiddleware
    >=> render(conn:)
""",
    timestamp: (20*60 + 17),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
That's intense! There are _three_ operators on the screen right now. I'm sorry! But there are some interesting things going on here! We have a concept of "middleware", which is the fundamental unit of composition we have in our server. It is what describes how to transform a request into a response. It also packages up the side effects inside. You may notice that we have a fish operator (`>=>`) here, and that's because we're executing side effects. We saw this in [our second episode](https://www.pointfree.co/episodes/ep2-side-effects): the fish operator helps you compose functions where side effects are involved. That's exactly what is happening here!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We also have backwards arrow (`<<<`) composition! We showed in [Setters](https://www.pointfree.co/episodes/ep6-functional-setters) that the backwards arrow allowed us to traverse deeply into nest in structures and make changes. What is backwards arrow doing here?
""",
    timestamp: (21*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
These aren't setters, but they _are_ higher order functions, just like setters. The code that precedes each backwards arrow, like `requestLogger`, `requireHerokuHttps`, and `redirectUnrelatedHosts`, are what we call "middleware transformers". They transform one middleware into another middleware. Middleware are functions themselves, so it's a function _between_ functions. As we saw with [setters](https://www.pointfree.co/episodes/ep6-functional-setters), these functions, for very well-known but unintuitive reasons, compose _backwards_.
""",
    timestamp: (21*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We learned early on that our transformers composed backwards even though it made no sense to us. The `requestLogger` middleware runs first, then `requireHerokuHttps`, then `redirectUnrelatedHosts`, but it's all composed together using _backwards_ arrows.
""",
    timestamp: (21*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Finally, while we've talk about "pipe forward" operator (`|>`) in this series, we've never talked about "pipe backward". This is necessary because we first compose all of our middleware together using `>=>`, and then we compose all of our transformers together using `<<<`, and we finally want to plug our composed middleware into our composed transformer. `<|` is a natural candidate for that!
""",
    timestamp: (22*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Middleware transformers are a lot like what Ruby on Rails calls [filters](http://guides.rubyonrails.org/action_controller_overview.html#filters). Rails has `before_filter`s and `after_filter`s and `around_filter`s, and each of these middleware transformers is like an `around_filter` because it is just wrapping that transformation. With that in mind, backwards composition begins to make a little more sense because it's that same nesting we saw when composing into deeper setters, and here we're going deeper and deeper into our middleware transformer stack.
""",
    timestamp: (22*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I think it's really fun that we kinda accidentally stumbled upon this. We had our middleware concept, and we knew it was gonna be useful to transform one middleware into another. We pretty much completely replaced the need for any concept of `before_filter`, `after_filter`, or `around_filter`, because this one thing does it all and it's just function composition!
""",
    timestamp: (23*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
These operators are composing quite a few things! We're composing _four_ middleware transformers and _three_ middlware! Operators allow you to compose any number of things because of precedence groups. The alternative named functions would be `pipe` and `chain`, although `pipe` was for forward composition, and this is backwards composition so we need a _new_ name.
""",
    timestamp: (23*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
That's the trouble with names! Worse was we had to overload them for every number of arguments that we wanted to support. With operators we don't have to worry about all that! We just keep on composing.
""",
    timestamp: (23*60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We're used to operators and they work great! It can definitely look scary because if you don't know what they're doing, it's difficult to read. But as soon as you _do_ know what they're doing, it's much easier to read _and_ maintain.
""",
    timestamp: (24*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Preach & practice: testing",
    timestamp: (24*60 + 17),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's look at one more "practice what we preach": how we test!
""",
    timestamp: (24*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's hop over to a typical test, `AccountTests.swift`.
""",
    timestamp: (24*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func testAccount() {
  Current = .teamYearly

  let conn = connection(from: request(to: .account(.index), session: .loggedIn))
  let result = conn |> siteMiddleware

  assertSnapshot(matching: result.perform())

  #if !os(Linux)
  if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
    let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
    webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
    assertSnapshot(matching: webView, named: "desktop")

    webView.frame.size.width = 400
    assertSnapshot(matching: webView, named: "mobile")
  }
  #endif
}
""",
    timestamp: (24*60 + 34),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here we have a full test and it looks a lot like the playground code we were looking at earlier. We're building up a connection given a request, in this case to the account index route, and we are simulating that the session is logged-in, because we require it for our account page.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We are using `assertSnapshot`, which is a helper provided by our [`swift-snapshot-testing`](https://github.com/pointfreeco/swift-snapshot-testing) library, which allows us to take a snapshot of data structures.
""",
    timestamp: (24*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertSnapshot(matching: result.perform())
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Our viewers may be familiar with the idea of screenshot testing, and there are some great libraries out there! The idea of taking snapshots of _data_ is just next level stuff! We are asserting on the results of an HTTP request: it captures all the headers and all of the body. Let's take a look!
""",
    timestamp: (25*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Snapshots are automatically generated and saved in a `__Snapshots__` directory. They live right alongside our tests. Here we have all of our account tests and they all have a bunch of snapshots. In this case we have this one for `testAccount`, which was the test we were looking at earlier.
""",
    timestamp: (25*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The thing that gets emitted for our first assertion is this file.
""",
    timestamp: (25*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
▿ Step
  ResponseEnded

▿ Request
  GET http://localhost:8080/account
  Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}

  (Data, 0 bytes)

▿ Response
  Status 200 OK
  Content-Length: 37719
  Content-Type: text/html; charset=utf-8

  <!DOCTYPE html>…
""",
    timestamp: nil,
    type: .code(lang: .other("txt"))
  ),
  Episode.TranscriptBlock(
    content: """
It might be a little difficult to parse, but a lot of this is just the raw representation of our connection response.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This ensures that the connection completed: it is in the `ResponseEnded` state. Then we have our request: we note that it's to a particular page, we have a cookie set which is what all those helpers did for us. The request had no data so we just don't have a body to read here. Finally we have a response with the status code, all the headers that got, and the payload. The payload's huge! Why would we ever want to snapshot this?
""",
    timestamp: (26*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This snapshot is an artifact that, every time we run tests, gets checked. If anything changes on this page the test will fail and we'll have to audit that change. It has caught so many bugs in the process! There are many, very small changes that we've made unintentionally, and it's kind of remarkable that this kind of testing is not more popular.
""",
    timestamp: (26*60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This particular snapshot is just a blob of text right now and we do want to improve its actually pretty print the HTML, we just haven't had a lot of time recently.
""",
    timestamp: (26*60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[CORRECTION WITH LINK]
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We call `assertSnapshot` a couple other times in this test.
""",
    timestamp: (27*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
#if !os(Linux)
if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
  let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
  webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
  assertSnapshot(matching: webView, named: "desktop")

  webView.frame.size.width = 400
  assertSnapshot(matching: webView, named: "mobile")
}
#endif
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We don't run these tests on Linux because it doesn't have access to web views, which is what we use to render our HTML payload into an actual image. Here we create a `WKWebView` and give it the HTML we generated and we assert against that web view. We can even change the width of that when you to see if it's rendering in a responsive way: we have a desktop version and a mobile version of each snapshots.
""",
    timestamp: (27*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We can take a look at this snapshot and see the rendered desktop version of this account page! It's just like the screenshot testing that folks may be used to, but for the web! And we can just as easily view the mobile version of the same screen. All these tests ensure nothing changes visually by accident.
""",
    timestamp: (27*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
These screen shots look a lot like the playground we were looking at earlier. We have the playground feedback loop and then we get to take a snapshot, commit it, and use it for our tests to make sure we don't accidentally break anything.
""",
    timestamp: (28*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
All these ideas just kind of play so nicely together.
""",
    timestamp: (28*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We even updated a small CSS library a couple weeks ago and it only changed a few little things but it broke a whole bunch of tests! The way it broke the test was that it fixed something that we've been wanting to fix for a long time! We had visual proof that it fixed that and broke nothing else.
""",
    timestamp: (28*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Adding a feature",
    timestamp: (28*60 + 54),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
It might be interesting to try to code up a quick little feature for the site.
""",
    timestamp: (28*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Here we are back on the local dev site. Down in the footer we have this contact link that just links to our support email. It might be better if we had a dedicated support page that provided our email but also allowed someone to send us a message on that page.
""",
    timestamp: (29*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
A lot of the the bugs we get emails about could have also been GitHub issues that could have been opened up and then we could have track them there! Maybe we'll let people know that the site is open source and that they can also file an issue.
""",
    timestamp: (29*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's see what it would take to get the basics of that in place. It all begins in our routes. We have a `PointFreeRoutes.swift` file, which has a huge enum that describes all of the routes that you can visit on our website: our about page, account page, invite page, etc.
""",
    timestamp: (29*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
public enum Route: DerivePartialIsos {
  case about
  case account(Account)
  case admin(Admin)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
I'm gonna add a new route: the support route!
""",
    timestamp: (29*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
case support
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's do a quick build to see what breaks.
""",
    timestamp: (30*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We have one error:

> 🛑 Switch must be exhaustive

In our site's middleware, there's a switch that we're doing on that enum and well of course we don't have the `support` case, so let's put in a `fatalError` to make this happy.
""",
    timestamp: (30*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
With that done let's update our _router_. Those cases are our routes, but our _router_ is the way in which we describe how to transform an incoming request into a `Route` value. And secretly under the hood the mere fact of describing how to do that parsing you're also describing how to do printing in the reverse direction.
""",
    timestamp: (30*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
private let routers: [Router<Route>] = [

  .about
    <¢> get %> lit("about") <% end,

  .account <<< .confirmEmailChange
    <¢> get %> lit("account") %> lit("confirm-email-change")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, .tagged))
    <% end,
""",
    timestamp: (30*60 + 49),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So here it is! There's a lot here. There are a bunch of new operators. I totally get how intimidating this can be and how it just looks like computer barf. We've even got backwards arrows!
""",
    timestamp: (30*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Without explaining all the details of this, because we are gonna have lots of episodes about it, I'm just going to implement the route
""",
    timestamp: (31*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So when you look at this route here you'll you'll see that that we're backwards composing some things together.
""",
    timestamp: (31*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.webhooks <<< .stripe <<< .fallthrough
  <¢> post %> lit("webhooks") %> lit("stripe") <% end,
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What are these things? If I command click on it, what we'll see is that it's something called a `PartialIso`.
""",
    timestamp: (31*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension PartialIso where A == (
      Route.Webhooks
  ), B == Route {

    public static let webhooks = parenthesize <| PartialIso(
      apply: Route.webhooks,
      unapply: {
        guard case let .webhooks(result) = $0 else { return nil }
        return .some(result)
    })
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is also something we don't want to get into right now, but it's just a very small bit of boilerplate that unlocks all the cool router stuff. Luckily, we have a Sourcery command that is going to generate all that boilerplate for us.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's hop over to a terminal window and run a `make` command.
""",
    timestamp: (31*60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
$ make sourcery
  ⚠️ Checking on Sourcery...
  ✅ Sourcery is installed!
  ⚠️ Generating routes...
  ✅ Generated!
  ⚠️ Generating tests...
  ✅ Generated!
""",
    timestamp: nil,
    type: .code(lang: .other("sh"))
  ),
  Episode.TranscriptBlock(
    content: """
If we run `git status`, we'll see what changed.
""",
    timestamp: (31*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   Sources/PointFree/Routers/PointFreeRoutes.swift
	modified:   Sources/PointFree/SiteMiddleware.swift
	modified:   Sources/PointFree/__Generated__/DerivedPartialIsos.swift

no changes added to commit (use "git add" and/or "git commit -a")
""",
    timestamp: nil,
    type: .code(lang: .other("sh"))
  ),
  Episode.TranscriptBlock(
    content: """
We can see that something in `__Generated__/DerivedPartialIsos.swift` has changed. If I look at the diff:
""",
    timestamp: (31*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
+      extension PartialIso where A == Prelude.Unit, B == Route {
+        public static let support = parenthesize <| PartialIso<Prelude.Unit, Route>(
+          apply: const(.some(.support)),
+          unapply: {
+            guard case .support = $0 else { return nil }
+            return .some(Prelude.unit)
+        })
+      }
""",
    timestamp: nil,
    type: .code(lang: .other("diff"))
  ),
  Episode.TranscriptBlock(
    content: """
What I'll see is that what was added was some extension to a partial I so that just does a little bit of boilerplate. This boilerplate will probably someday be implemented by Swift to give us easy access to the associated values of enums. With this boilerplate at our disposal, we have this `support` value and we can use it much like we're using the other router values.
""",
    timestamp: (32*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// /support
.support
  <¢> get %> lit("support") <% end,
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This tells our router that we're gonna route GET requests with a path that matches the string literal `"support"`, matching the path `/support`!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's build this.

It succeeds, but over in `siteMiddleware`, where we added the `support` case and we call `fatalError()`,  we need to do something instead of crash.
""",
    timestamp: (32*60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's do the easiest thing possible.
""",
    timestamp: (33*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
case .support:
  return conn
    |> writeStatus(.ok)
    >=> respond(text: "Support Page")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We take our `conn` value, which represents the request coming in _and_ the response going out, and we provide some transformations on it to get it into a shape that can be sent out to the browser. In this case we pipe it into middleware that first writes the status code as `OK`, meaning there's no way for this request to fail, it just gets served whatever content comes next. Now that we've written the status we could write some headers, but we don't really need to, so we just respond with some text.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We compose with `>=>` because each of these steps can execute side effects. Let's run this!
""",
    timestamp: (33*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's running! When I hop back over to the browser and navigate to `/support`, I've got the support page!
""",
    timestamp: (33*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Support Page
""",
    timestamp: nil,
    type: .code(lang: .other("txt"))
  ),
  Episode.TranscriptBlock(
    content: """
Let's make it a little bit nicer. Let's provide a `supportView` that we're gonna build HTML in.
""",
    timestamp: (34*60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Our views are functions and these functions are generic over the type of data that they are viewing. In this case we don't have any data that were actually viewing so I want to make it a view on `Void`. It's just a function that takes that `Void` value and then spits out some HTML DOM. We have [an entire library](https://github.com/pointfreeco/swift-web#html) that models HTML in Swift types and it's super composable and super transformable. I'm gonna use it without much explaining because we're also gonna have episodes that cover it in the future.
""",
    timestamp: (34*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let supportView = View<Void> {
  html([
    body([
      h1(["Welcome to the support page!"])
      ])
    ])
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We have a middleware helper that allows us to respond with a view so I can plug in our `supportView` there now.
""",
    timestamp: (35*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
return conn
  |> writeStatus(.ok)
  >=> respond(supportView)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
the only problem is that `supportView` is a view on `Void` but `conn` holds a first class value of its own kind. We need these two data types to match in order to plug them together.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
One thing we can do is `map` it to `Void`!
""",
    timestamp: (35*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
return conn.map { _ in () }
  |> writeStatus(.ok)
  >=> respond(supportView)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This `map` is much like all the `map`s we've encountered in our [previous episode](https://www.pointfree.co/episodes/ep13-the-many-faces-of-map).
""",
    timestamp: (35*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's build and run things. Now we get HTML! It doesn't look all that much better, but if we open this up the web inspector we can see definitely we got our HTML in there, so it's something!
""",
    timestamp: (35*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Down in the further let's replace "Contact us" with a "Support" link.
""",
    timestamp: (36*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I can hop over to our footer view and locate the contact link.
""",
    timestamp: (36*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
a([`class`([footerLinkClass]), mailto("support@pointfree.co")], ["Contact us"])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And I can update it to say "Support" and provide an `href`. I could just hard-code a raw string.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
a([`class`([footerLinkClass]), href("/support")], ["Support"])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This works, but if we ever change the URL, it would break silently.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Our router fixes this for us. It links the idea of _parsing_ request and _printing_ request so they never get out of sync.
""",
    timestamp: (36*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We want to use our router and we have a little helper here that just calls out to the router and makes it nice and short to use inline
""",
    timestamp: (36*60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
a([`class`([footerLinkClass]), href(path(to: .support))], ["Support"])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is completely type-safe! If this were misspelled, it will not compile, and if the enum case changes, it won't compile. That weird operator description we did of the support route was the simultaneous description of how to parse and print.
""",
    timestamp: (37*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now when I run this and we go down to the footer, we see now the "Support" link _and_ it does go to `/support`, and clicking it takes me there!
""",
    timestamp: (37*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I think you and I take the stuff for granted. I don't think most people that work in the server world, with Rails has this experience where it lets you know, at compile time, that you've got this honest route.
""",
    timestamp: (37*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Swift is giving us a lot of really powerful features that make this possible. I think a lot of people would think that you need a dynamic language in order to do things like this. That you need the the dynamics of Ruby in order to make a router that can simultaneously print and route, but it's totally possible in a strongly-typed language like Swift.
""",
    timestamp: (37*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
That's the tour of our code base! We didn't fully build the support page, but we'll have a PR of it up sometime soon and people can go check it out. We think it's really cool stuff and we hope that this can be like yet another bullet point for us to to say, look: real world production-quality, production-ready code _can_ be functional and it can give you a lot of really amazing things because we kind of feel like functional programming is what unlocked a lot of these things for us.
""",
    timestamp: (38*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "What’s the point?",
    timestamp: (38*60 + 53),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Every week we ask "what's the point!?" but this is another one of those episodes where the entire episode _was_ the point! This is real website and you're on it right now! The "point" is that all these concepts work in production to build websites and apps, and you can use them!
""",
    timestamp: (38*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
I think we'll have some more abstract stuff coming soon now call the next time the next
""",
    timestamp: (39*60 + 15),
    type: .paragraph
  ),
]
