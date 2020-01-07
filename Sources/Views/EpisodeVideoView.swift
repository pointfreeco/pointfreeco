import Css
import Foundation
import Html
import HtmlCssSupport
import Models
import Styleguide

public func videoView(forEpisode episode: Episode, isEpisodeViewable: Bool) -> Node {
  let episodeSource = isEpisodeViewable
    ? episode.fullVideo.streamingSource
    : episode.trailerVideo?.streamingSource ?? ""

  return .div(
    attributes: [
      .class([outerVideoContainerClass]),
      .style(outerVideoContainerStyle)
    ],
    .iframe(
      attributes: [
        .class([innerVideoContainerClass]),
        .src(episodeSource),
        Attribute("frameborder", "0"),
        Attribute("allow", "autoplay; fullscreen"),
        Attribute("allowfullscreen", "")
      ]
    ),
    .script(attributes: [.src("https://player.vimeo.com/api/player.js")]),
    .script(safe: """
window.addEventListener("load", function (event) {
  var player = new Vimeo.Player(document.querySelector("iframe"));

  jump(window.location.hash, false);

  document.addEventListener("click", function (event) {
    var target = event.target;
    if (target.tagName != "A") { return; }
    var hash = new URL(target.href).hash;
    jump(hash, true);
  });

  function jump(hash, play) {
    var time = +((/^#t(\\d+)$/.exec(hash) || [])[1] || "");
    if (time <= 0) { return; }
    player.setCurrentTime(time);
    if (play) { player.play(); }
  }
});
"""
    )
  )
}
