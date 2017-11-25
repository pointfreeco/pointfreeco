import Css
import Html
import HtmlCssSupport
import Styleguide
import Prelude

let footerView = View<Prelude.Unit> { _ in
  footer(
    [
      `class`([
        Class.grid.row,
        Class.padding.leftRight(4),
        Class.padding.topBottom(4),
        Class.border.top,
        Class.pf.colors.bg.white]),
      style(borderColor(top: .other("#ccc")))
    ],
    footerInfoColumnsView.view(unit)
  )
}

let footerInfoColumnsView =
       pointFreeView.map(gridColumn(sizes: [.xs: 12, .md: 6]))
    <> learnColumnView.map(gridColumn(sizes: [.xs: 4, .md: 2]))
    <> followColumnView.map(gridColumn(sizes: [.xs: 4, .md: 2]))
    <> moreColumnView.map(gridColumn(sizes: [.xs: 4, .md: 2]))

private let pointFreeView = View<Prelude.Unit> { _ in
  div([`class`([Class.padding.right(4)])], [
    h4([`class`([Class.h4, Class.margin.bottom(0)])], ["Point-Free"]),
    p(["A weekly video series on functional programming and the Swift programming language."])
    ])
}

private let learnColumnView = View<Prelude.Unit> { _ in
  div([
    h5([`class`([Class.h5])], ["Learn"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href(path(to: .episodes(tag: nil)))], ["Videos"])]),
      li([a([href("#")], ["Books"])]),
      li([a([href("#")], ["Hire Us"])]),
      ])
    ])
}

private let followColumnView = View<Prelude.Unit> { _ in
  div([
    h5([`class`([Class.h5])], ["Follow"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href("#")], ["Blog"])]),
      li([a([href("https://www.twitter.com/pointfreeco")], ["Twitter"])]),
      ])
    ])
}

private let moreColumnView = View<Prelude.Unit> { _ in
  div([
    h5([`class`([Class.h5])], ["More"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href(path(to: .about))], ["About"])]),
      li([a([href("mailto:support@pointfree.co")], ["Email"])]),
      li([a([href(path(to: .terms))], ["Terms"])]),
      ])
    ])
}
