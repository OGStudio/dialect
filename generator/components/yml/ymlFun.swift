func ymlIsLineChunkEnd(_ ln: String) -> Bool {
    return ln.isEmpty
}

func ymlIsLineChunkStart(_ ln: String) -> Bool {
    // A line is the start of a chunk if:
    // 1. it has no indentation
    // 2. it is not empty
    return !ln.hasPrefix(" ") && !ln.isEmpty
}

func ymlParseChunks(_ lines: [String]) -> [String: [String]] {
    var chunks = [String: [String]]()
    var currentChunkLines = [String]()
    var isChunk = false

    for ln in lines {
        // Detect chunk start/end
        if ymlIsLineChunkEnd(ln) {
            isChunk = false
        }
        if ymlIsLineChunkStart(ln) {
            isChunk = true
        }

        // Collect chunk lines
        if isChunk {
            currentChunkLines.append(ln)
        }

        // Create chunk while parsing
        if
            !isChunk,
            let firstLine = currentChunkLines.first
        {
            chunks[firstLine] = currentChunkLines
        }

        // Flush collected chunk lines for the next chunk
        if !isChunk {
            currentChunkLines = []
        }
    }

    // Create chunk for the ending chunk
    if let firstLine = currentChunkLines.first {
        chunks[firstLine] = currentChunkLines
    }

    return chunks
}

func ymlParseEntities(_ lines: [String]) -> [String] {
    var entities = [String]()

    for ln in lines {
        if
            ln.hasPrefix(" ") || // Ignore non-top level keys
            ln.hasPrefix("\t") || // Ignore non-top level keys
            ln.isEmpty || // Ignore empty lines
            !ln.hasSuffix(":") // Ignore non-top level keys
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

func ymlParseVersion(_ chunks: [String: [String]]) -> Int {
    for key in chunks.keys {
        if key.hasPrefix(YML_PREFIX_VERSION) {
            let versionStr = key.dropFirst(YML_PREFIX_VERSION.count)
            if let version = Int(versionStr) {
                return version
            }
        }
    }

    return -1
}
