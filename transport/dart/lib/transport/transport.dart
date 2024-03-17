import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:meta/meta.dart';

import 'bindings.dart';
import 'client/factory.dart';
import 'client/registry.dart';
import 'constants.dart';
import 'exception.dart';
import 'file/factory.dart';
import 'file/registry.dart';
import 'payload.dart';
import 'server/factory.dart';
import 'server/registry.dart';
import 'server/responder.dart';
import 'timeout.dart';

class Transport {
  final _fromTransport = ReceivePort();

  late final Pointer<transport> _native;
  late final Executor _executor;
  late final TransportClientRegistry _clientRegistry;
  late final TransportServerRegistry _serverRegistry;
  late final TransportClientsFactory _clientsFactory;
  late final TransportServersFactory _serversFactory;
  late final TransportFileRegistry _filesRegistry;
  late final TransportFilesFactory _filesFactory;
  late final MemoryModule _memory;
  late final MemoryStaticBuffers _staticBuffers;
  late final TransportTimeoutChecker _timeoutChecker;
  late final TransportPayloadPool _payloadPool;
  late final TransportServerDatagramResponderPool _datagramResponderPool;

  var _active = true;

  bool get active => _active;
  int get descriptor => _executor.descriptor;
  TransportServersFactory get servers => _serversFactory;
  TransportClientsFactory get clients => _clientsFactory;
  TransportFilesFactory get files => _filesFactory;

  Transport(this._native, this._executor);

  Future<void> initialize() async {
    final configuration = await _fromTransport.first as List;
    _native = Pointer.fromAddress(configuration[0] as int).cast<transport>();
    _fromTransport.close();
    await _executor.initialize(processor: _process, pending: () => 0);
    _staticBuffers = context().staticBuffers();
    _native.ref.buffers = _staticBuffers.native.ref.buffers;
    final result = transport_setup(_native, _executor.native);
    if (result != 0) {
      throw TransportInitializationException(TransportMessages.workerError(result));
    }
    _payloadPool = TransportPayloadPool(_staticBuffers);
    _datagramResponderPool = TransportServerDatagramResponderPool(_staticBuffers);
    _clientRegistry = TransportClientRegistry();
    _serverRegistry = TransportServerRegistry();
    _serversFactory = TransportServersFactory(
      _serverRegistry,
      _native,
      _staticBuffers,
      _payloadPool,
      _datagramResponderPool,
    );
    _clientsFactory = TransportClientsFactory(
      _clientRegistry,
      _native,
      _staticBuffers,
      _payloadPool,
    );
    _filesRegistry = TransportFileRegistry();
    _filesFactory = TransportFilesFactory(
      _filesRegistry,
      _native,
      _staticBuffers,
      _payloadPool,
    );
    _timeoutChecker = TransportTimeoutChecker(
      _native,
      Duration(milliseconds: _native.ref.configuration.timeout_checker_period_milliseconds),
    );
    _timeoutChecker.start();
    _executor.activate();
  }

  Future<void> shutdown({Duration? gracefulTimeout}) async {
    _timeoutChecker.stop();
    await _filesRegistry.close(gracefulTimeout: gracefulTimeout);
    await _clientRegistry.close(gracefulTimeout: gracefulTimeout);
    await _serverRegistry.close(gracefulTimeout: gracefulTimeout);
    _active = false;
    await _executor.shutdown();
    transport_destroy(_native);
    _memory.destroy();
  }

  void _process(Pointer<Pointer<executor_completion_event>> completions, int count) {
    for (var index = 0; index < count; index++) {
      Pointer<executor_completion_event> completion = (completions + index).value.cast();
      final data = completion.ref.user_data;
      transport_remove_event(_native, data);
      final result = completion.ref.res;
      var event = data & 0xffff;
      final fd = (data >> 32) & 0xffffffff;
      final bufferId = (data >> 16) & 0xffff;
      if (_native.ref.configuration.trace) {
        final server = event & transportEventServer != 0;
        final client = event & transportEventClient != 0;
        final parsed = server
            ? TransportEvent.serverEvent(event & ~transportEventServer)
            : client
                ? TransportEvent.clientEvent(event & ~transportEventClient)
                : TransportEvent.fileEvent(event & ~transportEventFile);
        print(TransportMessages.workerTrace(parsed, result, data, fd));
      }

      if (event & transportEventClient != 0) {
        event &= ~transportEventClient;
        if (event == transportEventConnect) {
          _clientRegistry.get(fd)?.notifyConnect(fd, result);
          continue;
        }
        _clientRegistry.get(fd)?.notifyData(bufferId, result, event);
        continue;
      }

      if (event & transportEventServer != 0) {
        event &= ~transportEventServer;
        if (event == transportEventRead || event == transportEventWrite) {
          _serverRegistry.getConnection(fd)?.notify(bufferId, result, event);
          continue;
        }
        if (event == transportEventReceiveMessage || event == transportEventSendMessage) {
          _serverRegistry.getServer(fd)?.notifyDatagram(bufferId, result, event);
          continue;
        }
        _serverRegistry.getServer(fd)?.notifyAccept(result);
        continue;
      }

      if (event & transportEventFile != 0) {
        _filesRegistry.get(fd)?.notify(bufferId, result, event & ~transportEventFile);
        continue;
      }
    }
  }

  @visibleForTesting
  MemoryStaticBuffers get buffers => _staticBuffers;
}
