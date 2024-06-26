import 'dart:typed_data';

import 'package:memory/memory.dart';

class TransportPayloadPool {
  final MemoryStaticBuffers _buffers;
  final _payloads = <TransportPayload>[];

  TransportPayloadPool(this._buffers) {
    for (var bufferId = 0; bufferId < _buffers.capacity; bufferId++) {
      _payloads.add(TransportPayload(bufferId, this));
    }
  }

  @inline
  TransportPayload getPayload(int bufferId, Uint8List bytes) {
    final payload = _payloads[bufferId];
    payload._bytes = bytes;
    return payload;
  }

  @inline
  void release(int bufferId) => _buffers.release(bufferId);
}

class TransportPayload {
  late Uint8List _bytes;
  final int _bufferId;
  final TransportPayloadPool _pool;

  Uint8List get bytes => _bytes;

  TransportPayload(this._bufferId, this._pool);

  @inline
  void release() => _pool.release(_bufferId);

  @inline
  Uint8List takeBytes({bool release = true}) {
    final result = Uint8List.fromList(bytes);
    if (release) this.release();
    return result;
  }

  @inline
  List<int> toBytes({bool release = true}) {
    final result = _bytes.toList();
    if (release) this.release();
    return result;
  }
}
