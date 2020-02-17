import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Tagged

public typealias DecodableRequest<A> = Tagged<A, URLRequest> where A: Decodable
