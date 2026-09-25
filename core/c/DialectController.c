// C port of core/swift/DialectController.swift
#include "dialect.h"

#include <stdlib.h>
#include <string.h>

static void growCallbacks(DialectController* ctrl) {
    if (ctrl->callbacksCount < ctrl->callbacksCapacity) {
        return;
    }
    size_t newCapacity = ctrl->callbacksCapacity == 0 ? 4 : ctrl->callbacksCapacity * 2;
    DialectCallbackEntry* newCallbacks =
        (DialectCallbackEntry*)realloc(ctrl->callbacks, newCapacity * sizeof(DialectCallbackEntry));
    if (newCallbacks == NULL) {
        return;
    }
    ctrl->callbacks = newCallbacks;
    ctrl->callbacksCapacity = newCapacity;
}

static void growFunctions(DialectController* ctrl) {
    if (ctrl->functionsCount < ctrl->functionsCapacity) {
        return;
    }
    size_t newCapacity = ctrl->functionsCapacity == 0 ? 4 : ctrl->functionsCapacity * 2;
    DialectFunction* newFunctions =
        (DialectFunction*)realloc(ctrl->functions, newCapacity * sizeof(DialectFunction));
    if (newFunctions == NULL) {
        return;
    }
    ctrl->functions = newFunctions;
    ctrl->functionsCapacity = newCapacity;
}

static void growQueue(DialectController* ctrl) {
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
        ctrl->queue[i]->vtable->dealloc(ctrl->queue[i]);
    }
    free(ctrl->queue);
    free(ctrl->functions);
    free(ctrl->callbacks);
    free(ctrl);
}

void dialectControllerRegisterCallback(DialectController* ctrl, DialectCallback cb) {
    growCallbacks(ctrl);
    ctrl->callbacks[ctrl->callbacksCount].fieldName = NULL;
    ctrl->callbacks[ctrl->callbacksCount].cb = cb;
    ctrl->callbacksCount++;
}

void dialectControllerRegisterFieldCallback(
    DialectController* ctrl,
    const char* fieldName,
    DialectCallback cb
) {
    growCallbacks(ctrl);
    ctrl->callbacks[ctrl->callbacksCount].fieldName = fieldName;
    ctrl->callbacks[ctrl->callbacksCount].cb = cb;
    ctrl->callbacksCount++;
}

void dialectControllerRegisterFunction(DialectController* ctrl, DialectFunction f) {
    growFunctions(ctrl);
    ctrl->functions[ctrl->functionsCount] = f;
    ctrl->functionsCount++;
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
    const char* cRecentField = c->vtable->recentField(c);
    ctrl->context->vtable->setRecentField(ctrl->context, cRecentField);
    DialectValue cField = c->vtable->fieldAny(c, cRecentField);
    ctrl->context->vtable->setField(ctrl->context, cRecentField, cField);
    dialectValueFree(&cField);

    for (size_t i = 0; i < ctrl->functionsCount; i++) {
        // Mirror Swift value semantics: each should-function receives its own copy
        DialectContext* copy = ctrl->context->vtable->copy(ctrl->context);
        DialectContext* ctx = ctrl->functions[i](copy);
        if (strcmp(ctx->vtable->recentField(ctx), DIALECT_CONTEXT_RECENT_FIELD_NONE) != 0) {
            growQueue(ctrl);
            ctrl->queue[ctrl->queueCount] = ctx;
            ctrl->queueCount++;
        } else {
            ctx->vtable->dealloc(ctx);
        }
    }

    dialectControllerReportContext(ctrl);

    c->vtable->dealloc(c);
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

void dialectControllerReportContext(DialectController* ctrl) {
    for (size_t i = 0; i < ctrl->callbacksCount; i++) {
        DialectCallbackEntry* entry = &ctrl->callbacks[i];
        if (entry->fieldName == NULL ||
            strcmp(ctrl->context->vtable->recentField(ctrl->context), entry->fieldName) == 0) {
            entry->cb(ctrl->context);
        }
    }
}

void dialectControllerSet(DialectController* ctrl, const char* fieldName, DialectValue value) {
    DialectContext* c = ctrl->context->vtable->copy(ctrl->context);
    c->vtable->setField(c, fieldName, value);
    c->vtable->setRecentField(c, fieldName);

    growQueue(ctrl);
    ctrl->queue[ctrl->queueCount] = c;
    ctrl->queueCount++;

    dialectControllerProcessQueue(ctrl);
}