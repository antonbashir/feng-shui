import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import '../bindings.dart';
import '../channel.dart';
import '../constants.dart';
import '../exception.dart';
import '../payload.dart';
import 'provider.dart';
import 'registry.dart';
import 'responder.dart';

abstract class TransportServer {
  Future<void> close({Duration? gracefulTimeout});
}

class TransportServerConnectionChannel {
  final _closer = Completer();
  final _inboundEvents = StreamController<TransportPayload>();
  final _outboundDoneHandlers = <int, void Function()>{};
  final _outboundErrorHandlers = <int, void Function(Exception error)>{};

  final int? _readTimeout;
  final int? _writeTimeout;
  final TransportChannel channel;
  final Pointer<transport> _workerPointer;
  final TransportServerChannel _server;
  final MemoryStaticBuffers _buffers;
  final TransportPayloadPool _payloadPool;
  final int _fd;

  var _active = true;
  var _closing = false;
  var _pending = 0;

  bool get active => !_closing;
  Stream<TransportPayload> get inbound => _inboundEvents.stream;

  TransportServerConnectionChannel(
    this._server,
    this._buffers,
    this._fd,
    this._payloadPool,
    this._readTimeout,
    this._writeTimeout,
    this.channel,
    this._workerPointer,
  );

  Future<void> read() async {
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing || _server._closing) return Future.error(TransportClosedException.forServer());
    channel.read(bufferId, transportEventRead | transportEventServer, timeout: _readTimeout);
    channel.submit();
    _pending++;
  }

  Future<void> writeSingle(Uint8List bytes, {void Function(Exception error)? onError, void Function()? onDone}) async {
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing || _server._closing) return Future.error(TransportClosedException.forServer());
    if (onError != null) _outboundErrorHandlers[bufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    channel.write(bytes, bufferId, transportEventWrite | transportEventServer, timeout: _writeTimeout);
    channel.submit();
    _pending++;
  }

  Future<void> writeMany(List<Uint8List> bytes, {bool linked = true, void Function(Exception error)? onError, void Function()? onDone}) async {
    final bufferIds = await _buffers.allocateArray(bytes.length);
    if (_closing || _server._closing) return Future.error(TransportClosedException.forServer());
    final lastBufferId = bufferIds.last;
    for (var index = 0; index < bytes.length - 1; index++) {
      final bufferId = bufferIds[index];
      channel.write(
        bytes[index],
        bufferId,
        transportEventWrite | transportEventServer,
        sqeFlags: linked ? ringIosqeIoLink : 0,
        timeout: _writeTimeout,
      );
      if (onError != null) _outboundErrorHandlers[bufferId] = onError;
      if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    }
    channel.write(
      bytes.last,
      lastBufferId,
      transportEventWrite | transportEventServer,
      timeout: _writeTimeout,
    );
    if (onError != null) _outboundErrorHandlers[lastBufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[lastBufferId] = onDone;
    channel.submit();
    _pending += bytes.length;
  }

  void notify(int bufferId, int result, int event) {
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
          _inboundEvents.addError(createTransportException(TransportEvent.serverEvent(event), result));
        }
        unawaited(close());
        return;
      }
      if (event == transportEventWrite) {
        _buffers.release(bufferId);
        if (result > 0) {
          _outboundDoneHandlers.remove(bufferId)?.call();
          return;
        }
        _outboundErrorHandlers.remove(bufferId)?.call(createTransportException(TransportEvent.serverEvent(event), result));
        unawaited(close());
        return;
      }
      _buffers.release(bufferId);
      return;
    }
    _buffers.release(bufferId);
    if (_pending == 0 && _closing && !_closer.isCompleted) _closer.complete();
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
        transport_cancel_by_fd(_workerPointer, _fd);
        await _closer.future;
      }
      if (gracefulTimeout != null) {
        await _closer.future.timeout(
          gracefulTimeout,
          onTimeout: () {
            _active = false;
            transport_cancel_by_fd(_workerPointer, _fd);
            return _closer.future;
          },
        );
      }
    }
    _active = false;
    if (_inboundEvents.hasListener) await _inboundEvents.close();
    _server._removeConnection(_fd);
    system_shutdown_descriptor(_fd);
  }

  Future<void> closeServer({Duration? gracefulTimeout}) => _server.close(gracefulTimeout: gracefulTimeout);
}

