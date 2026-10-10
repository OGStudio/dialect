import Foundation

/// Generate single entity `context` declaration
func kotlinContext(
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
        let defaultValue = kotlinTypeDefaultValue(type)
        outFields +=
            KOTLIN_CONTEXT_FIELD_T
                .replacingOccurrences(of: "%NAME%", with: field)
                .replacingOccurrences(of: "%TYPE%", with: kotlinType(type))
                .replacingOccurrences(of: "%DEFAULT%", with: defaultValue)
        outGetters +=
            KOTLIN_CONTEXT_GETTER_T
                .replacingOccurrences(of: "%ELSE%", with: els)
                .replacingOccurrences(of: "%NAME%", with: field)
        outSetters +=
            KOTLIN_CONTEXT_SETTER_T
                .replacingOccurrences(of: "%ELSE%", with: els)
                .replacingOccurrences(of: "%NAME%", with: field)
                .replacingOccurrences(of: "%TYPE%", with: kotlinType(type))
        fieldId += 1
    }

    return
        KOTLIN_CONTEXT_T
            .replacingOccurrences(of: "%NAME%", with: name)
            .replacingOccurrences(of: "%FIELDS%", with: outFields)
            .replacingOccurrences(of: "%GETTERS%", with: outGetters)
            .replacingOccurrences(of: "%SETTERS%", with: outSetters)
}

/// Generate the context name for a component
func kotlinContextName(_ entity: String) -> String {
    return entity.replacingOccurrences(of: KOTLIN_SUFFIX_COMPONENT, with: KOTLIN_SUFFIX_CONTEXT)
}

/// Generate entities of `context` type
func kotlinContexts(
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
        if type == KOTLIN_TYPE_CONTEXT {
            contextIds.append(entityId)
        }
        entityId += 1
    }

    // Generate each context
    for id in contextIds {
        out +=
            kotlinContext(
                entities[id],
                entityFields[id]!,
                entityFieldTypes[id]!
            )
    }

    return out
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

/// Join code lines
func kotlinFormatCode(_ lines: [String]) -> String {
    return lines.joined(separator: "\n")
}

/// Generate single component `RegisterEffects` function
func kotlinRegisterEffect(
    _ contextName: String,
    _ oneliners: [Oneliner]
) -> String {
    let prefix = String(contextName.dropLast(KOTLIN_SUFFIX_CONTEXT.count)).lowercased()
    let funcName = prefix + KOTLIN_REGISTER_EFFECTS_SUFFIX

    var outItems = ""
    for oneliner in oneliners {
        outItems +=
            KOTLIN_REGISTER_EFFECT_ITEM_T
                .replacingOccurrences(of: "%FIELD%", with: oneliner.field)
                .replacingOccurrences(of: "%REACTION%", with: kotlinFormatCode([oneliner.reaction]))
    }

    return
        KOTLIN_REGISTER_EFFECTS_T
            .replacingOccurrences(of: "%FUNC%", with: funcName)
            .replacingOccurrences(of: "%ITEMS%", with: outItems)
}

/// Generate `RegisterEffects` functions for all components
func kotlinRegisterEffects(
    _ entities: [String],
    _ entityOneliners: [Int: [Oneliner]]
) -> String {
    var out = ""

    // Collect entity ids with oneliners
    var entityIds = [Int]()
    for entityId in entityOneliners.keys.sorted() {
        let oneliners = entityOneliners[entityId]!
        if !oneliners.isEmpty {
            entityIds.append(entityId)
        }
    }

    // Generate register-effects function for each component
    for entityId in entityIds {
        let contextName = kotlinContextName(entities[entityId])

        let oneliners = entityOneliners[entityId] ?? []
        if !oneliners.isEmpty {
            out += kotlinRegisterEffect(contextName, oneliners)
        }
    }

    return out
}

/// Generate single component `RegisterShoulds` function
func kotlinRegisterShould(
    _ contextName: String,
    _ shoulds: [String]
) -> String {
    let prefix = String(contextName.dropLast(KOTLIN_SUFFIX_CONTEXT.count)).lowercased()
    let funcName = prefix + KOTLIN_REGISTER_SHOULDS_SUFFIX

    var outItems = ""
    for should in shoulds {
        let shouldFuncName = prefix + KOTLIN_SHOULD_RESET + otherCapitalize(should)
        outItems +=
            KOTLIN_REGISTER_SHOULDS_ITEM_T
                .replacingOccurrences(of: "%SHOULD%", with: shouldFuncName)
    }

    return
        KOTLIN_REGISTER_SHOULDS_T
            .replacingOccurrences(of: "%FUNC%", with: funcName)
            .replacingOccurrences(of: "%CONTEXT%", with: contextName)
            .replacingOccurrences(of: "%ITEMS%", with: outItems)
}

