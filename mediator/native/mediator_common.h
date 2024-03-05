#ifndef MEDIATOR_COMMON_H
#define MEDIATOR_COMMON_H

#include <liburing.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define MEDIATOR_CQE_FORMAT_BUFFER 1024

    static inline char* mediator_cqe_to_string(struct io_uring_cqe* cqe)
    {
        char* buffer = malloc(MEDIATOR_CQE_FORMAT_BUFFER);
        snprintf(buffer, MEDIATOR_CQE_FORMAT_BUFFER, "cqe.res = [%d], cqe.user_data = [%lld], cqe.flags = [%d]", cqe->res, cqe->user_data, cqe->flags);
        return buffer;
    };

#if defined(__cplusplus)
}
#endif

#endif
