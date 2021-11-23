import ApplicativeRouter
import Foundation
import Models
import Parsing
import Prelude
import Stripe
import TaggedMoney

public enum Gifts: Equatable {
  case confirmation(GiftFormData)
  case create(GiftFormData)
  case index
  case plan(Plan)
  case redeem(Gift.Id)
  case redeemLanding(Gift.Id)

  public enum Plan: String {
    case threeMonths
    case sixMonths
    case year

    public init?(monthCount: Int) {
      switch monthCount {
      case 3:  self = .threeMonths
      case 6:  self = .sixMonths
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

let giftsRouter = giftsRouters.reduce(.empty, <|>)

private let giftsRouters: [Router<Gifts>] = [
  .case(Gifts.confirmation)
    <¢> post
    %> formBody(GiftFormData.self, decoder: formDecoder) <% end,

  .case(Gifts.create)
    <¢> post
    %> jsonBody(GiftFormData.self, encoder: routeJsonEncoder, decoder: routeJsonDecoder) <% end,

  .case(.index)
    <¢> get <% end,

  .case(Gifts.plan)
    <¢> get %> pathParam(.rawRepresentable) <% end,

  .case(Gifts.redeem)
    <¢> post %> pathParam(.tagged(.uuid)) <% end,

  .case(Gifts.redeemLanding)
    <¢> get %> pathParam(.tagged(.uuid)) <% end,
]

let _giftsRouter = OneOf {
  Routing(/Gifts.index) {
    Method.get
  }

//  Routing(/Gifts.confirmation) {
//    Method.post
//    Body {
//      FormData(GiftFormData.self, decoder: formDecoder)
//    }
//  }

//  Routing(/Gifts.create) {
//    Method.post
//    Body {
//      JSON(GiftFormData.self, encoder: routeJsonEncoder, decoder: routeJsonDecoder)
//    }
//  }

  Routing(/Gifts.plan) {
    Method.get
    Path(String.parser().pipe { Gifts.Plan.parser() })
  }

  Routing(/Gifts.redeemLanding) {
    Method.get
    Path(UUID.parser().pipe { Gift.Id.parser() })
  }

  Routing(/Gifts.redeem) {
    Method.post
    Path(UUID.parser().pipe { Gift.Id.parser() })
  }
}
