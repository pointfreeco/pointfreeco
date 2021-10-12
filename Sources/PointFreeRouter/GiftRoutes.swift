public enum Gift: Equatable {
  case index
  case plan(Plan)

  public enum Plan: String {
    case threeMonths
    case sixMonths
    case year
  }
}
