# [www.pointfree.co](http://www.pointfree.co)

[![CircleCI](https://circleci.com/gh/pointfreeco/pointfreeco.svg?style=svg)](https://circleci.com/gh/pointfreeco/pointfreeco)

This repo contains the application code for the [Point-Free](http://www.pointfree.co) website, a weekly video series exploring Swift and functional programming. It’s responsible for routing requests, loading data and serving html. If you're interested in running it locally, check out the [server code](https://github.com/pointfreeco/pointfreeco-server), which is responsible for connecting a bare bones Kitura server to this code.

![Point-Free Homepage](.github/pointfreeco-announcement-homepage.png)

## Getting started

The repo contains an extensive test suite and some playgrounds to explore. You can get this running by:

* `git clone https://github.com/pointfreeco/pointfreeco.git`
* `cd pointfreeco`
* `swift package generate-xcodeproj`
* `xed .`
* Run tests: cmd+U
* Build: Cmd+B
* Open a playground!


### Some fun things to explore

There’s a lot of fun things to explore in this repo. For example:

* We develop web pages in playgrounds for a continuous feedback loop.

  - We use playgrounds to iterate on each web page. (links).

  - Our tests use snapshot testing to capture several iOS and desktop breakpoints (links) and track UI changes over time (link).

Point-Free uses a bunch of cool (and related) open-source software:

  - swift-web Powers our back-end and front-end: (more)

  - swift-prelude Offers a standard library for experimental functional programming in Swift (expect to learn more if you subscribe to our series)

  - swift-snapshot-testing Powers our testing infrastructure: we get detailed views of our expectations, visually and...figuratively?
