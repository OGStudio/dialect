/*
func ymlDedent(_ lines: [String]) -> String {
    if lines.isEmpty {
        return ""
    }

    let base = otherLineIndent(lines[0])
    let amount = base - 8
    var out = ""
    var isFirst = true
    for ln in lines {
        if !isFirst {
            out += "\n"
        }
        isFirst = false
        if amount > 0 && otherLineIndent(ln) >= amount {
            out += String(ln.dropFirst(amount))
        } else {
            out += ln
        }
    }
    return out
}
*/

func ymlIsLineChunkEnd(_ ln: String) -> Bool {
    return ln.isEmpty
}

func ymlIsLineChunkStart(_ ln: String) -> Bool {
    // A line is the start of a chunk if:
    // 1. it has no indentation
    // 2. it is not empty
    return !ln.hasPrefix(" ") && !ln.isEmpty
}

/*
func ymlParseBranches(_ lines: [String]) -> [ShouldBranch] {
    var branches = [ShouldBranch]()
    var current = [String]()

    for ln in lines {
        let trimmed = ln.trimmingCharacters(in: .whitespaces)
        if
            otherLineIndent(ln) == 12,
            let first = trimmed.first,
            first.isNumber
        {
            if !current.isEmpty {
                branches.append(ymlParseShouldBranch(current))
            }
            current = [ln]
        } else {
            current.append(ln)
        }
    }
    if !current.isEmpty {
        branches.append(ymlParseShouldBranch(current))
    }

    return branches
}
*/

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

    for entityId in entityIds {
        let entity = entities[entityId]
        guard let lines = chunks["\(entity):"] else { continue }

        var currentBranch = ShouldBranch()
        var isParsing = false
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

            // Detect should section
            if otherLineIndent(ln) == YML_INDENT_SHOULD {
                shouldId += 1
                shouldSections[shouldId] = []
                continue
            }

            // Detect branch description
            if otherLineIndent(ln) == YML_INDENT_SHOULD_BRANCH_DESC {
                currentBranch.desc = String(ln.dropFirst(YML_INDENT_SHOULD_BRANCH_DESC).dropLast())
                shouldSections[shouldId]?.append(currentBranch)
            }
        }

        print("ИГР ymlPESB shouldS entityId/value: '\(entityId)'/'\(shouldSections)'")
    }

    return result
}

/*
    for entity in entities {
        var all = [Int: [ShouldBranch]]()

        guard let lines = chunks["\(entity):"] else {
            entityId += 1
            continue
        }

        let names = entityShoulds[entityId] ?? []
        var currentIndex: Int? = nil
        var block = [String]()

        func flush() {
            if let index = currentIndex, !block.isEmpty {
                all[index] = ymlParseBranches(block)
                block = []
            }
        }

        var inShoulds = false

        for ln in lines {
            if ln.hasPrefix(YML_PREFIX_SHOULDS) {
                inShoulds = true
                continue
            }
            if !inShoulds {
                continue
            }

            if otherLineIndent(ln) == 8 {
                flush()
                let trimmed = ln.trimmingCharacters(in: .whitespaces)
                let fieldName = trimmed.hasSuffix(":") ? String(trimmed.dropLast(1)) : trimmed
                currentIndex = names.firstIndex(of: fieldName)
            } else if otherLineIndent(ln) > 8 {
                block.append(ln)
            }
        }
        flush()

        result[entityId] = all
        entityId += 1
    }
    */

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

/*
func ymlParseShouldBranch(_ lines: [String]) -> ShouldBranch {
    var branch = ShouldBranch()
    var ifLines = [String]()
    var thenLines = [String]()
    var section = "if"

    for (index, ln) in lines.enumerated() {
        let trimmed = ln.trimmingCharacters(in: .whitespaces)
        if index == 0 {
            var desc = trimmed
            if desc.hasSuffix(":") {
                desc = String(desc.dropLast(1))
            }
            branch.desc = desc
            continue
        }
        if trimmed == "if:" {
            section = "if"
        } else if trimmed == "then:" {
            section = "then"
        } else if !trimmed.isEmpty {
            if section == "if" {
                ifLines.append(ln)
            } else {
                thenLines.append(ln)
            }
        }
    }

    branch.`if` = ymlDedent(ifLines)
    branch.then = ymlDedent(thenLines)

    return branch
}
*/

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
