#ifndef CORE_PRINTER_PRINTER_H
#define CORE_PRINTER_PRINTER_H

#include <system/system.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define print_message(format, ...) system_print(format NEW_LINE NEW_LINE, __VA_ARGS__)
#define print_error(format, ...) system_print_error(format NEW_LINE NEW_LINE, __VA_ARGS__)
#define print_string(string) print_message(STRING_FORMAT NEW_LINE, string)
#define print_error_string(string) print_error(STRING_FORMAT NEW_LINE, string)
#define print_event(event) system_print_event(event)

#ifdef TRACE
#define trace_event(event) print_event(event)
#define trace_message(format, ...) print_message(format, __VA_ARGS__)
#else
#define trace_event(event) \
    do                     \
    {                      \
    }                      \
    while (0)
#define trace_system(format, ...) \
    do                            \
    {                             \
    }                             \
    while (0)
#endif

#if defined(__cplusplus)
}
#endif

#endif