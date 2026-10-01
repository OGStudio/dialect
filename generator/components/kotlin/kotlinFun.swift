import Foundation

/// Generate the context name for a component
func kotlinContextName(_ entity: String) -> String {
    return entity.replacingOccurrences(of: KOTLIN_SUFFIX_COMPONENT, with: KOTLIN_SUFFIX_CONTEXT)
}

/// Generate `object F` holding one string constant per field name
func kotlinFields(_ entityFields: [Int: [String]]) -> String {
    var names = Set<String>()

    // Collect field names
    for fields in entityFields.values {
        for field in fields {
            names.insert(field)
        }
    }

    // Construct the body of the object
    var sitems = ""
    for name in names.sorted() {
        sitems += KOTLIN_FIELD_T.replacingOccurrences(of: "%NAME%", with: name)
    }

    // Construct the whole object
    return KOTLIN_FIELDS_T.replacingOccurrences(of: "%ITEMS%", with: sitems)
}

/// Generate single component `Set` function
func kotlinSet(_ entity: String) -> String {
    let contextName = kotlinContextName(entity)
    let prefix = String(contextName.dropLast(KOTLIN_SUFFIX_CONTEXT.count)).lowercased()
    let funcName = prefix + KOTLIN_SET_SUFFIX

    return
        KOTLIN_SET_T
            .replacingOccurrences(of: "%FUNC%", with: funcName)
            .replacingOccurrences(of: "%COMPONENT%", with: entity)
}

/// Generate `Set` functions for all components
func kotlinSets(_ entities: [String]) -> String {
    var out = ""

    // Generate each component's `Set` function
    for entity in entities {
        if entity.hasSuffix(KOTLIN_SUFFIX_COMPONENT) {
            out += kotlinSet(entity)
        }
    }

    return out
}
