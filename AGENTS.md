# Dialect

Declarative reactive state management for macOS. Business logic is defined in YAML ("dialect") and executed by a Swift runtime.

## Structure

```
core/              Core Swift runtime library
  swift/           DialectContext protocol + DialectController engine
  test/swift/      8 unit tests (custom runner, no XCTest)
  util/run-swift-test   Compile & run core tests (raw swiftc)
generator/         YAML parser CLI tool (SPM, depends on Yams 5.4.0)
example/           Sample macOS SwiftUI app + dialect.yml
  ver-mac/         SPM-based SwiftUI app (macOS 11+)
  dialect.yml      Example dialect definition
  util/run-mac     Build & launch the example app
```

## Build & Test

```bash
# Core tests (raw swiftc, no SPM)
core/util/run-swift-test

# Generator tool
cd generator && swift build

# Example app
example/util/run-mac
```

## Key Concepts

- **DialectContext**: Protocol for typed field access by string name
- **DialectController**: Reactive engine — queue field mutations, process cascade
- **dialect.yml**: Declarative rules with `should` blocks, `if`/`then` conditions

## Conventions

- macOS-only (Swift 5.9+, macOS 11+ for app, 13+ for generator)
- No Xcode projects, SPM only (except core tests use swiftc directly)
- No CI/CD
- License: CC0 1.0 (public domain)
