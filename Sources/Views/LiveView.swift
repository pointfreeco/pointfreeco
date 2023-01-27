import Dependencies
import FunctionalCss
import Html
import PointFreeDependencies

public func liveView() -> Node {
  @Dependency(\.livestreams) var livestreams

  guard let activeLivestream = livestreams.first(where: { $0.isActive })
  else { return [] }

  return .gridRow(
    attributes: [
      .class([
        Class.pf.colors.bg.black
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [
        .class([
          Class.grid.center(.desktop)
        ])
      ],
      .raw(
        """
        <div style="padding:56.25% 0 0 0;position:relative;">
          <iframe src="https://vimeo.com/event/\(activeLivestream.eventID)/embed"
                  frameborder="0"
                  allow="autoplay; fullscreen; picture-in-picture"
                  allowfullscreen
                  style="position:absolute;top:0;left:0;width:100%;height:100%;">
          </iframe>
        </div>
        """)
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 4],
      attributes: [
        .class([
          Class.grid.center(.desktop)
        ])
      ],
      .raw(
        """
        <iframe src="https://vimeo.com/event/\(activeLivestream.eventID)/chat/"
                width="100%"
                height="100%"
                frameborder="0"
                style="min-height: 30rem;">
        </iframe>
        """)
    )
  )
}
