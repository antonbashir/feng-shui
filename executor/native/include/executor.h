#ifndef EXECUTOR_H
#define EXECUTOR_H

#include <common/common.h>
#include <executor_configuration.h>
#include <executor_message.h>
#include <liburing.h>
#include "executor_constants.h"

struct io_uring;
typedef struct io_uring_cqe executor_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif
struct executor_dart
{
    int64_t callback;
    struct executor_background_scheduler* background_scheduler;
    struct io_uring* ring;
    executor_completion_event** completions;
    struct executor_configuration configuration;
    int32_t descriptor;
    uint32_t id;
    int8_t state;
};

int32_t executor_initialize(struct executor_dart* executor, struct executor_configuration* configuration, struct executor_background_scheduler* scheduler, uint32_t id);

int8_t executor_register_background(struct executor_dart* executor, int64_t callback);
int8_t executor_unregister_background(struct executor_dart* executor);

int32_t executor_peek(struct executor_dart* executor);
void executor_submit(struct executor_dart* executor);

int8_t executor_awake_begin(struct executor_dart* executor);
void executor_awake_complete(struct executor_dart* executor, uint32_t completions);

int8_t executor_call_native(struct executor_dart* executor, int32_t target_ring_fd, struct executor_message* message);
int8_t executor_callback_to_native(struct executor_dart* executor, struct executor_message* message);

extern FORCEINLINE int8_t executor_call_dart(struct io_uring* ring, int32_t source_ring_fd, int32_t target_ring_fd, struct executor_message* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    message->source = source_ring_fd;
    message->target = target_ring_fd;
    message->flags |= EXECUTOR_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, EXECUTOR_CALL, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

extern FORCEINLINE int8_t executor_callback_to_dart(struct io_uring* ring, int32_t source_ring_fd, struct executor_message* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    uint64_t target = message->source;
    message->source = source_ring_fd;
    message->target = target;
    message->flags |= EXECUTOR_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, EXECUTOR_CALLBACK, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

void executor_destroy(struct executor_dart* executor);

#if defined(__cplusplus)
}
#endif

#endif