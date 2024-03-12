#ifndef CORE_CONTEXT_H
#define CORE_CONTEXT_H

#include <common/common.h>
#include <common/constants.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct context
{
    DART_FIELD bool initialized;
    DART_FIELD size_t size;
    DART_FIELD void** modules;
};

extern struct context context_instance;

DART_INLINE_FUNCTION struct context* context_get()
{
    return &context_instance;
}

DART_FUNCTION void context_create();
DART_FUNCTION void* context_get_module(uint32_t id);
DART_FUNCTION void context_put_module(uint32_t id, void* module);

#if defined(__cplusplus)
}
#endif

#endif