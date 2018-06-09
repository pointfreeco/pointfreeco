import Css
import Html

// TODO: extract to grid helpers in design systems?
public func gridRow(_ attribs: [Attribute<Element.Div>], _ content: [Node]) -> Node {
  return div(addClasses([Class.grid.row], to: attribs), content)
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
  let classes = [Class.grid.col(.mobile, nil)]
    + sizes
      .sorted(by: { $0.key.rawValue < $1.key.rawValue })
      .map(Class.grid.col(_:_:))

  return div(addClasses(classes, to: attribs), content)
}

// todo: where should this live?
// todo: render `CssSelector.union` better
public func addClasses<T>(_ classes: [CssSelector], to attributes: [Attribute<T>]) -> [Attribute<T>] {
  return guaranteeClassAttributeExists(attributes)
    .map { attribute in
      guard attribute.attrib.key == "class" else { return attribute }

      let newValue = (attribute.attrib.value.renderedValue()?.string ?? "")
        + " "
        + render(classes: classes)

      return .init("class", newValue)
  }
}

private func guaranteeClassAttributeExists<T>(_ attributes: [Attribute<T>]) -> [Attribute<T>] {
  return attributes.contains(where: { $0.attrib.key == "class" })
    ? attributes
    : attributes + [Attribute<T>.init("class", "")]
}
