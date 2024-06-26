import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../bindings.dart';
import '../channel.dart';
import '../constants.dart';
import '../exception.dart';
import '../payload.dart';
import 'provider.dart';
import 'registry.dart';

class TransportClientChannel {
  final _inboundEvents = StreamController<TransportPayload>();
  final _outboundDoneHandlers = <int, void Function()>{};
  final _outboundErrorHandlers = <int, void Function(Exception error)>{};
  final Pointer<transport_client> _pointer;
  final Pointer<transport> _workerPointer;
  final TransportChannel _channel;
  final int? _connectTimeout;
  final int? _readTimeout;
  final int? _writeTimeout;
  final MemoryStaticBuffers _buffers;
  final TransportClientRegistry _registry;
  final TransportPayloadPool _payloadPool;

  final Pointer<sockaddr> _destination;

  var _connector = Completer();
  var _pending = 0;
  var _active = true;
  var _closing = false;
  final _closer = Completer();

  bool get active => !_closing;
  Stream<TransportPayload> get inbound => _inboundEvents.stream;

  TransportClientChannel(
    this._channel,
    this._pointer,
    this._workerPointer,
    this._readTimeout,
    this._writeTimeout,
    this._buffers,
    this._registry,
    this._payloadPool, {
    int? connectTimeout,
  })  : _connectTimeout = connectTimeout,
        _destination = transport_client_get_destination_address(_pointer);

