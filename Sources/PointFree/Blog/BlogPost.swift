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
