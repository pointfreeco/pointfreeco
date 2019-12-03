import ApplicativeRouter
import Prelude

/// Flattens a left-weighted nested 4-tuple.
func flatten<A, B, C, D, E>() -> PartialIso<(A, (B, (C, (D, E)))), (A, B, C, D, E)> {
  return .init(
    apply: { ($0.0, $0.1.0, $0.1.1.0, $0.1.1.1.0, $0.1.1.1.1) },
    unapply: { ($0, ($1, ($2, ($3, $4)))) }
  )
}

/// Converts a partial isomorphism of a flat 4-tuple to one of a right-weighted nested tuple.
public func parenthesize<A, B, C, D, E, F>(_ f: PartialIso<(A, B, C ,D, E), F>) -> PartialIso<(A, (B, (C, (D, E)))), F> {
  return flatten() >>> f
}
