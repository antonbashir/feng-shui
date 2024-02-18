// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint, unused_field
import 'dart:ffi' as ffi;

@ffi.Native<
        ffi.Int Function(
            ffi.Pointer<memory_dart>, ffi.Pointer<memory_dart_configuration>)>(
    symbol: 'memory_dart_initialize', assetId: 'memory-bindings', isLeaf: true)
external int memory_dart_initialize(
  ffi.Pointer<memory_dart> memory,
  ffi.Pointer<memory_dart_configuration> configuration,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<memory_dart>)>(
    symbol: 'memory_dart_static_buffers_get',
    assetId: 'memory-bindings',
    isLeaf: true)
external int memory_dart_static_buffers_get(
  ffi.Pointer<memory_dart> memory,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<memory_dart>, ffi.Int32)>(
    symbol: 'memory_dart_static_buffers_release',
    assetId: 'memory-bindings',
    isLeaf: true)
external void memory_dart_static_buffers_release(
  ffi.Pointer<memory_dart> memory,
  int buffer_id,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<memory_dart>)>(
    symbol: 'memory_dart_static_buffers_available',
    assetId: 'memory-bindings',
    isLeaf: true)
external int memory_dart_static_buffers_available(
  ffi.Pointer<memory_dart> memory,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<memory_dart>)>(
    symbol: 'memory_dart_static_buffers_used',
    assetId: 'memory-bindings',
    isLeaf: true)
external int memory_dart_static_buffers_used(
  ffi.Pointer<memory_dart> memory,
);

