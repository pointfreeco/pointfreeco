import Tagged
import TaggedTime

extension Tagged where Tag == SecondsTag, RawValue == Int {
  public func formatted() -> String {
    let minutes = (rawValue / 60) % 60
    let hours = (rawValue / 60 / 60) % 60
    return hours == 0 ? "\(minutes) min" : "\(hours) hr \(minutes) min"
  }
}
