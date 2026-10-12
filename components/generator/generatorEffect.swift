func generatorWriteFile(
    _ path: String,
    _ contents: String,
    _ keyDone: String
) {
    otherWriteFile(path, contents)
    generatorSet(keyDone, true)
}
