
func cliArgumentValue(
    _ args: [String],
    _ argument: String
) -> String {
    for item in args {
        if item.hasPrefix(argument) {
            let prefix = argument + "="
            return String(item.dropFirst(prefix.count))
        }
    }
    return ""
}
