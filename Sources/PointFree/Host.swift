import Views

extension Host {
  static var brandon: Host {
    return Host(
      bio: """
Brandon did math for a very long time, and now enjoys talking about functional programming as a means to
better our craft as engineers.
""",
      image: Current.assets.brandonImgSrc,
      name: "Brandon Williams",
      twitterRoute: .mbrandonw,
      website: "http://www.fewbutripe.com"
    )
  }

  static var stephen: Host {
    return Host(
      bio: """
Stephen taught himself to code when he realized his English degree didn’t pay the bills. He became a
functional convert and believer after years of objects.
""",
      image: Current.assets.stephenImgSrc,
      name: "Stephen Celis",
      twitterRoute: .stephencelis,
      website: "http://www.stephencelis.com"
    )
  }
}
