#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <executor/configuration.h>
#include <stdbool.h>
#include <stdint.h>
#include "memory/configuration.h"
#include "transport_client.h"
#include "transport_server.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_TYPE struct simple_map_events_t;
DART_TYPE struct ip_mreqn;
DART_TYPE struct sockaddr;
DART_TYPE struct sockaddr_in;
DART_TYPE struct sockaddr_un;
DART_TYPE struct msghdr;

DART_STRUCTURE struct transport_configuration
{
    DART_FIELD struct memory_configuration* memory_instance_configuration;
    DART_FIELD struct executor_configuration* executor_instance_configuration;
    DART_FIELD uint64_t timeout_checker_period_milliseconds;
    DART_FIELD bool trace;
};

DART_STRUCTURE struct transport
{
    DART_FIELD uint8_t id;
    DART_FIELD struct iovec* buffers;
    DART_FIELD struct executor_instance* transport_executor;
    DART_FIELD struct transport_configuration configuration;
    DART_FIELD struct msghdr* inet_used_messages;
    DART_FIELD struct msghdr* unix_used_messages;
    DART_FIELD struct simple_map_events_t* events;
};

DART_LEAF_FUNCTION int32_t transport_initialize(struct transport* transport,
                                                struct transport_configuration* configuration,
                                                uint8_t id);

DART_LEAF_FUNCTION int32_t transport_setup(struct transport* transport, struct executor_instance* executor);

DART_LEAF_FUNCTION void transport_write(struct transport* transport,
                                        uint32_t fd,
                                        uint16_t buffer_id,
                                        uint32_t offset,
                                        int64_t timeout,
                                        uint16_t event,
                                        uint8_t sqe_flags);
DART_LEAF_FUNCTION void transport_read(struct transport* transport,
                                       uint32_t fd,
                                       uint16_t buffer_id,
                                       uint32_t offset,
                                       int64_t timeout,
                                       uint16_t event,
                                       uint8_t sqe_flags);
DART_LEAF_FUNCTION void transport_send_message(struct transport* transport,
                                               uint32_t fd,
                                               uint16_t buffer_id,
                                               struct sockaddr* address,
                                               DART_SUBSTITUTE(uint8_t) transport_socket_family_t socket_family,
                                               int32_t message_flags,
                                               int64_t timeout,
                                               uint16_t event,
                                               uint8_t sqe_flags);
DART_LEAF_FUNCTION void transport_receive_message(struct transport* transport,
                                                  uint32_t fd,
                                                  uint16_t buffer_id,
                                                  DART_SUBSTITUTE(uint8_t) transport_socket_family_t socket_family,
                                                  int32_t message_flags,
                                                  int64_t timeout,
                                                  uint16_t event,
                                                  uint8_t sqe_flags);
DART_LEAF_FUNCTION void transport_connect(struct transport* transport, struct transport_client* client, int64_t timeout);
DART_LEAF_FUNCTION void transport_accept(struct transport* transport, struct transport_server* server);

DART_LEAF_FUNCTION void transport_cancel_by_fd(struct transport* transport, int32_t fd);

DART_LEAF_FUNCTION void transport_check_event_timeouts(struct transport* transport);
DART_LEAF_FUNCTION void transport_remove_event(struct transport* transport, uint64_t data);

DART_LEAF_FUNCTION struct sockaddr* transport_get_datagram_address(struct transport* transport,
                                                                   DART_SUBSTITUTE(uint8_t) transport_socket_family_t socket_family,
                                                                   int32_t buffer_id);

DART_LEAF_FUNCTION void transport_destroy(struct transport* transport);
#if defined(__cplusplus)
}
#endif

#endif