/// Generate `RegisterShoulds` functions for all components
func kotlinRegisterShoulds(
    _ entities: [String],
    _ entityShoulds: [Int: [String]]
) -> String {
    var out = ""

    // Collect entity ids with shoulds
    var entityIds = [Int]()
    for entityId in entityShoulds.keys.sorted() {
        let shoulds = entityShoulds[entityId]!
        if !shoulds.isEmpty {
            entityIds.append(entityId)
        }
    }

    // Generate register-shoulds function for each component
    for entityId in entityIds {
        let contextName = kotlinContextName(entities[entityId])

        let shoulds = entityShoulds[entityId] ?? []
        if !shoulds.isEmpty {
            out += kotlinRegisterShould(contextName, shoulds)
        }
    }

    return out
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

/// Generate single component should-function
func kotlinShould(
    _ name: String,
    _ contextName: String,
    _ branches: [ShouldBranch]
) -> String {
    var outBranches = ""
    for branch in branches {
        outBranches +=
            KOTLIN_SHOULD_BRANCH_T
                .replacingOccurrences(of: "%ABOUT%", with: branch.about)
                .replacingOccurrences(of: "%FIELD%", with: name)
                .replacingOccurrences(of: "%CONDITION%", with: kotlinFormatCode(branch.condition))
                .replacingOccurrences(of: "%REACTION%", with: kotlinFormatCode(branch.reaction))
    }

    let prefix = String(contextName.dropLast(KOTLIN_SUFFIX_CONTEXT.count)).lowercased()
    let funcName = prefix + KOTLIN_SHOULD_RESET + otherCapitalize(name)

    return
        KOTLIN_SHOULD_T
            .replacingOccurrences(of: "%FUNC%", with: funcName)
            .replacingOccurrences(of: "%CONTEXT%", with: contextName)
            .replacingOccurrences(of: "%BRANCHES%", with: outBranches)
}

/// Generate should-functions for all components
func kotlinShoulds(
    _ entities: [String],
    _ entityShoulds: [Int: [String]],
    _ entityShouldBranches: [Int: [Int: [ShouldBranch]]]
) -> String {
    var out = ""

    // Collect entity ids with shoulds
    var entityIds = [Int]()
    for entityId in entityShoulds.keys.sorted() {
        let shoulds = entityShoulds[entityId]!
        if !shoulds.isEmpty {
            entityIds.append(entityId)
        }
    }

    // Generate should-functions for each component
    for entityId in entityIds {
        let contextName = kotlinContextName(entities[entityId])

        let shoulds = entityShoulds[entityId] ?? []
        var shouldId = 0
        for should in shoulds {
            let branches = entityShouldBranches[entityId]?[shouldId] ?? []
            if !branches.isEmpty {
                out += kotlinShould(should, contextName, branches)
            }
            shouldId += 1
        }
    }

    return out
}

/// Generate single entity `struct` declaration
func kotlinStruct(
    _ name: String,
    _ fields: [String],
    _ fieldTypes: [Int: String]
) -> String {
    var outFields = ""
    var fieldId = 0
    for field in fields {
        let type = fieldTypes[fieldId]!
        let defaultValue = kotlinTypeDefaultValue(type)
        outFields +=
            KOTLIN_STRUCT_FIELD_T
                .replacingOccurrences(of: "%NAME%", with: field)
                .replacingOccurrences(of: "%TYPE%", with: kotlinType(type))
                .replacingOccurrences(of: "%DEFAULT%", with: defaultValue)
        fieldId += 1
    }
    return
        KOTLIN_STRUCT_T
            .replacingOccurrences(of: "%NAME%", with: name)
            .replacingOccurrences(of: "%FIELDS%", with: outFields)
}

/// Generate entities of `struct` type
func kotlinStructs(
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
        if type == KOTLIN_TYPE_STRUCT {
            structIds.append(entityId)
        }
        entityId += 1
    }

    // Generate each struct
    for id in structIds {
        out +=
            kotlinStruct(
                entities[id],
                entityFields[id]!,
                entityFieldTypes[id]!
            )
    }

    return out
}

/// Generate the Kotlin type for a dialect type
func kotlinType(_ type: String) -> String {
    var isCollection = false
    var inner = type
    if inner.hasPrefix("[") && inner.hasSuffix("]") {
        isCollection = true
        inner = String(inner.dropFirst().dropLast())
    }

    // Map collections
    let parts = kotlinTypeParts(inner)
    if parts.count == 2 {
        return
            KOTLIN_MAP_T
                .replacingOccurrences(of: "%KEY%", with: kotlinType(parts[0]))
                .replacingOccurrences(of: "%VALUE%", with: kotlinType(parts[1]))
    }
    if isCollection {
        return
            KOTLIN_LIST_T
                .replacingOccurrences(of: "%TYPE%", with: kotlinType(parts[0]))
    }

    // Map primitives, the rest are already valid Kotlin types
    if inner == KOTLIN_TYPE_BOOL {
        return KOTLIN_MAPPED_BOOL
    }

    return inner
}

/// Generate the default value for a dialect type
func kotlinTypeDefaultValue(_ type: String) -> String {
    if type.hasPrefix("[") && type.hasSuffix("]") {
        if type.contains(":") {
            return KOTLIN_DEFAULT_MAP
        }
        return KOTLIN_DEFAULT_LIST
    }
    if type == KOTLIN_TYPE_BOOL {
        return KOTLIN_DEFAULT_BOOL
    }
    if type == KOTLIN_TYPE_INT {
        return KOTLIN_DEFAULT_INT
    }
    if type == KOTLIN_TYPE_STRING {
        return KOTLIN_DEFAULT_STRING
    }
    return
        KOTLIN_DEFAULT_NAMED_T
            .replacingOccurrences(of: "%TYPE%", with: type)
}

/// Split a dialect type into parts, ignoring colons inside brackets
func kotlinTypeParts(_ type: String) -> [String] {
    var parts = [String]()
    var current = ""
    var depth = 0
    for ch in type {
        if ch == "[" {
            depth += 1
        }
        if ch == "]" {
            depth -= 1
        }
        if ch == ":" && depth == 0 {
            parts.append(String(current.drop(while: { $0 == " " })))
            current = ""
        } else {
            current.append(ch)
        }
    }
    parts.append(String(current.drop(while: { $0 == " " })))
    return parts
}