class TransportServerChannel implements TransportServer {
  final _closer = Completer();
  final _connections = <int, TransportServerConnectionChannel>{};
  final _inboundEvents = StreamController<TransportServerDatagramResponder>();
  final _outboundErrorHandlers = <int, void Function(Exception error)>{};
  final _outboundDoneHandlers = <int, void Function()>{};

  final TransportChannel? _datagramChannel;
  final Pointer<transport_server> pointer;
  final Pointer<transport> _workerPointer;
  final int? _readTimeout;
  final int? _writeTimeout;
  final MemoryStaticBuffers _buffers;
  final TransportServerRegistry _registry;
  final TransportPayloadPool _payloadPool;
  final TransportServerDatagramResponderPool _datagramResponderPool;

  late void Function(TransportServerConnection connection) _acceptor;

  var _pending = 0;
  var _active = true;
  var _closing = false;

  bool get active => !_closing;
  Stream<TransportServerDatagramResponder> get inbound => _inboundEvents.stream;

  TransportServerChannel(
    this.pointer,
    this._workerPointer,
    this._readTimeout,
    this._writeTimeout,
    this._buffers,
    this._registry,
    this._payloadPool,
    this._datagramResponderPool, {
    TransportChannel? datagramChannel,
  }) : this._datagramChannel = datagramChannel;

  @inline
  void accept(void Function(TransportServerConnection connection) onAccept) {
    if (_closing) throw TransportClosedException.forServer();
    _acceptor = onAccept;
    transport_accept(_workerPointer, pointer);
    executor_submit(_workerPointer.ref.transport_executor);
  }

