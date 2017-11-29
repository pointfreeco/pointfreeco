import Html
import Styleguide
import Prelude

let navView = View<Unit> { _ in
  nav([`class`([Class.pf.navBar])], [
    ul([`class`([Class.type.list.reset, Class.margin.all(0)])], [
      li([`class`([Class.layout.inline])], [
        a([href(path(to: .episodes(tag: nil))), `class`([Class.padding.leftRight(1)])], ["Videos"])
        ]),
      li([`class`([Class.layout.inline])], [
        a([href("#"), `class`([Class.padding.leftRight(1)])], ["Blog"])
        ]),
      li([`class`([Class.layout.inline])], [
        a([href("#"), `class`([Class.padding.leftRight(1)])], ["Books"])
        ]),
      li([`class`([Class.layout.inline])], [
        a([href(path(to: .about)), `class`([Class.padding.leftRight(1)])], ["About"])
        ]),
      ])
    ])
}
