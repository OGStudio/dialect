// C port of core/test/swift/main.swift
#include <stdio.h>

int t01_ExampleContext_field(void);
int t02_ExampleContext_field_optional(void);
int t03_ExampleContext_setField(void);
int t04_ExampleContext_setField_optional(void);
int t05_DialectController_executeFunctions_set(void);
int t06_DialectController_processQueue(void);
int t07_DialectController_registerFieldCallback_match(void);
int t08_DialectController_registerFieldCallback_mismatch(void);

int main(void) {
    printf("Testing... \n");

    int (*tests[])(void) = {
        t01_ExampleContext_field,
        t02_ExampleContext_field_optional,
        t03_ExampleContext_setField,
        t04_ExampleContext_setField_optional,
        t05_DialectController_executeFunctions_set,
        t06_DialectController_processQueue,
        t07_DialectController_registerFieldCallback_match,
        t08_DialectController_registerFieldCallback_mismatch,
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