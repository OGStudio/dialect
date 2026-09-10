# Dialect

Declarative reactive state management for macOS. This is a **new Swift port ("v4")** of the Kotlin Dialect (KD) controller & Klin code generator. Business logic is defined in YAML ("dialect") and executed by a Swift runtime.

## Structure

```
core/              Core Swift runtime library
  swift/           DialectContext protocol + DialectController engine
  test/swift/      8 unit tests (custom runner, no XCTest)
  util/run-swift-test   Compile & run core tests (raw swiftc)
generator/         The Swift port of the Klin code generator (tool)
  ver-mac/         SPM package (macOS 13+, no external dependencies)
    src/           Source; many files are SYMLINKS -> ../../components/...
    components/    Source-of-truth for generated-style Swift files
      cli/         cli.swift, cliConst, cliFun, cliEffect, cliAux (symlinked into src)
      yml/         yml.swift, ymlConst, ymlEffect, ymlFun, ymlAux (symlinked into src)
      other/       other.swift (otherSetupConsoleLogging)
    tmp.dialect.swift   Hand-written contexts, shoulds, register/set funcs, oneliners (temp, will be generated)
  dialect.yml       v4 dialect: CLIContext, CLIComponent, YMLContext, YMLComponent, RootContext
  util/run-generator    Build & run generator binary ($@, ver-mac/.build/release/generator)
example/           Sample macOS SwiftUI app + dialect.yml
  ver-mac/         SPM-based SwiftUI app (macOS 11+)
  dialect.yml      Example dialect definition
  util/run-mac     Build & launch the example app
ref/               Reference to original Kotlin Dialect (symlink -> ../../kotlin-dialect)
  kom/             Newer Kotlin Multiplatform reference (symlink -> ../../kom)
```

**SYMLINK PARITY RULE**: Whenever a new `components/<group>/<file>.swift` is added, create a matching symlink `ver-mac/src/<group>/<file>.swift -> ../../../components/<group>/<file>.swift`, or the build won't see it. Component groups live under their own dirs under `src/`: `cli/`, `yml/`, `other/` (e.g. `ver-mac/src/yml/ymlConst.swift -> ../../../components/yml/ymlConst.swift`). New yml files (`ymlConst.swift`, `ymlFun.swift`) must be symlinked just like the cli ones.

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
- **dialect.yml**: Declarative rules with `should` blocks, `if`/`then` conditions, plus `oneliners` mapping field-changes to effect/UI callbacks (e.g. `readFile: cliReadInputFile(c.inputFileName)`)
- **Oneliner effects**: registered via generic `registerOneliners<T>(ctrl, items:[Any]) -> T?` (from ref/kom) where items are `[fieldName, (T)->Void, ...]`; caller pins T via `let _: CLIContext? = registerOneliners(...)`. Effect funcs call `cliSet(field, value)` to push results back into the context, expanding the cascade.
- **Multiple components**: each component (CLIComponent, YMLComponent) owns its own context + controller and registers its own oneliners/shoulds. **Cross-component bridging** is done via oneliners in the source component, e.g. CLI's `inputContents` oneliner calls `ymlSet(F.inputContents, c.inputContents)` to push a value into the YML controller (`F` field-name constants are shared/global). Each component's init must call `xxxRegisterEffects(ctrl)` (oneliners) and `xxxRegisterShoulds(ctrl)`.
- **Per-component helper files** (components/yml/): `ymlConst.swift` (global constants like `YML_PREFIX_VERSION`), `ymlFun.swift` (pure helpers/parsers like `ymlParseVersion`), `ymlEffect.swift` (effects that `ymlSet` results back), `ymlAux.swift` (aux/print helpers). Matching `cliConst/cliFun/cliEffect/cliAux`.
- **YML schema parsing** (chunks): input is split into **chunks** = `[String: [String]]` keyed by the chunk's first (non-indented) line. Blank lines (`""`) delimit chunks — detected by `ymlIsLineChunkStart`/`ymlIsLineChunkEnd`. Downstream parsers consume structures: `ymlParseEntities` (top-level `Key:` lines, `hasSuffix(":")`), `ymlParseEntityTypes` (indented `type:` under each entity, `YML_PREFIX_TYPE` bakes in the 4-space indent), `ymlParseVersion` (from the chunk key prefix `YML_PREFIX_VERSION`). Should-chains cascade: `inputLines` → `chunks`/`entities`, then `chunks` → `version`, `entities` → `entityTypes`.

