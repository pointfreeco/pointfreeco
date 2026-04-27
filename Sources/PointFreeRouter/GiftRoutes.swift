import Foundation
import Models
import Stripe
import TaggedMoney
import URLRouting

public enum Gifts: Equatable {
  case create(GiftFormData)
  case index
  case plan(Plan)
  case redeem(Gift.ID, Redeem = .landing)

  public enum Redeem: Equatable {
    case confirm
    case landing
  }

  public enum Plan: String, CaseIterable {
    case threeMonthsPro
    case sixMonthsPro
    case yearlyPro
    case yearlyMax

    public static var allCases: [Plan] {
      [.sixMonthsPro, .yearlyPro, .yearlyMax]
    }

    public var amount: Cents<Int> {
      switch self {
      case .threeMonthsPro:
        return 72_00
      case .sixMonthsPro:
        return 144_00
      case .yearlyPro:
        return 216_00
      case .yearlyMax:
        return 349_00
      }
    }

    public init?(monthsFree: Int, plan: Pricing.Plan) {
      switch (monthsFree, plan) {
      case (3, .pro): self = .threeMonthsPro
      case (6, .pro): self = .sixMonthsPro
      case (12, .pro): self = .yearlyPro
      case (12, .max): self = .yearlyMax
      default: return nil
      }
    }

    public var monthCount: Int {
      switch self {
      case .threeMonthsPro:
        return 3
      case .sixMonthsPro:
        return 6
      case .yearlyPro, .yearlyMax:
        return 12
      }
    }

    public var pricingPlan: Pricing.Plan {
      switch self {
      case .threeMonthsPro, .sixMonthsPro, .yearlyPro:
        return .pro
      case .yearlyMax:
        return .max
      }
    }
  }
}

struct GiftsRouter: ParserPrinter {
  var body: some Router<Gifts> {
    OneOf {
      Route(.case(Gifts.index))

      Route(.case(Gifts.create)) {
        Method.post
        Body(.form(GiftFormData.self, decoder: formDecoder))
      }

      Route(.case(Gifts.plan)) {
        Path { Gifts.Plan.parser() }
      }

      Route(.case(Gifts.redeem)) {
        Path { UUID.parser().map(.representing(Gift.ID.self)) }

        OneOf {
          Route(.case(Gifts.Redeem.landing))

          Route(.case(Gifts.Redeem.confirm)) {
            Method.post
          }
        }
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
