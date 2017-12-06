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
      + legalView.map(gridColumn(sizes: [.xs: 12]) >>> pure).view(unit)
  )
}

private let footerInfoColumnsView =
       pointFreeView    .map(gridColumn(sizes: [.xs: 12, .md: 6]) >>> pure)
    <> learnColumnView  .map(gridColumn(sizes: [.xs: 4, .md: 2]) >>> pure)
    <> followColumnView .map(gridColumn(sizes: [.xs: 4, .md: 2]) >>> pure)
    <> moreColumnView   .map(gridColumn(sizes: [.xs: 4, .md: 2]) >>> pure)

private let legalView = View<Prelude.Unit> { _ in
  p([`class`([Class.type.align.center, Class.h6])], [
"""
All videos © Point-Free, Inc. All Rights Reserved. You may not sell or distribute the content found on this site.
"""
    ])
}

private let pointFreeView = View<Prelude.Unit> { _ in
  div([`class`([Class.padding.right(4)])], [
    h4([`class`([Class.h4, Class.margin.bottom(0)])], ["Point-Free"]),
    p([
      "A weekly video series on functional programming and the Swift programming language. Hosted by ",
      a(
        [href(twitterUrl(to: .mbrandonw)), `class`([Class.type.textDecorationNone])],
        ["Brandon Williams"]
      ),
      " and ",
      a(
        [href(twitterUrl(to: .stephencelis)), `class`([Class.type.textDecorationNone])],
        ["Stephen Celis"]
      ),
      "."
      ])
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
      li([a([href(twitterUrl(to: .pointfreeco))], ["Twitter"])]),
      li([a([href(gitHubUrl(to: .organization))], ["GitHub"])]),
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
