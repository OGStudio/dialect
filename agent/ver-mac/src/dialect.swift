
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
    static let arguments = "arguments"
    static let body = "body"
    static let consoleOutput = "consoleOutput"
    static let contents = "contents"
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"
    static let headers = "headers"
    static let inputPrompt = "inputPrompt"
    static let method = "method"
    static let prompt = "prompt"
    static let reply = "reply"
    static let req = "req"
    static let request = "request"
    static let response = "response"
    static let responseError = "responseError"
    static let system = "system"
    static let url = "url"
    static let willShutdown = "willShutdown"

}
struct NetRequest {
    var body = String()
    var headers = [String: String]()
    var method = String()
    var url = String()

}


struct NetResponse {
    var contents = String()
    var req = NetRequest()

}


struct AgentContext: DialectContext {
    var consoleOutput = String()
    var reply = String()
    var willShutdown = Bool()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "consoleOutput") {
            return consoleOutput as! T
        }
        else if (name == "reply") {
            return reply as! T
        }
        else if (name == "willShutdown") {
            return willShutdown as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "consoleOutput") {
            consoleOutput = value as! String
        }
        else if (name == "reply") {
            reply = value as! String
        }
        else if (name == "willShutdown") {
            willShutdown = value as! Bool
        }

    }
}

struct CLIContext: DialectContext {
    var arguments = [String]()
    var consoleOutput = String()
    var didLaunch = Bool()
    var didSetup = Bool()
    var inputPrompt = String()
    var prompt = String()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "arguments") {
            return arguments as! T
        }
        else if (name == "consoleOutput") {
            return consoleOutput as! T
        }
        else if (name == "didLaunch") {
            return didLaunch as! T
        }
        else if (name == "didSetup") {
            return didSetup as! T
        }
        else if (name == "inputPrompt") {
            return inputPrompt as! T
        }
        else if (name == "prompt") {
            return prompt as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "arguments") {
            arguments = value as! [String]
        }
        else if (name == "consoleOutput") {
            consoleOutput = value as! String
        }
        else if (name == "didLaunch") {
            didLaunch = value as! Bool
        }
        else if (name == "didSetup") {
            didSetup = value as! Bool
        }
        else if (name == "inputPrompt") {
            inputPrompt = value as! String
        }
        else if (name == "prompt") {
            prompt = value as! String
        }

    }
}

struct LLMContext: DialectContext {
    var didLaunch = Bool()
    var didSetup = Bool()
    var prompt = String()
    var reply = String()
    var request = NetRequest()
    var response = NetResponse()
    var responseError = NetResponse()
    var system = String()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "didLaunch") {
            return didLaunch as! T
        }
        else if (name == "didSetup") {
            return didSetup as! T
        }
        else if (name == "prompt") {
            return prompt as! T
        }
        else if (name == "reply") {
            return reply as! T
        }
        else if (name == "request") {
            return request as! T
        }
        else if (name == "response") {
            return response as! T
        }
        else if (name == "responseError") {
            return responseError as! T
        }
        else if (name == "system") {
            return system as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "didLaunch") {
            didLaunch = value as! Bool
        }
        else if (name == "didSetup") {
            didSetup = value as! Bool
        }
        else if (name == "prompt") {
            prompt = value as! String
        }
        else if (name == "reply") {
            reply = value as! String
        }
        else if (name == "request") {
            request = value as! NetRequest
        }
        else if (name == "response") {
            response = value as! NetResponse
        }
        else if (name == "responseError") {
            responseError = value as! NetResponse
        }
        else if (name == "system") {
            system = value as! String
        }

    }
}

func agentSet(
    _ key: String,
    _ value: Any
) {
    AgentComponent.singleton!.ctrl.set(key, value)
}

func cliSet(
    _ key: String,
    _ value: Any
) {
    CLIComponent.singleton!.ctrl.set(key, value)
}

func llmSet(
    _ key: String,
    _ value: Any
) {
    LLMComponent.singleton!.ctrl.set(key, value)
}

