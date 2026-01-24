public func retry<R>(
  maxRetries: Int,
  backoff: (Int) -> Duration,
  operation: () async throws -> R
) async throws -> R {
  var attempt = 0
  while true {
    do {
      return try await operation()
    } catch {
      attempt += 1
      if attempt > maxRetries { throw error }
      try await Task.sleep(for: backoff(attempt))
    }
  }
}
