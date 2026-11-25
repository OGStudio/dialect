// C port of core/swift/DialectController.swift
// Define DIALECT_CONTROLLER_IMPLEMENTATION in one translation unit to emit definitions

#ifndef DIALECT_CONTROLLER_H
#define DIALECT_CONTROLLER_H

#include "DialectContext.h"

typedef DialectContext* (*DialectFunction)(DialectContext* ctx);

typedef struct {
    DialectFieldName fieldName;
    DialectCallback cb;
} DialectCallbackEntry;

typedef struct DialectController {
    bool isProcessingQueue;
    DialectContext* context;
    DialectCallbackEntry* callbacks;
    size_t callbacksCount;
    DialectFunction* functions;
    size_t functionsCount;
    DialectContext** queue;
    size_t queueCount;
    size_t queueCapacity;
} DialectController;

// DialectController API
DialectController* dialectControllerCreate(DialectContext* ctx);
void dialectControllerDestroy(DialectController* ctrl);
void dialectControllerRegisterCallback(
    DialectController* ctrl,
    DialectCallback cb
);
// Copies up to 15 bytes of fieldName and null-terminates it.
// NULL or an empty name registers a plain callback.
void dialectControllerRegisterFieldCallback(
    DialectController* ctrl,
    const DialectFieldName fieldName,
    DialectCallback cb
);
void dialectControllerRegisterFunction(
    DialectController* ctrl,
    DialectFunction f
);
void dialectControllerExecuteFunctions(DialectController* ctrl);
void dialectControllerProcessQueue(DialectController* ctrl);
void dialectControllerReportContext(DialectController* ctrl);
void dialectControllerSet(
    DialectController* ctrl,
    const DialectFieldName fieldName,
    DialectValue value
);

void growQueue(DialectController* ctrl);

#endif // DIALECT_CONTROLLER_H

#if defined(DIALECT_CONTROLLER_IMPLEMENTATION) && !defined(DIALECT_CONTROLLER_IMPLEMENTATION_ONCE)
#define DIALECT_CONTROLLER_IMPLEMENTATION_ONCE

#include "registerOneliners.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

DialectController* dialectControllerCreate(DialectContext* ctx) {
    DialectController* ctrl = (DialectController*)calloc(1, sizeof(DialectController));
    ctrl->context = ctx;
    return ctrl;
}

void dialectControllerDestroy(DialectController* ctrl) {
    if (ctrl == NULL) {
        return;
    }
    for (size_t i = 0; i < ctrl->queueCount; i++) {
        ctrl->queue[i]->dealloc(ctrl->queue[i]);
    }
    free(ctrl->queue);
    free(ctrl->functions);
    free(ctrl->callbacks);
    free(ctrl);
}

void dialectControllerExecuteFunctions(DialectController* ctrl) {
    // let c = queue.removeFirst()
    if (ctrl->queueCount == 0) {
        return;
    }
    DialectContext* c = ctrl->queue[0];
    for (size_t i = 1; i < ctrl->queueCount; i++) {
        ctrl->queue[i - 1] = ctrl->queue[i];
    }
    ctrl->queueCount--;

    // Keep SSOT: Only allow single field change per should-function
    DialectFieldName cRecentField;
    dialectFieldNameCopy(cRecentField, c->recentField(c));
    ctrl->context->setRecentField(ctrl->context, cRecentField);
    DialectValue cField = c->field(c, cRecentField);
    ctrl->context->setField(ctrl->context, cRecentField, cField);
    dialectValueFree(&cField);

    for (size_t i = 0; i < ctrl->functionsCount; i++) {
        // Mirror Swift value semantics: each should-function receives its own copy
        DialectContext* copy = ctrl->context->copy(ctrl->context);
        DialectContext* ctx = ctrl->functions[i](copy);
        if (strcmp(ctx->recentField(ctx), DIALECT_CONTEXT_RECENT_FIELD_NONE) != 0) {
            growQueue(ctrl);
            ctrl->queue[ctrl->queueCount] = ctx;
            ctrl->queueCount++;
        } else {
            ctx->dealloc(ctx);
        }
    }

    dialectControllerReportContext(ctrl);

    c->dealloc(c);
}

void dialectControllerProcessQueue(DialectController* ctrl) {
    // Prevent recursion.
    if (ctrl->isProcessingQueue) {
        return;
    }

    ctrl->isProcessingQueue = true;

    while (ctrl->queueCount > 0) {
        dialectControllerExecuteFunctions(ctrl);
    }

    ctrl->isProcessingQueue = false;
}

void dialectControllerRegisterCallback(
    DialectController* ctrl,
    DialectCallback cb
) {
    dialectControllerRegisterFieldCallback(ctrl, NULL, cb);
}

void dialectControllerRegisterFieldCallback(
    DialectController* ctrl,
    const DialectFieldName fieldName,
    DialectCallback cb
) {
    DialectOneliner item = {.cb = cb};
    dialectFieldNameCopy(item.field, fieldName);
    dialectRegisterOneliners(ctrl, &item, 1);
}

void dialectControllerRegisterFunction(
    DialectController* ctrl,
    DialectFunction f
) {
    if (ctrl->functionsCount == SIZE_MAX / sizeof(DialectFunction)) {
        return;
    }
    size_t count = ctrl->functionsCount + 1;
    DialectFunction* functions = malloc(count * sizeof(DialectFunction));
    if (functions == NULL) {
        return;
    }
    if (ctrl->functionsCount > 0) {
        memcpy(functions, ctrl->functions, ctrl->functionsCount * sizeof(DialectFunction));
    }
    functions[ctrl->functionsCount] = f;
    free(ctrl->functions);
    ctrl->functions = functions;
    ctrl->functionsCount = count;
}

void dialectControllerReportContext(DialectController* ctrl) {
    for (size_t i = 0; i < ctrl->callbacksCount; i++) {
        DialectCallbackEntry* entry = &ctrl->callbacks[i];
        if (entry->fieldName[0] == '\0' ||
            strcmp(ctrl->context->recentField(ctrl->context), entry->fieldName) == 0) {
            entry->cb(ctrl->context);
        }
    }
}

void dialectControllerSet(
    DialectController* ctrl,
    const DialectFieldName fieldName,
    DialectValue value
) {
    DialectFieldName name;
    dialectFieldNameCopy(name, fieldName);
    DialectContext* c = ctrl->context->copy(ctrl->context);
    c->setField(c, name, value);
    c->setRecentField(c, name);

    growQueue(ctrl);
    ctrl->queue[ctrl->queueCount] = c;
    ctrl->queueCount++;

    dialectControllerProcessQueue(ctrl);
}

void growQueue(DialectController* ctrl) {
    if (ctrl->queueCount < ctrl->queueCapacity) {
        return;
    }
    size_t newCapacity = ctrl->queueCapacity == 0 ? 4 : ctrl->queueCapacity * 2;
    DialectContext** newQueue =
        (DialectContext**)realloc(ctrl->queue, newCapacity * sizeof(DialectContext*));
    if (newQueue == NULL) {
        return;
    }
    ctrl->queue = newQueue;
    ctrl->queueCapacity = newCapacity;
}

#endif // DIALECT_CONTROLLER_IMPLEMENTATION
