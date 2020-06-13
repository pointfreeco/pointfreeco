import Css
import Html

// TODO: extract to grid helpers in design systems?
extension Node {
  public static func gridRow(attributes: [Attribute<Tag.Div>] = [], _ content: Node...) -> Node {
    return .div(attributes: _addClasses([Class.grid.row], to: attributes), .fragment(content))
  }

  public static func gridColumn(
    sizes: [Breakpoint: Int],
    attributes: [Attribute<Tag.Div>] = [],
    _ content: Node...
  ) -> Node {

    let classes =
      [Class.grid.col(.mobile, nil)]
      + sizes
      .sorted(by: { $0.key.rawValue < $1.key.rawValue })
      .map(Class.grid.col(_:_:))

    return .div(attributes: _addClasses(classes, to: attributes), .fragment(content))
  }
}

// todo: where should this live?
// todo: render `CssSelector.union` better
public func _addClasses<T>(_ classes: [CssSelector], to attributes: [Attribute<T>]) -> [Attribute<
  T
>] {
  return guaranteeClassAttributeExists(attributes)
    .map { attribute in
      guard attribute.key == "class" else { return attribute }

      let newValue =
        (attribute.value ?? "")
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
