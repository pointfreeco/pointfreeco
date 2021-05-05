import Either
import Prelude

extension EitherIO {
  public func debug<B>(prefix: @autoclosure @escaping () -> String = "", _ inspect: @escaping (A) -> B) -> EitherIO {
    self.flatMap {
      let p = prefix()
      print("\(p.isEmpty ? "" : "\(p): ")\(inspect($0))")
      return self
    }
  }

  public func debug(prefix: @autoclosure @escaping () -> String = "") -> EitherIO {
    self.debug(prefix: prefix(), id)
  }
}

extension EitherIO where A == Prelude.Unit, E == Error {
  public static func debug(prefix: @autoclosure @escaping () -> String) -> EitherIO {
    EitherIO(run: IO {
      print(prefix())
      return .right(unit)
    })
  }
}
