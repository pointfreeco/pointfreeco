import Css
import FunctionalCss
import Html

extension Node {
  public init<T: HTML>(@HTMLBuilder content: () -> T) {
    var printer = HTMLPrinter()
    T._render(content(), into: &printer)
    self = .fragment([
      .element("style", [], .raw(printer.stylesheet)),
      .raw(String(decoding: printer.bytes, as: UTF8.self))
    ])
  }
}

public protocol NodeView {
  @NodeBuilder
  var body: Node { get }
}

extension NodeView {
  public func render() -> String {
    Html.render(body)
  }
}

extension Node: NodeView {
  public var body: Node { self }
}

public struct Tuple<A: NodeView, B: NodeView>: NodeView {
  let a: A
  let b: B
  public var body: Node {
    Node.fragment([a.body, b.body])
  }
}
extension Optional: NodeView where Wrapped: NodeView {
  public var body: Node {
    if let wrapped = self {
      return wrapped.body
    } else {
      return []
    }
  }
}
public enum ConditionalNode<A: NodeView, B: NodeView>: NodeView {
  case first(A)
  case second(B)
  public var body: Node {
    switch self {
    case .first(let view):
      return view.body
    case .second(let view):
      return view.body
    }
  }
}

public struct ArrayNode<A: NodeView>: NodeView {
  let components: [A]
  public var body: Node {
    Node.fragment(components.map(\.body))
  }
}

public struct TextNode: NodeView {
  let text: String
  init(_ text: String) {
    self.text = text
  }
  public var body: Node {
    Node.text(text)
  }
}

@resultBuilder
public enum NodeBuilder {
  public static func buildBlock() -> Node {
    []
  }

  public static func buildPartialBlock<N: NodeView>(first: N) -> N {
    first
  }

  public static func buildPartialBlock<A: NodeView, B: NodeView>(
    accumulated: A,
    next: B
  ) -> Tuple<A, B> {
    Tuple(a: accumulated, b: next)
  }

  public static func buildOptional<A: NodeView>(_ component: A?) -> A? {
    component
  }

  public static func buildEither<A: NodeView, B: NodeView>(first component: A) -> ConditionalNode<A, B> {
    .first(component)
  }

  public static func buildEither<A: NodeView, B: NodeView>(second component: B) -> ConditionalNode<A, B> {
    .second(component)
  }

  public static func buildArray<A: NodeView>(_ components: [A]) -> ArrayNode<A> {
    ArrayNode(components: components)
  }

  public static func buildExpression<A: NodeView>(_ expression: A) -> A {
    expression
  }

  public static func buildExpression(_ expression: String) -> TextNode {
    TextNode(expression)
  }

  public static func buildFinalResult(_ component: some NodeView) -> Node {
    component.body
  }

  public static func buildFinalResult(_ component: Node) -> Node {
    component
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
public func label(@NodeBuilder _ children: () -> Node) -> Node { Node("label", children: children) }
public func input(@NodeBuilder _ children: () -> Node) -> Node { Node("input", children: children) }
public func html(@NodeBuilder _ children: () -> Node) -> Node { Node("html", children: children) }
public func head(@NodeBuilder _ children: () -> Node) -> Node { Node("head", children: children) }
public func body(@NodeBuilder _ children: () -> Node) -> Node { Node("body", children: children) }
public func meta(@NodeBuilder _ children: () -> Node) -> Node { Node("meta", children: children) }
extension NodeView {
  public func body(@NodeBuilder _ children: () -> Node) -> Node { Node("body", children: children) }
}

extension NodeView {
  public func attribute(
    _ attributeName: String,
    _ value: String?,
    _ separator: String? = nil
  ) -> Node {
    // TODO: awful hacks
    guard let node = self as? Node 
    else {
      return body.attribute(attributeName, value, separator)
    }

    // TODO: ok to do no-op for nil value?
    guard let value
    else { return node }

    guard
      case .element(let tagName, var attributes, let children) = node
    else {
      guard case .fragment(let array) = node else {
        return node
      }
      return .fragment(array.map { $0.attribute(attributeName, value, separator) })
    }

    guard let index = attributes.firstIndex(where: { name, _ in name == attributeName })
    else {
      attributes.append((attributeName, value))
      return .element(tagName, attributes, children)
    }

    if attributes[index].value != nil, let separator {
      attributes[index].value! += separator
      attributes[index].value! += value
    }

    return .element(tagName, attributes, children)
  }

  public func `class`(_ value: String) -> Node {
    attribute("class", value, " ")
  }

  public func `class`(_ selectors: [CssSelector]) -> Node {
    `class`(FunctionalCss.render(classes: selectors))
  }

  public func style(_ name: String, _ value: String) -> Node {
    attribute("style", "\(name): \(value)")
  }
}
