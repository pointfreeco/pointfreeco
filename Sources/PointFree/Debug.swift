import Either
import Prelude

extension EitherIO {
  public func debug<B>(prefix: String = "", _ inspect: @escaping (A) -> B) -> EitherIO {
    self.flatMap {
      print("\(prefix.isEmpty ? "" : "\(prefix): ")\(inspect($0))")
      return self
    }
  }

  public func debug(prefix: String = "") -> EitherIO {
    self.debug(prefix: prefix, id)
  }
}

extension EitherIO where A == Prelude.Unit, E == Error {
  public static func debug(prefix: String) -> EitherIO {
    EitherIO(run: IO {
      print(prefix)
      return .right(unit)
    })
  }
}
