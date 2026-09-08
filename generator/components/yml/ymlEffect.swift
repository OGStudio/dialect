func ymlReadLines(_ input: String) {
    let lines = input.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    ymlSet(F.inputLines, lines)
}
