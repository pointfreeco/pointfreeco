import Testing

struct GatedTrait: TestTrait, SuiteTrait, TestScoping {
  let gate: Gate
  var isRecursive: Bool { true }

  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: @Sendable () async throws -> Void
  ) async throws {
    guard testCase != nil else { return try await function() }
    try await gate.withGate(function)
  }
}

extension Trait where Self == GatedTrait {
  static func gated(limit: Int) -> Self {
    Self(gate: Gate(limit: limit))
  }
  static func gated(by gate: Gate) -> Self {
    Self(gate: gate)
  }
}

actor Gate {
  private let limit: Int
  private var active = 0
  private var waiters: [CheckedContinuation<Void, Never>] = []

  init(limit: Int) {
    self.limit = limit
  }

  func acquire() async {
    guard active >= limit
    else {
      active += 1
      return
    }
    await withCheckedContinuation { waiters.append($0) }
  }

  func release() {
    guard !waiters.isEmpty
    else {
      active -= 1
      return
    }
    waiters.removeFirst().resume()
  }

  func withGate<R: Sendable>(
    _ body: @Sendable () async throws -> R
  ) async rethrows -> R {
    await acquire()
    defer { release() }
    return try await body()
  }
}
