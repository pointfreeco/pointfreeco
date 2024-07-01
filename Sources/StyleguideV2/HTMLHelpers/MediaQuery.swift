extension MediaQuery {
  public static let desktop = Self(rawValue: "only screen and (min-width: 832px)")
  public static let mobile = Self(rawValue: "only screen and (max-width: 831px)")
  public static let dark = Self(rawValue: "(prefers-color-scheme: dark)")
}
