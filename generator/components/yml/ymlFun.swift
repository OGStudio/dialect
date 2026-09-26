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

func ymlParseEntities(_ chunks: [String: [String]]) -> [String] {
    var entities = [String]()

    for key in chunks.keys {
        // Ignore known non-entity chunks.
        if key == YML_PREFIX_OUTPUT {
            continue
        }
        if key.hasSuffix(":") {
            entities.append(String(key.dropLast(1)))
        }
    }

    return entities.sorted()
}

func ymlParseEntityFieldTypes(
    _ chunks: [String: [String]],
    _ entities: [String],
    _ entityFields: [Int: [String]]
) -> [Int: [Int: String]] {
    var result = [Int: [Int: String]]()
    var entityId = 0

    for entity in entities {
        guard let lines = chunks["\(entity):"] else {
            entityId += 1
            continue
        }

        var types = [Int: String]()
        var fieldId = 0
        var inFields = false

        for ln in lines {
            if ln.hasPrefix(YML_PREFIX_FIELDS) {
                inFields = true
                continue
            }
            if inFields && !ln.hasPrefix(YML_PREFIX_FIELD) {
                break
            }
            if inFields {
                let nameAndType = String(ln.dropFirst(YML_PREFIX_FIELD.count))
                let parts = nameAndType.split(
                    separator: YML_FIELD_DELIMITER,
                    maxSplits: 1,
                    omittingEmptySubsequences: false
                )
                if parts.count == 2 {
                    types[fieldId] = String(parts[1])
                    fieldId += 1
                }
            }
        }

        result[entityId] = types
        entityId += 1
    }

    return result
}

func ymlParseEntityFields(
    _ chunks: [String: [String]],
    _ entities: [String]
) -> [Int: [String]] {
    var result = [Int: [String]]()
    var i = 0

    for entity in entities {
        var fields = [String]()

        guard let lines = chunks["\(entity):"] else {
            i += 1
            continue
        }

        var inFields = false

        for ln in lines {
            if ln.hasPrefix(YML_PREFIX_FIELDS) {
                inFields = true
                continue
            }
            if inFields && !ln.hasPrefix(YML_PREFIX_FIELD) {
                break
            }
            if inFields {
                let name = String(ln.dropFirst(YML_PREFIX_FIELD.count).split(separator: ":")[0])
                fields.append(name)
            }
        }

        result[i] = fields
        i += 1
    }

    return result
}

func ymlParseEntityShouldBranches(
    _ chunks: [String: [String]],
    _ entities: [String],
    _ entityShoulds: [Int: [String]]
) -> [Int: [Int: [ShouldBranch]]] {
    var result = [Int: [Int: [ShouldBranch]]]()

    // Collect entity ids with shoulds
    var entityIds = [Int]()
    for id in entityShoulds.keys.sorted() {
        let shoulds = entityShoulds[id]!
        if !shoulds.isEmpty {
            entityIds.append(id)
        }
    }

    // Collect should branches
    for entityId in entityIds {
        let entity = entities[entityId]
        guard let lines = chunks["\(entity):"] else { continue }

        var isParsing = false
        var isParsingCondition = false
        var isParsingReaction = false
        var shouldId = -1
        var shouldSections = [Int: [ShouldBranch]]()

        for ln in lines {

            // Detect parsed region
            if ln.hasPrefix(YML_PREFIX_SHOULDS) {
                isParsing = true
                continue
            }
            if !isParsing {
                continue
            }

            // Detect parsing `condition`
            if ln.hasPrefix(YML_PREFIX_SHOULD_BRANCH_IF) {
                isParsingCondition = true
                continue
            }
            if ln.hasPrefix(YML_PREFIX_SHOULD_BRANCH_THEN) {
                isParsingCondition = false
            }

            // Detect parsing `reaction`
            if ln.hasPrefix(YML_PREFIX_SHOULD_BRANCH_THEN) {
                isParsingReaction = true
                continue
            }
            if otherLineIndent(ln) == YML_INDENT_SHOULD {
                isParsingReaction = false
            }

            // Detect should section
            if otherLineIndent(ln) == YML_INDENT_SHOULD {
                shouldId += 1
                shouldSections[shouldId] = []
                continue
            }

            // Parse branch description
            if otherLineIndent(ln) == YML_INDENT_SHOULD_BRANCH_DESC {
                isParsingCondition = false
                isParsingReaction = false
                shouldSections[shouldId]!.append(ShouldBranch())
                let lastId = shouldSections[shouldId]!.count - 1
                let about = String(ln.dropFirst(YML_INDENT_SHOULD_BRANCH_DESC).dropLast())
                shouldSections[shouldId]![lastId].about = about
            }

            // Parse branch condition
            if isParsingCondition {
                let lastId = shouldSections[shouldId]!.count - 1
                let condition = String(ln.dropFirst(YML_INDENT_SHOULD_BRANCH_IF))
                shouldSections[shouldId]![lastId].condition.append(condition)
            }

            // Parse branch reaction
            if isParsingReaction {
                let lastId = shouldSections[shouldId]!.count - 1
                let reaction = String(ln.dropFirst(YML_INDENT_SHOULD_BRANCH_THEN))
                shouldSections[shouldId]![lastId].reaction.append(reaction)
            }
        }

        result[entityId] = shouldSections
    }

    return result
}

func ymlParseEntityShoulds(
    _ chunks: [String: [String]],
    _ entities: [String]
) -> [Int: [String]] {
    var result = [Int: [String]]()
    var i = 0

    for entity in entities {
        var shoulds = [String]()

        guard let lines = chunks["\(entity):"] else {
            i += 1
            continue
        }

        var inShoulds = false

        for ln in lines {
            if ln.hasPrefix(YML_PREFIX_SHOULDS) {
                inShoulds = true
                continue
            }
            if 
                inShoulds &&
                otherLineIndent(ln) == YML_INDENT_SHOULD &&
                ln.hasSuffix(":")
            {
                let name = ln.dropFirst(YML_INDENT_SHOULD).dropLast()
                shoulds.append(String(name))
            }
        }

        result[i] = shoulds
        i += 1
    }

    return result
}

func ymlParseEntityTypes(
    _ chunks: [String: [String]],
    _ entities: [String]
) -> [Int: String] {
    var result = [Int: String]()
    var i = 0

    for entity in entities {
        var type = ""

        guard let lines = chunks["\(entity):"] else {
            i += 1
            continue
        }

        for ln in lines {
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

func ymlParseOutputPaths(_ chunks: [String: [String]]) -> [OutputPath] {
    var paths = [OutputPath]()

    guard let lines = chunks[YML_PREFIX_OUTPUT] else {
        return paths
    }

    var currentPath = ""

    for ln in lines {
        // Type
        if ln.hasPrefix(YML_PREFIX_OUTPUT_TYPE) {
            var p = OutputPath()
            p.path = currentPath
            p.type = String(ln.dropFirst(YML_PREFIX_OUTPUT_TYPE.count))
            paths.append(p)
        }
        // Path
        else if ln.hasPrefix(YML_PREFIX_OUTPUT_PATH) {
            currentPath = String(ln.dropFirst(YML_PREFIX_OUTPUT_PATH.count).dropLast(1))
        }
    }

    return paths
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
