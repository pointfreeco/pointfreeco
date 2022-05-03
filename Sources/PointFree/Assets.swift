public struct Assets {
  public var brandonImgSrc: String
  public var stephenImgSrc: String
  public var emailHeaderImgSrc: String
  public var pointersEmailHeaderImgSrc: String

  public init(
    brandonImgSrc: String = "https://d3rccdn33rt8ze.cloudfront.net/about-us/brando.jpg",
    stephenImgSrc: String = "https://d3rccdn33rt8ze.cloudfront.net/about-us/stephen.jpg",
    emailHeaderImgSrc: String =
      "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-email-header.png",
    pointersEmailHeaderImgSrc: String =
      "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-pointers-header.jpg"
  ) {
    self.brandonImgSrc = brandonImgSrc
    self.stephenImgSrc = stephenImgSrc
    self.emailHeaderImgSrc = emailHeaderImgSrc
    self.pointersEmailHeaderImgSrc = pointersEmailHeaderImgSrc
  }
}
