func convQueuePrompt(
    _ queue: [String],
    _ id: Int
) -> String {
    let src = CONV_PREFIX_SWIFT + String(queue[id])
    return CONV_PROMPT_PREFIX + src + CONV_PROMPT_SUFFIX
}

func convSrcQueue(
    _ entityShouldBranches: [Int: [Int: [ShouldBranch]]]
) -> [String] {
    var items = [String]()
    for entityId in entityShouldBranches.keys.sorted() {
        let shoulds = entityShouldBranches[entityId] ?? [:]
        for shouldId in shoulds.keys.sorted() {
            let branches = shoulds[shouldId] ?? []
            for branch in branches {
                items.append(branch.condition.joined(separator: "\n"))
                items.append(branch.reaction.joined(separator: "\n"))
            }
        }
    }

    return items
}

// Construct single transpiled branch
func convTranspiledShouldBranch(
    _ orig: ShouldBranch,
    _ cond: String,
    _ reac: String
) -> ShouldBranch {
    var b = orig

    var linesCondition = cond.split(separator: "\n")
    if
        let first = linesCondition.first,
        first.hasPrefix(CONV_PREFIX_KOTLIN)
    {
        linesCondition = Array(linesCondition.dropFirst())
        b.condition = linesCondition.map(String.init)
    }

    var linesReaction = reac.split(separator: "\n")
    if
        let first = linesReaction.first,
        first.hasPrefix(CONV_PREFIX_KOTLIN)
    {
        linesReaction = Array(linesReaction.dropFirst())
        b.reaction = linesReaction.map(String.init)
    }

    return b
}

// Construct serveral transpiled branches
func convTranspiledShouldBranches(
    _ entityShouldBranches: [Int: [Int: [ShouldBranch]]],
    _ dstQueue: [String]
) -> [Int: [Int: [ShouldBranch]]] {
    var items = [Int: [Int: [ShouldBranch]]]()
    var id = 0
    for entityId in entityShouldBranches.keys.sorted() {
        let shoulds = entityShouldBranches[entityId] ?? [:]
        for shouldId in shoulds.keys.sorted() {
            let branches = shoulds[shouldId] ?? []
            for branch in branches {
                // Get transpiled snippets
                let condition = dstQueue[id]
                id += 1
                let reaction = dstQueue[id]
                id += 1
                // Format the snippets
                let item = convTranspiledShouldBranch(branch, condition, reaction)
                items[entityId, default: [:]][shouldId, default: []].append(item)
            }
        }
    }

    return items
}
