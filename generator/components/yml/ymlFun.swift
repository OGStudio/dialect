func ymlParseEntities(_ lines: [String]) -> [String] {
    var entities = [String]()

    for ln in lines {
        if
            ln.hasPrefix(" ") || // Ignore non-top level keys
            ln.hasPrefix("\t") || // Ignore non-top level keys
            ln.isEmpty || // Ignore empty lines
            !ln.hasSuffix(":") // Ignore non-keys
        {
            continue
        }

        let key = String(ln.dropLast(1))
        entities.append(key)
    }

    return entities
}

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
