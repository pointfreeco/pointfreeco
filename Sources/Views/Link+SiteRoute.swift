import Dependencies
import PointFreeRouter
import StyleguideV2

extension Link {
  public init(destination: SiteRoute, @HTMLBuilder label: () -> Label) {
    @Dependency(\.siteRouter) var siteRouter
    self.init(href: siteRouter.path(for: destination), label: label)
  }

  public init(_ title: String, destination: SiteRoute) where Label == HTMLText {
    @Dependency(\.siteRouter) var siteRouter
    self.init(title, href: siteRouter.path(for: destination))
  }
}
