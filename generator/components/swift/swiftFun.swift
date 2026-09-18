import Foundation

/// Generate single `context` entity
func swiftContext(
    _ name: String,
    _ fields: [String],
    _ fieldTypes: [Int: String]
) -> String {
    var outFields = ""
    var outGetters = ""
    var outSetters = ""
    var fieldId = 0
    for field in fields {
        let type = fieldTypes[fieldId]!
        let defaultValue = swiftTypeDefaultValue(type)
        outFields +=
            SWIFT_CONTEXT_FIELD_T
                .replacingOccurrences(of: "%NAME%", with: field)
                .replacingOccurrences(of: "%DEFAULT%", with: defaultValue)
        outGetters +=
            SWIFT_CONTEXT_GETTER_T
                .replacingOccurrences(of: "%NAME%", with: field)
        outSetters +=
            SWIFT_CONTEXT_SETTER_T
                .replacingOccurrences(of: "%NAME%", with: field)
                .replacingOccurrences(of: "%TYPE%", with: type)
        fieldId += 1
    }

    return
        SWIFT_CONTEXT_T
            .replacingOccurrences(of: "%NAME%", with: name)
            .replacingOccurrences(of: "%FIELDS%", with: outFields)
            .replacingOccurrences(of: "%GETTERS%", with: outGetters)
            .replacingOccurrences(of: "%SETTERS%", with: outSetters)
}

/// Generate entities of `context` type
func swiftContexts(
    _ entities: [String],
    _ entityTypes: [Int: String],
    _ entityFields: [Int: [String]],
    _ entityFieldTypes: [Int: [Int: String]]
) -> String {
    var out = ""

    // Locate contexts
    var entityId = 0
    var contextIds = [Int]()
    for _ in entities {
        let type = entityTypes[entityId]
        if type == SWIFT_TYPE_CONTEXT {
            contextIds.append(entityId)
        }
        entityId += 1
    }

    // Generate each context
    for id in contextIds {
        out +=
            swiftContext(
                entities[id],
                entityFields[id]!,
                entityFieldTypes[id]!
            )
    }

    return out
}

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
    var outFields = ""
    var fieldId = 0
    for field in fields {
        let type = fieldTypes[fieldId]!
        let defaultValue = swiftTypeDefaultValue(type)
        outFields +=
            SWIFT_STRUCT_FIELD_T
                .replacingOccurrences(of: "%NAME%", with: field)
                .replacingOccurrences(of: "%DEFAULT%", with: defaultValue)
        fieldId += 1
    }
    return
        SWIFT_STRUCT_T
            .replacingOccurrences(of: "%NAME%", with: name)
            .replacingOccurrences(of: "%FIELDS%", with: outFields)
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
    for _ in entities {
        let type = entityTypes[entityId]
        if type == SWIFT_TYPE_STRUCT {
            structIds.append(entityId)
        }
        entityId += 1
    }

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

/// Generate default value for a type
func swiftTypeDefaultValue(_ type: String) -> String {
    return "\(type)()"
}
