
enum CLIError: Error {
    case cannotDecode(String)
    case cannotRead(String, any Error)
    case invalidString(String)
}
