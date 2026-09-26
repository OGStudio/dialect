
// Reusable "none" constant
public let DIALECT_CONTEXT_RECENT_FIELD_NONE = "none"

// Base protocol for each component's state
public protocol DialectContext {
    var recentField: String { get set }

    func field<T>(_ name: String) -> T
    func fieldAny(_ name: String) -> Any
    mutating func setField(_ name: String, _ value: Any)
}

// Default implementation of `fieldAny` method for the protocol
public extension DialectContext {
    /// Default implementation of `fieldAny()`
    func fieldAny(_ name: String) -> Any {
        return field(name)
    }
}

// The engine of the dialect components
public class DialectController {
    var callbacks = [(DialectContext) -> Void]()
    var context: DialectContext
    var functions = [(DialectContext) -> DialectContext]()
    var isProcessingQueue = false
    var queue = [DialectContext]()

    public init(_ context: DialectContext) {
        self.context = context
    }

    func executeFunctions() {
        let c = queue.removeFirst()
        // Keep SSOT: Only allow single field change per should-function
        context.recentField = c.recentField
        context.setField(c.recentField, c.fieldAny(c.recentField))
      
        for f in functions {
            let ctx = f(context)
            if ctx.recentField != DIALECT_CONTEXT_RECENT_FIELD_NONE {
                queue.append(ctx)
            }
        }
      
        reportContext()
    }

    func processQueue() {
        // Prevent recursion.
        if isProcessingQueue {
            return
        }
      
        isProcessingQueue = true
      
        while (queue.count > 0) {
            executeFunctions()
        }
      
        isProcessingQueue = false
    }

    public func registerCallback(_ cb: @escaping (DialectContext) -> Void) {
        callbacks.append(cb)
    }

    public func registerFieldCallback(
        _ fieldName: String,
        _ cb: @escaping (DialectContext) -> Void
    ) {
        callbacks.append({ c in
            if c.recentField == fieldName {
                cb(c)
            }
        })
    }

    public func registerFunction(_ f: @escaping (DialectContext) -> DialectContext) {
        functions.append(f)
    }

    func reportContext() {
        for cb in callbacks {
            cb(context)
        }
    }

    public func set(
        _ fieldName: String,
        _ value: Any
    ) {
        var c = context
        c.setField(fieldName, value)
        c.recentField = fieldName
        queue.append(c)
        processQueue()
    }
}

// Register several oneliner callbacks to a controller
func registerOneliners<T>(
    _ ctrl: DialectController,
    _ items: [Any]
) -> T? {
    let halfCount = items.count / 2
    for i in 0..<halfCount {
        let field = items[i * 2] as! String
        let callback = items[i * 2 + 1] as! (T) -> Void
        ctrl.registerFieldCallback(field) { cc in
            let c = cc as! T
            callback(c)
        }
    }

    // A hack for generics to operate
    return nil
}

// Context field names for static type check
struct F {
    static let count = "count"
    static let countText = "countText"
    static let didClickIncrement = "didClickIncrement"
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"

}
struct RootContext: DialectContext {
    var count = Int()
    var countText = String()
    var didClickIncrement = Bool()
    var didLaunch = Bool()
    var didSetup = Bool()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "count") {
            return count as! T
        }
        else if (name == "countText") {
            return countText as! T
        }
        else if (name == "didClickIncrement") {
            return didClickIncrement as! T
        }
        else if (name == "didLaunch") {
            return didLaunch as! T
        }
        else if (name == "didSetup") {
            return didSetup as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "count") {
            count = value as! Int
        }
        else if (name == "countText") {
            countText = value as! String
        }
        else if (name == "didClickIncrement") {
            didClickIncrement = value as! Bool
        }
        else if (name == "didLaunch") {
            didLaunch = value as! Bool
        }
        else if (name == "didSetup") {
            didSetup = value as! Bool
        }

    }
}

func rootSet(
    _ key: String,
    _ value: Any
) {
    RootComponent.singleton!.ctrl.set(key, value)
}

func rootShouldResetCount(_ c: RootContext) -> RootContext {
    var c = c

    /* 1. Upon hitting 10 the first time */
    if
        c.recentField == F.didClickIncrement &&
        c.count == 9
    {
        c.count += 10
        c.recentField = F.count
        return c
    }

    /* 2. Upon each button click */
    if
        c.recentField == F.didClickIncrement
    {
        c.count += 1
        c.recentField = F.count
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func rootShouldResetCountText(_ c: RootContext) -> RootContext {
    var c = c

    /* 1. Upon each count chang */
    if
        c.recentField == F.count
    {
        c.countText = "Count: '\(c.count)'"
        c.recentField = F.countText
        return c
    }

    /* 2. Upon launc */
    if
        c.recentField == F.didLaunch
    {
        c.countText = "Press the button to count"
        c.recentField = F.countText
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func rootShouldResetDidLaunch(_ c: RootContext) -> RootContext {
    var c = c

    /* 1. Only once during the first setup */
    if
        c.recentField == F.didSetup &&
        c.didLaunch == false
    {
        c.didLaunch = true
        c.recentField = F.didLaunch
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}
