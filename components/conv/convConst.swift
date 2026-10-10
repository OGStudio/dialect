let CONV_EXAMPLE_KOTLIN_DST = """
KOTLIN-1
        c.singleton!!.countText = c.countText
KOTLIN-2
        val vm = RootVM.shared as RootVM
KOTLIN-3
        RootVM.shared!!.countText = c.countText
KOTLIN-4
        proxy.base!!.count = 0
KOTLIN-5
        val copy = engine.stage as Stage
KOTLIN-6
        c.words = listOf(c.head, "z")
KOTLIN-7
        c.countText = "Count: '${c.count}'"
KOTLIN-8
        !c.countText.isEmpty()
KOTLIN-9
        c.items = listOf(c.name, "x")
KOTLIN-10
        c.label = "name: '${c.name}'"
KOTLIN-11
        c.items.forEach { item ->
            c.count += 1
        }
KOTLIN-12
        c.countText = if (c.count > 0) "yes" else "no"
KOTLIN-13
        c.recentField == F.didClickIncrement &&
        c.count == 9
KOTLIN-14
        c.count += 10
KOTLIN-15
        c.recentField == F.didClickIncrement
KOTLIN-16
        c.count += 1
KOTLIN-17
        c.recentField == F.count
KOTLIN-18
        c.recentField == F.didLaunch
KOTLIN-19
        c.countText = "Press the button to count"
KOTLIN-20
        c.recentField == F.didSetup &&
        c.didLaunch == false
KOTLIN-21
        c.didLaunch = true
KOTLIN-22
        print(c.countText)
KOTLIN-23
        c.recentField == F.didRename &&
        c.name != "new"
KOTLIN-24
        c.count >= 10
KOTLIN-25
        !c.didLaunch
KOTLIN-26
        c.label = c.name + "-" + c.countText
"""
let CONV_EXAMPLE_SWIFT_SRC = """
SWIFT-1
        c.singleton!.countText = c.countText
SWIFT-2
        let vm = RootVM.shared as! RootVM
SWIFT-3
        RootVM.shared!.countText = c.countText
SWIFT-4
        proxy.base!.count = 0
SWIFT-5
        let copy = engine.stage as! Stage
SWIFT-6
        c.words = [c.head, "z"]
SWIFT-7
        c.countText = "Count: '\\(c.count)'"
SWIFT-8
        !c.countText.isEmpty
SWIFT-9
        c.items = [c.name, "x"]
SWIFT-10
        c.label = "name: '\\(c.name)'"
SWIFT-11
        c.items.forEach { item in
            c.count += 1
        }
SWIFT-12
        c.countText = c.count > 0 ? "yes" : "no"
SWIFT-13
        c.recentField == F.didClickIncrement &&
        c.count == 9
SWIFT-14
        c.count += 10
SWIFT-15
        c.recentField == F.didClickIncrement
SWIFT-16
        c.count += 1
SWIFT-17
        c.recentField == F.count
SWIFT-18
        c.recentField == F.didLaunch
SWIFT-19
        c.countText = "Press the button to count"
SWIFT-20
        c.recentField == F.didSetup &&
        c.didLaunch == false
SWIFT-21
        c.didLaunch = true
SWIFT-22
        print(c.countText)
SWIFT-23
        c.recentField == F.didRename &&
        c.name != "new"
SWIFT-24
        c.count >= 10
SWIFT-25
        !c.didLaunch
SWIFT-26
        c.label = c.name + "-" + c.countText
"""
let CONV_PREFIX_KOTLIN = "KOTLIN-"
let CONV_PREFIX_SWIFT = "SWIFT-"
let CONV_PROMPT_PREFIX = """
You are a transpiler that converts Swift source code into idiomatic Kotlin source code.

Rules you must always follow:
- Output ONLY the transpiled Kotlin code as numbered KOTLIN-n blocks matching the format of the example below. Never repeat, quote, or echo the input Swift code.
- Never add leading titles, bullet points, explanations, or prose before the KOTLIN-0 block. Never add trailing notes, greetings, or text after the last KOTLIN-n block.
- Never wrap the output in markdown code fences or backticks.
- Never add blank lines anywhere: neither between blocks nor inside a block.
- Preserve the exact shape of every fragment. A block with N lines in the input MUST have exactly N lines in the output, in the same order: never merge two lines into one, never split one line into two, and never change the indentation.
- Emit only the fragment itself with the token conversions below applied. Never add an enclosing statement, braces, or any surrounding syntax that was not in the input.
- Convert Swift 'x.isEmpty' (Bool property, no parentheses) into the Kotlin function call 'x.isEmpty()'. The Swift '!c.countText.isEmpty' MUST become '!c.countText.isEmpty()' with parentheses, because Kotlin requires the call.
- Convert Swift string interpolation '\\(expr)' to Kotlin '${expr}'.
- Convert a Swift force unwrap 'x!' to the Kotlin non-null assertion 'x!!'. For example 'c.singleton!.countText' must become 'c.singleton!!.countText' — add the second '!'.
- Convert a Swift force cast 'x as! T' to Kotlin 'x as T'. For example 'RootVM.shared as! RootVM' must become 'RootVM.shared as RootVM' — remove the '!'.
- Convert Swift array literals '[a, b]' to Kotlin 'listOf(a, b)'.
- Convert Swift trailing closures '{ x in ... }' to Kotlin lambdas '{ x -> ... }'.
- Convert a Swift ternary 'a ? b : c' to Kotlin 'if (a) b else c'.
- Convert a Swift force cast 'x as! T' to Kotlin 'x as T'.

Study this example of a correct Swift-to-Kotlin transpilation and match its format exactly:

SWIFT INPUT
===
\(CONV_EXAMPLE_SWIFT_SRC)
KOTLIN OUTPUT
===
\(CONV_EXAMPLE_KOTLIN_DST)
Transpile the following Swift input:
"""
let CONV_PROMPT_SUFFIX = """

Kotlin output:
"""