  Future<void> read() async {
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing) return Future.error(TransportClosedException.forClient());
    _channel.read(bufferId, transportEventRead | transportEventClient, timeout: _readTimeout);
    _channel.submit();
    _pending++;
  }

  Future<void> writeSingle(Uint8List bytes, {void Function(Exception error)? onError, void Function()? onDone}) async {
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing) return Future.error(TransportClosedException.forClient());
    if (onError != null) _outboundErrorHandlers[bufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    _channel.write(bytes, bufferId, transportEventWrite | transportEventClient, timeout: _writeTimeout);
    _channel.submit();
    _pending++;
  }

  Future<void> writeMany(List<Uint8List> bytes, {bool linked = true, void Function(Exception error)? onError, void Function()? onDone}) async {
    final bufferIds = await _buffers.allocateArray(bytes.length);
    if (_closing) return Future.error(TransportClosedException.forClient());
    final lastBufferId = bufferIds.last;
    for (var index = 0; index < bytes.length - 1; index++) {
      final bufferId = bufferIds[index];
      _channel.write(
        bytes[index],
        bufferId,
        transportEventWrite | transportEventClient,
        sqeFlags: linked ? ringIosqeIoLink : 0,
        timeout: _writeTimeout,
      );
      if (onError != null) _outboundErrorHandlers[bufferId] = onError;
      if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    }
    _channel.write(
      bytes.last,
      lastBufferId,
      transportEventWrite | transportEventClient,
      timeout: _writeTimeout,
    );
    if (onError != null) _outboundErrorHandlers[lastBufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[lastBufferId] = onDone;
    _channel.submit();
    _pending += bytes.length;
  }

  Future<void> receive({TransportDatagramMessageFlag? flags}) async {
    flags = flags ?? TransportDatagramMessageFlag.trunc;
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing) return Future.error(TransportClosedException.forClient());
    _channel.receiveMessage(
      bufferId,
      _pointer.ref.family,
      flags.flag,
      transportEventReceiveMessage | transportEventClient,
      timeout: _readTimeout,
    );
    _channel.submit();
    _pending++;
  }

  Future<void> sendSingle(
    Uint8List bytes, {
    TransportDatagramMessageFlag? flags,
    void Function(Exception error)? onError,
    void Function()? onDone,
  }) async {
    flags = flags ?? TransportDatagramMessageFlag.trunc;
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing) return Future.error(TransportClosedException.forClient());
    if (onError != null) _outboundErrorHandlers[bufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    _channel.sendMessage(
      bytes,
      bufferId,
      _pointer.ref.family,
      _destination,
      flags.flag,
      transportEventSendMessage | transportEventClient,
      timeout: _writeTimeout,
    );
    _channel.submit();
    _pending++;
  }

  Future<void> sendMany(
    List<Uint8List> bytes, {
    TransportDatagramMessageFlag? flags,
    bool linked = false,
    void Function(Exception error)? onError,
    void Function()? onDone,
  }) async {
    flags = flags ?? TransportDatagramMessageFlag.trunc;
    final bufferIds = await _buffers.allocateArray(bytes.length);
    if (_closing) return Future.error(TransportClosedException.forClient());
    final lastBufferId = bufferIds.last;
    for (var index = 0; index < bytes.length - 1; index++) {
      final bufferId = bufferIds[index];
      _channel.sendMessage(
        bytes[index],
        bufferId,
        _pointer.ref.family,
        _destination,
        flags.flag,
        transportEventSendMessage | transportEventClient,
        sqeFlags: linked ? ringIosqeIoLink : 0,
        timeout: _writeTimeout,
      );
      if (onError != null) _outboundErrorHandlers[bufferId] = onError;
      if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    }
    _channel.sendMessage(
      bytes.last,
      lastBufferId,
      _pointer.ref.family,
      _destination,
      flags.flag,
      transportEventSendMessage | transportEventClient,
      sqeFlags: linked ? ringIosqeIoLink : 0,
      timeout: _writeTimeout,
    );
    if (onError != null) _outboundErrorHandlers[lastBufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[lastBufferId] = onDone;
    _channel.submit();
    _pending += bytes.length;
  }

  @inline
  Future<TransportClientChannel> connect() {
    if (_closing) return Future.error(TransportClosedException.forClient());
    transport_connect(_workerPointer, _pointer, _connectTimeout!);
    _channel.submit();
    _pending++;
    return _connector.future.then((_) => this);
  }

  void notifyConnect(int fd, int result) {
    _pending--;
    if (_active) {
      if (_pending == 0 && _closing) {
        _active = false;
        _closer.complete();
      }
      if (result == 0) {
        _connector.complete();
        return;
      }
      if (result == -SystemErrors.ECANCELED.code) {
        _connector.completeError(TransportCanceledException(TransportEvent.connect));
        return;
      }
      _connector.completeError(
        TransportInternalException(
          event: TransportEvent.connect,
          code: result,
        ),
      );
      return;
    }
    if (_pending == 0 && !_closer.isCompleted) _closer.complete();
    _connector.completeError(TransportClosedException.forClient());
  }

  void notifyData(int bufferId, int result, int event) {
    _pending--;
    if (_active) {
      if (_pending == 0 && _closing) {
        _active = false;
        _closer.complete();
      }
      if (event == transportEventRead) {
        if (result > 0) {
          _buffers.setLength(bufferId, result);
          _inboundEvents.add(_payloadPool.getPayload(bufferId, _buffers.read(bufferId)));
          return;
        }
        _buffers.release(bufferId);
        if (result < 0) {
          _inboundEvents.addError(createTransportException(TransportEvent.clientEvent(event), result));
        }
        unawaited(close());
        return;
      }
      if (event == transportEventReceiveMessage) {
        if (result > 0) {
          _buffers.setLength(bufferId, result);
          _inboundEvents.add(_payloadPool.getPayload(bufferId, _buffers.read(bufferId)));
          return;
        }
        _buffers.release(bufferId);
        _inboundEvents.addError(createTransportException(TransportEvent.clientEvent(event), result));
        return;
      }
      if (event == transportEventWrite) {
        _buffers.release(bufferId);
        if (result > 0) {
          _outboundDoneHandlers.remove(bufferId)?.call();
          return;
        }
        _outboundErrorHandlers.remove(bufferId)?.call(createTransportException(TransportEvent.clientEvent(event), result));
        return;
      }
      if (event == transportEventSendMessage) {
        _buffers.release(bufferId);
        if (result > 0) {
          _outboundDoneHandlers.remove(bufferId)?.call();
          return;
        }
        _outboundErrorHandlers.remove(bufferId)?.call(createTransportException(TransportEvent.clientEvent(event), result));
        return;
      }
      _buffers.release(bufferId);
      return;
    }
    _buffers.release(bufferId);
    if (_pending == 0 && !_closer.isCompleted) _closer.complete();
  }

  Future<void> close({Duration? gracefulTimeout}) async {
    if (_closing) {
      if (!_closer.isCompleted) {
        if (_pending > 0) await _closer.future;
      }
      return;
    }
    _closing = true;
    if (_pending > 0) {
      if (gracefulTimeout == null) {
        _active = false;
        transport_cancel_by_fd(_workerPointer, _pointer.ref.fd).systemCheck();
        await _closer.future;
      }
      if (gracefulTimeout != null) {
        await _closer.future.timeout(
          gracefulTimeout,
          onTimeout: () async {
            _active = false;
            transport_cancel_by_fd(_workerPointer, _pointer.ref.fd).systemCheck();
            await _closer.future;
          },
        );
      }
    }
    _active = false;
    if (_inboundEvents.hasListener) await _inboundEvents.close();
    _channel.close();
    _registry.remove(_pointer.ref.fd);
    transport_client_destroy(_pointer);
  }

  @visibleForTesting
  TransportClientRegistry get registry => _registry;
}

class TransportClientConnectionPool {
  final List<TransportClientConnection> _clients;
  var _next = 0;

  List<TransportClientConnection> get clients => _clients;

  TransportClientConnectionPool(this._clients);

  @inline
  TransportClientConnection select() {
    final provider = _clients[_next];
    if (++_next == _clients.length) _next = 0;
    return provider;
  }

  @inline
  void forEach(FutureOr<void> Function(TransportClientConnection provider) action) => _clients.forEach(action);

  @inline
  int count() => _clients.length;

  @inline
  Future<void> close({Duration? gracefulTimeout}) => Future.wait(_clients.toList().map((provider) => provider.close(gracefulTimeout: gracefulTimeout)));
}
