public enum Gifts: Equatable {
  case create
  case index
  case plan(Plan)

  public enum Plan: String {
    case threeMonths
    case sixMonths
    case year

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
