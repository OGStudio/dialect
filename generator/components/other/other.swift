
/// Print each key/value processed by a controller into console
func otherSetupDebugging(
    ctrl: DialectController,
    prefix: String
) {
    ctrl.registerCallback { c -> Void in
        let value: String = c.field(c.recentField)
        let line = "ИГР \(prefix) k/v: '\(c.recentField)'/'\(value)'"
        print(line)
    }
}
