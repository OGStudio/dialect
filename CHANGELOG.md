# [4.1.1](https://github.com/OGStudio/kotlin-dialect/pull/8 https://github.com/OGStudio/kotlin-dialect/pull/10)

2026-10-15

1. Add `public` to generated entities to Swift target so that the generated entites are visible across Swift module boundaries (entities are `internal` by default and invisible outside the hosting module)

# [4.1.0](https://github.com/OGStudio/kotlin-dialect/pull/8 https://github.com/OGStudio/kotlin-dialect/pull/9)

2026-10-14

1. Introduce `generator-script.swift` to be able to use the generator like a script (skipping the build stage) on macOS 

# [4.0.0](https://github.com/OGStudio/kotlin-dialect/pull/8)

2026-10-14

Initial release of the 4th edition of the cross-platform Redux approach, a logical continuation of Kotlin Dialect

Major changes: 
1. Kotlin is no longer SSOT
2. Kotlin Multiplatform has been deprecated in favour of code transpilation
3. Swift is now considered SSOT
4. LLM (Qwen Coder 2.5 3B) transpiled Swift to Kotlin to remove any runtime overhead incurred by Kotlin Multiplatform
