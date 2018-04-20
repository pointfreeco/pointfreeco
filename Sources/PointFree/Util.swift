import Foundation
import Optics
import Prelude

public let currencyFormatter = NumberFormatter()
  // Workaround for https://bugs.swift.org/browse/SR-7481
  |> set(^\.minimumIntegerDigits, 1)
  <> set(^\.numberStyle, .currency)

public let dateFormatter = DateFormatter()
  |> set(^\.dateStyle, .short)
  |> set(^\.timeStyle, .none)
  |> set(^\.timeZone, TimeZone(secondsFromGMT: 0))

public let episodeDateFormatter = DateFormatter()
  |> set(^\.dateFormat, "EEEE MMM d, yyyy")
  |> set(^\.timeZone, TimeZone(secondsFromGMT: 0))
