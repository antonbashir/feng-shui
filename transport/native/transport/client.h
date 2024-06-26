#ifndef TRANSPORT_CLIENT_H
#define TRANSPORT_CLIENT_H

#include <common/common.h>
#include <system/library.h>
#include "constants.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct transport_client_configuration
{
    DART_FIELD uint64_t socket_configuration_flags;
    DART_FIELD uint32_t socket_receive_buffer_size;
    DART_FIELD uint32_t socket_send_buffer_size;
    DART_FIELD uint32_t socket_receive_low_at;
    DART_FIELD uint32_t socket_send_low_at;
    DART_FIELD uint16_t ip_ttl;
    DART_FIELD uint32_t tcp_keep_alive_idle;
    DART_FIELD uint32_t tcp_keep_alive_max_count;
    DART_FIELD uint32_t tcp_keep_alive_individual_count;
    DART_FIELD uint32_t tcp_max_segment_size;
    DART_FIELD uint16_t tcp_syn_count;
    DART_FIELD struct ip_mreqn* ip_multicast_interface;
    DART_FIELD uint32_t ip_multicast_ttl;
};

DART_STRUCTURE struct transport_client
{
    DART_FIELD int32_t fd;
    DART_FIELD struct sockaddr_in* inet_destination_address;
    DART_FIELD struct sockaddr_in* inet_source_address;
    DART_FIELD struct sockaddr_un* unix_destination_address;
    DART_FIELD DART_SUBSTITUTE(uint32_t) __socklen_t client_address_length;
    DART_FIELD uint8_t family;
    DART_FIELD int8_t initialization_error;
};

DART_LEAF_FUNCTION struct transport_client* transport_client_initialize_tcp(struct transport_client_configuration* configuration,
                                                                            const char* ip,
                                                                            int32_t port);

DART_LEAF_FUNCTION struct transport_client* transport_client_initialize_udp(struct transport_client_configuration* configuration,
                                                                            const char* destination_ip,
                                                                            int32_t destination_port,
                                                                            const char* source_ip,
                                                                            int32_t source_port);

DART_LEAF_FUNCTION struct transport_client* transport_client_initialize_unix_stream(struct transport_client_configuration* configuration,
                                                                                    const char* path);

DART_INLINE_LEAF_FUNCTION struct sockaddr* transport_client_get_destination_address(struct transport_client* client)
{
    return client->family == TRANSPORT_SOCKET_FAMILY_INET ? (struct sockaddr*)client->inet_destination_address : (struct sockaddr*)client->unix_destination_address;
}

DART_LEAF_FUNCTION void transport_client_destroy(struct transport_client* client);
#if defined(__cplusplus)
}
#endif

#endif
