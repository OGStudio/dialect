let CONV_EXAMPLE_KOTLIN_DST = """
KOTLIN-1
        c.recentField == F.didClickIncrement &&
        c.count == 9
KOTLIN-2
        c.count += 10
KOTLIN-3
        c.recentField == F.didClickIncrement
KOTLIN-4
        c.count += 1
KOTLIN-5
        c.recentField == F.count
KOTLIN-6
        c.countText = "Count: '${c.count}'"
KOTLIN-7
        c.recentField == F.didLaunch
KOTLIN-8
        c.countText = "Press the button to count"
KOTLIN-9
        c.recentField == F.didSetup &&
        c.didLaunch == false
KOTLIN-10
        c.didLaunch = true
KOTLIN-11
        print(c.countText)
KOTLIN-12
        RootVM.shared!!.countText = c.countText

"""
let CONV_EXAMPLE_SWIFT_SRC = """
SWIFT-1
        c.recentField == F.didClickIncrement &&
        c.count == 9
SWIFT-2
        c.count += 10
SWIFT-3
        c.recentField == F.didClickIncrement
SWIFT-4
        c.count += 1
SWIFT-5
        c.recentField == F.count
SWIFT-6
        c.countText = "Count: '\\(c.count)'"
SWIFT-7
        c.recentField == F.didLaunch
SWIFT-8
        c.countText = "Press the button to count"
SWIFT-9
        c.recentField == F.didSetup &&
        c.didLaunch == false
SWIFT-10
        c.didLaunch = true
SWIFT-11
        print(c.countText)
SWIFT-12
        RootVM.shared!.countText = c.countText

"""
let CONV_OUTPUT_SUFFIX = """

Kotlin output:
"""
let CONV_PROMPT_PREFIX = """
You are a transpiler that converts Swift source code into idiomatic Kotlin source code.

Rules you must always follow:
- Output ONLY the transpiled Kotlin code as numbered KOTLIN-n blocks matching the format of the example below. Never repeat, quote, or echo the input Swift code.
- Never add leading titles, bullet points, explanations, or prose before the KOTLIN-1 block. Never add trailing notes, greetings, or text after the last KOTLIN-n block.
- Never wrap the output in markdown code fences or backticks.
- Never add blank lines between blocks. Keep the line structure of every condition exactly as in the input: never merge two lines, never split one line, never re-indent.
- Convert Swift string interpolation '\\(expr)' to Kotlin '${expr}'.
- Convert a Swift force unwrap 'x!' to the Kotlin non-null assertion 'x!!'.

Study this example of a correct Swift-to-Kotlin transpilation and match its format exactly:

SWIFT INPUT
===
\(CONV_EXAMPLE_SWIFT_SRC)
KOTLIN OUTPUT
===
\(CONV_EXAMPLE_KOTLIN_DST)
Transpile the following Swift input:
"""