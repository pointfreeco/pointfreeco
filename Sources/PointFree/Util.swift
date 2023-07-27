import Foundation
import Prelude

public let currencyFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  // Workaround for https://bugs.swift.org/browse/SR-7481
  formatter.minimumIntegerDigits = 1
  formatter.numberStyle = .currency
  return formatter
}()

public let wholeCurrencyFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  // Workaround for https://bugs.swift.org/browse/SR-7481
  formatter.minimumIntegerDigits = 1
  formatter.maximumFractionDigits = 0
  formatter.numberStyle = .currency
  return formatter
}()

public let monthDayYearFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMM d, yyyy"
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  return formatter
}()

public let episodeDateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "EEEE MMM d, yyyy"
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  return formatter
}()
