import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../bindings.dart';
import '../channel.dart';
import '../configuration.dart';
import '../constants.dart';
import '../defaults.dart';
import '../exception.dart';
import '../payload.dart';
import 'client.dart';
import 'configuration.dart';
import 'provider.dart';
import 'registry.dart';

class TransportClientsFactory {
  final TransportClientRegistry _registry;
  final Pointer<transport> _workerPointer;
  final MemoryStaticBuffers _buffers;
  final TransportPayloadPool _payloadPool;

  const TransportClientsFactory(this._registry, this._workerPointer, this._buffers, this._payloadPool);

  Future<TransportClientConnectionPool> tcp(
    InternetAddress address,
    int port, {
    TransportTcpClientConfiguration? configuration,
  }) async {
    configuration = configuration ?? TransportDefaults.tcpClient;
    final clients = <Future<TransportClientConnection>>[];
    for (var clientIndex = 0; clientIndex < configuration.pool; clientIndex++) {
      final clientPointer = using(
        (arena) => transport_client_initialize_tcp(
          _tcpConfiguration(configuration!, arena),
          address.address.toNativeUtf8(allocator: arena).cast(),
          port,
        ),
      );
      final result = clientPointer.ref.initialization_error;
      if (result < 0) {
        if (clientPointer.ref.fd > 0) {
          system_shutdown_descriptor(clientPointer.ref.fd);
          transport_client_destroy(clientPointer);
          throw TransportInitializationException(TransportMessages.clientError(result));
        }
        transport_client_destroy(clientPointer);
        throw TransportInitializationException(TransportMessages.clientSocketError(result));
      }
      final client = TransportClientChannel(
        TransportChannel(
          _workerPointer,
          clientPointer.ref.fd,
          _buffers,
        ),
        clientPointer,
        _workerPointer,
        configuration.readTimeout?.inSeconds,
        configuration.writeTimeout?.inSeconds,
        _buffers,
        _registry,
        _payloadPool,
        connectTimeout: configuration.connectTimeout?.inSeconds,
      );
      _registry.add(clientPointer.ref.fd, client);
      clients.add(client.connect().then(TransportClientConnection.new));
    }
    return Future.wait(clients).then(TransportClientConnectionPool.new);
  }

  TransportDatagramClient udp(
    InternetAddress sourceAddress,
    int sourcePort,
    InternetAddress destinationAddress,
    int destinationPort, {
    TransportUdpClientConfiguration? configuration,
  }) {
    configuration = configuration ?? TransportDefaults.udpClient;
    final clientPointer = using((arena) {
      final client = transport_client_initialize_udp(
        _udpConfiguration(configuration!, arena),
        sourceAddress.address.toNativeUtf8(allocator: arena).cast(),
        destinationPort,
        destinationAddress.address.toNativeUtf8(allocator: arena).cast(),
        sourcePort,
      );
      final result = client.ref.initialization_error;
      if (result < 0) {
        if (client.ref.fd > 0) {
          system_shutdown_descriptor(client.ref.fd);
          transport_client_destroy(client);
          throw TransportInitializationException(TransportMessages.clientError(result));
        }
        transport_client_destroy(client);
        throw TransportInitializationException(TransportMessages.clientSocketError(result));
      }
      if (configuration.multicastManager != null) {
        configuration.multicastManager!.subscribe(
          onAddMembership: (configuration) => using(
            (arena) => transport_socket_multicast_add_membership(
              client.ref.fd,
              configuration.groupAddress.toNativeUtf8(allocator: arena).cast(),
              configuration.localAddress.toNativeUtf8(allocator: arena).cast(),
              _getMembershipIndex(configuration),
            ),
          ),
          onDropMembership: (configuration) => using(
            (arena) => transport_socket_multicast_drop_membership(
              client.ref.fd,
              configuration.groupAddress.toNativeUtf8(allocator: arena).cast(),
              configuration.localAddress.toNativeUtf8(allocator: arena).cast(),
              _getMembershipIndex(configuration),
            ),
          ),
          onAddSourceMembership: (configuration) => using(
            (arena) => transport_socket_multicast_add_source_membership(
              client.ref.fd,
              configuration.groupAddress.toNativeUtf8(allocator: arena).cast(),
              configuration.localAddress.toNativeUtf8(allocator: arena).cast(),
              configuration.sourceAddress.toNativeUtf8(allocator: arena).cast(),
            ),
          ),
          onDropSourceMembership: (configuration) => using(
            (arena) => transport_socket_multicast_drop_source_membership(
              client.ref.fd,
              configuration.groupAddress.toNativeUtf8(allocator: arena).cast(),
              configuration.localAddress.toNativeUtf8(allocator: arena).cast(),
              configuration.sourceAddress.toNativeUtf8(allocator: arena).cast(),
            ),
          ),
        );
      }
      return client;
    });
    final client = TransportClientChannel(
      TransportChannel(
        _workerPointer,
        clientPointer.ref.fd,
        _buffers,
      ),
      clientPointer,
      _workerPointer,
      configuration.readTimeout?.inSeconds,
      configuration.writeTimeout?.inSeconds,
      _buffers,
      _registry,
      _payloadPool,
    );
    _registry.add(clientPointer.ref.fd, client);
    return TransportDatagramClient(client);
  }

