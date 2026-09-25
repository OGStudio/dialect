# Dialect

Declarative reactive state management for macOS. This is a **new Swift port ("v4")** of the Kotlin Dialect (KD) controller & Klin code generator. Business logic is defined in YAML ("dialect") and executed by a Swift runtime.

## Structure

```
core/              Core runtime library
  swift/           Swift: DialectContext protocol + DialectController engine
  c/               C port of the Swift engine (dialect.h, DialectContext.c, DialectController.c, registerOneliners.c)
  nim/             Nim port of the Swift engine (dialectContext.nim, dialectController.nim, registerOneliners.nim)
  test/swift/      8 unit tests (custom runner, no XCTest)
  test/c/          C port of the 8 unit tests
  test/nim/        Nim port of the 8 unit tests
  util/run-swift-test   Compile & run core Swift tests (raw swiftc)
  util/run-c-test       Compile & run core C tests (raw cc)
  util/run-nim-test     Compile & run core Nim tests (raw nim)
generator/         The Swift port of the Klin code generator (tool)
  ver-mac/         SPM package (macOS 13+, no external dependencies)
    src/           Source; many files are SYMLINKS per group dir -> ../../../components/...
    components/    Source-of-truth for generated-style Swift files
      cli/         cli.swift, cliConst, cliFun, cliEffect, cliAux (symlinked into src)
      yml/         yml.swift, ymlConst, ymlEffect, ymlFun, ymlAux (symlinked into src)
      gen/         DEPRECATED (renamed to swift/) — removed
      swift/       swift.swift (SwiftComponent), swiftConstEmb64.swift (GENERATED `SWIFT_EMB64_CORE` = base64 of core/swift, built by util/step/embedCoreSwift); shoulds/register/set funcs live in tmp.dialect.swift
      other/       other.swift (otherSetupConsoleLogging, otherWriteFile)
    tmp.dialect.swift   Hand-written contexts, shoulds, register/set funcs, oneliners (temp, will be generated)
  dialect.swift       GENERATED (chicken-egg hand-patch of `struct F`; see below)
  dialect.yml       v4 dialect: CLIComponent, CLIContext, SwiftComponent, SwiftContext, OutputPath, RootContext, ShouldBranch, YMLComponent, YMLContext
  util/run-generator    Build & run generator binary (utility scripts live at the repo root)
example/           Sample macOS SwiftUI app + its own dialect.yml (a self-contained 2nd generation target)
  ver-mac/         SPM-based SwiftUI app (macOS 11+); fully regenerated `src/dialect.swift` (the engine is inline Swift source here — NOT a base64-embedded core)
  dialect.yml      Example dialect definition: one component (HelloWorldComponent) + one context (HelloWorldContext: count/didClickCount/didLaunch/didSetup) — no cross-component bridging needed (single context, single component)
  util/run-mac     Build & launch the example app (steps: generateDialect -> buildMac -> packageMac -> runMac; generateDialect runs `../../util/run-generator --file=dialect.yml` so the app fully regenerates from the built generator)
  src/tmp.dialect.swift  EMPTY (0 bytes) by design — the example's dialect.swift is fully regeneratable, so no hand-written mirror like the generator's own chicken-egg tmp
ref/               Reference to original Kotlin Dialect (symlink -> ../../kotlin-dialect)
  kom/             Newer Kotlin Multiplatform reference (symlink -> ../../kom)
```

**SYMLINK PARITY RULE**: Whenever a new `components/<group>/<file>.swift` is added, create a matching symlink `ver-mac/src/<group>/<file>.swift -> ../../../components/<group>/<file>.swift`, or the build won't see it. Component groups live under their own dirs under `src/`: `cli/`, `yml/`, `other/` (e.g. `ver-mac/src/yml/ymlConst.swift -> ../../../components/yml/ymlConst.swift`). New yml files (`ymlConst.swift`, `ymlFun.swift`) must be symlinked just like the cli ones.

## Build & Test

```bash
# Core Swift tests (raw swiftc, no SPM)
core/util/run-swift-test

# Core C tests (raw cc)
core/util/run-c-test

# Core Nim tests (raw nim)
core/util/run-nim-test

# Build generator (step-based; util/paths + util/step/* sourced by both scripts)
util/build-generator

# Generator tool (embeds core, builds, parses a YAML file & prints it)
util/run-generator <file.yaml>

# Example app
example/util/run-mac
```

**Steps**: `util/run-generator` and `util/build-generator` source `util/paths` (CORE_SWIFT, GENERATOR_COMPONENTS) and run `util/step/*` scripts in order: `embedCoreSwift` (Step 1: regenerates `components/swift/swiftConstEmb64.swift` = `let SWIFT_EMB64_CORE = base64` of core/swift + DialectController + registerOneliners), `buildGenerator` (Step 2: `swift build -c release`), `runGenerator` (Step 3, run-generator only). `build-generator` also sets `STEP=0` first.

