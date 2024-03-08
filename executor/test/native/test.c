

#include "test.h"
#include <bits/pthreadtypes.h>
#include <stdlib.h>
#include "executor_task.h"
#include "executor_native.h"
#include "memory_module.h"
#include "memory_small_data.h"

static pthread_mutex_t mutex;
struct memory memory_module;
struct memory_pool pool;
struct memory_small_data small_data;

test_executor_native* test_executor_initialize(bool initialize_memory)
{
    struct executor_native* test_executor = malloc(sizeof(struct executor_native));
    if (!test_executor)
    {
        return NULL;
    }
    int32_t result = executor_native_initialize_default(test_executor, 0);
    if (result < 0)
    {
        return NULL;
    }
    if (initialize_memory)
    {
        memory_create(&memory_module, 1 * 1024 * 1024, 64 * 1024, 64 * 1024);
        memory_pool_create(&pool, &memory_module, sizeof(struct executor_task));
        memory_small_data_create(&small_data, &memory_module);
    }
    return test_executor;
}

int32_t test_executor_descriptor(test_executor_native* executor)
{
    return ((struct executor_native*)executor)->descriptor;
}

void test_executor_destroy(test_executor_native* executor, bool initialize_memory)
{
    if (initialize_memory)
    {
        memory_small_data_destroy(&small_data);
        memory_pool_destroy(&pool);
        memory_destroy(&memory_module);
    }
    executor_native_destroy(executor);
    free(executor);
}

struct executor_task* test_allocate_message()
{
    return memory_pool_allocate(&pool);
}

double* test_allocate_double()
{
    return memory_small_data_allocate(&small_data, sizeof(double));
}