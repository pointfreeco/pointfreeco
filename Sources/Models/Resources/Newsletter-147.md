We are excited to announce a new library from Point-Free: [Issue Reporting][issue-reporting-gh].
This library provides tools to report issues in your application and library code as Xcode runtime 
warnings, breakpoints, assertions, and do so in a testable manner.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://pointfreeco-blog.s3.amazonaws.com/posts/0147-issue-reporting/runtime-warning~dark.png">
  <source media="(prefers-color-scheme: light)" srcset="https://pointfreeco-blog.s3.amazonaws.com/posts/0147-issue-reporting/runtime-warning.png">
  <img alt="A purple runtime warning in Xcode showing that an issue has been reported." src="https://pointfreeco-blog.s3.amazonaws.com/posts/0147-issue-reporting/runtime-warning.png" width="100%">
</picture>


## Reporting issues

The primary tool for reporting an issue in your application code is the `reportIssue` function. You
can invoke it from anywhere in your features' code to signal that something happened that should not
have:

```swift
guard let lastItem = items.last
else {
  reportIssue("'items' should never be empty.")
  return 
}
…
```

By default, this will trigger an unobtrusive, purple runtime warning when running your app in Xcode
(simulator and device):

> Runtime Warning: 'items' should never be empty.

This provides a very visual way to see when an issue has occurred in your application without
stopping the app's execution or interrupting your workflow.

The `reportIssue` tool can also be customized to allow for other ways of reporting issues. It can be
configured to trigger a breakpoint if you want to do some debugging when an issue is reported, or a
precondition or fatal error if you want to truly stop execution. And you can create your own custom
issue reporter to send issues to OSLog or an external server. 

Further, when running your code in a testing context (both XCTest and Swift's native Testing
framework), all reported issues become _test failures_:

> Failed: Expectation failed: 'items' should never be empty.

This helps you get test coverage that
problematic code paths are not executed, and makes it possible to build testing tools for libraries
that ship in the same target as the library itself.

## Issue reporters

The library comes with a variety of issue reporters that can be used right away:

  * `runtimeWarning`: Issues are reported as purple runtime warnings in Xcode and
    printed to the console on all other platforms. This is the default reporter.
  * `breakpoint`: A breakpoint is triggered, stopping execution of your app. This
    gives you the ability to debug the issue.
  * `fatalError`: A fatal error is raised and execution of your app is permanently
    stopped.

You an also create your own custom issue reporter by defining a type that conforms to the 
`IssueReporter` protocol. It has one requirement, which you can implement to report issues in any
way you want.

## Overriding issue reporters

By default the library uses the `runtimeWarning` reporter, but it is possible to override the
reporters used. There are two primary ways:

  * You can temporarily override reporters for a lexical scope using `withIssueReporters`. For
    example, to turn off reporting entirely you can do:

    ```swift
    withIssueReporters([]) {
      // Any issues raised here will not be reported.
    }
    ```

    …or to temporarily add a new issue reporter:

    ```swift
    withIssueReporters(IssueReporters.current + [.breakpoint]) {
      // Any issues reported here will trigger a breakpoint
    }
    ```

  * You can also override the issue reporters globally by setting the `IssueReporters.current`
    variable. This is typically best done at the entry point of your application:

    ```swift
    import IssueReporting
    import SwiftUI 

    @main
    struct MyApp: App {
      init() {
        IssueReporters.current = [.fatalError]
      }
      var body: some Scene {
        …
      }
    }
    ```

## Get started today

Add [Issue Reporting][issue-reporting-gh] to your project today to start reporting issues in an
unobtrusive and testable manner. If you were previously using our XCTest Dynamic Overlay library,
then you should know that Issue Reporting is the successor to that library, and you should be able
to seamlessly migrate over.

[issue-reporting-gh]: https://github.com/pointfreeco/swift-issue-reporting
[unobtrusive-blog]: /blog/posts/70-unobtrusive-runtime-warnings-for-libraries

