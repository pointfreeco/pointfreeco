func allBlogPosts() -> [BlogPost] {
  let now = Current.date()
  return _allBlogPosts
    .filter {
      Current.envVars.appEnv == .production
        ? $0.publishedAt <= now
        : true
  }
}

private let _allBlogPosts: [BlogPost] = [
  post0001_welcome,
  post0002_episodeCredits,
  post0003_ep14Solutions,
  post0004_overtureSetters,
  post0005_stylingWithFunctions,
  post0006_taggedSecondsAndMilliseconds,
  post0007_openSourcingNonEmpty,
  post0008_conditionalCoding,
]
