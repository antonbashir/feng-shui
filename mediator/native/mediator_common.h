#ifndef MEDIATOR_COMMON_H
#define MEDIATOR_COMMON_H

#if defined(__cplusplus)
extern "C"
{
#endif

#include <liburing.h>
#include <core_common.h>

  static inline struct io_uring_sqe *mediator_provide_sqe(struct io_uring *ring)
  {
    struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
    while (unlikely(sqe == NULL))
    {
      struct io_uring_cqe *unused;
      io_uring_wait_cqe_nr(ring, &unused, 1);
      sqe = io_uring_get_sqe(ring);
    }
    return sqe;
  };

#if defined(__cplusplus)
}
#endif

#endif