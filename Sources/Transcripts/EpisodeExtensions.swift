import Models
import Tagged

extension Episode {
  public var fullVideo: Video {
    let video = self._fullVideo ?? Episode.allPrivateVideos[self.id]
    assert(video != nil, "Missing full video for episode #\(self.id) (\(self.title))!")
    return video!
  }

  public var transcriptBlocks: [TranscriptBlock] {
    get {
      let transcripts = self._transcriptBlocks ?? Episode.allPrivateTranscripts[self.id]
      assert(
        transcripts != nil, "Missing private transcript for episode #\(self.id) (\(self.title))!")
      return transcripts!
    }
    set {
      self._transcriptBlocks = newValue
    }
  }
}
