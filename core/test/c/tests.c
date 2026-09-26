// C port of core/test/swift/tests.swift
#include "dialect.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Sample Context used for testing
typedef struct {
    DialectContext base; // first member -> cast between DialectContext* and ExampleContext*
    bool didLaunch;
    char* host;
    char* sometimes; // NULL = .none
    const char* recentField;
} ExampleContext;

static DialectValue exField(const DialectContext* ctx, const char* name) {
    const ExampleContext* c = (const ExampleContext*)ctx;
    if (strcmp(name, "didLaunch") == 0) {
        return dialectValueBool(c->didLaunch);
    } else if (strcmp(name, "host") == 0) {
        return dialectValueString(c->host);
    } else if (strcmp(name, "sometimes") == 0) {
        return c->sometimes != NULL ? dialectValueString(c->sometimes) : dialectValueNone();
    }

    return dialectValueString("unknown-field-name");
}

static void exSetField(DialectContext* ctx, const char* name, DialectValue value) {
    ExampleContext* c = (ExampleContext*)ctx;
    if (strcmp(name, "didLaunch") == 0) {
        if (value.kind == D_VALUE_BOOL) {
            c->didLaunch = value.as.boolean;
        }
    } else if (strcmp(name, "host") == 0) {
        free(c->host);
        c->host = value.kind == D_VALUE_STRING ? strdup(value.as.str) : NULL;
    } else if (strcmp(name, "sometimes") == 0) {
        free(c->sometimes);
        c->sometimes = value.kind == D_VALUE_STRING ? strdup(value.as.str) : NULL;
    }
}

static const char* exRecentField(const DialectContext* ctx) {
    return ((const ExampleContext*)ctx)->recentField;
}

static void exSetRecentField(DialectContext* ctx, const char* name) {
    ((ExampleContext*)ctx)->recentField = name;
}

static DialectContext* exCopy(const DialectContext* ctx) {
    const ExampleContext* c = (const ExampleContext*)ctx;
    ExampleContext* n = (ExampleContext*)calloc(1, sizeof(ExampleContext));
    n->base.vtable = c->base.vtable;
    n->didLaunch = c->didLaunch;
    n->host = c->host != NULL ? strdup(c->host) : NULL;
    n->sometimes = c->sometimes != NULL ? strdup(c->sometimes) : NULL;
    n->recentField = c->recentField;
    return (DialectContext*)n;
}

static void exDealloc(DialectContext* ctx) {
    ExampleContext* c = (ExampleContext*)ctx;
    free(c->host);
    free(c->sometimes);
    free(c);
}

static const DialectContextVtable exVtable = {
    exField,
    dialectContextDefaultFieldAny,
    exSetField,
    exRecentField,
    exSetRecentField,
    exCopy,
    exDealloc,
};

// Sample function for processing context change
static DialectContext* hostToDidLaunch(DialectContext* ctx) {
    ExampleContext* c = (ExampleContext*)ctx;
    if (strcmp(c->recentField, "host") == 0) {
        c->didLaunch = true;
        c->recentField = "didLaunch";
        return ctx;
    }

    c->recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE;
    return ctx;
}

// Validate field access by name
int t01_ExampleContext_field(void) {
    ExampleContext c;
    memset(&c, 0, sizeof(c));
    c.base.vtable = &exVtable;
    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE;
    c.host = strdup("abc");
    DialectValue v = exField(&c.base, "host");
    bool ok = c.host != NULL && v.kind == D_VALUE_STRING && strcmp(c.host, v.as.str) == 0;
    dialectValueFree(&v);
    free(c.host);
    return ok;
}

// Validate field access by name for optional value
int t02_ExampleContext_field_optional(void) {
    ExampleContext c;
    memset(&c, 0, sizeof(c));
    c.base.vtable = &exVtable;
    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE;

    DialectValue v1 = exField(&c.base, "sometimes");
    bool ok1 = v1.kind == D_VALUE_NONE;
    dialectValueFree(&v1);

    c.sometimes = strdup("def");
    DialectValue v2 = exField(&c.base, "sometimes");
    bool ok2 = v2.kind == D_VALUE_STRING && c.sometimes != NULL && strcmp(c.sometimes, v2.as.str) == 0;
    dialectValueFree(&v2);

    free(c.sometimes);
    return ok1 && ok2;
}

// Validate changing field value by name
int t03_ExampleContext_setField(void) {
    ExampleContext c;
    memset(&c, 0, sizeof(c));
    c.base.vtable = &exVtable;
    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE;
    c.didLaunch = true;
    exSetField(&c.base, "didLaunch", dialectValueBool(false));
    return c.didLaunch == false;
}

