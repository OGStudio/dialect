
func ymlParseVersion(_ lines: [String]) -> Int {
    for ln in lines {
        if ln.hasPrefix(YML_PREFIX_VERSION) {
            let versionStr = ln.dropFirst(YML_PREFIX_VERSION.count)
            if let version = Int(versionStr) {
                return version
            }
        }
    }

    return -1
}
