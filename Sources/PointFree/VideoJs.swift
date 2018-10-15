import Css
import Foundation
import Html
import HtmlCssSupport

var videoJsHead: [ChildOf<Element.Head>] {
  let videoJsAssets: [ChildOf<Element.Head>] = [
    link([
      href("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.2.4/alt/video-js-cdn.min.css"),
      rel(.stylesheet)
      ]),
    .init(script([
      .init("onload", "videoJsLoaded();"),
      src("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.2.4/video.min.js"),
      `defer`(true)
      ]))
  ]

  return [
    style(".vjs-subs-caps-button" % display(.none)),
    script("window.HELP_IMPROVE_VIDEOJS = false;"),
    script("""
function videoJsLoaded() {
  videojs("episode-video").ready(function() {
    var controlBar = document.getElementsByClassName('vjs-control-bar')[0];
    var video = document.getElementsByTagName('video')[0];

    var template = document.createElement('div');
    template.innerHTML = '<button class="vjs-airplay-control vjs-control vjs-button" type="button" title="Airplay" aria-disabled="false"><span aria-hidden="true" class="vjs-icon-placeholder"></span><span class="vjs-control-text" aria-live="polite">Airplay</span></button>';

    controlBar.insertBefore(template.firstChild, controlBar.childNodes[controlBar.childNodes.length - 1]);

    video.addEventListener('webkitplaybacktargetavailabilitychanged', function(event) {
      if (event.availability != "available") { return }

      var airplayControl = document.getElementsByClassName('vjs-airplay-control')[0];
      airplayControl.addEventListener('click', function() {
        video.webkitShowPlaybackTargetPicker();
      });
    })
  });
}
""")
    ]
    + (Current.envVars.appEnv == .testing ? [] : videoJsAssets)
}

let videoJsClasses: CssSelector =
  ".video-js"
    | ".vjs-default-skin"
    | ".vjs-big-play-centered"

struct VideoJsOptions: Encodable {
  let control: Bool
  let playbackRates: [Double]

  static let `default` = VideoJsOptions(control: true, playbackRates: [0.5, 1, 1.5, 2])

  var jsonString: String {
    return ((try? String(data: JSONEncoder().encode(VideoJsOptions.default), encoding: .utf8)) ?? nil)
      ?? "{}"
  }
}
