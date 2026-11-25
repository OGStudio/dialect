// C port of core/swift/DialectContext.swift
// Define DIALECT_CONTEXT_IMPLEMENTATION in one translation unit to emit definitions

#ifndef DIALECT_CONTEXT_H
#define DIALECT_CONTEXT_H

#include <stdbool.h>
#include <stddef.h>

// Reusable "none" constant
#define DIALECT_CONTEXT_RECENT_FIELD_NONE "none"

// Includes the terminating null byte.
#define DIALECT_FIELD_NAME_CAPACITY 16
typedef char DialectFieldName[DIALECT_FIELD_NAME_CAPACITY];
// Array parameters decay to pointers in C. Copy incoming names into this type
// with dialectFieldNameAssign before storing them.

// A value of a context field (mirrors Swift `Any`)
typedef enum {
    D_VALUE_NONE = 0,
    D_VALUE_BOOL,
    D_VALUE_STRING,
    D_VALUE_OUTPUT_PATH,
    D_VALUE_SHOULD_BRANCH,
} DialectValueKind;

// OutputPath: path: String, type: String
typedef struct {
    char* path;
    char* type;
} OutputPath;

// A list of strings (for ShouldBranch's condition:[String]/reaction:[String])
typedef struct {
    char** items;
    size_t count;
} StringList;

// ShouldBranch: about: String, condition: [String], reaction: [String]
typedef struct {
    char* about;
    StringList condition;
    StringList reaction;
} ShouldBranch;

typedef struct {
    DialectValueKind kind;
    union {
        bool boolean;
        char* str; // owned copy when kind == D_VALUE_STRING
        OutputPath outputPath;
        ShouldBranch shouldBranch;
    } as;
} DialectValue;

typedef struct DialectContext DialectContext;

struct DialectContext {
    DialectContext* (*copy)(const DialectContext* ctx);
    void (*destroy)(DialectContext* ctx);
    DialectValue (*field)(
        const DialectContext* ctx,
        const DialectFieldName name
    );
    // Borrowed view of the concrete context's DialectFieldName storage.
    const char* (*recentField)(const DialectContext* ctx);
    void (*setField)(
        DialectContext* ctx,
        const DialectFieldName name,
        DialectValue value
    );
    void (*setRecentField)(
        DialectContext* ctx,
        const DialectFieldName name
    );
};

typedef void (*DialectCallback)(DialectContext* ctx);

// Copies a field name, truncating to capacity - 1 bytes and null-terminating it.
// NULL becomes an empty name. Source and destination may overlap.
void dialectFieldNameAssign(
    DialectFieldName destination,
    const char* source
);

// DialectValue helpers
DialectValue dialectValueBool(bool b);
void dialectValueFree(DialectValue* v);
DialectValue dialectValueNone(void);
DialectValue dialectValueString(const char* s);

#endif // DIALECT_CONTEXT_H

#if defined(DIALECT_CONTEXT_IMPLEMENTATION) && !defined(DIALECT_CONTEXT_IMPLEMENTATION_ONCE)
#define DIALECT_CONTEXT_IMPLEMENTATION_ONCE

#include <stdlib.h>
#include <string.h>

void dialectFieldNameAssign(
    DialectFieldName destination,
    const char* source
) {
    size_t length = source == NULL ? 0 : strnlen(source, DIALECT_FIELD_NAME_CAPACITY - 1);
    if (length > 0) {
        memmove(destination, source, length);
    }
    destination[length] = '\0';
}

DialectValue dialectValueBool(bool b) {
    DialectValue v;
    v.kind = D_VALUE_BOOL;
    v.as.boolean = b;
    return v;
}

void dialectValueFree(DialectValue* v) {
    if (v != NULL && v->kind == D_VALUE_STRING) {
        free(v->as.str);
        v->as.str = NULL;
    }
}

// DialectValue helpers
DialectValue dialectValueNone(void) {
    DialectValue v;
    v.kind = D_VALUE_NONE;
    v.as.boolean = false;
    return v;
}

DialectValue dialectValueString(const char* s) {
    DialectValue v;
    v.kind = D_VALUE_STRING;
    v.as.str = s != NULL ? strdup(s) : NULL;
    return v;
}

#endif // DIALECT_CONTEXT_IMPLEMENTATION
