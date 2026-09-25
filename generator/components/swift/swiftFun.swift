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
        let els = (fieldId == 0) ? "" : "else "
        let type = fieldTypes[fieldId]!
        let defaultValue = swiftTypeDefaultValue(type)
        outFields +=
            SWIFT_CONTEXT_FIELD_T
                .replacingOccurrences(of: "%DEFAULT%", with: defaultValue)
                .replacingOccurrences(of: "%NAME%", with: field)
        outGetters +=
            SWIFT_CONTEXT_GETTER_T
                .replacingOccurrences(of: "%ELSE%", with: els)
                .replacingOccurrences(of: "%NAME%", with: field)
        outSetters +=
            SWIFT_CONTEXT_SETTER_T
                .replacingOccurrences(of: "%ELSE%", with: els)
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

/// Generate the context name for a component
func swiftContextName(_ entity: String) -> String {
    if entity.hasSuffix(SWIFT_SUFFIX_COMPONENT) {
        return String(entity.dropLast(SWIFT_SUFFIX_COMPONENT.count)) + SWIFT_SUFFIX_CONTEXT
    }
    return entity
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
        sitems +=
            SWIFT_FIELD_T
                .replacingOccurrences(of: "%NAME%", with: name)
    }

    // Construct the whole struct
    return SWIFT_FIELDS_T.replacingOccurrences(of: "%ITEMS%", with: sitems)
}

/// Join branch lines, indenting each by 8 spaces while keeping relative indent
func swiftShouldLines(_ lines: [String]) -> String {
    return lines.map { "        " + $0 }.joined(separator: "\n")
}

/// Generate should-functions for a single component entity
func swiftShould(
    _ name: String,
    _ contextName: String,
    _ branches: [ShouldBranch]
) -> String {
    var outBranches = ""
    for branch in branches {
        outBranches +=
            SWIFT_SHOULD_BRANCH_T
                .replacingOccurrences(of: "%ABOUT%", with: branch.about)
                .replacingOccurrences(of: "%FIELD%", with: name)
                .replacingOccurrences(of: "%CONDITION%", with: swiftShouldLines(branch.condition))
                .replacingOccurrences(of: "%REACTION%", with: swiftShouldLines(branch.reaction))
    }

    let prefix = String(contextName.dropLast(SWIFT_SUFFIX_CONTEXT.count)).lowercased()
    let funcName = prefix + "ShouldReset" + otherCapitalize(name)

    return
        SWIFT_SHOULD_T
            .replacingOccurrences(of: "%FUNC%", with: funcName)
            .replacingOccurrences(of: "%CONTEXT%", with: contextName)
            .replacingOccurrences(of: "%BOTH%", with: outBranches)
}

/// Generate should-functions for all components
func swiftShoulds(
    _ entities: [String],
    _ entityTypes: [Int: String],
    _ entityShoulds: [Int: [String]],
    _ entityShouldBranches: [Int: [Int: [ShouldBranch]]]
) -> String {
    var out = ""
    var entityId = 0

    for entity in entities {
        if entityTypes[entityId] == SWIFT_TYPE_COMPONENT {
            let contextName = swiftContextName(entity)

            let fields = entityShoulds[entityId] ?? []
            var fieldId = 0
            for field in fields {
                let branches = entityShouldBranches[entityId]?[fieldId] ?? []
                out += swiftShould(field, contextName, branches)
                fieldId += 1
            }
        }
        entityId += 1
    }

    return out
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
