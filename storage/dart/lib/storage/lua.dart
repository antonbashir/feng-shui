import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:memory/memory.dart';

@inline
bool? tarantoolCallExtractBool((Uint8List, void Function()) buffer) {
  final (tuple, cleaner) = buffer;
  final data = ByteData.view(tuple.buffer, tuple.offsetInBytes);
  var offset = 0;
  offset = tupleReadList(data, offset).offset;
  final value = tupleReadBool(data, offset).value;
  cleaner();
  return value;
}

@inline
int? tarantoolCallExtractInt((Uint8List, void Function()) buffer) {
  final (tuple, cleaner) = buffer;
  final data = ByteData.view(tuple.buffer, tuple.offsetInBytes);
  var offset = 0;
  offset = tupleReadList(data, offset).offset;
  final value = tupleReadInt(data, offset).value;
  cleaner();
  return value;
}

@inline
double? tarantoolCallExtractDouble((Uint8List, void Function()) buffer) {
  final (tuple, cleaner) = buffer;
  final data = ByteData.view(tuple.buffer, tuple.offsetInBytes);
  var offset = 0;
  offset = tupleReadList(data, offset).offset;
  final value = tupleReadDouble(data, offset).value;
  cleaner();
  return value;
}

@inline
String? tarantoolCallExtractString((Uint8List, void Function()) buffer) {
  final (tuple, cleaner) = buffer;
  final data = ByteData.view(tuple.buffer, tuple.offsetInBytes);
  var offset = 0;
  offset = tupleReadList(data, offset).offset;
  final value = tupleReadString(tuple, data, offset).value;
  cleaner();
  return value;
}

@inline
Uint8List tarantoolCallExtractBinary((Uint8List, void Function()) buffer) {
  final (tuple, cleaner) = buffer;
  final data = ByteData.view(tuple.buffer, tuple.offsetInBytes);
  var offset = 0;
  offset = tupleReadList(data, offset).offset;
  final value = Uint8List.fromList(tupleReadBinary(tuple, data, offset).value);
  cleaner();
  return value;
}

@inline
List<T?> tarantoolCallExtractList<T>(
  (Uint8List, void Function()) buffer,
  ({T? value, int offset}) Function(Uint8List buffer, ByteData data, int offset) mapper,
) {
  final (tuple, cleaner) = buffer;
  final data = ByteData.view(tuple.buffer, tuple.offsetInBytes);
  var offset = 0;
  offset = tupleReadList(data, offset).offset;
  final value = tupleReadList(data, offset);
  offset = value.offset;
  List<T?> results = [];
  for (var i = 0; i < value.length; i++) {
    final item = mapper(tuple, data, offset);
    offset = item.offset;
    results.add(item.value);
  }
  cleaner();
  return results;
}

@inline
Map<K, V?> tarantoolCallExtractMap<K, V>(
  (Uint8List, void Function()) buffer,
  ({K key, int offset}) Function(Uint8List buffer, ByteData data, int offset) keyMapper,
  ({V? value, int offset}) Function(Uint8List buffer, ByteData data, int offset) valueMapper,
) {
  final (tuple, cleaner) = buffer;
  final data = ByteData.view(tuple.buffer, tuple.offsetInBytes);
  var offset = 0;
  offset = tupleReadList(data, offset).offset;
  final value = tupleReadMap(data, offset);
  offset = value.offset;
  Map<K, V?> results = {};
  for (var i = 0; i < value.length; i++) {
    final key = keyMapper(tuple, data, offset);
    offset = key.offset;
    final value = valueMapper(tuple, data, offset);
    offset = value.offset;
    results[key.key] = value.value;
  }
  cleaner();
  return results;
}
