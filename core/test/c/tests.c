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
int t01_ExampleContext_field(void) {
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
int t02_ExampleContext_field_optional(void) {
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
int t03_ExampleContext_setField(void) {
    var c = exampleContextCreate();
    c->didLaunch = true;
    var dc = (DialectContext *)c;
    dc->setField(dc, "didLaunch", dialectValueBool(false));
    bool ok = (c->didLaunch == false);
    exampleContextDestroy(c);
    return ok;
}

// Validate changing field optional value by name
int t04_ExampleContext_setField_optional(void) {
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
int t05_DialectController_executeFunctions_set(void) {
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
int t06_DialectController_processQueue(void) {
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

bool g_callbackDidLaunch = false;
void cbDidLaunch(DialectContext* ctx) {
    (void)ctx;
    g_callbackDidLaunch = true;
}

// Validate registerFieldCallback() if an expected field was changed
int t07_DialectController_registerFieldCallback_match(void) {
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
int t08_DialectController_registerFieldCallback_mismatch(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;
    dialectFieldNameAssign(c->recentField, "host");
    var ctrl = dialectControllerCreate(dc);

    g_callbackFlag = false;
    dialectControllerRegisterFieldCallback(ctrl, "didLaunch", &cbDidLaunch);

    dialectControllerReportContext(ctrl);

    bool ok = !g_callbackDidLaunch;
    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return ok;
}

// Field filters own their names and truncate to 15 bytes plus a terminator.
int t09_DialectController_fieldName_capacity(void) {
    var c = exampleContextCreate();
    dialectFieldNameAssign(c->recentField, "123456789012345");
    var ctrl = dialectControllerCreate((DialectContext *)c);

    DialectFieldName name;
    dialectFieldNameAssign(name, c->recentField);
    dialectControllerRegisterFieldCallback(ctrl, name, cbFlag);
    name[0] = 'x';

    g_callbackFlag = false;
    dialectControllerReportContext(ctrl);
    bool copied = g_callbackFlag &&
        strcmp(ctrl->callbacks[0].fieldName, c->recentField) == 0;

    dialectControllerRegisterFieldCallback(ctrl, "12345678901234567890", cbFlag);
    bool truncated = strcmp(ctrl->callbacks[1].fieldName, c->recentField) == 0;
    char unterminated[DIALECT_FIELD_NAME_CAPACITY];
    memset(unterminated, 'x', sizeof(unterminated));
    dialectControllerRegisterFieldCallback(ctrl, unterminated, cbFlag);
    bool bounded = strlen(ctrl->callbacks[2].fieldName) == DIALECT_FIELD_NAME_CAPACITY - 1;

    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return copied && truncated && bounded;
}

// Empty and NULL field names register plain callbacks; oneliners copy names.
int t10_DialectController_fieldName_registration(void) {
    var c = exampleContextCreate();
    dialectFieldNameAssign(c->recentField, "host");
    var ctrl = dialectControllerCreate((DialectContext *)c);

    dialectControllerRegisterFieldCallback(ctrl, "", cbFlag);
    g_callbackFlag = false;
    dialectControllerReportContext(ctrl);
    bool emptyUnconditional = g_callbackFlag;
    dialectFieldNameAssign(c->recentField, "");
    g_callbackFlag = false;
    dialectControllerReportContext(ctrl);
    bool emptyMatched = g_callbackFlag;

    dialectControllerDestroy(ctrl);
    ctrl = dialectControllerCreate((DialectContext *)c);
    dialectFieldNameAssign(c->recentField, "host");
    dialectControllerRegisterFieldCallback(ctrl, NULL, cbFlag);
    g_callbackFlag = false;
    dialectControllerReportContext(ctrl);
    bool plainMatched = g_callbackFlag;

    DialectOneliner items[] = {
        {"host", cbFlag},
        {"", cbFlag},
    };
    dialectFieldNameAssign(items[1].field, "1234567890123456");
    dialectRegisterOneliners(ctrl, items, 2);
    items[0].field[0] = 'x';
    bool copied = strcmp(ctrl->callbacks[1].fieldName, "host") == 0;
    bool truncated = strcmp(ctrl->callbacks[2].fieldName, "123456789012345") == 0;

    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return emptyUnconditional && emptyMatched && plainMatched && copied && truncated;
}

// Oneliner filters and queued recent fields use the same truncated name.
int t11_DialectController_fieldName_consistency(void) {
    var c = exampleContextCreate();
    var dc = (DialectContext *)c;
    var ctrl = dialectControllerCreate(dc);
    var item = (DialectOneliner){.cb = cbFlag};
    char name[] = "12345678901234567890";
    dialectFieldNameAssign(item.field, name);
    dialectRegisterOneliners(ctrl, &item, 1);

    g_callbackFlag = false;
    dialectControllerSet(ctrl, name, dialectValueBool(true));
    name[0] = 'x';
    bool matched = g_callbackFlag &&
        strcmp(c->recentField, item.field) == 0 &&
        strcmp(c->recentField, "123456789012345") == 0;
    bool sameCapacity = sizeof(c->recentField) == sizeof(item.field) &&
        sizeof(item.field) == sizeof(ctrl->callbacks[0].fieldName);

    var copy = dc->copy(dc);
    dialectFieldNameAssign(c->recentField, NULL);
    bool independent = c->recentField[0] == '\0' &&
        strcmp(copy->recentField(copy), item.field) == 0;
    dialectFieldNameAssign(item.field, item.field + 1);
    bool overlap = strcmp(item.field, "23456789012345") == 0;

    copy->destroy(copy);
    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return matched && sameCapacity && independent && overlap;
}

size_t g_callbackCount = 0;

void cbCount(DialectContext* ctx) {
    (void)ctx;
    g_callbackCount++;
}

// Separate registration batches preserve earlier callbacks and functions.
int t12_DialectController_registration_batches(void) {
    var c = exampleContextCreate();
    var ctrl = dialectControllerCreate((DialectContext *)c);
    DialectOneliner items[12] = {0};
    for (size_t i = 0; i < 12; i++) {
        items[i].cb = cbCount;
        dialectControllerRegisterFunction(ctrl, shouldChangeDidLaunch);
    }

    dialectRegisterOneliners(ctrl, items, 10);
    bool firstBatch = ctrl->callbacksCount == 10;
    dialectRegisterOneliners(ctrl, items + 10, 2);
    bool secondBatch = ctrl->callbacksCount == 12;
    var callbacks = ctrl->callbacks;
    dialectRegisterOneliners(ctrl, NULL, 0);
    bool emptyBatch = ctrl->callbacks == callbacks && ctrl->callbacksCount == 12;
    bool functions = ctrl->functionsCount == 12;
    for (size_t i = 0; i < ctrl->functionsCount; i++) {
        functions = functions && ctrl->functions[i] == shouldChangeDidLaunch;
    }

    memset(items, 0, sizeof(items));
    g_callbackCount = 0;
    dialectControllerSet(ctrl, "didLaunch", dialectValueBool(true));
    bool reported = c->didLaunch && g_callbackCount == 12;

    dialectControllerDestroy(ctrl);
    exampleContextDestroy(c);
    return firstBatch && secondBatch && emptyBatch && functions && reported;
}
