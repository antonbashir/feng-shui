#ifndef CORE_PANIC_PANIC_H
#define CORE_PANIC_PANIC_H

#include <events/events.h>
#include <system/system.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define raise_panic(event) system_raise_event(event);

#if defined(__cplusplus)
}
#endif

#endif