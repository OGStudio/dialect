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
