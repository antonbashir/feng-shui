#include "context.h"
#include <dart_api.h>
#include <panic/panic.h>
#include <printer/printer.h>
#include "dart/dart.h"

struct context_structure context_instance;

struct context_structure* context_get()
{
    return &context_instance;
}

void context_create()
{
    if (context_instance.initialized)
    {
        raise_panic(event_panic(event_field_message(PANIC_CONTEXT_CREATED)));
    }
    context_instance.modules = simple_map_modules_new();
    context_instance.containers = calloc(MODULES_MAXIMUM, sizeof(struct module_container));
    if (context_instance.modules == NULL || context_instance.containers == NULL)
    {
        raise_panic(event_system_panic(ENOMEM));
    }
    context_instance.initialized = true;
    context_instance.size = 0;
}

void* context_get_module(const char* name)
{
    simple_map_int_t slot = simple_map_modules_find(context_instance.modules, name, NULL);
    if (slot != simple_map_end(context_instance.modules))
    {
        return simple_map_modules_node(context_instance.modules, slot)->module;
    }
    return NULL;
}

void context_put_module(const char* name, void* module, const char* type)
{
    struct module_container container = {
        .id = context_instance.size,
        .name = strdup(name),
        .module = module,
        .type = type,
    };
    memcpy(&context_instance.containers[context_instance.size], &container, sizeof(struct module_container));
    simple_map_modules_put_copy(context_instance.modules, &container, NULL, NULL);
    context_instance.size++;
}

void context_remove_module(const char* name)
{
    simple_map_int_t slot = simple_map_modules_find(context_instance.modules, name, NULL);
    if (slot != simple_map_end(context_instance.modules))
    {
        struct module_container* container = simple_map_modules_node(context_instance.modules, slot);
        free((void*)container->name);
        memset(&context_instance.containers[container->id], 0, sizeof(struct module_container));
        simple_map_modules_del(context_instance.modules, slot, NULL);
    }
    context_instance.size--;
}

DART_LEAF_FUNCTION void context_load()
{
    Dart_EnterScope();
    for (int i = 0; i < context_instance.size; i++)
    {
        struct module_container container = context_instance.containers[i];
        Dart_Handle arguments[1] = {dart_from_unsigned((uintptr_t)container.module)};
        dart_call_constructor(dart_find_class(container.type), DART_MODULE_FACTORY, arguments, 1);
    }
    Dart_ExitScope();
}