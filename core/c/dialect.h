// C port of core/swift (v4 Dialect engine)
#ifndef DIALECT_H
#define DIALECT_H

#include <stdbool.h>
#include <stddef.h>

// Reusable "none" constant
#define DIALECT_CONTEXT_RECENT_FIELD_NONE "none"

// Includes the terminating null byte.
#define DIALECT_FIELD_NAME_CAPACITY 16
typedef char DialectFieldName[DIALECT_FIELD_NAME_CAPACITY];
// Array parameters decay to pointers in C. Copy incoming names into this type
// with dialectFieldNameCopy before storing them.

// A value of a context field (mirrors Swift `Any`)
typedef enum {
    D_VALUE_NONE = 0,
    D_VALUE_BOOL,
    D_VALUE_STRING,
    D_VALUE_OUTPUT_PATH,
    D_VALUE_SHOULD_BRANCH,
} DialectValueKind;

// OutputPath: path: String, type: String
typedef struct {
    char* path;
    char* type;
} OutputPath;

// A list of strings (for ShouldBranch's condition:[String]/reaction:[String])
typedef struct {
    char** items;
    size_t count;
} StringList;

// ShouldBranch: about: String, condition: [String], reaction: [String]
typedef struct {
    char* about;
    StringList condition;
    StringList reaction;
} ShouldBranch;

typedef struct {
    DialectValueKind kind;
    union {
        bool boolean;
        char* str; // owned copy when kind == D_VALUE_STRING
        OutputPath outputPath;
        ShouldBranch shouldBranch;
    } as;
} DialectValue;

typedef struct DialectContext DialectContext;

struct DialectContext {
    DialectValue (*field)(const DialectContext* ctx, const DialectFieldName name);
    DialectValue (*fieldAny)(const DialectContext* ctx, const DialectFieldName name);
    void (*setField)(DialectContext* ctx, const DialectFieldName name, DialectValue value);
    // Borrowed view of the concrete context's DialectFieldName storage.
    const char* (*recentField)(const DialectContext* ctx);
    void (*setRecentField)(DialectContext* ctx, const DialectFieldName name);
    DialectContext* (*copy)(const DialectContext* ctx);
    void (*dealloc)(DialectContext* ctx);
};

typedef void (*DialectCallback)(DialectContext* ctx);
typedef DialectContext* (*DialectFunction)(DialectContext* ctx);

typedef struct {
    DialectFieldName fieldName;
    DialectCallback cb;
} DialectCallbackEntry;

typedef struct {
    DialectFieldName field;
    DialectCallback cb;
} DialectOneliner;

typedef struct {
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

// Copies a field name, truncating to capacity - 1 bytes and null-terminating it.
// NULL becomes an empty name. Source and destination may overlap.
void dialectFieldNameCopy(DialectFieldName destination, const char* source);

// DialectValue helpers
DialectValue dialectValueNone(void);
DialectValue dialectValueBool(bool b);
DialectValue dialectValueString(const char* s);
void dialectValueFree(DialectValue* v);

// Default `fieldAny`, mirroring the Swift DialectContext extension
DialectValue dialectContextDefaultFieldAny(const DialectContext* ctx, const DialectFieldName name);

// DialectController API
DialectController* dialectControllerCreate(DialectContext* ctx);
void dialectControllerDestroy(DialectController* ctrl);
void dialectControllerRegisterCallback(DialectController* ctrl, DialectCallback cb);
// Copies up to 15 bytes of fieldName and null-terminates it.
// NULL or an empty name registers a plain callback.
void dialectControllerRegisterFieldCallback(DialectController* ctrl, const DialectFieldName fieldName, DialectCallback cb);
void dialectControllerRegisterFunction(DialectController* ctrl, DialectFunction f);
void dialectControllerExecuteFunctions(DialectController* ctrl);
void dialectControllerProcessQueue(DialectController* ctrl);
void dialectControllerReportContext(DialectController* ctrl);
void dialectControllerSet(DialectController* ctrl, const DialectFieldName fieldName, DialectValue value);

// registerOneliners (items = [field, cb, ...])
void dialectRegisterOneliners(DialectController* ctrl, const DialectOneliner* items, size_t count);

#endif // DIALECT_H
