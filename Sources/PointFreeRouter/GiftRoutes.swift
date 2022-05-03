import Foundation
import Models
import Stripe
import TaggedMoney
import URLRouting

public enum Gifts: Equatable {
  case confirmation(GiftFormData)
  case create(GiftFormData)
  case index
  case plan(Plan)
  case redeem(Gift.Id, Redeem = .landing)

  public enum Redeem: Equatable {
    case confirm
    case landing
  }

  public enum Plan: String, CaseIterable {
    case threeMonths
    case sixMonths
    case year

    public init?(monthCount: Int) {
      switch monthCount {
      case 3: self = .threeMonths
      case 6: self = .sixMonths
      case 12: self = .year
      default: return nil
      }
    }

    public var amount: Cents<Int> {
      switch self {
      case .threeMonths:
        return 54_00
      case .sixMonths:
        return 108_00
      case .year:
        return 168_00
      }
    }

    public var monthCount: Int {
      switch self {
      case .threeMonths:
        return 3
      case .sixMonths:
        return 6
      case .year:
        return 12
      }
    }
  }
}

let giftsRouter = OneOf {
  Route(.case(Gifts.index))

  Route(.case(Gifts.confirmation)) {
    Method.post
    Body(.form(GiftFormData.self, decoder: formDecoder))
  }

  Route(.case(Gifts.create)) {
    Method.post
    Body(.json(GiftFormData.self, decoder: routeJsonDecoder, encoder: routeJsonEncoder))
  }

  Route(.case(Gifts.plan)) {
    Path { Gifts.Plan.parser() }
  }

  Route(.case(Gifts.redeem)) {
    Path { UUID.parser().map(.representing(Gift.Id.self)) }

    OneOf {
      Route(.case(Gifts.Redeem.landing))

      Route(.case(Gifts.Redeem.confirm)) {
        Method.post
      }
    }
  }
}

private let routeJsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()

private let routeJsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .secondsSince1970
  encoder.keyEncodingStrategy = .convertToSnakeCase
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  return encoder
}()
