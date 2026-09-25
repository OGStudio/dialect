// C port of core/swift/DialectContext.swift
#include "dialect.h"

#include <stdlib.h>
#include <string.h>

// DialectValue helpers
DialectValue dialectValueNone(void) {
    DialectValue v;
    v.kind = D_VALUE_NONE;
    v.as.boolean = false;
    return v;
}

DialectValue dialectValueBool(bool b) {
    DialectValue v;
    v.kind = D_VALUE_BOOL;
    v.as.boolean = b;
    return v;
}

DialectValue dialectValueString(const char* s) {
    DialectValue v;
    v.kind = D_VALUE_STRING;
    v.as.str = s != NULL ? strdup(s) : NULL;
    return v;
}

void dialectValueFree(DialectValue* v) {
    if (v != NULL && v->kind == D_VALUE_STRING) {
        free(v->as.str);
        v->as.str = NULL;
    }
}

// Default implementation of `fieldAny`, mirroring the Swift extension:
// it just delegates to `field(name)`.
DialectValue dialectContextDefaultFieldAny(const DialectContext* ctx, const char* name) {
    return ctx->vtable->field(ctx, name);
}