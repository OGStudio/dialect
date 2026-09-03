func ymlReadLines(_ input: String) {
    let lines = input.split(separator: "\n").map(String.init)
    ymlSet(F.inputLines, lines)
}
