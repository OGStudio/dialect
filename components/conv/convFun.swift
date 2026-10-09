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
func convTranspiledShouldBranche(
    _ orig: ShouldBranch,
    _ cond: String,
    _ reac: String
) -> ShouldBranch {
    var b = orig

    var linesCondition = condition.split("\n")
    if linesCondition[0].startsWith(CONV_PREFIX_KOTLIN) {
        linesCondition.dropFirst()
        b.condition = linesCondition
    }

    var linesReaction = condition.split("\n")
    if linesReaction[0].startsWith(CONV_PREFIX_KOTLIN) {
        linesReaction.dropFirst()
        b.reaction = linesReaction
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
                items.append(item)
            }
        }
    }

    return items
}