@ffi.Native<ffi.Pointer<iovec> Function(ffi.Pointer<memory_dart>)>(
    symbol: 'memory_dart_static_buffers_inner',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<iovec> memory_dart_static_buffers_inner(
  ffi.Pointer<memory_dart> memory,
);

@ffi.Native<
        ffi.Pointer<memory_input_buffer> Function(
            ffi.Pointer<memory_dart>, ffi.Size)>(
    symbol: 'memory_dart_io_buffers_allocate_input',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<memory_input_buffer> memory_dart_io_buffers_allocate_input(
  ffi.Pointer<memory_dart> memory,
  int initial_capacity,
);

@ffi.Native<
        ffi.Pointer<memory_output_buffer> Function(
            ffi.Pointer<memory_dart>, ffi.Size)>(
    symbol: 'memory_dart_io_buffers_allocate_output',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<memory_output_buffer>
    memory_dart_io_buffers_allocate_output(
  ffi.Pointer<memory_dart> memory,
  int initial_capacity,
);

@ffi.Native<
        ffi.Void Function(
            ffi.Pointer<memory_dart>, ffi.Pointer<memory_input_buffer>)>(
    symbol: 'memory_dart_io_buffers_free_input',
    assetId: 'memory-bindings',
    isLeaf: true)
external void memory_dart_io_buffers_free_input(
  ffi.Pointer<memory_dart> memory,
  ffi.Pointer<memory_input_buffer> buffer,
);

@ffi.Native<
        ffi.Void Function(
            ffi.Pointer<memory_dart>, ffi.Pointer<memory_output_buffer>)>(
    symbol: 'memory_dart_io_buffers_free_output',
    assetId: 'memory-bindings',
    isLeaf: true)
external void memory_dart_io_buffers_free_output(
  ffi.Pointer<memory_dart> memory,
  ffi.Pointer<memory_output_buffer> buffer,
);

@ffi.Native<
        ffi.Pointer<ffi.Uint8> Function(
            ffi.Pointer<memory_input_buffer>, ffi.Size)>(
    symbol: 'memory_dart_input_buffer_reserve',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_input_buffer_reserve(
  ffi.Pointer<memory_input_buffer> buffer,
  int size,
);

@ffi.Native<
        ffi.Pointer<ffi.Uint8> Function(
            ffi.Pointer<memory_input_buffer>, ffi.Size)>(
    symbol: 'memory_dart_input_buffer_allocate',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_input_buffer_allocate(
  ffi.Pointer<memory_input_buffer> buffer,
  int size,
);

@ffi.Native<
        ffi.Pointer<ffi.Uint8> Function(
            ffi.Pointer<memory_input_buffer>, ffi.Size, ffi.Size)>(
    symbol: 'memory_dart_input_buffer_allocate_reserve',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_input_buffer_allocate_reserve(
  ffi.Pointer<memory_input_buffer> buffer,
  int delta,
  int size,
);

@ffi.Native<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<memory_input_buffer>)>(
    symbol: 'memory_dart_input_buffer_read_position',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_input_buffer_read_position(
  ffi.Pointer<memory_input_buffer> buffer,
);

@ffi.Native<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<memory_input_buffer>)>(
    symbol: 'memory_dart_input_buffer_write_position',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_input_buffer_write_position(
  ffi.Pointer<memory_input_buffer> buffer,
);

@ffi.Native<
        ffi.Pointer<ffi.Uint8> Function(
            ffi.Pointer<memory_output_buffer>, ffi.Size)>(
    symbol: 'memory_dart_output_buffer_reserve',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_output_buffer_reserve(
  ffi.Pointer<memory_output_buffer> buffer,
  int size,
);

@ffi.Native<
        ffi.Pointer<ffi.Uint8> Function(
            ffi.Pointer<memory_output_buffer>, ffi.Size)>(
    symbol: 'memory_dart_output_buffer_allocate',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_output_buffer_allocate(
  ffi.Pointer<memory_output_buffer> buffer,
  int size,
);

@ffi.Native<
        ffi.Pointer<ffi.Uint8> Function(
            ffi.Pointer<memory_output_buffer>, ffi.Size, ffi.Size)>(
    symbol: 'memory_dart_output_buffer_allocate_reserve',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Uint8> memory_dart_output_buffer_allocate_reserve(
  ffi.Pointer<memory_output_buffer> buffer,
  int delta,
  int size,
);

@ffi.Native<ffi.Pointer<iovec> Function(ffi.Pointer<memory_output_buffer>)>(
    symbol: 'memory_dart_output_buffer_content',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<iovec> memory_dart_output_buffer_content(
  ffi.Pointer<memory_output_buffer> buffer,
);

@ffi.Native<
        ffi.Pointer<memory_dart_structure_pool> Function(
            ffi.Pointer<memory_dart>, ffi.Size)>(
    symbol: 'memory_dart_structure_pool_create',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<memory_dart_structure_pool>
    memory_dart_structure_pool_create(
  ffi.Pointer<memory_dart> memory,
  int size,
);

@ffi.Native<
        ffi.Pointer<ffi.Void> Function(
            ffi.Pointer<memory_dart_structure_pool>)>(
    symbol: 'memory_dart_structure_allocate',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Void> memory_dart_structure_allocate(
  ffi.Pointer<memory_dart_structure_pool> pool,
);

@ffi.Native<
        ffi.Void Function(
            ffi.Pointer<memory_dart_structure_pool>, ffi.Pointer<ffi.Void>)>(
    symbol: 'memory_dart_structure_free',
    assetId: 'memory-bindings',
    isLeaf: true)
external void memory_dart_structure_free(
  ffi.Pointer<memory_dart_structure_pool> pool,
  ffi.Pointer<ffi.Void> pointer,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<memory_dart_structure_pool>)>(
    symbol: 'memory_dart_structure_pool_destroy',
    assetId: 'memory-bindings',
    isLeaf: true)
external void memory_dart_structure_pool_destroy(
  ffi.Pointer<memory_dart_structure_pool> pool,
);

@ffi.Native<ffi.Size Function(ffi.Pointer<memory_dart_structure_pool>)>(
    symbol: 'memory_dart_structure_pool_size',
    assetId: 'memory-bindings',
    isLeaf: true)
external int memory_dart_structure_pool_size(
  ffi.Pointer<memory_dart_structure_pool> pool,
);

@ffi.Native<ffi.Pointer<ffi.Void> Function(ffi.Pointer<memory_dart>, ffi.Size)>(
    symbol: 'memory_dart_small_data_allocate',
    assetId: 'memory-bindings',
    isLeaf: true)
external ffi.Pointer<ffi.Void> memory_dart_small_data_allocate(
  ffi.Pointer<memory_dart> memory,
  int size,
);

@ffi.Native<
        ffi.Void Function(
            ffi.Pointer<memory_dart>, ffi.Pointer<ffi.Void>, ffi.Size)>(
    symbol: 'memory_dart_small_data_free',
    assetId: 'memory-bindings',
    isLeaf: true)
external void memory_dart_small_data_free(
  ffi.Pointer<memory_dart> memory,
  ffi.Pointer<ffi.Void> pointer,
  int size,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<memory_dart>)>(
    symbol: 'memory_dart_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_dart_destroy(
  ffi.Pointer<memory_dart> memory,
);

@ffi.Native<ffi.Uint64 Function(ffi.Pointer<ffi.Char>, ffi.Uint64)>(
    symbol: 'memory_dart_tuple_next', assetId: 'memory-bindings', isLeaf: true)
external int memory_dart_tuple_next(
  ffi.Pointer<ffi.Char> buffer,
  int offset,
);

final class iovec extends ffi.Struct {
  external ffi.Pointer<ffi.Void> iov_base;

  @ffi.Size()
  external int iov_len;
}

final class memory_static_buffers extends ffi.Opaque {}

final class memory_io_buffers extends ffi.Opaque {}

final class memory_small_data extends ffi.Opaque {}

final class memory extends ffi.Opaque {}

final class memory_structure_pool extends ffi.Opaque {}

final class memory_dart_configuration extends ffi.Struct {
  @ffi.Size()
  external int quota_size;

  @ffi.Size()
  external int preallocation_size;

  @ffi.Size()
  external int slab_size;

  @ffi.Size()
  external int static_buffers_capacity;

  @ffi.Size()
  external int static_buffer_size;
}

final class memory_dart extends ffi.Struct {
  external ffi.Pointer<memory_dart_static_buffers> static_buffers;

  external ffi.Pointer<memory_dart_io_buffers> io_buffers;

  external ffi.Pointer<memory_dart_small_data> small_data;

  external ffi.Pointer<memory_dart_memory> memory;
}

typedef memory_dart_static_buffers = memory_static_buffers;
typedef memory_dart_io_buffers = memory_io_buffers;
typedef memory_dart_small_data = memory_small_data;
typedef memory_dart_memory = memory;

final class memory_input_buffer extends ffi.Opaque {}

final class memory_output_buffer extends ffi.Opaque {}

final class memory_dart_structure_pool extends ffi.Opaque {}