## Swift gotchas (learned the hard way)

- `!x.isEmpty()` parses as force-unwrap — use `!x.isEmpty` or `x != ""`.
- `String.startsWith(prefix)` is not Swift — use `hasPrefix`.
- `String.substring(from:)` is not Swift — use `dropFirst(n)`/`dropFirst(prefix.count)`.
- `String.trim()`, `find`, `indexOf`, `trimming` do NOT exist here — use `hasPrefix`/`hasSuffix`/`isEmpty`/`contains`. To strip indentation, either bake it into the `YML_PREFIX_*` constant (e.g. `"    type: "`) or loop `while s.hasPrefix(" ") { s = String(s.dropFirst(1)) }`.
- `String.split(separator:)` DEFAULTS to `omittingEmptySubsequences: true` — blank lines get silently dropped. Pass `omittingEmptySubsequences: false` when blank lines matter (chunk boundaries depend on them!).
- `Substring` is NOT implicitly convertible to `String` — `s.dropFirst(1)`/`dropLast(1)` return `Substring`; you must write `String(...)` explicitly (at assignment, `.append`, and argument boundaries).
- `[String] += someString` fails (String is treated as a character Sequence) — use `.append(someString)`.
- Kotlin-style `if cond && let x = ...` is invalid Swift — use a comma: `if cond, let x = ...`.
- `str.split("\n")` is wrong — use `str.split(separator: "\n")`. But for chunking you need the empty-subsequences variant above.
- Optionals at the boundary: `value as! Bool`/`as! String` force-casts in setField; a String field wrote from an effect must match its declared type exactly.

## Code layout

- **Alphabetical ordering is enforced**: F constants, struct fields, `field<T>`/`setField` branches, should-functions, and register lists are all sorted alphabetically (ASCII collation, so `entityFieldTypes` < `entityFields` since `T` < `s`). Same for functions in `ymlFun.swift`/`ymlConst.swift`.

## KD (Kotlin Dialect) reference — see ref/kotlin-dialect

We're porting this to Swift as dialect v4

- **Redux-like architecture**: Controller/Context (Store), Shoulds (Reducers), Effects
- **KDContext** protocol: `recentField: String`, `field<T>(name)`, `fieldAny(name)`, `selfCopy()`, `setField(name, value)` — selfCopy lets the controller treat derived contexts uniformly
- **KDController**: accumulates a `queue` of context snapshots, each with `recentField` set. `set()` copies context, applies mutation, queues it, runs `processQueue()`. `executeFunctions()` applies queued mutation then runs every should-function; a function re-queues only if it changed a field (`recentField != KD_FIELD_NONE ("none")`). Recursion blocked via `isProcessingQueue`.
- **Should-functions (reducers)**: receive a context copy, return a new context. SSOT rule: **only one should-function may write a given field** (name them `shouldReset<FieldName>` style; combine branches that write the same field into one function, e.g. `cliShouldResetConsoleOutput` holds both "no file arg" and "input error" branches).
- **CLIError**: enum in `components/cli/cliAux.swift` (conforming to Error) for should/effect error signaling; effect funcs `throw` rather than doing multiple `cliSet` writes, so each field has exactly one write site.
- **Entity types** in kd.yml: `context`, `struct`, `should`; fields typed; `output:` section declares codegen targets (`type: kotlin|swift|c++hdr|c++sdk|c++src|jsexport`); `prefix-kotlin`/`raw*` for code insertion; `F` struct holds field-name string constants used in conditions like `c.recentField == F.didSetup`.
- **Klin**: Original KD codegen is a Node.js app built from Kotlin. Dialect v4 is reimplementing this in Swift.

## Conventions

- macOS-only (Swift 5.9+, macOS 11+ for app, 13+ for generator)
- No Xcode projects, SPM only (except core tests use swiftc directly)
- Artifacts go to `.build/` (not `build/`)
- No CI/CD
- License: CC0 1.0 (public domain)
