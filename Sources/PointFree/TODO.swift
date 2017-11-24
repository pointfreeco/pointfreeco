import Css
import Html
import Prelude
import Styleguide

// todo: where should this live?
// todo: render `CssSelector.union` better
public func addClasses<T>(_ classes: [CssSelector]) -> ([Attribute<T>]) -> [Attribute<T>] {
  return { attributes in
    attributes.map { attribute in
      guard attribute.attrib.key == "class" else { return attribute }

      let newValue = (attribute.attrib.value.renderedValue()?.string ?? "")
        + " "
        + classes
          .map { renderSelector($0).replacingOccurrences(of: ".", with: "") }
          .joined(separator: " ")

      return .init("class", newValue)
    }
  }
}

// TODO: extract to grid helpers in design systems?
public func gridRow(_ attribs: [Attribute<Element.Div>], _ content: [Node]) -> Node {
  let tmp = addClasses([Class.grid.row]) <| attribs
  return node("div", tmp, content)
}

// TODO: extract to grid helpers in design systems?
public func gridRow(_ content: [Node]) -> Node {
  return div([`class`([Class.grid.row])], content)
}

// TODO: extract to grid helpers in design systems?
public func gridColumn(_ attribs: [Attribute<Element.Div>], _ content: [Node]) -> Node {
  let tmp = addClasses([Class.grid.col]) <| attribs
  return node("div", tmp, content)
}

// TODO: extract to grid helpers in design systems?
public func gridColumn(sizes: [Breakpoint: Int]) -> ([Node]) -> [Node] {
  return { nodes in
    let classes = [Class.grid.col] + sizes.map { breakpoint, size in
      Class.grid.col(breakpoint, size)
    }
    return [
      div([`class`(classes)], nodes)
    ]
  }
}

// TODO: extract to grid helpers in design systems?
public func gridColumn(_ content: [Node]) -> Node {
  return gridColumn([], content)
}
