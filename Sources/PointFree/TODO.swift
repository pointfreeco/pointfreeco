import Css
import Html
import Prelude
import Styleguide

// TODO: extract to grid helpers in design systems?
public func gridRow(_ attribs: [Attribute<Element.Div>], _ content: [Node]) -> Node {
  let tmp = addClasses([Class.grid.row]) <| attribs
  return div(tmp, content)
}

// TODO: extract to grid helpers in design systems?
public func gridRow(_ content: [Node]) -> Node {
  return gridRow([], content)
}

// TODO: extract to grid helpers in design systems?
public func gridColumn(sizes: [Breakpoint: Int]) -> ([Node]) -> Node {
  return { content in
    gridColumn(sizes: sizes, [], content)
  }
}

public func gridColumn(sizes: [Breakpoint: Int], _ content: [Node]) -> Node {
  return gridColumn(sizes: sizes, [], content)
}

public func gridColumn(sizes: [Breakpoint: Int], _ attribs: [Attribute<Element.Div>], _ content: [Node]) -> Node {
  let classes = [Class.grid.col] + sizes.map { breakpoint, size in
    Class.grid.col(breakpoint, size)
  }

  return div(addClasses(classes)(attribs), content)
}

// todo: swift-prelude?
public func array<A>(_ tuple: (A, A)) -> [A] {
  return [tuple.0, tuple.1]
}
public func array<A>(_ tuple: (A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2]
}
public func array<A>(_ tuple: (A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3]
}
public func array<A>(_ tuple: (A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4]
}
public func array<A>(_ tuple: (A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8, tuple.9]
}

// todo: where should this live?
// todo: render `CssSelector.union` better
private func addClasses<T>(_ classes: [CssSelector]) -> ([Attribute<T>]) -> [Attribute<T>] {
  return { attributes in
    guaranteeClassAttributeExists(attributes)
      .map { attribute in
        guard attribute.attrib.key == "class" else { return attribute }

        let newValue = (attribute.attrib.value.renderedValue()?.string ?? "")
          + " "
          + render(classes: classes)

        return .init("class", newValue)
    }
  }
}

private func guaranteeClassAttributeExists<T>(_ attributes: [Attribute<T>]) -> [Attribute<T>] {
  return attributes.contains(where: { $0.attrib.key == "class" })
    ? attributes
    : attributes + [Attribute<T>.init("class", "")]
}

// todo: HasPlaysInline
public func playsInline<T>(_ value: Bool) -> Attribute<T> {
  return .init("playsinline", value)
}
public func muted<T>(_ value: Bool) -> Attribute<T> {
  return .init("muted", value)
}

extension FunctionM {
  public static func <¢> <N>(f: @escaping (M) -> N, c: FunctionM) -> FunctionM<A, N> {
    return c.map(f)
  }
}
