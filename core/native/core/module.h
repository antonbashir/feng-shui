#ifndef CORE_CORE_H
#define CORE_CORE_H

#include <context/context.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_SOURCE

#define module_id 0
#define module_name core
struct core_module_configuration
{
    bool silent;
    uint8_t print_level;
};
#define module_configuration struct core_module_configuration
struct core_module
{
    uint32_t id;
    const char* name;
    struct core_module_configuration* configuration;
};
#define module_structure struct core_module
#include <modules/module.h>

#if defined(__cplusplus)
}
#endif

#endif