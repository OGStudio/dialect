// C port of core/test/swift/tests.swift
#include "DialectController.h"
#include "registerOneliners.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define var __auto_type

// Sample Context used for testing
typedef struct {
    DialectContext base; // first member -> cast between DialectContext* and ExampleContext*
    bool didLaunch;
    char* host;
    char* sometimes; // NULL = .none
    DialectFieldName recentField;
} ExampleContext;

ExampleContext* exampleContextCreate(void);
void exampleContextDestroy(ExampleContext* c);
void exampleContextDestroyBase(DialectContext* ctx);
DialectValue exampleContextField(
    const DialectContext* ctx,
    const DialectFieldName name
);
const char* exampleContextRecentField(const DialectContext* ctx);
void exampleContextSetField(
    DialectContext* ctx,
    const DialectFieldName name,
    DialectValue value
);
void exampleContextSetRecentField(
    DialectContext* ctx,
    const DialectFieldName name
);

DialectContext* exampleContextCopy(const DialectContext* ctx) {
    var c = (const ExampleContext*)ctx;
    var inst = exampleContextCreate();
    var dc = (DialectContext *)inst;
    *dc = *ctx;
    inst->didLaunch = c->didLaunch;
    inst->host = c->host != NULL ? strdup(c->host) : NULL;
    inst->sometimes = c->sometimes != NULL ? strdup(c->sometimes) : NULL;
    dialectFieldNameAssign(inst->recentField, c->recentField);
    return dc;
}

ExampleContext* exampleContextCreate(void) {
    var inst = (ExampleContext*)malloc(sizeof(ExampleContext));
    if (inst == NULL) {
        abort();
    }
    *inst = (ExampleContext){
        .base = {
            .copy = exampleContextCopy,
            .destroy = exampleContextDestroyBase,
            .field = exampleContextField,
            .recentField = exampleContextRecentField,
            .setField = exampleContextSetField,
            .setRecentField = exampleContextSetRecentField,
        },
        .recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE,
    };
    return inst;
}

void exampleContextDestroy(ExampleContext* c) {
    free(c->host);
    free(c->sometimes);
    free(c);
}

void exampleContextDestroyBase(DialectContext* ctx) {
    exampleContextDestroy((ExampleContext*)ctx);
}

DialectValue exampleContextField(
    const DialectContext* ctx,
    const DialectFieldName name
) {
    var c = (const ExampleContext*)ctx;
    if (strcmp(name, "didLaunch") == 0) {
        return dialectValueBool(c->didLaunch);
    } else if (strcmp(name, "host") == 0) {
        return dialectValueString(c->host);
    } else if (strcmp(name, "sometimes") == 0) {
        return c->sometimes != NULL ? dialectValueString(c->sometimes) : dialectValueNone();
    }

    return dialectValueString("unknown-field-name");
}

const char* exampleContextRecentField(const DialectContext* ctx) {
    return ((const ExampleContext*)ctx)->recentField;
}

void exampleContextSetField(
    DialectContext* ctx,
    const DialectFieldName name,
    DialectValue value
) {
    var c = (ExampleContext*)ctx;
    if (strcmp(name, "didLaunch") == 0) {
        c->didLaunch = value.as.boolean;
    } else if (strcmp(name, "host") == 0) {
        free(c->host);
        c->host = strdup(value.as.str);
    } else if (strcmp(name, "sometimes") == 0) {
        free(c->sometimes);
        c->sometimes = value.kind == D_VALUE_NONE ? NULL : strdup(value.as.str);
    }
}

void exampleContextSetRecentField(
    DialectContext* ctx,
    const DialectFieldName name
) {
    dialectFieldNameAssign(((ExampleContext*)ctx)->recentField, name);
}

// Should function for altering context
DialectContext* shouldChangeDidLaunch(DialectContext* ctx) {
    var c = (ExampleContext*)ctx;
    if (strcmp(c->recentField, "host") == 0) {
        c->didLaunch = true;
        dialectFieldNameAssign(c->recentField, "didLaunch");
        return ctx;
    }

    dialectFieldNameAssign(c->recentField, DIALECT_CONTEXT_RECENT_FIELD_NONE);
    return ctx;
}

// Validate field access by name
bool t01_ExampleContext_field(void) {
    var c = exampleContextCreate();
    c->host = strdup("abc");
    var dc = (DialectContext *)c;
    var host = dc->field(dc, "host");
    bool ok = strcmp(c->host, host.as.str) == 0;
    dialectValueFree(&host);
    exampleContextDestroy(c);
    return ok;
}

