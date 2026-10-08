
# Dialect

Plan:

1. You write Swift code as Single source of truth
1. Agent transpiles parts of the code to other languages
1. You get native support (without KMP or similar binary approach) at no runtime cost

# Example

Prerequisites for Android:

* Android Studio for macOS

Prerequisites for iOS:

* XcodeGen: `brew install xcodegen`

Prerequisites for transpilation:

* `ollama serve` everytime you plan to transpile
* `ollama run qwen2.5-coder:3b` (2 GB disk, 2 GB VRAM) only once to install, for later runs ollama loads requested models itself, `ollama serve` is enough after that
