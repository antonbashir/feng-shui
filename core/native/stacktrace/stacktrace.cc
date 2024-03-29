#include <common/common.h>
#include <cxxabi.h>
#include <libunwind.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>
#include <strings/format.h>

FORCE_ALIGN_ARG_POINTER NOINLINE void stacktrace_collect_current(struct stacktrace* trace, int skip)
{
    unw_accessors_t* accessors = unw_get_accessors(unw_local_addr_space);
    if (accessors->get_proc_name == NULL)
    {
        unw_context_t unw_ctx;
        int status = unw_getcontext(&unw_ctx);
        if (status != 0)
        {
            return;
        }
        unw_cursor_t unw_cur;
        status = unw_init_local(&unw_cur, &unw_ctx);
        if (status != 0)
        {
            return;
        }
    }
    trace->size = unw_backtrace((void**)trace->frames, STACKTRACE_FRAME_MAX);
    trace->size -= MIN(skip, trace->size);
    memmove(trace->frames, trace->frames + skip, sizeof(trace->frames[0]) * trace->size);
}

const char* stacktrace_frame_read(const struct stacktrace_frame* frame, uintptr_t* offset)
{
    int status;
    size_t size = 0;
    char name[STACKTRACE_PROCEDURE_SIZE];
    char* result = (char*)calloc(STACKTRACE_PROCEDURE_SIZE, sizeof(char));

    unw_accessors_t* accessors = unw_get_accessors(unw_local_addr_space);
    unw_word_t unw_offset;

    status = accessors->get_proc_name(unw_local_addr_space, (unw_word_t)frame->instruction, name, sizeof(name), &unw_offset, NULL);
    if (status != 0 && status != -UNW_ENOMEM)
    {
        return NULL;
    }
    *offset = (uintptr_t)unw_offset;

    char* demangled_procedure = abi::__cxa_demangle(name, result, &size, &status);
    if (status != 0 && status != -UNW_ENOMEM)
    {
        demangled_procedure = nullptr;
    }

    if (demangled_procedure != nullptr)
    {
        return demangled_procedure;
    }

    size_t new_size = strlen(name) + 1;
    result = size < new_size ? (char*)realloc(result, new_size) : result;
    size = size < new_size ? new_size : size;
    memcpy(result, name, size);
    return (const char*)result;
}

int stacktrace_format(struct stacktrace* trace, char* buffer, size_t buffer_size)
{
    int frame_number = 1;
    int total = 0;
    for (const struct stacktrace_frame* frame = trace->frames; frame != &trace->frames[trace->size]; ++frame, ++frame_number)
    {
        uintptr_t offset = 0;
        const char* procedure = stacktrace_frame_read(frame, &offset);
        bool free = procedure != NULL;
        procedure = procedure != NULL ? procedure : STACKTRACE_UNKNOWN;
        int written = snprintf(buffer + total, buffer_size - total, STACKTRACE_FRAME_FORMAT_LONG NEW_LINE, frame_number, frame->instruction, procedure, offset);
        if (written < 0)
        {
            if (free) delete procedure;
            return total;
        }
        total += written;
        if (free) delete procedure;
        if (total >= buffer_size)
        {
            return total;
        }
    }
    return total;
}

void stacktrace_print(int skip)
{
    char buffer[STACKTRACE_PRINT_BUFFER];
    struct stacktrace trace;
    stacktrace_collect_current(&trace, skip + 2);
    if (stacktrace_format(&trace, buffer, STACKTRACE_PRINT_BUFFER) > 0)
    {
        print_string(buffer);
    }
}

int stacktrace_format_at(int skip, int index, char* buffer, size_t size)
{
    struct stacktrace trace;
    stacktrace_collect_current(&trace, skip + 1);
    uintptr_t offset = 0;
    const struct stacktrace_frame* frame = &trace.frames[index];
    const char* procedure = stacktrace_frame_read(frame, &offset);
    bool free = procedure != NULL;
    procedure = procedure != NULL ? procedure : STACKTRACE_UNKNOWN;
    int written = snprintf(buffer, size, STACKTRACE_FRAME_FORMAT_SHORT, procedure, offset);
    if (written < 0)
    {
        if (free) delete procedure;
        return written;
    }
    if (free) delete procedure;
    return written;
}