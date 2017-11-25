import Css
import Html
import HtmlCssSupport
import Styleguide
import Prelude

let footerView = View<Prelude.Unit> { _ in
  footer(
    [
      `class`([Class.grid.row, Class.padding.all(4), Class.border.top, Class.pf.colors.bg.white]),
      style(borderColor(top: .other("#ccc")))
    ],
    footerInfoColumnsView.view(unit)
  )
}

private let footerInfoColumnsView =
       pointFreeView    .map(gridColumn(sizes: [.xs: 12, .md: 6]) >>> pure)
    <> learnColumnView  .map(gridColumn(sizes: [.xs: 4, .md: 2]) >>> pure)
    <> followColumnView .map(gridColumn(sizes: [.xs: 4, .md: 2]) >>> pure)
    <> moreColumnView   .map(gridColumn(sizes: [.xs: 4, .md: 2]) >>> pure)

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
      li([a([href("https://www.github.com/pointfreeco")], ["GitHub"])]),
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
