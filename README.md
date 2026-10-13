
# Dialect

Dialect is a way to write cross-platform logic core natively without a burden of having KMP-like binary, wrappers, and other runtime / build time overhead

How you should now work:

1. Write macOS application with Swift and SwiftUI to serve as Single source of truth
1. Add iOS support by adapting SwiftUI to mobile UX
1. Add Android support by using 'kotlin' target inside `dialect.yml` to have it transpiled to `dialect.kt` via LLM
1. Manually provide and fine tune Effects, SwiftUI, Jetpack Compose

# Supported platforms

Currently Dialect only supports development for: macOS, iOS, and Android.

Linux and Windows support is pending.

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
