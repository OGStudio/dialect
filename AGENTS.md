# Dialect

Declarative reactive state management for macOS. This is a **new Swift port ("v4")** of the Kotlin Dialect (KD) controller & Klin code generator. Business logic is defined in YAML ("dialect") and executed by a Swift runtime.

## Structure

```
core/              Core Swift runtime library
  swift/           DialectContext protocol + DialectController engine
  test/swift/      8 unit tests (custom runner, no XCTest)
  util/run-swift-test   Compile & run core tests (raw swiftc)
generator/         The Swift port of the Klin code generator (tool)
  ver-mac/         SPM package (macOS 13+, depends on Yams 5.4.0)
    src/           Source (collapsed from Sources/YamlParser -> src)
    tmp.dialect.swift   Hand-written CLIContext + should funcs (temp, will be generated)
  dialect.yml       v4 dialect: CLIContext, CLIShould, DialectContext, RootContext
  util/run-generator    Build & run yamlparser binary ($@, ver-mac/.build/release)
example/           Sample macOS SwiftUI app + dialect.yml
  ver-mac/         SPM-based SwiftUI app (macOS 11+)
  dialect.yml      Example dialect definition
  util/run-mac     Build & launch the example app
ref/               Reference to original Kotlin Dialect (symlink -> ../../kotlin-dialect)
```

## Build & Test

```bash
# Core tests (raw swiftc, no SPM)
core/util/run-swift-test

# Generator tool (parses a YAML file & prints it)
generator/util/run-generator <file.yaml>

# Example app
example/util/run-mac
```

## Key Concepts

- **DialectContext**: Protocol for typed field access by string name
- **DialectController**: Reactive engine — queue field mutations, process cascade
- **dialect.yml**: Declarative rules with `should` blocks, `if`/`then` conditions

## KD (Kotlin Dialect) reference — see ref/kotlin-dialect

We're porting this to Swift as dialect v4

- **Redux-like architecture**: Controller/Context (Store), Shoulds (Reducers), Effects
- **KDContext** protocol: `recentField: String`, `field<T>(name)`, `fieldAny(name)`, `selfCopy()`, `setField(name, value)` — selfCopy lets the controller treat derived contexts uniformly
- **KDController**: accumulates a `queue` of context snapshots, each with `recentField` set. `set()` copies context, applies mutation, queues it, runs `processQueue()`. `executeFunctions()` applies queued mutation then runs every should-function; a function re-queues only if it changed a field (`recentField != KD_FIELD_NONE ("none")`). Recursion blocked via `isProcessingQueue`.
- **Should-functions (reducers)**: receive a context copy, return a new context. SSOT rule: **only one should-function may write a given field** (name them `shouldReset<FieldName>` style; combine branches that write the same field into one function).
- **Entity types** in kd.yml: `context`, `struct`, `should`; fields typed; `output:` section declares codegen targets (`type: kotlin|swift|c++hdr|c++sdk|c++src|jsexport`); `prefix-kotlin`/`raw*` for code insertion; `F` struct holds field-name string constants used in conditions like `c.recentField == F.didSetup`.
- **Klin**: Original KD codegen is a Node.js app built from Kotlin. Dialect v4 is reimplementing this in Swift.

## Conventions

- macOS-only (Swift 5.9+, macOS 11+ for app, 13+ for generator)
- No Xcode projects, SPM only (except core tests use swiftc directly)
- Artifacts go to `.build/` (not `build/`)
- No CI/CD
- License: CC0 1.0 (public domain)
