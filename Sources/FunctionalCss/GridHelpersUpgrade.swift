import Css
import HtmlUpgrade

// TODO: extract to grid helpers in design systems?
extension Node {
  public static func _gridRow(_ attribs: [Attribute<Tag.Div>], _ content: [Node]) -> Node {
    return .div(attributes: _addClasses([Class.grid.row], to: attribs), .fragment(content))
  }

  // TODO: extract to grid helpers in design systems?
  public static func _gridRow(_ content: [Node]) -> Node {
    return ._gridRow([], content)
  }

  // TODO: extract to grid helpers in design systems?
  public static func _gridColumn(sizes: [Breakpoint: Int]) -> ([Node]) -> Node {
    return { content in
      ._gridColumn(sizes: sizes, [], content)
    }
  }

  public static func _gridColumn(sizes: [Breakpoint: Int], _ content: [Node]) -> Node {
    return ._gridColumn(sizes: sizes, [], content)
  }

  public static func _gridColumn(sizes: [Breakpoint: Int], _ attribs: [Attribute<Tag.Div>], _ content: [Node]) -> Node {
    let classes = [Class.grid.col(.mobile, nil)]
      + sizes
        .sorted(by: { $0.key.rawValue < $1.key.rawValue })
        .map(Class.grid.col(_:_:))

    return .div(attributes: _addClasses(classes, to: attribs), .fragment(content))
  }
}

// todo: where should this live?
// todo: render `CssSelector.union` better
public func _addClasses<T>(_ classes: [CssSelector], to attributes: [Attribute<T>]) -> [Attribute<T>] {
  return guaranteeClassAttributeExists(attributes)
    .map { attribute in
      guard attribute.key == "class" else { return attribute }

      let newValue = (attribute.value ?? "")
        + " "
        + render(classes: classes)

      return .init("class", newValue)
  }
}

private func guaranteeClassAttributeExists<T>(_ attributes: [Attribute<T>]) -> [Attribute<T>] {
  return attributes.contains(where: { $0.key == "class" })
    ? attributes
    : attributes + [Attribute<T>.init("class", "")]
}
