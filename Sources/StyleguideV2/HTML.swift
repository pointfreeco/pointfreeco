import Css
import FunctionalCss
import Html

@resultBuilder
public enum NodeBuilder {
  public static func buildBlock() -> Node {
    []
  }

  public static func buildBlock(_ components: Node...) -> Node {
    .fragment(components)
  }

  public static func buildOptional(_ component: Node?) -> Node {
    guard let component
    else { return [] }
    return component
  }

  public static func buildEither(first component: Node) -> Node {
    component
  }

  public static func buildEither(second component: Node) -> Node {
    component
  }

  public static func buildArray(_ components: [Node]) -> Node {
    .fragment(components)
  }

  public static func buildExpression(_ expression: Node) -> Node {
    expression
  }

  public static func buildExpression(_ expression: String) -> Node {
    .text(expression)
  }
}

extension Node {
  public init(
    @NodeBuilder children: () -> Node
  ) {
    self = children()
  }

  public init(
    _ name: String,
    @NodeBuilder children: () -> Node
  ) {
    self = .element(name, [], children())
  }
}

public func div(@NodeBuilder _ children: () -> Node) -> Node { Node("div", children: children) }
public func a(@NodeBuilder _ children: () -> Node) -> Node { Node("a", children: children) }
public func ul(@NodeBuilder _ children: () -> Node) -> Node { Node("ul", children: children) }
public func li(@NodeBuilder _ children: () -> Node) -> Node { Node("li", children: children) }

extension Node {
  public func attribute(
    _ attributeName: String,
    _ value: String,
    _ separator: String = ";"
  ) -> Node {
    guard
      case .element(let tagName, var attributes, let children) = self
    else {
      // TODO: Runtime warn?
      return self
    }

    guard let index = attributes.firstIndex(where: { name, _ in name == attributeName })
    else {
      attributes.append((attributeName, value))
      return .element(tagName, attributes, children)
    }

    if attributes[index].value != nil {
      attributes[index].value! += separator
      attributes[index].value! += value
    } else {
      attributes[index].value = value
    }

    return .element(tagName, attributes, children)
  }

  public func `class`(_ value: String) -> Node {
    attribute("class", value, " ")
  }

  public func `class`(_ selectors: [CssSelector]) -> Node {
    `class`(render(classes: selectors))
  }
}
