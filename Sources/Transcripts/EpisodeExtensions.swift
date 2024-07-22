import Foundation
import Models
import Tagged

extension Episode {
  public var hasTranscript: Bool {
    Bundle.module.url(forResource: "Episode-\(sequence.rawValue)", withExtension: "md") != nil
  }

  public var transcript: String? {
    guard
      let url = Bundle.module.url(forResource: "Episode-\(sequence.rawValue)", withExtension: "md")
    else { return nil }
    return try? String(decoding: Data(contentsOf: url), as: UTF8.self)
  }

  public var fullVideo: Video {
    let video = self._fullVideo ?? Episode.allPrivateVideos[self.id]
    assert(video != nil, "Missing full video for episode #\(self.id) (\(self.title))!")
    return video!
  }
}