func agentShouldResetConsoleOutput(_ c: AgentContext) -> AgentContext {
    var c = c

    /* 1. Upon reply */
    if
        c.recentField == F.reply
    {
        c.consoleOutput = c.reply
        c.recentField = F.consoleOutput
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func agentShouldResetWillShutdown(_ c: AgentContext) -> AgentContext {
    var c = c

    /* 1. Upon reply */
    if
        c.recentField == F.reply
    {
        c.willShutdown = true
        c.recentField = F.willShutdown
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func cliShouldResetConsoleOutput(_ c: CLIContext) -> CLIContext {
    var c = c

    /* 1. File argument was not found */
    if
        c.recentField == F.didLaunch &&
        cliArgumentValue(c.arguments, CLI_ARG_PROMPT).isEmpty
    {
        c.consoleOutput = CLI_CONSOLE_USAGE_AGENT
        c.recentField = F.consoleOutput
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func cliShouldResetDidLaunch(_ c: CLIContext) -> CLIContext {
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

func cliShouldResetInputPrompt(_ c: CLIContext) -> CLIContext {
    var c = c

    /* 1. Parse prompt at launc */
    if
        c.recentField == F.didLaunch
    {
        c.inputPrompt = cliArgumentValue(c.arguments, CLI_ARG_PROMPT)
        c.recentField = F.inputPrompt
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func cliShouldResetPrompt(_ c: CLIContext) -> CLIContext {
    var c = c

    /* 1. Report prompt if vali */
    if
        c.recentField == F.inputPrompt &&
        !c.inputPrompt.isEmpty
    {
        c.prompt = c.inputPrompt
        c.recentField = F.prompt
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func llmShouldResetDidLaunch(_ c: LLMContext) -> LLMContext {
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

func llmShouldResetReply(_ c: LLMContext) -> LLMContext {
    var c = c

    /* 1. Upon successful response */
    if
        c.recentField == F.response
    {
        c.reply = llmFormatResponse(c.response.contents)
        c.recentField = F.reply
        return c
    }

    /* 2. Upon error response */
    if
        c.recentField == F.responseError
    {
        c.reply = c.responseError.contents
        c.recentField = F.reply
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func llmShouldResetRequest(_ c: LLMContext) -> LLMContext {
    var c = c

    /* 1. See if server is available upon receiving promp */
    if
        c.recentField == F.prompt
    {
        c.request = llmReqPrompt(LLM_DEFAULT_HOST, LLM_DEFAULT_PORT, c.prompt)
        c.recentField = F.request
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func agentRegisterShoulds(_ ctrl: DialectController) {
    [
        agentShouldResetConsoleOutput,
        agentShouldResetWillShutdown,

    ].forEach { f in
        ctrl.registerFunction { c in f(c as! AgentContext) }
    }
}

func cliRegisterShoulds(_ ctrl: DialectController) {
    [
        cliShouldResetConsoleOutput,
        cliShouldResetDidLaunch,
        cliShouldResetInputPrompt,
        cliShouldResetPrompt,

    ].forEach { f in
        ctrl.registerFunction { c in f(c as! CLIContext) }
    }
}

func llmRegisterShoulds(_ ctrl: DialectController) {
    [
        llmShouldResetDidLaunch,
        llmShouldResetReply,
        llmShouldResetRequest,

    ].forEach { f in
        ctrl.registerFunction { c in f(c as! LLMContext) }
    }
}

func agentRegisterEffects(_ ctrl: DialectController) {
    let _: AgentContext? = registerOneliners(ctrl, [
        F.consoleOutput, { (c: AgentContext) in print(c.consoleOutput) },
        F.willShutdown, { (c: AgentContext) in agentShutdown() },

    ])
}

func cliRegisterEffects(_ ctrl: DialectController) {
    let _: CLIContext? = registerOneliners(ctrl, [
        F.consoleOutput, { (c: CLIContext) in print(c.consoleOutput) },
        F.prompt, { (c: CLIContext) in llmSet(F.prompt, c.prompt) },

    ])
}

func llmRegisterEffects(_ ctrl: DialectController) {
    let _: LLMContext? = registerOneliners(ctrl, [
        F.reply, { (c: LLMContext) in agentSet(F.reply, c.reply) },
        F.request, { (c: LLMContext) in llmLoad(c.request, F.response, F.responseError) },

    ])
}