// Validate field access by name for optional value
bool t02_ExampleContext_field_optional(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;

    var sometimes = dc->field(dc, "sometimes");
    bool wasEmpty = sometimes.kind == D_VALUE_NONE;
    dialectValueFree(&sometimes);

    c->sometimes = strdup("def");
    sometimes = dc->field(dc, "sometimes");
    bool matches = strcmp(c->sometimes, sometimes.as.str) == 0;
    dialectValueFree(&sometimes);

    exampleContextDestroy(c);
    return wasEmpty && matches;
}

// Validate changing field value by name
bool t03_ExampleContext_setField(void) {
    var c = exampleContextCreate();
    c->didLaunch = true;
    var dc = (DialectContext *)c;
    dc->setField(dc, "didLaunch", dialectValueBool(false));
    bool ok = (c->didLaunch == false);
    exampleContextDestroy(c);
    return ok;
}

// Validate changing field optional value by name
bool t04_ExampleContext_setField_optional(void) {
    var c = exampleContextCreate();
    c->sometimes = strdup("anything");
    var dc = (DialectContext *)c;
    dc->setField(dc, "sometimes", dialectValueNone());
    bool cleared = c->sometimes == NULL;

    var sometimes = dialectValueString("make it quick");
    dc->setField(dc, "sometimes", sometimes);
    dialectValueFree(&sometimes);
    bool matches = strcmp(c->sometimes, "make it quick") == 0;

    exampleContextDestroy(c);
    return cleared && matches;
}

// Validate executeFunctions() and set()
bool t05_DialectController_executeFunctions_set(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;
    var ctrl = dialectControllerCreate(dc);

    // Disable the execution of executeFunctions() for testing purpose
    ctrl->isProcessingQueue = true;

    var host = dialectValueString("123");
    dialectControllerSet(ctrl, "host", host);
    dialectValueFree(&host);

    dialectControllerRegisterFunction(ctrl, shouldChangeDidLaunch);

    // Apply `host` value
    dialectControllerExecuteFunctions(ctrl);
    // Apply `didLaunch` value
    dialectControllerExecuteFunctions(ctrl);

    bool ok = c->didLaunch && strcmp(c->host, "123") == 0;

    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return ok;
}

// Validate processQueue()
bool t06_DialectController_processQueue(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;
    var ctrl = dialectControllerCreate(dc);

    dialectControllerRegisterFunction(ctrl, shouldChangeDidLaunch);
    var host = dialectValueString("123");
    dialectControllerSet(ctrl, "host", host);
    dialectValueFree(&host);

    bool ok = c->didLaunch;

    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return ok;
}

const char* g_callbackHost;
void cbHost(DialectContext* ctx) {
    var c = (const ExampleContext*)ctx;
    g_callbackHost = c->host;
}

bool g_callbackDidLaunch;
void cbDidLaunch(DialectContext* ctx) {
    (void)ctx;
    g_callbackDidLaunch = true;
}

// Validate registerFieldCallback() if an expected field was changed
bool t07_DialectController_registerFieldCallback_match(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;
    g_callbackHost = NULL;
    c->host = strdup("123");
    dialectFieldNameAssign(c->recentField, "host");
    var ctrl = dialectControllerCreate(dc);

    dialectControllerRegisterFieldCallback(ctrl, "host", &cbHost);
    dialectControllerReportContext(ctrl);

    bool ok = g_callbackHost != NULL && strcmp(c->host, g_callbackHost) == 0;
    g_callbackHost = NULL;
    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return ok;
}

// Validate registerFieldCallback() if an unexpected field was changed, i.e.,
// callback should not be called
bool t08_DialectController_registerFieldCallback_mismatch(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;
    g_callbackDidLaunch = false;
    dialectFieldNameAssign(c->recentField, "host");
    var ctrl = dialectControllerCreate(dc);

    g_callbackDidLaunch = false;
    dialectControllerRegisterFieldCallback(ctrl, "didLaunch", &cbDidLaunch);

    dialectControllerReportContext(ctrl);

    bool ok = !g_callbackDidLaunch;
    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return ok;
}

size_t g_callbackCount;

void cbCount(DialectContext* ctx) {
    (void)ctx;
    g_callbackCount++;
}

// Validate that both oneliners run when their field changes.
bool t09_ExampleContext_registerOneliners(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;
    var ctrl = dialectControllerCreate(dc);
    const DialectOneliner items[] = {
        {"host", cbCount},
        {"host", cbCount},
    };
    dialectRegisterOneliners(ctrl, items, sizeof(items) / sizeof(items[0]));

    g_callbackCount = 0;
    var host = dialectValueString("abc");
    dialectControllerSet(ctrl, "host", host);
    dialectValueFree(&host);

    bool ok = g_callbackCount == 2;
    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return ok;
}
