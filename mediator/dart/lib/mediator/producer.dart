import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';
import 'declaration.dart';

class MediatorProducerExecutor implements MediatorProducerRegistrat {
  final Map<int, MediatorMethodExecutor> _methods = {};

  final int _id;
  final Pointer<mediator_dart> _mediatorPointer;

  MediatorProducerExecutor(this._id, this._mediatorPointer);

  MediatorMethod register(Pointer<NativeFunction<Void Function(Pointer<mediator_message>)>> pointer) {
    final executor = MediatorMethodExecutor(pointer.address, _id, _mediatorPointer);
    _methods[pointer.address] = executor;
    return executor;
  }

  @inline
  void callback(Pointer<mediator_message> message) => _methods[message.ref.method]?.callback(message);
}

class MediatorMethodExecutor implements MediatorMethod {
  final Map<int, Completer<Pointer<mediator_message>>> _calls = {};
  final int _methodId;
  final int _executorId;
  final Pointer<mediator_dart> _mediator;

  MediatorMethodExecutor(
    this._methodId,
    this._executorId,
    this._mediator,
  );

  @override
  Future<Pointer<mediator_message>> call(int target, Pointer<mediator_message> message) {
    final completer = Completer<Pointer<mediator_message>>();
    message.ref.id = message.address;
    message.ref.owner = _executorId;
    message.ref.method = _methodId;
    _calls[message.address] = completer;
    mediator_dart_call_native(_mediator, target, message);
    return completer.future.then(_onComplete);
  }

  @inline
  void callback(Pointer<mediator_message> message) => _calls[message.ref.id]?.complete(message);

  @inline
  Pointer<mediator_message> _onComplete(Pointer<mediator_message> message) {
    _calls.remove(message.address);
    return message;
  }
}