// Validate changing field optional value by name
int t04_ExampleContext_setField_optional(void) {
    ExampleContext c;
    memset(&c, 0, sizeof(c));
    c.base.vtable = &exVtable;
    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE;
    c.sometimes = strdup("anything");
    exSetField(&c.base, "sometimes", dialectValueNone());
    DialectValue v1 = exField(&c.base, "sometimes");
    bool ok1 = v1.kind == D_VALUE_NONE;
    dialectValueFree(&v1);

    exSetField(&c.base, "sometimes", dialectValueString("make it quick"));
    DialectValue v2 = exField(&c.base, "sometimes");
    bool ok2 = v2.kind == D_VALUE_STRING && c.sometimes != NULL && strcmp(c.sometimes, v2.as.str) == 0;
    dialectValueFree(&v2);

    free(c.sometimes);
    return ok1 && ok2;
}

// Validate executeFunctions() and set()
int t05_DialectController_executeFunctions_set(void) {
    ExampleContext* initial = (ExampleContext*)calloc(1, sizeof(ExampleContext));
    initial->base.vtable = &exVtable;
    initial->recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE;
    DialectController* ctrl = dialectControllerCreate((DialectContext*)initial);

    // Disable the execution of executeFunctions() for testing purpose
    ctrl->isProcessingQueue = true;

    DialectValue hostValue = dialectValueString("123");
    dialectControllerSet(ctrl, "host", hostValue);
    dialectValueFree(&hostValue);

    dialectControllerRegisterFunction(ctrl, hostToDidLaunch);

    // Apply `host` value
    dialectControllerExecuteFunctions(ctrl);
    // Apply `didLaunch` value
    dialectControllerExecuteFunctions(ctrl);

    ExampleContext* c = (ExampleContext*)ctrl->context;
    bool ok = c->host != NULL && strcmp(c->host, "123") == 0 && c->didLaunch == true;

    dialectControllerDestroy(ctrl);
    return ok;
}

// Validate processQueue()
int t06_DialectController_processQueue(void) {
    ExampleContext* initial = (ExampleContext*)calloc(1, sizeof(ExampleContext));
    initial->base.vtable = &exVtable;
    initial->recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE;
    DialectController* ctrl = dialectControllerCreate((DialectContext*)initial);

    dialectControllerRegisterFunction(ctrl, hostToDidLaunch);
    DialectValue hostValue = dialectValueString("123");
    dialectControllerSet(ctrl, "host", hostValue);
    dialectValueFree(&hostValue);

    ExampleContext* c = (ExampleContext*)ctrl->context;
    bool ok = c->didLaunch == true;

    dialectControllerDestroy(ctrl);
    return ok;
}

static char* g_callbackHost = NULL;
static bool g_callbackFlag = false;

// Capture the host field from the current context
static void cbHostCapture(DialectContext* ctx) {
    const ExampleContext* c = (const ExampleContext*)ctx;
    if (g_callbackHost != NULL) {
        free(g_callbackHost);
    }
    g_callbackHost = c->host != NULL ? strdup(c->host) : NULL;
}

// Set a flag when the callback is invoked
static void cbFlag(DialectContext* ctx) {
    (void)ctx;
    g_callbackFlag = true;
}

// Validate registerFieldCallback() if an expected field was changed
int t07_DialectController_registerFieldCallback_match(void) {
    ExampleContext* initial = (ExampleContext*)calloc(1, sizeof(ExampleContext));
    initial->base.vtable = &exVtable;
    initial->host = strdup("123");
    initial->recentField = "host";
    DialectController* ctrl = dialectControllerCreate((DialectContext*)initial);

    g_callbackHost = NULL;
    dialectControllerRegisterFieldCallback(ctrl, "host", &cbHostCapture);

    dialectControllerReportContext(ctrl);

    bool ok = g_callbackHost != NULL && strcmp(((ExampleContext*)ctrl->context)->host, g_callbackHost) == 0;
    free(g_callbackHost);
    g_callbackHost = NULL;
    dialectControllerDestroy(ctrl);
    return ok;
}

// Validate registerFieldCallback() if an unexpected field was changed, i.e.,
// callback should not be called
int t08_DialectController_registerFieldCallback_mismatch(void) {
    ExampleContext* initial = (ExampleContext*)calloc(1, sizeof(ExampleContext));
    initial->base.vtable = &exVtable;
    initial->host = strdup("123");
    initial->recentField = "host";
    DialectController* ctrl = dialectControllerCreate((DialectContext*)initial);

    g_callbackFlag = false;
    dialectControllerRegisterFieldCallback(ctrl, "didLaunch", &cbFlag);

    dialectControllerReportContext(ctrl);

    bool ok = g_callbackFlag == false;
    dialectControllerDestroy(ctrl);
    return ok;
}