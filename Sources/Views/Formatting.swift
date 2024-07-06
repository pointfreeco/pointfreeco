import Foundation
import Tagged
import TaggedTime

extension Tagged where Tag == SecondsTag, RawValue == Int {
  public func formatted() -> String {
    let minutes = (rawValue / 60) % 60
    let hours = (rawValue / 60 / 60) % 60
    return hours == 0 ? "\(minutes) min" : "\(hours) hr \(minutes) min"
  }
}

extension Date {
  public func monthDayYear() -> String {
    Self.episodeFormatter.string(from: self)
  }

  public func weekdayMonthDayYear() -> String {
    Self.newsletterFormatter.string(from: self)
  }
  
  private static let episodeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "MMM d, yyyy"
    df.timeZone = TimeZone(secondsFromGMT: 0)
    return df
  }()

  private static let newsletterFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "EEEE MMMM d, yyyy"
    df.timeZone = TimeZone(secondsFromGMT: 0)
    return df
  }()
}
