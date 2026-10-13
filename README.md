
# Dialect

Dialect is a way to write cross-platform logic core natively.

How it works:

1. Write Swift code as Single source of truth
1. Make sure (debug, fine tune, etc.) it works for both macOS & iOS
1. Use 'kotlin' target inside `dialect.yml` to have it transpiled to `dialect.kt` via LLM
1. Make sure (debug, fine tune, etc.) it works for Android, too (Effects are your part, yes, only `dialect.yml` logic is transpiled)

# Supported platforms

Currently Dialect is only supported for: macOS, iOS, and Android.

Linux and Windows support is pending

# Example

Have a look at `example` directory. The `dialect.swift` file is generated for macOS & iOS. The `dialect.kt` file is an equivalent transpilation to Kotlin.

Prerequisites for macOS:

* Xcode

Prerequisites for iOS:

* XcodeGen: `brew install xcodegen`

Prerequisites for Android:

* Android Studio for macOS

Prerequisites for transpilation:

* `ollama serve` everytime you plan to transpile
* `ollama run qwen2.5-coder:3b` (2 GB disk, 2 GB VRAM) only once to install, for later runs ollama loads requested models itself, `ollama serve` is enough after that
