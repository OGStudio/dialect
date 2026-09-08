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

func ymlParseEntityTypes(_ lines: [String], _ entities: [String]) -> [Int: String] {
    var result = [Int: String]()
    var i = 0

    for entity in entities {
        var type = ""
        var inEntity = false

        for ln in lines {
            if ln == "\(entity):" {
                inEntity = true
                continue
            }
            if !inEntity {
                continue
            }
            if !(ln.hasPrefix(" ") || ln.hasPrefix("\t")) {
                break
            }

            if ln.hasPrefix(YML_PREFIX_TYPE) {
                type = String(ln.dropFirst(YML_PREFIX_TYPE.count))
                break
            }
        }

        result[i] = type
        i += 1
    }

    return result
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
