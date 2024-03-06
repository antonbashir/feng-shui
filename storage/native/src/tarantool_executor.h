#ifndef TARANTOOL_EXECUTOR_H
#define TARANTOOL_EXECUTOR_H

#include <stdbool.h>
#include "tarantool.h"

#if defined(__cplusplus)
extern "C"
{
#endif
    struct tarantool_executor_configuration
    {
        size_t executor_ring_size;
        struct tarantool_configuration* configuration;
        uint32_t executor_id;
    };

    int32_t tarantool_executor_initialize(struct tarantool_executor_configuration* configuration);
    void tarantool_executor_start(struct tarantool_executor_configuration* configuration);
    void tarantool_executor_stop();
    void tarantool_executor_destroy();
    int32_t tarantool_executor_descriptor();
#if defined(__cplusplus)
}
#endif

#endif
