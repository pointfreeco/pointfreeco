import ApplicativeRouter
import Either
import Models
import Prelude

extension BlogPost.Author {
  public var twitterUrl: String {
    switch self {
    case .brandon:
      return PointFree.twitterUrl(to: .mbrandonw)
    case .pointfree:
      return PointFree.twitterUrl(to: .pointfreeco)
    case .stephen:
      return PointFree.twitterUrl(to: .stephencelis)
    }
  }
}

extension PartialIso where A == Either<String, Int>, B == BlogPost {
  static var blogPostFromParam: PartialIso {
    return PartialIso(
      apply: fetchBlogPost(forParam:),
      unapply: Either.left <<< ^\.slug
    )
  }
}

extension PartialIso where A == BlogPost.Id, B == BlogPost {
  static var blogPostFromId: PartialIso {
    return PartialIso(
      apply: fetchBlogPost(forId:),
      unapply: ^\.id
    )
  }
}
