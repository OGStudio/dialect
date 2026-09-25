// C port of core/swift (v4 Dialect engine)
#ifndef DIALECT_H
#define DIALECT_H

#include <stdbool.h>
#include <stddef.h>

// Reusable "none" constant
#define DIALECT_CONTEXT_RECENT_FIELD_NONE "none"

// A value of a context field (mirrors Swift `Any`)
typedef enum {
    D_VALUE_NONE = 0,
    D_VALUE_BOOL,
    D_VALUE_STRING,
} DialectValueKind;

typedef struct DialectValue {
    DialectValueKind kind;
    union {
        bool boolean;
        char* str; // owned copy when kind == D_VALUE_STRING
    } as;
} DialectValue;

typedef struct DialectContext DialectContext;
typedef struct DialectContextVtable DialectContextVtable;

struct DialectContext {
    const DialectContextVtable* vtable;
};

struct DialectContextVtable {
    DialectValue (*field)(const DialectContext* ctx, const char* name);
    DialectValue (*fieldAny)(const DialectContext* ctx, const char* name);
    void (*setField)(DialectContext* ctx, const char* name, DialectValue value);
    const char* (*recentField)(const DialectContext* ctx);
    void (*setRecentField)(DialectContext* ctx, const char* name);
    DialectContext* (*copy)(const DialectContext* ctx);
    void (*dealloc)(DialectContext* ctx);
};

typedef void (*DialectCallback)(DialectContext* ctx);
typedef DialectContext* (*DialectFunction)(DialectContext* ctx);

typedef struct {
    const char* fieldName; // NULL => plain callback
    DialectCallback cb;
} DialectCallbackEntry;

typedef struct {
    const char* field;
    DialectCallback cb;
} DialectOneliner;

typedef struct DialectController {
    bool isProcessingQueue;
    DialectContext* context;
    DialectCallbackEntry* callbacks;
    size_t callbacksCount;
    size_t callbacksCapacity;
    DialectFunction* functions;
    size_t functionsCount;
    size_t functionsCapacity;
    DialectContext** queue;
    size_t queueCount;
    size_t queueCapacity;
} DialectController;

// DialectValue helpers
DialectValue dialectValueNone(void);
DialectValue dialectValueBool(bool b);
DialectValue dialectValueString(const char* s);
void dialectValueFree(DialectValue* v);

// Default `fieldAny`, mirroring the Swift DialectContext extension
DialectValue dialectContextDefaultFieldAny(const DialectContext* ctx, const char* name);

// DialectController API
DialectController* dialectControllerCreate(DialectContext* ctx);
void dialectControllerDestroy(DialectController* ctrl);
void dialectControllerRegisterCallback(DialectController* ctrl, DialectCallback cb);
void dialectControllerRegisterFieldCallback(DialectController* ctrl, const char* fieldName, DialectCallback cb);
void dialectControllerRegisterFunction(DialectController* ctrl, DialectFunction f);
void dialectControllerExecuteFunctions(DialectController* ctrl);
void dialectControllerProcessQueue(DialectController* ctrl);
void dialectControllerReportContext(DialectController* ctrl);
void dialectControllerSet(DialectController* ctrl, const char* fieldName, DialectValue value);

// registerOneliners (items = [field, cb, ...])
void dialectRegisterOneliners(DialectController* ctrl, const DialectOneliner* items, size_t count);

#endif // DIALECT_H