  Future<TransportClientConnectionPool> unixStream(
    String path, {
    TransportUnixStreamClientConfiguration? configuration,
  }) async {
    configuration = configuration ?? TransportDefaults.unixStreamClient;
    final clients = <Future<TransportClientConnection>>[];
    for (var clientIndex = 0; clientIndex < configuration.pool; clientIndex++) {
      final clientPointer = using(
        (arena) => transport_client_initialize_unix_stream(
          _unixStreamConfiguration(configuration!, arena),
          path.toNativeUtf8(allocator: arena).cast(),
        ),
      );
      final result = clientPointer.ref.initialization_error;
      if (result < 0) {
        if (clientPointer.ref.fd > 0) {
          system_shutdown_descriptor(clientPointer.ref.fd);
          transport_client_destroy(clientPointer);
          throw TransportInitializationException(TransportMessages.clientError(result));
        }
        transport_client_destroy(clientPointer);
        throw TransportInitializationException(TransportMessages.clientSocketError(result));
      }
      final channel = TransportChannel(
        _workerPointer,
        clientPointer.ref.fd,
        _buffers,
      );
      final clientChannel = TransportClientChannel(
        channel,
        clientPointer,
        _workerPointer,
        configuration.readTimeout?.inSeconds,
        configuration.writeTimeout?.inSeconds,
        _buffers,
        _registry,
        _payloadPool,
        connectTimeout: configuration.connectTimeout?.inSeconds,
      );
      _registry.add(clientPointer.ref.fd, clientChannel);
      clients.add(clientChannel.connect().then(TransportClientConnection.new, onError: (error, stackTrace) {
        channel.close();
        _registry.remove(clientPointer.ref.fd);
        transport_client_destroy(clientPointer);
        throw error;
      }));
    }
    return TransportClientConnectionPool(await Future.wait(clients));
  }

