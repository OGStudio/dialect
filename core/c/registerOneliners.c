// C port of core/swift/registerOneliners.swift
#include "dialect.h"

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