## Key Concepts

- **DialectContext**: Protocol for typed field access by string name
- **DialectController**: Reactive engine — queue field mutations, process cascade
- **dialect.yml**: Declarative rules with `should` blocks, `if`/`then` conditions, plus `oneliners` mapping field-changes to effect/UI callbacks (e.g. `readFile: cliReadInputFile(c.inputFileName)`)
- **Oneliner effects**: registered via generic `registerOneliners<T>(ctrl, items:[Any]) -> T?` (from ref/kom) where items are `[fieldName, (T)->Void, ...]`; caller pins T via `let _: CLIContext? = registerOneliners(...)`. Effect funcs call `cliSet(field, value)` to push results back into the context, expanding the cascade.
- **Multiple components**: each component (CLIComponent, YMLComponent, SwiftComponent) owns its own context + controller and registers its own oneliners/shoulds. **Cross-component bridging** is done via oneliners in the source component, e.g. CLI's `inputContents` oneliner calls `ymlSet(F.inputContents, c.inputContents)` and YML's `entities` oneliner calls `swiftSet(F.entities, c.entities)` to push values into the YML/Swift controllers (`F` field-name constants are shared/global). Each component's init must call `xxxRegisterEffects(ctrl)` (oneliners) and `xxxRegisterShoulds(ctrl)`. Swift's `out` oneliner calls `otherWriteFile(c.path, c.out)` (needs `path` field in SwiftContext).
- **`outStructs` (v4-specific, separate from `out`)**: `SwiftContext.outStructs` holds the generated *plain struct-declaration text*, produced by the `outStructs` should: when `c.recentField == F.entityFieldTypes`, `c.outStructs = swiftStructs(c.entities, c.entityTypes, c.entityFields, c.entityFieldTypes)` and `recentField` becomes `F.outStructs`. It is NOT concatenated into `out` — `out` = `otherBase64ToString(SWIFT_EMB64_CORE) + c.outFields` only (verbatim). The `swiftStructs` fun (in `components/swift/swiftFun.swift`, 4 params: `entities [String]`, `entityTypes [Int:String]`, `entityFields [Int:[String]]`, `entityFieldTypes [Int:[Int:String]]`) filters entities by `entityTypes[id] == SWIFT_TYPE_STRUCT` ("struct"), then for each struct entity calls `swiftStruct(name, fields, fieldTypes)` which emits a plain `struct <Name> { var <field> = <Type>() ... }` — NO DialectContext conformance, NO recentField. The `entityTypes` dict drives which entities become plain structs vs components vs contexts. Templates: `SWIFT_STRUCT_T` (uses `%FIELDS%` placeholder, not `%ITEMS%`), `SWIFT_STRUCT_FIELD_T` (uses `%NAME%` + `%DEFAULT%`), `SWIFT_TYPE_STRUCT` ("struct").
- **`outContexts` (v4-specific, parallel to `outStructs`)**: `SwiftContext.outContexts` holds the generated *DialectContext struct-declaration text*, produced by the `outContexts` should: when `c.recentField == F.entityFieldTypes`, `c.outContexts = swiftContexts(c.entities, c.entityTypes, c.entityFields, c.entityFieldTypes)` and `recentField` becomes `F.outContexts`. Concatenated into `out` after `outStructs`. The `swiftContexts` fun filters entities by `entityTypes[id] == SWIFT_TYPE_CONTEXT` ("context"), then for each context entity calls `swiftContext(name, fields, fieldTypes)` which emits a full `struct <Name>: DialectContext { var <field> = <Type>() ... var recentField = "" func field<T>... mutating func setField... }`. Templates: `SWIFT_CONTEXT_T` (uses `%ITEMS%` + `%GETTERS%` + `%SETTERS%`), `SWIFT_CONTEXT_FIELD_T` (uses `%NAME%` + `%DEFAULT%`), `SWIFT_CONTEXT_GETTER_T` (uses `%NAME%`), `SWIFT_CONTEXT_SETTER_T` (uses `%NAME%` + `%TYPE%`), `SWIFT_TYPE_CONTEXT` ("context").
- **CHICKEN-EGG / struct F upkeep (critical)**: `F` (`struct F { static let ... = "<name>" }`) is a field-name constant struct. It is defined ONLY in the **generated** `ver-mac/src/dialect.swift` (compiled with tmp; tmp references `F.*` but declares no `struct F`). `dialect.swift` cannot be regenerated (regen needs the built generator, which needs dialect.swift). So **whenever dialect.yml adds a new field to any context, you MUST hand-patch the new `static let <field> = "<field>"` into the generated `ver-mac/src/dialect.swift` struct `F`**, placed in ASCII-alphabetical order between its siblings (e.g. `outStructs` goes between `outFields` and `outputPaths` — `S`(0x53) < `p`(0x70)). Skip this and the build fails (`F.outStructs` unresolved). This hand-patch is exactly what a future regen would emit, so it stays consistent.
- **tmp.dialect.swift mirror checklist** (when SSOT dialect.yml gains a field on a context — e.g. `entityFieldTypes` + `outStructs` on SwiftContext): (1) add the stored var to the context struct, alphabetically; (2) add the `field<T>` get-branch, alphabetically; (3) add the `setField` branch, alphabetically; (4) add a `xxxShouldReset<Field>` should fun (with `if c.recentField == F.<sourceField>` → compute → `c.recentField = F.<targetField>`) and register it in `xxxRegisterShoulds` (alphabetical); (5) if another component's oneliner should feed it (YML→Swift bridge), add its oneliner in `ymlRegisterEffects` (e.g. `entityFieldTypes: swiftSet(F.entityFieldTypes, c.entityFieldTypes)` — this both feeds `SwiftContext.entityFieldTypes` and, via `recentField`, triggers `swiftShouldResetOutStructs`).
- **Per-component helper files** (components/yml/): `ymlConst.swift` (global constants like `YML_PREFIX_VERSION`), `ymlFun.swift` (pure helpers/parsers like `ymlParseVersion`), `ymlEffect.swift` (effects that `ymlSet` results back), `ymlAux.swift` (aux/print helpers). Matching `cliConst/cliFun/cliEffect/cliAux`.
- **YML schema parsing** (chunks): input is split into **chunks** = `[String: [String]]` keyed by the chunk's first (non-indented) line. Blank lines (`""`) delimit chunks — detected by `ymlIsLineChunkStart`/`ymlIsLineChunkEnd`. Downstream parsers consume structures: `ymlParseEntities` (top-level `Key:` lines, `hasSuffix(":")`), `ymlParseEntityTypes` (indented `type:` under each entity, `YML_PREFIX_TYPE` bakes in the 4-space indent), `ymlParseVersion` (from the chunk key prefix `YML_PREFIX_VERSION`). Should-chains cascade: `inputLines` → `chunks`/`entities`, then `chunks` → `version`, `entities` → `entityTypes`.
- **ShouldBranch struct (renamed fields)**: dialect.yml's `ShouldBranch` struct entity has fields `about` (String), `condition` ([String]), `reaction` ([String]) — these were **renamed** from `desc`/`if`/`then` to avoid the Swift keywords `if`/`then` and match "condition/reaction" semantics. The YAML **input** markers for parsing still read `if:`/`then:` (prefixed lines), but they map into `condition`/`reaction` fields via `isParsingCondition`/`isParsingReaction` flags in `ymlParseEntityShouldBranches`. Generated code: `struct ShouldBranch` (plain struct, in `outStructs`) + the `F.about/condition/reaction` constants (hand-patched into the generated `dialect.swift`).
- **Rename propagation (single SSOT in dialect.yml)**: when a struct *field* is renamed in dialect.yml (like `desc/if/then` → `about/condition/reaction`), update ALL of these in one pass: (1) the `ShouldBranch` struct declaration + `F` constants in the generated `ver-mac/src/dialect.swift` (hand-patch); (2) `ymlFun.swift` — field writes (`.about`), local var names, parser flags (`isParsingCondition`/`isParsingReaction`) and their comments; (3) `swiftConst.swift` `SWIFT_SHOULD_BRANCH_T` template placeholders (`%ABOUT%`/`%CONDITION%`/`%REACTION%`); (4) `swiftFun.swift` commented `swiftShould` refs (`branch.about`, `.condition`, `.reaction`); (5) C `core/c/dialect.h` `ShouldBranch` struct (`about`/`condition`/`reaction`; the `if`→`condition` change also *removes* the old `if_` C-keyword workaround); (6) Nim `core/nim/dialectContext.nim` `ShouldBranch` object (`about`/`condition`/`reaction`; backticks only remain where the field is still a Nim keyword, e.g. `OutputPath`'s `` `type` ``). After the rename, verify regen-stability: run `core/util/run-c-test`, `core/util/run-nim-test`, `util/build-generator`, then `util/run-generator --file=dialect.yml` and confirm `ver-mac/src/dialect.swift` regenerates byte-identical to the hand-patch (hash matches).
- **Keyword collision conventions across ports**: Swift backticks Swift keywords (`` `if` ``, `` `type` ``); C appends `_` (former `if_`); Nim backticks Nim keywords (`` `type` ``). Renaming a field away from a keyword lets you drop the escape in every port. The `if`/`then` in `ymlConst.swift` prefix constants (`YML_PREFIX_SHOULD_BRANCH_IF` = `"                if:"`, then-marker) are the *input syntax*, NOT struct fields — they intentionally keep the `if:`/`then:` spelling and are NOT part of the rename.

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
