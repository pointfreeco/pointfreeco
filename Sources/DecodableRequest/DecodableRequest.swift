import Foundation
import Tagged

public typealias DecodableRequest<A> = Tagged<A, URLRequest> where A: Decodable
