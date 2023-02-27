import Models

extension Episode {
  public var fullVideo: Video {
    #if OSS
      return self._fullVideo ?? self.trailerVideo
    #else
      let video = self._fullVideo ?? Episode.allPrivateVideos[self.id]
      assert(video != nil, "Missing full video for episode #\(self.id) (\(self.title))!")
      return video!
    #endif
  }

  public var transcriptBlocks: [TranscriptBlock] {
    get {
      #if OSS
        return self._transcriptBlocks ?? []
      #else
        let transcripts = self._transcriptBlocks ?? Episode.allPrivateTranscripts[self.id]
        assert(
          transcripts != nil, "Missing private transcript for episode #\(self.id) (\(self.title))!")
        return transcripts!
      #endif
    }
    set {
      self._transcriptBlocks = newValue
    }
  }
}
