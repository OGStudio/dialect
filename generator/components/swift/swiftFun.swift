/// Generate a `struct F` block holding one string constant per field name
func swiftFields(_ entityFields: [Int: [String]]) -> String {
    var names = Set<String>()

    for fields in entityFields.values {
        for field in fields {
            names.insert(field)
        }
    }

    var out = "struct F {\n"
    for name in names.sorted() {
        out += "    static let \(name) = \"\(name)\"\n"
    }
    out += "}"

    return out
}