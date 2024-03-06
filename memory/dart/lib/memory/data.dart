import 'dart:ffi';

import 'package:core/core.dart';

import '../memory/bindings.dart';

class MemorySmallData {
  final Pointer<memory_state> _memory;

  MemorySmallData(this._memory);

  @inline
  Pointer<Void> allocate(int size) => memory_small_data_allocate(_memory.ref.small_data, size);

  @inline
  void free(Pointer<Void> pointer, int size) => memory_small_data_free(_memory.ref.small_data, pointer, size);
}
