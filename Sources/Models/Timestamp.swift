extension Int {
  public static func timestamp(hours: Int = 0, minutes: Int = 0, seconds: Int) -> Int {
    hours * 60 * 60 + minutes * 60 + seconds
  }
}