  Pointer<transport_client_configuration> _tcpConfiguration(TransportTcpClientConfiguration clientConfiguration, Allocator allocator) {
    final nativeClientConfiguration = allocator<transport_client_configuration>();
    var flags = 0;
    if (clientConfiguration.socketNonblock == true) flags |= transportSocketOptionSocketNonblock;
    if (clientConfiguration.socketCloexec == true) flags |= transportSocketOptionSocketCloexec;
    if (clientConfiguration.socketReuseAddress == true) flags |= transportSocketOptionSocketReuseaddr;
    if (clientConfiguration.socketReusePort == true) flags |= transportSocketOptionSocketReuseport;
    if (clientConfiguration.socketKeepalive == true) flags |= transportSocketOptionSocketKeepalive;
    if (clientConfiguration.ipFreebind == true) flags |= transportSocketOptionIpFreebind;
    if (clientConfiguration.tcpQuickack == true) flags |= transportSocketOptionTcpQuickack;
    if (clientConfiguration.tcpDeferAccept == true) flags |= transportSocketOptionTcpDeferAccept;
    if (clientConfiguration.tcpFastopen == true) flags |= transportSocketOptionTcpFastopen;
    if (clientConfiguration.socketReceiveBufferSize != null) {
      flags |= transportSocketOptionSocketRcvbuf;
      nativeClientConfiguration.ref.socket_receive_buffer_size = clientConfiguration.socketReceiveBufferSize!;
    }
    if (clientConfiguration.socketSendBufferSize != null) {
      flags |= transportSocketOptionSocketSndbuf;
      nativeClientConfiguration.ref.socket_send_buffer_size = clientConfiguration.socketSendBufferSize!;
    }
    if (clientConfiguration.socketReceiveLowAt != null) {
      flags |= transportSocketOptionSocketRcvlowat;
      nativeClientConfiguration.ref.socket_receive_low_at = clientConfiguration.socketReceiveLowAt!;
    }
    if (clientConfiguration.socketSendLowAt != null) {
      flags |= transportSocketOptionSocketSndlowat;
      nativeClientConfiguration.ref.socket_send_low_at = clientConfiguration.socketSendLowAt!;
    }
    if (clientConfiguration.ipTtl != null) {
      flags |= transportSocketOptionIpTtl;
      nativeClientConfiguration.ref.ip_ttl = clientConfiguration.ipTtl!;
    }
    if (clientConfiguration.tcpKeepAliveIdle != null) {
      flags |= transportSocketOptionTcpKeepidle;
      nativeClientConfiguration.ref.tcp_keep_alive_idle = clientConfiguration.tcpKeepAliveIdle!;
    }
    if (clientConfiguration.tcpKeepAliveMaxCount != null) {
      flags |= transportSocketOptionTcpKeepcnt;
      nativeClientConfiguration.ref.tcp_keep_alive_max_count = clientConfiguration.tcpKeepAliveMaxCount!;
    }
    if (clientConfiguration.tcpKeepAliveIdle != null) {
      flags |= transportSocketOptionTcpKeepintvl;
      nativeClientConfiguration.ref.tcp_keep_alive_individual_count = clientConfiguration.tcpKeepAliveIdle!;
    }
    if (clientConfiguration.tcpMaxSegmentSize != null) {
      flags |= transportSocketOptionTcpMaxseg;
      nativeClientConfiguration.ref.tcp_max_segment_size = clientConfiguration.tcpMaxSegmentSize!;
    }
    if (clientConfiguration.tcpSynCount != null) {
      flags |= transportSocketOptionTcpSyncnt;
      nativeClientConfiguration.ref.tcp_syn_count = clientConfiguration.tcpSynCount!;
    }
    nativeClientConfiguration.ref.socket_configuration_flags = flags;
    return nativeClientConfiguration;
  }

