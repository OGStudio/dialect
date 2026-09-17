import Foundation

/// Generate `struct F` holding one string constant per field name
func swiftFields(_ entityFields: [Int: [String]]) -> String {
    var names = Set<String>()

    // Collect field names
    for fields in entityFields.values {
        for field in fields {
            names.insert(field)
        }
    }

    // Construct the body of the struct
    var sitems = ""
    for name in names.sorted() {
        sitems += SWIFT_FIELD_T.replacingOccurrences(of: "%NAME%", with: name)
    }

    // Construct the whole struct
    return SWIFT_FIELDS_T.replacingOccurrences(of: "%ITEMS%", with: sitems)
}

/// Generate entities of type `struct`
func swiftStructs(
    _ entities: [String],
    _ entityFields: [Int: [String]],
    _ entityFieldTypes: [Int: [Int: String]]
) -> String {
    return "\n\n//TODO-swiftStructs\n\n"
}
