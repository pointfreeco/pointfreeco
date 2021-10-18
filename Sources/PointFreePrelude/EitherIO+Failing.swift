import Either
import Prelude
import XCTestDynamicOverlay

extension EitherIO where E == Error {
  public static func failing(_ prefix: String = "") -> Self {
    .init(
      run: .init {
        XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")A failing effect ran.")
        return .left(UnimplementedError())
      }
    )
  }
}

extension EitherIO where E == Unit {
  public static func failing(_ prefix: String = "") -> Self {
    .init(
      run: .init {
        XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")A failing effect ran.")
        return .left(unit)
      }
    )
  }
}

private struct UnimplementedError: Error {}
