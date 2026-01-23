---
name: Legacy Refactoring
description: Refactor legacy code in pointfree.co
metadata:
  short-description: Refactor legacy code
---

# Legacy Refactoring

## How to refactor middleware

- Refactor a single middleware at a time.
- The IO type should be refactored into simple Swift functions, using async where needed
- The EitherIO type should be refactored into inline async/throws logic that gets wrapped with try-catch
- The Prelude.Unit (sometimes just Unit) type should be refactored away to Void
- The Either type should be refactored away to a domain-specific enum or result type
- The Conn type should only be mapped to Void (`conn.map { _ in }`) and not to hold other data. Instead, always pass data along to the middleware function

## How to refactor views

1. Old Node-based views should be refactored using StyleguideV2's HTML protocol
2. Use respondV2 in middleware instead of respond
