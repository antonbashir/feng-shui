import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:executor/executor/broker.dart';
import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'factory.dart';
import 'schema.dart';
import 'strings.dart';

class StorageProducer implements ExecutorProducer {
  final Pointer<storage_box> _box;

  StorageProducer(this._box);

  late final ExecutorMethod evaluate;
  late final ExecutorMethod call;
  late final ExecutorMethod freeOutputBuffer;
  late final ExecutorMethod iteratorNextSingle;
  late final ExecutorMethod iteratorNextMany;
  late final ExecutorMethod iteratorDestroy;
  late final ExecutorMethod spaceIdByName;
  late final ExecutorMethod spaceCount;
  late final ExecutorMethod spaceLength;
  late final ExecutorMethod spaceIterator;
  late final ExecutorMethod spaceInsertSingle;
  late final ExecutorMethod spaceInsertMany;
  late final ExecutorMethod spacePutSingle;
  late final ExecutorMethod spacePutMany;
  late final ExecutorMethod spaceDeleteSingle;
  late final ExecutorMethod spaceDeleteMany;
  late final ExecutorMethod spaceUpdateSingle;
  late final ExecutorMethod spaceUpdateMany;
  late final ExecutorMethod spaceSelect;
  late final ExecutorMethod spaceGet;
  late final ExecutorMethod spaceMin;
  late final ExecutorMethod spaceMax;
  late final ExecutorMethod spaceTruncate;
  late final ExecutorMethod spaceUpsert;
  late final ExecutorMethod indexCount;
  late final ExecutorMethod indexLength;
  late final ExecutorMethod indexIterator;
  late final ExecutorMethod indexGet;
  late final ExecutorMethod indexMax;
  late final ExecutorMethod indexMin;
  late final ExecutorMethod indexUpdateSingle;
  late final ExecutorMethod indexUpdateMany;
  late final ExecutorMethod indexSelect;
  late final ExecutorMethod indexIdByName;

  @override
  void initialize(ExecutorProducerRegistrat registrat) {
    evaluate = registrat.register(Pointer.fromAddress(_box.ref.storage_evaluate_address));
    call = registrat.register(Pointer.fromAddress(_box.ref.storage_call_address));
    iteratorNextSingle = registrat.register(Pointer.fromAddress(_box.ref.storage_iterator_next_single_address));
    iteratorNextMany = registrat.register(Pointer.fromAddress(_box.ref.storage_iterator_next_many_address));
    iteratorDestroy = registrat.register(Pointer.fromAddress(_box.ref.storage_iterator_destroy_address));
    freeOutputBuffer = registrat.register(Pointer.fromAddress(_box.ref.storage_free_output_buffer_address));
    spaceIdByName = registrat.register(Pointer.fromAddress(_box.ref.storage_space_id_by_name_address));
    spaceCount = registrat.register(Pointer.fromAddress(_box.ref.storage_space_count_address));
    spaceLength = registrat.register(Pointer.fromAddress(_box.ref.storage_space_length_address));
    spaceIterator = registrat.register(Pointer.fromAddress(_box.ref.storage_space_iterator_address));
    spaceInsertSingle = registrat.register(Pointer.fromAddress(_box.ref.storage_space_insert_single_address));
    spaceInsertMany = registrat.register(Pointer.fromAddress(_box.ref.storage_space_insert_many_address));
    spacePutSingle = registrat.register(Pointer.fromAddress(_box.ref.storage_space_put_single_address));
    spacePutMany = registrat.register(Pointer.fromAddress(_box.ref.storage_space_put_many_address));
    spaceDeleteSingle = registrat.register(Pointer.fromAddress(_box.ref.storage_space_delete_single_address));
    spaceDeleteMany = registrat.register(Pointer.fromAddress(_box.ref.storage_space_delete_many_address));
    spaceUpdateSingle = registrat.register(Pointer.fromAddress(_box.ref.storage_space_update_single_address));
    spaceUpdateMany = registrat.register(Pointer.fromAddress(_box.ref.storage_space_update_many_address));
    spaceSelect = registrat.register(Pointer.fromAddress(_box.ref.storage_space_select_address));
    spaceGet = registrat.register(Pointer.fromAddress(_box.ref.storage_space_get_address));
    spaceMin = registrat.register(Pointer.fromAddress(_box.ref.storage_space_min_address));
    spaceMax = registrat.register(Pointer.fromAddress(_box.ref.storage_space_max_address));
    spaceTruncate = registrat.register(Pointer.fromAddress(_box.ref.storage_space_truncate_address));
    spaceUpsert = registrat.register(Pointer.fromAddress(_box.ref.storage_space_upsert_address));
    indexCount = registrat.register(Pointer.fromAddress(_box.ref.storage_index_count_address));
    indexLength = registrat.register(Pointer.fromAddress(_box.ref.storage_index_length_address));
    indexIterator = registrat.register(Pointer.fromAddress(_box.ref.storage_index_iterator_address));
    indexGet = registrat.register(Pointer.fromAddress(_box.ref.storage_index_get_address));
    indexMax = registrat.register(Pointer.fromAddress(_box.ref.storage_index_max_address));
    indexMin = registrat.register(Pointer.fromAddress(_box.ref.storage_index_min_address));
    indexUpdateSingle = registrat.register(Pointer.fromAddress(_box.ref.storage_index_update_single_address));
    indexUpdateMany = registrat.register(Pointer.fromAddress(_box.ref.storage_index_update_many_address));
    indexSelect = registrat.register(Pointer.fromAddress(_box.ref.storage_index_select_address));
    indexIdByName = registrat.register(Pointer.fromAddress(_box.ref.storage_index_id_by_name_address));
  }
}

