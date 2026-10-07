let CONV_EXAMPLE_SWIFT_SRC = """
SWIFT-4
        c.count += 1
SWIFT-5
        c.recentField == F.count
SWIFT-6
        c.countText = "Count: '\\(c.count)'"
SWIFT-7
        c.recentField == F.didLaunch

"""
let CONV_EXAMPLE_KOTLIN_DST = """
KOTLIN-4
        c.count += 1
KOTLIN-5
        c.recentField == F.count
KOTLIN-6
        c.countText = "Count: '${c.count}'"
KOTLIN-7
        c.recentField == F.didLaunch

"""
let CONV_PROMPT_PREFIX = """
You are a strict transpiler from Swift to Kotlin. Format output as in the following examples.

Example Swift input:
\(CONV_EXAMPLE_SWIFT_SRC)

Expected Kotlin output:
\(CONV_EXAMPLE_KOTLIN_DST)

And here are contents for you to transpile strictly according to the aforementioned format:

"""
