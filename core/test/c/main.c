// C port of core/test/swift/main.swift
#define DIALECT_CONTEXT_IMPLEMENTATION
#define DIALECT_CONTROLLER_IMPLEMENTATION
#define REGISTER_ONELINERS_IMPLEMENTATION

#include "DialectContext.h"
#include "DialectController.h"
#include "registerOneliners.h"

#include <stdbool.h>
#include <stdio.h>

bool t01_ExampleContext_field(void);
bool t02_ExampleContext_field_optional(void);
bool t03_ExampleContext_setField(void);
bool t04_ExampleContext_setField_optional(void);
bool t05_DialectController_executeFunctions_set(void);
bool t06_DialectController_processQueue(void);
bool t07_DialectController_registerFieldCallback_match(void);
bool t08_DialectController_registerFieldCallback_mismatch(void);
bool t09_ExampleContext_registerOneliners(void);

int main(void) {
    printf("Testing... \n");

    bool (*tests[])(void) = {
        t01_ExampleContext_field,
        t02_ExampleContext_field_optional,
        t03_ExampleContext_setField,
        t04_ExampleContext_setField_optional,
        t05_DialectController_executeFunctions_set,
        t06_DialectController_processQueue,
        t07_DialectController_registerFieldCallback_match,
        t08_DialectController_registerFieldCallback_mismatch,
        t09_ExampleContext_registerOneliners,
    };
    int totalCount = (int)(sizeof(tests) / sizeof(tests[0]));

    int okCount = 0;
    for (int i = 0; i < totalCount; i++) {
        if (tests[i]()) {
            okCount += 1;
        }
    }

    printf("Done. OK/total: %d/%d\n", okCount, totalCount);
    return 0;
}
