func allBlogPosts() -> [BlogPost] {
  let now = AppEnvironment.current.date()
  return _allBlogPosts
    .filter {
      AppEnvironment.current.envVars.appEnv == .production
        ? $0.publishedAt <= now
        : true
  }
}

private let _allBlogPosts: [BlogPost] = [
  post0001_welcome,
  post0002_episodeCredits,
]
