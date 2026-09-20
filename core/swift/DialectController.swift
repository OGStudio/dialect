
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
