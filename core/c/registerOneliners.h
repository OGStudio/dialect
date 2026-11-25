// C port of core/swift/registerOneliners.swift
// Define REGISTER_ONELINERS_IMPLEMENTATION in one translation unit to emit definitions

#ifndef REGISTER_ONELINERS_H
#define REGISTER_ONELINERS_H

#include "DialectContext.h"

struct DialectController;

typedef struct {
    DialectFieldName field;
    DialectCallback cb;
} DialectOneliner;

// Append a batch of copied field/callback pairs
void dialectRegisterOneliners(struct DialectController* ctrl, const DialectOneliner* items, size_t count);

#endif // REGISTER_ONELINERS_H

#if defined(REGISTER_ONELINERS_IMPLEMENTATION) && !defined(REGISTER_ONELINERS_IMPLEMENTATION_ONCE)
#define REGISTER_ONELINERS_IMPLEMENTATION_ONCE

#include "DialectController.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// Register several oneliner callbacks to a controller.
// items is an array of { field, cb } pairs mirroring the Swift
// alternating [field, callback, ...] payload.
void dialectRegisterOneliners(DialectController* ctrl, const DialectOneliner* items, size_t count) {
    if (count == 0 || count > SIZE_MAX / sizeof(DialectCallbackEntry) - ctrl->callbacksCount) {
        return;
    }
    size_t totalCount = ctrl->callbacksCount + count;
    DialectCallbackEntry* callbacks = malloc(totalCount * sizeof(DialectCallbackEntry));
    if (callbacks == NULL) {
        return;
    }
    if (ctrl->callbacksCount > 0) {
        memcpy(callbacks, ctrl->callbacks, ctrl->callbacksCount * sizeof(DialectCallbackEntry));
    }
    for (size_t i = 0; i < count; i++) {
        DialectCallbackEntry* entry = &callbacks[ctrl->callbacksCount + i];
        dialectFieldNameCopy(entry->fieldName, items[i].field);
        entry->cb = items[i].cb;
    }
    free(ctrl->callbacks);
    ctrl->callbacks = callbacks;
    ctrl->callbacksCount = totalCount;
}

#endif // REGISTER_ONELINERS_IMPLEMENTATION