  Future<void> receive({TransportDatagramMessageFlag? flags}) async {
    flags = flags ?? TransportDatagramMessageFlag.trunc;
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing) return Future.error(TransportClosedException.forServer());
    _datagramChannel!.receiveMessage(
      bufferId,
      pointer.ref.family,
      flags.flag,
      transportEventReceiveMessage | transportEventServer,
      timeout: _readTimeout,
    );
    _datagramChannel.submit();
    _pending++;
  }

  Future<void> respondSingle(
    TransportChannel channel,
    Pointer<sockaddr> destination,
    Uint8List bytes, {
    TransportDatagramMessageFlag? flags,
    void Function(Exception error)? onError,
    void Function()? onDone,
  }) async {
    flags = flags ?? TransportDatagramMessageFlag.trunc;
    final bufferId = _buffers.get() ?? await _buffers.allocate();
    if (_closing) return Future.error(TransportClosedException.forServer());
    if (onError != null) _outboundErrorHandlers[bufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    channel.sendMessage(
      bytes,
      bufferId,
      pointer.ref.family,
      destination,
      flags.flag,
      transportEventSendMessage | transportEventServer,
      timeout: _writeTimeout,
    );
    channel.submit();
    _pending++;
  }

  Future<void> respondMany(
    TransportChannel channel,
    Pointer<sockaddr> destination,
    List<Uint8List> bytes, {
    TransportDatagramMessageFlag? flags,
    bool linked = false,
    void Function(Exception error)? onError,
    void Function()? onDone,
  }) async {
    flags = flags ?? TransportDatagramMessageFlag.trunc;
    final bufferIds = await _buffers.allocateArray(bytes.length);
    if (_closing) return Future.error(TransportClosedException.forServer());
    final lastBufferId = bufferIds.last;
    for (var index = 0; index < bytes.length - 1; index++) {
      final bufferId = bufferIds[index];
      channel.sendMessage(
        bytes[index],
        bufferId,
        pointer.ref.family,
        destination,
        flags.flag,
        transportEventSendMessage | transportEventServer,
        sqeFlags: linked ? ringIosqeIoLink : 0,
        timeout: _writeTimeout,
      );
      if (onError != null) _outboundErrorHandlers[bufferId] = onError;
      if (onDone != null) _outboundDoneHandlers[bufferId] = onDone;
    }
    channel.sendMessage(
      bytes.last,
      lastBufferId,
      pointer.ref.family,
      destination,
      flags.flag,
      transportEventSendMessage | transportEventServer,
      sqeFlags: linked ? ringIosqeIoLink : 0,
      timeout: _writeTimeout,
    );
    if (onError != null) _outboundErrorHandlers[lastBufferId] = onError;
    if (onDone != null) _outboundDoneHandlers[lastBufferId] = onDone;
    channel.submit();
    _pending += bytes.length;
  }

  void notifyDatagram(int bufferId, int result, int event) {
    _pending--;
    if (_active) {
      if (_pending == 0 && _closing) {
        _active = false;
        _closer.complete();
      }
      if (event == transportEventReceiveMessage) {
        if (result > 0) {
          _buffers.setLength(bufferId, result);
          _inboundEvents.add(
            _datagramResponderPool.getDatagramResponder(
              bufferId,
              _buffers.read(bufferId),
              this,
              _datagramChannel!,
              transport_get_datagram_address(_workerPointer, pointer.ref.family, bufferId),
            ),
          );
          return;
        }
        _buffers.release(bufferId);
        _inboundEvents.addError(createTransportException(TransportEvent.serverEvent(event), result));
        return;
      }
      if (event == transportEventSendMessage) {
        _buffers.release(bufferId);
        if (result > 0) {
          _outboundDoneHandlers.remove(bufferId)?.call();
          return;
        }
        _outboundErrorHandlers.remove(bufferId)?.call(createTransportException(TransportEvent.serverEvent(event), result));
        return;
      }
      _buffers.release(bufferId);
      return;
    }
    _buffers.release(bufferId);
    if (_pending == 0 && _closing && !_closer.isCompleted) _closer.complete();
  }

  @inline
  void notifyAccept(int fd) {
    if (_closing) return;
    if (fd > 0) {
      final channel = TransportChannel(_workerPointer, fd, _buffers);
      final connection = TransportServerConnectionChannel(
        this,
        _buffers,
        fd,
        _payloadPool,
        _readTimeout,
        _writeTimeout,
        channel,
        _workerPointer,
      );
      _registry.addConnection(fd, connection);
      _connections[fd] = connection;
      _acceptor(TransportServerConnection(connection));
    }
    transport_accept(_workerPointer, pointer);
  }

  @inline
  bool connectionIsActive(int fd) => _connections[fd]?._closing == false;

  @inline
  void _removeConnection(int fd) {
    _connections.remove(fd);
    _registry.removeConnection(fd);
  }

  @override
  Future<void> close({Duration? gracefulTimeout}) async {
    if (_closing) {
      if (!_closer.isCompleted) {
        if (_pending > 0) await _closer.future;
      }
      return;
    }
    _closing = true;
    await Future.wait(_connections.values.toList().map((connection) => connection.close(gracefulTimeout: gracefulTimeout)));
    if (_pending > 0) {
      if (gracefulTimeout == null) {
        _active = false;
        transport_cancel_by_fd(_workerPointer, pointer.ref.fd);
        await _closer.future;
      }
      if (gracefulTimeout != null) {
        await _closer.future.timeout(
          gracefulTimeout,
          onTimeout: () {
            _active = false;
            transport_cancel_by_fd(_workerPointer, pointer.ref.fd);
            return _closer.future;
          },
        );
      }
    }
    _active = false;
    if (_inboundEvents.hasListener) await _inboundEvents.close();
    _registry.removeServer(pointer.ref.fd);
    system_shutdown_descriptor(pointer.ref.fd);
    transport_server_destroy(pointer);
  }
}
