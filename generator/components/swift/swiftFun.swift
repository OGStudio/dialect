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

/// Generate single `struct` entity
func swiftStruct(
    _ name: String,
    _ fields: [String],
    _ fieldTypes: [Int: String]
) -> String {
    return SWIFT_STRUCT_T.replacingOccurrences(of: "%NAME%", with: name)
}

/// Generate entities of `struct` type
func swiftStructs(
    _ entities: [String],
    _ entityTypes: [Int: String],
    _ entityFields: [Int: [String]],
    _ entityFieldTypes: [Int: [Int: String]]
) -> String {
    var out = ""

    // Locate structs
    var entityId = 0
    var structIds = [Int]()
    for entity in entities {
        let type = entityTypes[entityId]
        if type == SWIFT_TYPE_STRUCT {
            structIds.append(entityId)
        }
        entityId += 1
    }

    print("ИГР swiftS structI: '\(structIds)'")

    // Generate each struct
    for id in structIds {
        out +=
            swiftStruct(
                entities[id],
                entityFields[id]!,
                entityFieldTypes[id]!
            )
    }

    return out
}

/*
/// Map a field's SSOT type to a Swift default literal (mirrors the hand-written structs)
func swiftDefaultLiteral(for types: [Int: [Int: String]]?, field: String) -> String {
    guard let types = types else { return "\"\"" }
    for entry in types.values {
        for (_, type) in entry {
            switch type {
            case "Bool": return "false"
            case "OutputPath": return "OutputPath()"
            case "[OutputPath]": return "[OutputPath]()"
            case "[String]": return "[String]()"
            case "[Int: [String]]": return "[Int: [String]]()"
            case "[Int: [Int: String]]": return "[Int: [Int: String]]()"
            case "Int": return "0"
            default: return "\"\""
            }
        }
    }
    return "\"\""
}
*/
