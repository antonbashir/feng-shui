import 'dart:ffi';
import 'dart:typed_data';

import 'package:linux_interactor/interactor/extensions.dart';

import 'bindings.dart';
import 'constants.dart';

class StorageSerialization {
  final Pointer<tarantool_factory> _factory;

  StorageSerialization(this._factory);

  @inline
  (Pointer<Char>, int) createString(String source) {
    final units = Uint8List(source.length);
    fastEncodeString(source, units, 0);
    final length = source.length;
    final Pointer<Uint8> result = tarantool_create_string(_factory, length).cast();
    final unitsLength = units.length;
    final Uint8List nativeString = result.asTypedList(unitsLength + 1);
    nativeString.setAll(0, units);
    nativeString[unitsLength] = 0;
    return (result.cast(), length);
  }

  @inline
  void freeString(Pointer<Char> string, int size) => tarantool_free_string(_factory, string, size);
}
