// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint, unused_field
import 'dart:ffi' as ffi;
import 'package:memory/memory.dart' as memory;

@ffi.Native<
        ffi.Int Function(
            ffi.Pointer<transport_client_t>,
            ffi.Pointer<transport_client_configuration_t>,
            ffi.Pointer<ffi.Char>,
            ffi.Int32)>(
    symbol: 'transport_client_initialize_tcp',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_client_initialize_tcp(
  ffi.Pointer<transport_client_t> client,
  ffi.Pointer<transport_client_configuration_t> configuration,
  ffi.Pointer<ffi.Char> ip,
  int port,
);

@ffi.Native<
        ffi.Int Function(
            ffi.Pointer<transport_client_t>,
            ffi.Pointer<transport_client_configuration_t>,
            ffi.Pointer<ffi.Char>,
            ffi.Int32,
            ffi.Pointer<ffi.Char>,
            ffi.Int32)>(
    symbol: 'transport_client_initialize_udp',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_client_initialize_udp(
  ffi.Pointer<transport_client_t> client,
  ffi.Pointer<transport_client_configuration_t> configuration,
  ffi.Pointer<ffi.Char> destination_ip,
  int destination_port,
  ffi.Pointer<ffi.Char> source_ip,
  int source_port,
);

@ffi.Native<
        ffi.Int Function(
            ffi.Pointer<transport_client_t>,
            ffi.Pointer<transport_client_configuration_t>,
            ffi.Pointer<ffi.Char>)>(
    symbol: 'transport_client_initialize_unix_stream',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_client_initialize_unix_stream(
  ffi.Pointer<transport_client_t> client,
  ffi.Pointer<transport_client_configuration_t> configuration,
  ffi.Pointer<ffi.Char> path,
);

@ffi.Native<ffi.Pointer<sockaddr> Function(ffi.Pointer<transport_client_t>)>(
    symbol: 'transport_client_get_destination_address',
    assetId: 'transport-bindings',
    isLeaf: true)
external ffi.Pointer<sockaddr> transport_client_get_destination_address(
  ffi.Pointer<transport_client_t> client,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<transport_client_t>)>(
    symbol: 'transport_client_destroy',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_client_destroy(
  ffi.Pointer<transport_client_t> client,
);

@ffi.Native<
        ffi.Int Function(
            ffi.Pointer<transport_server_t>,
            ffi.Pointer<transport_server_configuration_t>,
            ffi.Pointer<ffi.Char>,
            ffi.Int32)>(
    symbol: 'transport_server_initialize_tcp',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_server_initialize_tcp(
  ffi.Pointer<transport_server_t> server,
  ffi.Pointer<transport_server_configuration_t> configuration,
  ffi.Pointer<ffi.Char> ip,
  int port,
);

@ffi.Native<
        ffi.Int Function(
            ffi.Pointer<transport_server_t>,
            ffi.Pointer<transport_server_configuration_t>,
            ffi.Pointer<ffi.Char>,
            ffi.Int32)>(
    symbol: 'transport_server_initialize_udp',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_server_initialize_udp(
  ffi.Pointer<transport_server_t> server,
  ffi.Pointer<transport_server_configuration_t> configuration,
  ffi.Pointer<ffi.Char> ip,
  int port,
);

@ffi.Native<
        ffi.Int Function(
            ffi.Pointer<transport_server_t>,
            ffi.Pointer<transport_server_configuration_t>,
            ffi.Pointer<ffi.Char>)>(
    symbol: 'transport_server_initialize_unix_stream',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_server_initialize_unix_stream(
  ffi.Pointer<transport_server_t> server,
  ffi.Pointer<transport_server_configuration_t> configuration,
  ffi.Pointer<ffi.Char> path,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<transport_server_t>)>(
    symbol: 'transport_server_destroy',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_server_destroy(
  ffi.Pointer<transport_server_t> server,
);

@ffi.Native<
        ffi.Int Function(ffi.Pointer<transport_t>,
            ffi.Pointer<transport_configuration_t>, ffi.Uint8)>(
    symbol: 'transport_initialize', assetId: 'transport-bindings', isLeaf: true)
external int transport_initialize(
  ffi.Pointer<transport_t> transport,
  ffi.Pointer<transport_configuration_t> configuration,
  int id,
);

@ffi.Native<ffi.Int Function(ffi.Pointer<transport_t>)>(
    symbol: 'transport_setup', assetId: 'transport-bindings', isLeaf: true)
external int transport_setup(
  ffi.Pointer<transport_t> transport,
);

@ffi.Native<
        ffi.Void Function(ffi.Pointer<transport_t>, ffi.Uint32, ffi.Uint16,
            ffi.Uint32, ffi.Int64, ffi.Uint16, ffi.Uint8)>(
    symbol: 'transport_write', assetId: 'transport-bindings', isLeaf: true)
external void transport_write(
  ffi.Pointer<transport_t> transport,
  int fd,
  int buffer_id,
  int offset,
  int timeout,
  int event,
  int sqe_flags,
);

@ffi.Native<
        ffi.Void Function(ffi.Pointer<transport_t>, ffi.Uint32, ffi.Uint16,
            ffi.Uint32, ffi.Int64, ffi.Uint16, ffi.Uint8)>(
    symbol: 'transport_read', assetId: 'transport-bindings', isLeaf: true)
external void transport_read(
  ffi.Pointer<transport_t> transport,
  int fd,
  int buffer_id,
  int offset,
  int timeout,
  int event,
  int sqe_flags,
);

@ffi.Native<
        ffi.Void Function(
            ffi.Pointer<transport_t>,
            ffi.Uint32,
            ffi.Uint16,
            ffi.Pointer<sockaddr>,
            ffi.Int32,
            ffi.Int,
            ffi.Int64,
            ffi.Uint16,
            ffi.Uint8)>(
    symbol: 'transport_send_message',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_send_message(
  ffi.Pointer<transport_t> transport,
  int fd,
  int buffer_id,
  ffi.Pointer<sockaddr> address,
  int socket_family,
  int message_flags,
  int timeout,
  int event,
  int sqe_flags,
);

@ffi.Native<
        ffi.Void Function(ffi.Pointer<transport_t>, ffi.Uint32, ffi.Uint16,
            ffi.Int32, ffi.Int, ffi.Int64, ffi.Uint16, ffi.Uint8)>(
    symbol: 'transport_receive_message',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_receive_message(
  ffi.Pointer<transport_t> transport,
  int fd,
  int buffer_id,
  int socket_family,
  int message_flags,
  int timeout,
  int event,
  int sqe_flags,
);

@ffi.Native<
        ffi.Void Function(ffi.Pointer<transport_t>,
            ffi.Pointer<transport_client_t>, ffi.Int64)>(
    symbol: 'transport_connect', assetId: 'transport-bindings', isLeaf: true)
external void transport_connect(
  ffi.Pointer<transport_t> transport,
  ffi.Pointer<transport_client_t> client,
  int timeout,
);

@ffi.Native<
        ffi.Void Function(
            ffi.Pointer<transport_t>, ffi.Pointer<transport_server_t>)>(
    symbol: 'transport_accept', assetId: 'transport-bindings', isLeaf: true)
external void transport_accept(
  ffi.Pointer<transport_t> transport,
  ffi.Pointer<transport_server_t> server,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<transport_t>, ffi.Int)>(
    symbol: 'transport_cancel_by_fd',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_cancel_by_fd(
  ffi.Pointer<transport_t> transport,
  int fd,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<transport_t>)>(
    symbol: 'transport_check_event_timeouts',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_check_event_timeouts(
  ffi.Pointer<transport_t> transport,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<transport_t>, ffi.Uint64)>(
    symbol: 'transport_remove_event',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_remove_event(
  ffi.Pointer<transport_t> transport,
  int data,
);

@ffi.Native<
        ffi.Pointer<sockaddr> Function(
            ffi.Pointer<transport_t>, ffi.Int32, ffi.Int)>(
    symbol: 'transport_get_datagram_address',
    assetId: 'transport-bindings',
    isLeaf: true)
external ffi.Pointer<sockaddr> transport_get_datagram_address(
  ffi.Pointer<transport_t> transport,
  int socket_family,
  int buffer_id,
);

@ffi.Native<ffi.Int Function(ffi.Pointer<transport_t>)>(
    symbol: 'transport_peek', assetId: 'transport-bindings', isLeaf: true)
external int transport_peek(
  ffi.Pointer<transport_t> transport,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<transport_t>)>(
    symbol: 'transport_destroy', assetId: 'transport-bindings', isLeaf: true)
external void transport_destroy(
  ffi.Pointer<transport_t> transport,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<io_uring>, ffi.Int)>(
    symbol: 'transport_cqe_advance',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_cqe_advance(
  ffi.Pointer<io_uring> ring,
  int count,
);

@ffi.Native<
        ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Int, ffi.Bool, ffi.Bool)>(
    symbol: 'transport_file_open', assetId: 'transport-bindings', isLeaf: true)
external int transport_file_open(
  ffi.Pointer<ffi.Char> path,
  int mode,
  bool truncate,
  bool create,
);

@ffi.Native<
        ffi.Int64 Function(
            ffi.Uint64,
            ffi.Uint32,
            ffi.Uint32,
            ffi.Uint32,
            ffi.Uint32,
            ffi.Uint16,
            ffi.Uint32,
            ffi.Uint32,
            ffi.Uint32,
            ffi.Uint32,
            ffi.Uint16)>(
    symbol: 'transport_socket_create_tcp',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_create_tcp(
  int flags,
  int socket_receive_buffer_size,
  int socket_send_buffer_size,
  int socket_receive_low_at,
  int socket_send_low_at,
  int ip_ttl,
  int tcp_keep_alive_idle,
  int tcp_keep_alive_max_count,
  int tcp_keep_alive_individual_count,
  int tcp_max_segment_size,
  int tcp_syn_count,
);

@ffi.Native<
        ffi.Int64 Function(ffi.Uint64, ffi.Uint32, ffi.Uint32, ffi.Uint32,
            ffi.Uint32, ffi.Uint16, ffi.Pointer<ip_mreqn>, ffi.Uint32)>(
    symbol: 'transport_socket_create_udp',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_create_udp(
  int flags,
  int socket_receive_buffer_size,
  int socket_send_buffer_size,
  int socket_receive_low_at,
  int socket_send_low_at,
  int ip_ttl,
  ffi.Pointer<ip_mreqn> ip_multicast_interface,
  int ip_multicast_ttl,
);

@ffi.Native<
        ffi.Int64 Function(
            ffi.Uint64, ffi.Uint32, ffi.Uint32, ffi.Uint32, ffi.Uint32)>(
    symbol: 'transport_socket_create_unix_stream',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_create_unix_stream(
  int flags,
  int socket_receive_buffer_size,
  int socket_send_buffer_size,
  int socket_receive_low_at,
  int socket_send_low_at,
);

@ffi.Native<
        ffi.Void Function(ffi.Pointer<ip_mreqn>, ffi.Pointer<ffi.Char>,
            ffi.Pointer<ffi.Char>, ffi.Int)>(
    symbol: 'transport_socket_initialize_multicast_request',
    assetId: 'transport-bindings',
    isLeaf: true)
external void transport_socket_initialize_multicast_request(
  ffi.Pointer<ip_mreqn> request,
  ffi.Pointer<ffi.Char> group_address,
  ffi.Pointer<ffi.Char> local_address,
  int interface_index,
);

@ffi.Native<
        ffi.Int Function(
            ffi.Int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>(
    symbol: 'transport_socket_multicast_add_membership',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_multicast_add_membership(
  int fd,
  ffi.Pointer<ffi.Char> group_address,
  ffi.Pointer<ffi.Char> local_address,
  int interface_index,
);

@ffi.Native<
        ffi.Int Function(
            ffi.Int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>(
    symbol: 'transport_socket_multicast_drop_membership',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_multicast_drop_membership(
  int fd,
  ffi.Pointer<ffi.Char> group_address,
  ffi.Pointer<ffi.Char> local_address,
  int interface_index,
);

@ffi.Native<
        ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>,
            ffi.Pointer<ffi.Char>)>(
    symbol: 'transport_socket_multicast_add_source_membership',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_multicast_add_source_membership(
  int fd,
  ffi.Pointer<ffi.Char> group_address,
  ffi.Pointer<ffi.Char> local_address,
  ffi.Pointer<ffi.Char> source_address,
);

@ffi.Native<
        ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>,
            ffi.Pointer<ffi.Char>)>(
    symbol: 'transport_socket_multicast_drop_source_membership',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_multicast_drop_source_membership(
  int fd,
  ffi.Pointer<ffi.Char> group_address,
  ffi.Pointer<ffi.Char> local_address,
  ffi.Pointer<ffi.Char> source_address,
);

@ffi.Native<ffi.Int Function(ffi.Pointer<ffi.Char>)>(
    symbol: 'transport_socket_get_interface_index',
    assetId: 'transport-bindings',
    isLeaf: true)
external int transport_socket_get_interface_index(
  ffi.Pointer<ffi.Char> interface1,
);

abstract class transport_socket_family {
  static const int INET = 0;
  static const int UNIX = 1;
}

final class sockaddr_in extends ffi.Opaque {}

final class sockaddr_un extends ffi.Opaque {}

final class transport_client_configuration extends ffi.Struct {
  @ffi.Uint64()
  external int socket_configuration_flags;

  @ffi.Uint32()
  external int socket_receive_buffer_size;

  @ffi.Uint32()
  external int socket_send_buffer_size;

  @ffi.Uint32()
  external int socket_receive_low_at;

  @ffi.Uint32()
  external int socket_send_low_at;

  @ffi.Uint16()
  external int ip_ttl;

  @ffi.Uint32()
  external int tcp_keep_alive_idle;

  @ffi.Uint32()
  external int tcp_keep_alive_max_count;

  @ffi.Uint32()
  external int tcp_keep_alive_individual_count;

  @ffi.Uint32()
  external int tcp_max_segment_size;

  @ffi.Uint16()
  external int tcp_syn_count;

  external ffi.Pointer<ip_mreqn> ip_multicast_interface;

  @ffi.Uint32()
  external int ip_multicast_ttl;
}

final class ip_mreqn extends ffi.Opaque {}

final class transport_client extends ffi.Struct {
  @ffi.Int()
  external int fd;

  external ffi.Pointer<sockaddr_in> inet_destination_address;

  external ffi.Pointer<sockaddr_in> inet_source_address;

  external ffi.Pointer<sockaddr_un> unix_destination_address;

  @ffi.UnsignedInt()
  external int client_address_length;

  @ffi.Int32()
  external int family;
}

typedef transport_client_t = transport_client;
typedef transport_client_configuration_t = transport_client_configuration;

final class sockaddr extends ffi.Opaque {}

final class transport_server_configuration extends ffi.Struct {
  @ffi.Int32()
  external int socket_max_connections;

  @ffi.Uint64()
  external int socket_configuration_flags;

  @ffi.Uint32()
  external int socket_receive_buffer_size;

  @ffi.Uint32()
  external int socket_send_buffer_size;

  @ffi.Uint32()
  external int socket_receive_low_at;

  @ffi.Uint32()
  external int socket_send_low_at;

  @ffi.Uint16()
  external int ip_ttl;

  @ffi.Uint32()
  external int tcp_keep_alive_idle;

  @ffi.Uint32()
  external int tcp_keep_alive_max_count;

  @ffi.Uint32()
  external int tcp_keep_alive_individual_count;

  @ffi.Uint32()
  external int tcp_max_segment_size;

  @ffi.Uint16()
  external int tcp_syn_count;

  external ffi.Pointer<ip_mreqn> ip_multicast_interface;

  @ffi.Uint32()
  external int ip_multicast_ttl;
}

final class transport_server extends ffi.Struct {
  @ffi.Int()
  external int fd;

  @ffi.Int32()
  external int family;

  external ffi.Pointer<sockaddr_in> inet_server_address;

  external ffi.Pointer<sockaddr_un> unix_server_address;

  @ffi.UnsignedInt()
  external int server_address_length;
}

typedef transport_server_t = transport_server;
typedef transport_server_configuration_t = transport_server_configuration;

final class mh_events_t extends ffi.Opaque {}

final class io_uring extends ffi.Opaque {}

final class io_uring_cqe extends ffi.Opaque {}

final class transport_configuration extends ffi.Struct {
  @ffi.Uint16()
  external int buffers_capacity;

  @ffi.Uint32()
  external int buffer_size;

  @ffi.Size()
  external int ring_size;

  @ffi.UnsignedInt()
  external int ring_flags;

  @ffi.Uint64()
  external int timeout_checker_period_millis;

  @ffi.Uint32()
  external int base_delay_micros;

  @ffi.Double()
  external double delay_randomization_factor;

  @ffi.Uint64()
  external int max_delay_micros;

  @ffi.Uint64()
  external int cqe_wait_timeout_millis;

  @ffi.Uint32()
  external int cqe_wait_count;

  @ffi.Uint32()
  external int cqe_peek_count;

  @ffi.Bool()
  external bool trace;
}

final class transport extends ffi.Struct {
  @ffi.Uint8()
  external int id;

  external ffi.Pointer<io_uring> ring;

  external ffi.Pointer<memory.iovec> buffers;

  @ffi.Uint16()
  external int buffers_capacity;

  @ffi.Uint16()
  external int buffer_size;

  @ffi.Uint64()
  external int timeout_checker_period_millis;

  @ffi.Uint32()
  external int base_delay_micros;

  @ffi.Double()
  external double delay_randomization_factor;

  @ffi.Uint64()
  external int max_delay_micros;

  external ffi.Pointer<msghdr> inet_used_messages;

  external ffi.Pointer<msghdr> unix_used_messages;

  external ffi.Pointer<mh_events_t> events;

  @ffi.Size()
  external int ring_size;

  @ffi.Int()
  external int ring_flags;

  external ffi.Pointer<ffi.Pointer<transport_completion_event>> completions;

  @ffi.Uint64()
  external int cqe_wait_timeout_millis;

  @ffi.Uint32()
  external int cqe_wait_count;

  @ffi.Uint32()
  external int cqe_peek_count;

  @ffi.Int32()
  external int descriptor;

  @ffi.Bool()
  external bool trace;
}

final class msghdr extends ffi.Opaque {}

typedef transport_completion_event = io_uring_cqe;
typedef transport_t = transport;
typedef transport_configuration_t = transport_configuration;

const int NULL = 0;

const int INT8_MIN = -128;

const int INT16_MIN = -32768;

const int INT32_MIN = -2147483648;

const int INT64_MIN = -9223372036854775808;

const int INT8_MAX = 127;

const int INT16_MAX = 32767;

const int INT32_MAX = 2147483647;

const int INT64_MAX = 9223372036854775807;

const int UINT8_MAX = 255;

const int UINT16_MAX = 65535;

const int UINT32_MAX = 4294967295;

const int UINT64_MAX = -1;

const int INT_LEAST8_MIN = -128;

const int INT_LEAST16_MIN = -32768;

const int INT_LEAST32_MIN = -2147483648;

const int INT_LEAST64_MIN = -9223372036854775808;

const int INT_LEAST8_MAX = 127;

const int INT_LEAST16_MAX = 32767;

const int INT_LEAST32_MAX = 2147483647;

const int INT_LEAST64_MAX = 9223372036854775807;

const int UINT_LEAST8_MAX = 255;

const int UINT_LEAST16_MAX = 65535;

const int UINT_LEAST32_MAX = 4294967295;

const int UINT_LEAST64_MAX = -1;

const int INT_FAST8_MIN = -128;

const int INT_FAST16_MIN = -9223372036854775808;

const int INT_FAST32_MIN = -9223372036854775808;

const int INT_FAST64_MIN = -9223372036854775808;

const int INT_FAST8_MAX = 127;

const int INT_FAST16_MAX = 9223372036854775807;

const int INT_FAST32_MAX = 9223372036854775807;

const int INT_FAST64_MAX = 9223372036854775807;

const int UINT_FAST8_MAX = 255;

const int UINT_FAST16_MAX = -1;

const int UINT_FAST32_MAX = -1;

const int UINT_FAST64_MAX = -1;

const int INTPTR_MIN = -9223372036854775808;

const int INTPTR_MAX = 9223372036854775807;

const int UINTPTR_MAX = -1;

const int INTMAX_MIN = -9223372036854775808;

const int INTMAX_MAX = 9223372036854775807;

const int UINTMAX_MAX = -1;

const int PTRDIFF_MIN = -9223372036854775808;

const int PTRDIFF_MAX = 9223372036854775807;

const int SIG_ATOMIC_MIN = -2147483648;

const int SIG_ATOMIC_MAX = 2147483647;

const int SIZE_MAX = -1;

const int WCHAR_MIN = -2147483648;

const int WCHAR_MAX = 2147483647;

const int WINT_MIN = 0;

const int WINT_MAX = 4294967295;

const int TRANSPORT_EVENT_READ = 1;

const int TRANSPORT_EVENT_WRITE = 2;

const int TRANSPORT_EVENT_RECEIVE_MESSAGE = 4;

const int TRANSPORT_EVENT_SEND_MESSAGE = 8;

const int TRANSPORT_EVENT_ACCEPT = 16;

const int TRANSPORT_EVENT_CONNECT = 32;

const int TRANSPORT_EVENT_CLIENT = 64;

const int TRANSPORT_EVENT_FILE = 128;

const int TRANSPORT_EVENT_SERVER = 256;

const int TRANSPORT_READ_ONLY = 1;

const int TRANSPORT_WRITE_ONLY = 2;

const int TRANSPORT_READ_WRITE = 4;

const int TRANSPORT_WRITE_ONLY_APPEND = 8;

const int TRANSPORT_READ_WRITE_APPEND = 16;

const int TRANSPORT_BUFFER_USED = -1;

const int TRANSPORT_TIMEOUT_INFINITY = -1;

const int TRANSPORT_SOCKET_OPTION_SOCKET_NONBLOCK = 2;

const int TRANSPORT_SOCKET_OPTION_SOCKET_CLOCEXEC = 4;

const int TRANSPORT_SOCKET_OPTION_SOCKET_REUSEADDR = 8;

const int TRANSPORT_SOCKET_OPTION_SOCKET_REUSEPORT = 16;

const int TRANSPORT_SOCKET_OPTION_SOCKET_RCVBUF = 32;

const int TRANSPORT_SOCKET_OPTION_SOCKET_SNDBUF = 64;

const int TRANSPORT_SOCKET_OPTION_SOCKET_BROADCAST = 128;

const int TRANSPORT_SOCKET_OPTION_SOCKET_KEEPALIVE = 256;

const int TRANSPORT_SOCKET_OPTION_SOCKET_RCVLOWAT = 512;

const int TRANSPORT_SOCKET_OPTION_SOCKET_SNDLOWAT = 1024;

const int TRANSPORT_SOCKET_OPTION_IP_TTL = 2048;

const int TRANSPORT_SOCKET_OPTION_IP_ADD_MEMBERSHIP = 4096;

const int TRANSPORT_SOCKET_OPTION_IP_ADD_SOURCE_MEMBERSHIP = 8192;

const int TRANSPORT_SOCKET_OPTION_IP_DROP_MEMBERSHIP = 16384;

const int TRANSPORT_SOCKET_OPTION_IP_DROP_SOURCE_MEMBERSHIP = 32768;

const int TRANSPORT_SOCKET_OPTION_IP_FREEBIND = 65536;

const int TRANSPORT_SOCKET_OPTION_IP_MULTICAST_ALL = 131072;

const int TRANSPORT_SOCKET_OPTION_IP_MULTICAST_IF = 262144;

const int TRANSPORT_SOCKET_OPTION_IP_MULTICAST_LOOP = 524288;

const int TRANSPORT_SOCKET_OPTION_IP_MULTICAST_TTL = 1048576;

const int TRANSPORT_SOCKET_OPTION_TCP_QUICKACK = 2097152;

const int TRANSPORT_SOCKET_OPTION_TCP_DEFER_ACCEPT = 4194304;

const int TRANSPORT_SOCKET_OPTION_TCP_FASTOPEN = 8388608;

const int TRANSPORT_SOCKET_OPTION_TCP_KEEPIDLE = 16777216;

const int TRANSPORT_SOCKET_OPTION_TCP_KEEPCNT = 33554432;

const int TRANSPORT_SOCKET_OPTION_TCP_KEEPINTVL = 67108864;

const int TRANSPORT_SOCKET_OPTION_TCP_MAXSEG = 134217728;

const int TRANSPORT_SOCKET_OPTION_TCP_NODELAY = 268435456;

const int TRANSPORT_SOCKET_OPTION_TCP_SYNCNT = 536870912;
