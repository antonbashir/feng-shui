#include "tarantool.h"
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <executor_native.h>
#include <lauxlib.h>
#include <lua.h>
#include <luajit.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include "box/box.h"
#include "cbus.h"
#include "lib/core/fiber.h"
#include "lua/init.h"
#include "on_shutdown.h"
#include "tarantool_box.h"
#include "tarantool_executor.h"
#include "tarantool_launcher.h"

#define TARANTOOL_EXECUTOR_FIBER "executor"

#define TARANTOOL_LUA_ERROR "Failed to execute initial Lua script"

static struct tarantool_executor_configuration executor;

static struct storage
{
    struct tarantool_configuration configuration;
    char* initialization_error;
    char* shutdown_error;
    struct tarantool_box* box;
    pthread_t main_thread_id;
    pthread_mutex_t initialization_mutex;
    pthread_cond_t initialization_condition;
    pthread_mutex_t shutdown_mutex;
    pthread_cond_t shutdown_condition;
    bool initialized;
} storage;

struct tarantool_initialization_args
{
    const char* binary_path;
    const char* script;
};

static int32_t tarantool_shutdown_trigger(void* ignore)
{
    (void)ignore;
    tarantool_executor_stop();
    ev_break(loop(), EVBREAK_ALL);
    return 0;
}

static int32_t tarantool_fiber(va_list args)
{
    (void)args;
    int32_t error;
    if (error = tarantool_executor_initialize(&executor))
    {
        tarantool_executor_destroy();
        storage.initialization_error = strerror(error);
        return 0;
    }
    if (error = pthread_mutex_lock(&storage.initialization_mutex))
    {
        tarantool_executor_destroy();
        storage.initialization_error = strerror(error);
        return 0;
    }
    storage.initialized = true;
    if (error = pthread_cond_broadcast(&storage.initialization_condition))
    {
        tarantool_executor_destroy();
        storage.initialized = false;
        storage.initialization_error = strerror(error);
        return 0;
    }
    if (error = pthread_mutex_unlock(&storage.initialization_mutex))
    {
        tarantool_executor_destroy();
        storage.initialized = false;
        storage.initialization_error = strerror(error);
        return 0;
    }
    tarantool_initialize_box(storage.box);
    tarantool_executor_start(&executor);
    tarantool_destroy_box(storage.box);
    tarantool_executor_destroy();
    ev_break(loop(), EVBREAK_ALL);
    return 0;
}

static void* tarantool_process_initialization(void* input)
{
    struct tarantool_initialization_args* args = (struct tarantool_initialization_args*)input;

    tarantool_launcher_launch((char*)args->binary_path);

    int32_t events = ev_activecnt(loop());

    if (tarantool_lua_run_string((char*)args->script) != 0)
    {
        diag_log();
        storage.initialization_error = TARANTOOL_LUA_ERROR;
        return NULL;
    }

    start_loop = start_loop && ev_activecnt(loop()) > events;

    region_free(&fiber()->gc);

    if (box_on_shutdown(NULL, tarantool_shutdown_trigger, NULL) != 0)
    {
        storage.initialization_error = strerror(errno);
        return NULL;
    }

    ev_now_update(loop());
    fiber_start(fiber_new(TARANTOOL_EXECUTOR_FIBER, tarantool_fiber));
    ev_run(loop(), 0);

    if (storage.initialized)
    {
        int32_t error;
        if (error = pthread_mutex_lock(&storage.shutdown_mutex))
        {
            storage.shutdown_error = strerror(error);
            return NULL;
        }
        tarantool_launcher_shutdown(0);
        storage.initialized = false;
        if (error = pthread_cond_broadcast(&storage.shutdown_condition))
        {
            storage.shutdown_error = strerror(error);
            return NULL;
        }
        if (error = pthread_mutex_unlock(&storage.shutdown_mutex))
        {
            storage.shutdown_error = strerror(error);
            return NULL;
        }
    }

    free(input);
    return NULL;
}

bool tarantool_initialize(struct tarantool_configuration* configuration, struct tarantool_box* box)
{
    if (storage.initialized)
    {
        return true;
    }

    storage.configuration = *configuration;
    storage.initialization_error = "";
    storage.box = box;
    
    executor.configuration = &storage.configuration;
    executor.executor_ring_size = configuration->executor_ring_size;
    executor.executor_id = 0;

    struct tarantool_initialization_args* args = calloc(1, sizeof(struct tarantool_initialization_args));
    if (args == NULL)
    {
        storage.initialization_error = strerror(ENOMEM);
        return false;
    }

    args->binary_path = configuration->binary_path;
    args->script = configuration->initial_script;

    struct timespec timeout;
    timespec_get(&timeout, TIME_UTC);
    timeout.tv_sec += configuration->initialization_timeout_seconds;
    int32_t error;
    if (error = pthread_create(&storage.main_thread_id, NULL, tarantool_process_initialization, args))
    {
        storage.initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_lock(&storage.initialization_mutex))
    {
        storage.initialization_error = strerror(error);
        return false;
    }
    while (!storage.initialized)
    {
        if (error = pthread_cond_timedwait(&storage.initialization_condition, &storage.initialization_mutex, &timeout))
        {
            storage.initialization_error = strerror(error);
            return false;
        }
    }
    if (error = pthread_mutex_unlock(&storage.initialization_mutex))
    {
        storage.initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&storage.initialization_condition))
    {
        storage.initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&storage.initialization_mutex))
    {
        storage.initialization_error = strerror(error);
        return false;
    }
    return strlen(storage.initialization_error) == 0;
}

bool tarantool_shutdown()
{
    if (!storage.initialized)
    {
        return true;
    }
    tarantool_executor_stop();
    int32_t error;
    if (error = pthread_mutex_lock(&storage.shutdown_mutex))
    {
        storage.shutdown_error = strerror(error);
        return false;
    }
    struct timespec timeout;
    timespec_get(&timeout, TIME_UTC);
    timeout.tv_sec += storage.configuration.shutdown_timeout_seconds;
    while (storage.initialized)
    {
        if (error = pthread_cond_timedwait(&storage.shutdown_condition, &storage.shutdown_mutex, &timeout))
        {
            storage.shutdown_error = strerror(error);
            return false;
        }
    }
    if (error = pthread_mutex_unlock(&storage.shutdown_mutex))
    {
        storage.shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&storage.shutdown_condition))
    {
        storage.shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&storage.shutdown_mutex))
    {
        storage.shutdown_error = strerror(error);
        return false;
    }
    return true;
}

bool tarantool_initialized()
{
    return storage.initialized;
}

const char* tarantool_status()
{
    return box_status();
}

int32_t tarantool_is_read_only()
{
    return box_is_ro() ? 1 : 0;
}

const char* tarantool_initialization_error()
{
    return storage.initialization_error;
}

const char* tarantool_shutdown_error()
{
    return storage.shutdown_error;
}