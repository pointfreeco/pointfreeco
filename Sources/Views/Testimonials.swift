struct Testimonial {
  let quote: String
  let subscriber: String?
  let tweetUrl: String
  let twitterHandle: String

  static let all: [Testimonial] = [

    Testimonial(
      quote: #"""
The best technical video series I've ever watched.
"""#,
      subscriber: "Majid",
      tweetUrl: "https://twitter.com/majid_again/status/1208317840966799362",
      twitterHandle: "majid_again"
    ),

    Testimonial(
      quote: #"""
Hard not to see Point-Free as the "sneak preview" of the deep thinking and exploration that turns into language features down the road.
"""#,
      subscriber: "Alexis Gallagher",
      tweetUrl: "https://twitter.com/alexisgallagher/status/1225949247683477504",
      twitterHandle: "alexisgallagher"
    ),

    Testimonial(
      quote: #"""
Three recent @pointfreeco episodes were so interesting I stayed in the treadmill 3x as long as usual and watched them all in a row! Walking may be challenging later/tomorrow…  😮
"""#,
      subscriber: "Dad",
      tweetUrl: "https://twitter.com/GeekAndDad/status/1226287417134436353",
      twitterHandle: "GeekAndDad"
    ),

    Testimonial(
      quote: #"""
My go-to for #swift functional programming videos. Great content. Well worth paying for <3
"""#,
      subscriber: "Alex Manarpies",
      tweetUrl: "https://twitter.com/jarrroo/status/1212360251669962752",
      twitterHandle: "jarrroo"
    ),

    Testimonial(
      quote: #"""
This is surely one of the best shows for Swift folks out there! The content and explanation is at a really high bar!
"""#,
      subscriber: "Boris Bielik",
      tweetUrl: "https://twitter.com/h3sperian/status/1222805854552018944",
      twitterHandle: "h3sperian"
    ),

    Testimonial(
      quote: #"""
Honestly, I'm an Android developer, I write applications in Kotlin. My colleague iOS developer told me about your course. And I liked it so I decided to buy a subscription.
"""#,
      subscriber: "Mr. Hartwell",
      tweetUrl: "https://twitter.com/sergeyfitis/status/1222228081735360513",
      twitterHandle: "sergeyfitis"
    ),

    Testimonial(
      quote: """
Every single episode of @pointfreeco has been mind blowing. I feel like I've grown a lot as a developer since I started learning Swift and this kind of tutorials definitely help. Functional High Five to @mbrandonw and @stephencelis 🙌🏼
""",
      subscriber: "Romain Pouclet",
      tweetUrl: "https://twitter.com/Palleas/status/978997094408212480",
      twitterHandle: "Palleas"
    ),

    Testimonial(
      quote: """
I bought the annual subscription pointfree.co and after I watched all videos and played with the sample code and libraries github.com/pointfreeco. I can say it was the best money I spent in the last 12 months.
""",
      subscriber: "Luca Ceppelli",
      tweetUrl: "https://twitter.com/lucaceppelli/status/1136290297242165249",
      twitterHandle: "lucaceppelli"
    ),

    Testimonial(
      quote: """
I haven't really done much Swift, but watched this out of curiosity, & it's really well done. Perfectly walks through the mindset of a dev w/ an OO background & addresses their concerns one by one with solid info explaining the benefits of taking the FP approach. (The how & why.)
""",
      subscriber: "Josh Burgess",
      tweetUrl: "https://twitter.com/_joshburgess/status/971169503890624513",
      twitterHandle: "_joshburgess"
    ),

    Testimonial(
      quote: """
Their content pushes the boundary of my knowledge, and it's fun to watch!
""",
      subscriber: "Ferran Pujol Camins",
      tweetUrl: "https://twitter.com/ferranpujolca/status/1130908056169136130",
      twitterHandle: "ferranpujolca"
    ),

    Testimonial(
      quote: """
The best thing, that happened to me for a while. @mbrandonw and @stephencelis really provide a lot of new information according to #ios development and #functionalprogramming. All info could be used in real production without boring academics.
""",
      subscriber: "Maxim Smirnov",
      tweetUrl: "https://twitter.com/atimca/status/1204399892531228672",
      twitterHandle: "Atimca"
    ),

    Testimonial(
      quote: """
There clearly was a before and an after @pointfreeco for me. I've always been an FP enthusiast intimidated by the F-word, but they made that accessible to the rest of us. Highly recommended!
""",
      subscriber: "Romain Pouclet",
      tweetUrl: "https://twitter.com/Palleas/status/1023976413429260288",
      twitterHandle: "Palleas"
    ),

    Testimonial(
      quote: """
tfw you are excited for a 4 hour train ride because you'll have time to watch the new @pointfreeco episode 🤓🏔🚂 #MathInTheAlps #typehype
""",
      subscriber: "Meghan Kane",
      tweetUrl: "https://twitter.com/meghafon/status/978624999866105859",
      twitterHandle: "meghafon"
    ),

    Testimonial(
      quote: """
My new favourite morning routine is feeding 👶🏻 while watching
@pointfreeco
""",
      subscriber: "Frank Courville",
      tweetUrl: "https://twitter.com/Frankacy/status/1204154907185557507",
      twitterHandle: "Frankacy"
    ),

    Testimonial(
      quote: """
After diving into @pointfreeco series reading Real World Haskell doesn’t seem all that intimidating after all. Major takeaway: the lesser is word “monad” is mentioned the better 😅
""",
      subscriber: "Ilya",
      tweetUrl: "https://twitter.com/rehsals/status/1144282266367070209",
      twitterHandle: "rehsals"
    ),

    Testimonial(
      quote: """
@pointfreeco Talk about being ahead of the curve guys… DSLs, Playground Driven Dev, FRP. Great job. I’m sure you inspired many Apple devs. We know who to look to for where to focus next!
""",
      subscriber: "Sam Rayner",
      tweetUrl: "https://twitter.com/samrayner/status/1136634106618568704",
      twitterHandle: "samrayner"
    ),

    Testimonial(
      quote: """
@pointfreeco ❤️: Thank you! 🧠: … The brain can’t say anything. It is blown away (🤯)!
""",
      subscriber: "Rajiv Jhoomuck",
      tweetUrl: "https://twitter.com/rajivjhoomuck/status/973178777768480771",
      twitterHandle: "rajivjhoomuck"
    ),

    Testimonial(
      quote: """
the @pointfreeco videos are fantastic, and such a gentle introduction to important ideas — seriously worth a look regardless of functional experience level
""",
      subscriber: "tom burns",
      tweetUrl: "https://twitter.com/tomburns/status/972535717300666368",
      twitterHandle: "tomburns"
    ),

    Testimonial(
      quote: """
Point-Free is really challenging my perspective and approach to Swift. Props to @mbrandonw and @stephencelis for creating an interesting and engaging video series!
""",
      subscriber: "Hesham Salman",
      tweetUrl: "https://twitter.com/_IronHam/status/967496514506543104",
      twitterHandle: "_IronHam"
    ),

    Testimonial(
      quote: """
I really love the dynamics of @pointfreeco. The dance of “this is super nice because…” “yes, BUT….”. they clearly show what’s good, what’s not so good and keep continuously improving.
""",
      subscriber: "Alejandro Martinez",
      tweetUrl: "https://twitter.com/alexito4/status/1158982960466550784",
      twitterHandle: "alexito4"
    ),

    Testimonial(
      quote: """
Thanks @mbrandonw @stephencelis for the very pedagogical series with @pointfreeco Excited and looking forward to learn from the series
""",
      subscriber: "Prakash Rajendran",
      tweetUrl: "https://twitter.com/dearprakash/status/1063165370159259648",
      twitterHandle: "dearprakash"
    ),

    Testimonial(
      quote: """
Just became a subscriber! I'm binge watching episodes now! Great content! I'm learning so much from you guys. The repo for the site is the best go-to reference for a well done project and swift-web is something I am definitely going to use in my projects. Thanks for everything!
""",
      subscriber: "William Savary",
      tweetUrl: "https://twitter.com/NSHumanBeing/status/1043141855884587008",
      twitterHandle: "NSHumanBeing"
    ),

    Testimonial(
      quote: """
We have this thing called WWTV at #PlanGrid where we mostly just listen to @mbrandonw and @stephencelis talk about functions.
""",
      subscriber: "Arjun Nayini",
      tweetUrl: "https://twitter.com/anayini/status/1129104381566001152",
      twitterHandle: "anayini"
    ),

    Testimonial(
      quote: #"""
Please stop releasing one amazing video after the other! I'm still at Episode 15! #pointfreemarathon #androiddevhere
"""#,
      subscriber: "Nico Passo",
      tweetUrl: "https://twitter.com/nicopasso/status/1225903028714311681",
      twitterHandle: "nicopasso"
    ),

    Testimonial(
      quote: """
Due to the amount of discussions that reference @pointfreeco, we added their logo as an emoji in our slack.
""",
      subscriber: "Rui Peres",
      tweetUrl: "https://twitter.com/peres/status/1020263301039689733",
      twitterHandle: "peres"
    ),

    Testimonial(
      quote: #"""
What the Effective C++ series did to my early career, Pointfree does to the, ummmmm, late summer? 😅
"""#,
      subscriber: "Sven A. Schmidt",
      tweetUrl: "https://twitter.com/_sa_s/status/1222783515391152129",
      twitterHandle: "_sa_s"
    ),

    // MARK: - Re: specific episodes

    Testimonial(
      quote: """
I listened to the first two episodes of @pointfreeco this weekend and it was the best presentation of FP fundamentals I've seen. Very thoughtful layout and progression of the material and motivations behind each introduced concept. Looking forward to watching the rest!
""",
      subscriber: "Christina Lee",
      tweetUrl: "https://twitter.com/RunChristinaRun/status/968920979320709120",
      twitterHandle: "RunChristinaRun"
    ),


    Testimonial(
      quote: """
Every episode has been amazing on Pointfree, yet somehow, you've managed to make these Parser combinator episodes even better!!! ⭐️⭐️⭐️⭐️⭐️
""",
      subscriber: "Mike Abidakun",
      tweetUrl: "https://twitter.com/mabidakun/status/1129050657783263232",
      twitterHandle: "mabidakun"
    ),

    Testimonial(
      quote: """
Watching the key path @pointfreeco episodes, and I am like 🤯🤯🤯. Super cool
""",
      subscriber: "Felipe Espinoza",
      tweetUrl: "https://twitter.com/fespinozacast/status/978997512500666368",
      twitterHandle: "fespinozacast"
    ),

    Testimonial(
      quote: """
I just watched the episode of @pointfreeco where Brandon and Stephen explain how curry is derived and it ALMOST literally blew my mind. Decomposed things are so simple to grasp ❤ I love how this series decompose and explains things very granular and simple
""",
      subscriber: "Esteban Torres",
      tweetUrl: "https://twitter.com/esttorhe/status/1063420584044965888",
      twitterHandle: "esttorhe"
    ),

    Testimonial(
      quote: """
Really love this episode - thanks @mbrandonw + @stephencelis! Understanding Swift types in terms of algebraic data types is such an elegant way of seeing the # of possible values your Swift types will represent 🤯 #Simplifyallthethings #GoodbyeComplexity
""",
      subscriber: "Meghan Kane",
      tweetUrl: "https://twitter.com/meghafon/status/966766186221461504",
      twitterHandle: "meghafon"
    ),

    Testimonial(
      quote: """
Just finished the mini-series on enum properties by @pointfreeco! They pointed out what’s missing from enums in Swift and used SwiftSyntax to generate code to add the missing parts. Thanks for your work @stephencelis and @mbrandonw! #pointfree
""",
      subscriber: "David Piper",
      tweetUrl: "https://twitter.com/HeyDaveTheDev/status/1142664959509368832",
      twitterHandle: "HeyDaveTheDev"
    ),

    Testimonial(
      quote: """
So many concepts presented at #WWDC19  reminded me of @pointfreeco video series. 👏👏 So happy I watched it before coming to San Jose.
""",
      subscriber: "Oscar Alvarez",
      tweetUrl: "https://twitter.com/iOjCaR/status/1136719341376790528",
      twitterHandle: "iOjCaR"
    ),

  ]
}
