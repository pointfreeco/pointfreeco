import Foundation
import Tagged

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public typealias DecodableRequest<A> = Tagged<A, URLRequest> where A: Decodable
