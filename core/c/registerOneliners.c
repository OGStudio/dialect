// C port of core/swift/registerOneliners.swift
#include "dialect.h"

// Register several oneliner callbacks to a controller.
// items is an array of { field, cb } pairs mirroring the Swift
// alternating [field, callback, ...] payload.
void dialectRegisterOneliners(DialectController* ctrl, const DialectOneliner* items, size_t count) {
    for (size_t i = 0; i < count; i++) {
        dialectControllerRegisterFieldCallback(ctrl, items[i].field, items[i].cb);
    }
}