  Pointer<transport_client_configuration> _udpConfiguration(TransportUdpClientConfiguration clientConfiguration, Allocator allocator) {
    final nativeClientConfiguration = allocator<transport_client_configuration>();
    var flags = 0;
    if (clientConfiguration.socketNonblock == true) flags |= transportSocketOptionSocketNonblock;
    if (clientConfiguration.socketCloexec == true) flags |= transportSocketOptionSocketCloexec;
    if (clientConfiguration.socketReuseAddress == true) flags |= transportSocketOptionSocketReuseaddr;
    if (clientConfiguration.socketReusePort == true) flags |= transportSocketOptionSocketReuseport;
    if (clientConfiguration.socketBroadcast == true) flags |= transportSocketOptionSocketBroadcast;
    if (clientConfiguration.ipFreebind == true) flags |= transportSocketOptionIpFreebind;
    if (clientConfiguration.ipMulticastAll == true) flags |= transportSocketOptionIpMulticastAll;
    if (clientConfiguration.ipMulticastLoop == true) flags |= transportSocketOptionIpMulticastLoop;
    if (clientConfiguration.socketReceiveBufferSize != null) {
      flags |= transportSocketOptionSocketRcvbuf;
      nativeClientConfiguration.ref.socket_receive_buffer_size = clientConfiguration.socketReceiveBufferSize!;
    }
    if (clientConfiguration.socketSendBufferSize != null) {
      flags |= transportSocketOptionSocketSndbuf;
      nativeClientConfiguration.ref.socket_send_buffer_size = clientConfiguration.socketSendBufferSize!;
    }
    if (clientConfiguration.socketReceiveLowAt != null) {
      flags |= transportSocketOptionSocketRcvlowat;
      nativeClientConfiguration.ref.socket_receive_low_at = clientConfiguration.socketReceiveLowAt!;
    }
    if (clientConfiguration.socketSendLowAt != null) {
      flags |= transportSocketOptionSocketSndlowat;
      nativeClientConfiguration.ref.socket_send_low_at = clientConfiguration.socketSendLowAt!;
    }
    if (clientConfiguration.ipTtl != null) {
      flags |= transportSocketOptionIpTtl;
      nativeClientConfiguration.ref.ip_ttl = clientConfiguration.ipTtl!;
    }
    if (clientConfiguration.ipMulticastTtl != null) {
      flags |= transportSocketOptionIpMulticastTtl;
      nativeClientConfiguration.ref.ip_multicast_ttl = clientConfiguration.ipMulticastTtl!;
    }
    if (clientConfiguration.ipMulticastInterface != null) {
      flags |= transportSocketOptionIpMulticastIf;
      final interface = clientConfiguration.ipMulticastInterface!;
      transport_socket_initialize_multicast_request(
        nativeClientConfiguration.ref.ip_multicast_interface,
        interface.groupAddress.toNativeUtf8(allocator: allocator).cast(),
        interface.localAddress.toNativeUtf8(allocator: allocator).cast(),
        _getMembershipIndex(interface),
      );
    }
    nativeClientConfiguration.ref.socket_configuration_flags = flags;
    return nativeClientConfiguration;
  }

  Pointer<transport_client_configuration> _unixStreamConfiguration(TransportUnixStreamClientConfiguration clientConfiguration, Allocator allocator) {
    final nativeClientConfiguration = allocator<transport_client_configuration>();
    var flags = 0;
    if (clientConfiguration.socketNonblock == true) flags |= transportSocketOptionSocketNonblock;
    if (clientConfiguration.socketCloexec == true) flags |= transportSocketOptionSocketCloexec;
    if (clientConfiguration.socketKeepalive == true) flags |= transportSocketOptionSocketKeepalive;
    if (clientConfiguration.socketReceiveBufferSize != null) {
      flags |= transportSocketOptionSocketRcvbuf;
      nativeClientConfiguration.ref.socket_receive_buffer_size = clientConfiguration.socketReceiveBufferSize!;
    }
    if (clientConfiguration.socketSendBufferSize != null) {
      flags |= transportSocketOptionSocketSndbuf;
      nativeClientConfiguration.ref.socket_send_buffer_size = clientConfiguration.socketSendBufferSize!;
    }
    if (clientConfiguration.socketReceiveLowAt != null) {
      flags |= transportSocketOptionSocketRcvlowat;
      nativeClientConfiguration.ref.socket_receive_low_at = clientConfiguration.socketReceiveLowAt!;
    }
    if (clientConfiguration.socketSendLowAt != null) {
      flags |= transportSocketOptionSocketSndlowat;
      nativeClientConfiguration.ref.socket_send_low_at = clientConfiguration.socketSendLowAt!;
    }
    nativeClientConfiguration.ref.socket_configuration_flags = flags;
    return nativeClientConfiguration;
  }

  int _getMembershipIndex(TransportUdpMulticastConfiguration configuration) => using(
        (arena) {
          if (configuration.calculateInterfaceIndex) {
            return transport_socket_get_interface_index(configuration.localInterface!.toNativeUtf8(allocator: arena).cast());
          }
          return configuration.interfaceIndex!;
        },
      );

  @visibleForTesting
  TransportClientRegistry get registry => _registry;
}
