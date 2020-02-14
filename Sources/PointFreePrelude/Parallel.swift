import Prelude

public func zip2<A, B>(_ lhs: Parallel<A>, _ rhs: Parallel<B>) -> Parallel<(A, B)> {
  return tuple <¢> lhs <*> rhs
}

public func zip3<A, B, C>(_ a: Parallel<A>, _ b: Parallel<B>, _ c: Parallel<C>) -> Parallel<(A, B, C)> {
  return tuple3 <¢> a <*> b <*> c
}

public func zip4<A, B, C, D>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>
  ) -> Parallel<(A, B, C, D)> {

  return tuple4 <¢> a <*> b <*> c <*> d
}

public func zip5<A, B, C, D, E>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>,
  _ e: Parallel<E>
  ) -> Parallel<(A, B, C, D, E)> {

  return tuple5 <¢> a <*> b <*> c <*> d <*> e
}

public func zip6<A, B, C, D, E, F>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>,
  _ e: Parallel<E>,
  _ f: Parallel<F>
  ) -> Parallel<(A, B, C, D, E, F)> {

  return tuple6 <¢> a <*> b <*> c <*> d <*> e <*> f
}

public func zip7<A, B, C, D, E, F, G>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>,
  _ e: Parallel<E>,
  _ f: Parallel<F>,
  _ g: Parallel<G>
  ) -> Parallel<(A, B, C, D, E, F, G)> {

  return tuple7 <¢> a <*> b <*> c <*> d <*> e <*> f <*> g
}

public func zip8<A, B, C, D, E, F, G, H>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>,
  _ e: Parallel<E>,
  _ f: Parallel<F>,
  _ g: Parallel<G>,
  _ h: Parallel<H>
  ) -> Parallel<(A, B, C, D, E, F, G, H)> {

  return tuple8 <¢> a <*> b <*> c <*> d <*> e <*> f <*> g <*> h
}

public func zip9<A, B, C, D, E, F, G, H, I>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>,
  _ e: Parallel<E>,
  _ f: Parallel<F>,
  _ g: Parallel<G>,
  _ h: Parallel<H>,
  _ i: Parallel<I>
  ) -> Parallel<(A, B, C, D, E, F, G, H, I)> {

  return tuple9 <¢> a <*> b <*> c <*> d <*> e <*> f <*> g <*> h <*> i
}