class StorageConsumer implements ExecutorConsumer {
  StorageConsumer();

  @override
  List<ExecutorCallback> callbacks() => [];
}

class Storage {
  final Pointer<storage_box> _box;
  final ExecutorBroker _broker;

  late final StorageSchema _schema;
  late final int _descriptor;
  late final MemoryTuples _tuples;
  late final StorageProducer _producer;
  late final Pointer<storage_factory> _nativeFactory;
  late final StorageStrings _strings;
  late final StorageFactory _factory;

  Storage(this._box, this._broker);

  StorageSchema get schema => _schema;
  MemoryTuples get tuples => _tuples;

  Future<void> initialize() async {
    _broker.initialize();
    _descriptor = storage_executor_descriptor();
    _nativeFactory = calloc<storage_factory>(sizeOf<storage_factory>());
    using((Arena arena) {
      final configuration = arena<storage_factory_configuration>();
      configuration.ref.quota_size = MemoryDefaults.memory.quotaSize;
      configuration.ref.preallocation_size = MemoryDefaults.memory.preallocationSize;
      configuration.ref.slab_size = MemoryDefaults.memory.slabSize;
      storage_factory_initialize(_nativeFactory, configuration);
    });
    _broker.consumer(StorageConsumer());
    _producer = _broker.producer(StorageProducer(_box));
    _tuples = context().tuples();
    _strings = StorageStrings(_nativeFactory);
    _factory = StorageFactory(_strings);
    _schema = StorageSchema(_descriptor, this, _tuples, _producer, _factory);
    _broker.activate();
  }

  void stop() => _broker.deactivate();

  Future<void> destroy() async {
    storage_factory_destroy(_nativeFactory);
    calloc.free(_nativeFactory.cast());
  }

  @inline
  Future<void> startBackup() => evaluate(LuaExpressions.startBackup);

  @inline
  Future<void> stopBackup() => evaluate(LuaExpressions.stopBackup);

  @inline
  Future<void> configure(StorageConfiguration configuration) => evaluate(configuration.format());

  @inline
  Future<void> boot(StorageLaunchConfiguration configuration) {
    final size = configuration.tupleSize;
    final small = _tuples.wrapSmall(size);
    configuration.serialize(small.buffer, small.data, 0);
    return call(LuaExpressions.boot, input: small.tuple, inputSize: size);
  }

  @inline
  Future<(Uint8List, void Function())> evaluate(String expression, {Pointer<Uint8>? input, int inputSize = 0}) {
    if (input != null) {
      return _producer.evaluate(_descriptor, _factory.createEvaluate(expression, input, inputSize)).then(_parseLuaEvaluate);
    }
    final (:Pointer<Uint8> value, :int size) = _tuples.emptyList;
    return _producer.evaluate(_descriptor, _factory.createEvaluate(expression, value, size)).then(_parseLuaEvaluate);
  }

  @inline
  Future<(Uint8List, void Function())> call(String function, {Pointer<Uint8>? input, int inputSize = 0}) {
    if (input != null) {
      return _producer.call(_descriptor, _factory.createCall(function, input, inputSize)).then(_parseLuaCall);
    }

    final (:Pointer<Uint8> value, :int size) = _tuples.emptyList;
    return _producer.call(_descriptor, _factory.createCall(function, value, size)).then(_parseLuaCall);
  }

  @inline
  Future<void> file(File file) => file.readAsString().then(evaluate);

  @inline
  Future<void> require(String module) => evaluate(LuaExpressions.require(module));

  @inline
  (Uint8List, void Function()) _parseLuaEvaluate(Pointer<executor_task> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = buffer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseEvaluate(message.getInputObject());
    return (
      result,
      () => _producer
          .freeOutputBuffer(
              _descriptor,
              _factory.createMessage()
                ..inputInt = buffer.address
                ..inputSize = bufferSize)
          .then(_factory.releaseMessage)
    );
  }

  @inline
  (Uint8List, void Function()) _parseLuaCall(Pointer<executor_task> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = message.outputPointer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseCall(message.getInputObject());
    return (
      result,
      () => _producer
          .freeOutputBuffer(
              _descriptor,
              _factory.createMessage()
                ..inputInt = buffer.address
                ..inputSize = bufferSize)
          .then(_factory.releaseMessage)
    );
  }
}
