import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:executor_test/test/consumer.dart';
import 'package:executor_test/test/producer.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

import 'bindings.dart';

void _execute(FutureOr<void> Function() test) => launch(
      () => [
        CoreModule(),
        MemoryModule(),
        ExecutorModule(),
      ],
      () async {
        SystemLibrary.loadByPath("${Directory(path.dirname(Platform.script.toFilePath())).parent.path}/assets/libexecutor_test.so", "executor_test");
        await test();
      },
    );

void testThreadingNative() {
  test(
    "[isolates]dart(bytes) <-> [threads]native(bytes)",
    () => _execute(() async {
      final messages = 16;
      final isolates = 4;
      final threads = 8;

      if (!test_threading_initialize(threads, isolates, messages * isolates)) {
        fail("native thread failed ");
      }

      final spawnedIsolates = <Future<Isolate>>[];
      final exitPorts = <ReceivePort>[];
      final errorPorts = <ReceivePort>[];

      for (var isolateNumber = 0; isolateNumber < isolates; isolateNumber++) {
        final exitPort = ReceivePort();
        exitPorts.add(exitPort);

        final errorPort = ReceivePort();
        errorPorts.add(errorPort);

        final isolate = Isolate.spawn<List<dynamic>>(
          _callNativeIsolate,
          debugName: "_callNativeIsolate-${isolateNumber}",
          onError: errorPort.sendPort,
          [messages, threads, exitPort.sendPort],
        );

        spawnedIsolates.add(isolate);
      }

      errorPorts.forEach(
        (element) => element.listen((message) {
          exitPorts.forEach((port) => port.close());
          errorPorts.forEach((port) => port.close());
          fail(message.toString());
        }),
      );

      await Future.wait(spawnedIsolates);
      while (test_threading_call_native_check() != messages * isolates * threads) await Future.delayed(Duration(milliseconds: 1));
      await Future.wait(exitPorts.map((port) => port.first));

      exitPorts.forEach((port) => port.close());
      errorPorts.forEach((port) => port.close());

      test_threading_destroy();
    }),
  );
}

void testThreadingDart() {
  test(
    "[threads]native(bytes) <-> [isolates]dart(bytes)",
    () => _execute(() async {
      final messages = 16;
      final isolates = 4;
      final threads = 8;

      if (!test_threading_initialize(threads, isolates, messages * isolates)) {
        fail("native thread failed ");
      }

      final spawnedIsolates = <Future<Isolate>>[];
      final descriptorPorts = <ReceivePort>[];
      final exitPorts = <ReceivePort>[];
      final errorPorts = <ReceivePort>[];

      for (var isolateNumber = 0; isolateNumber < isolates; isolateNumber++) {
        final descriptorPort = ReceivePort();
        descriptorPorts.add(descriptorPort);

        final exitPort = ReceivePort();
        exitPorts.add(exitPort);

        final errorPort = ReceivePort();
        errorPorts.add(errorPort);

        final isolate = Isolate.spawn<List<dynamic>>(
          _callDartIsolate,
          debugName: "_callDartIsolate-${isolateNumber}",
          onError: errorPort.sendPort,
          [messages * threads, descriptorPort.sendPort, exitPort.sendPort],
        );

        spawnedIsolates.add(isolate);
      }

      errorPorts.forEach(
        (element) => element.listen((message) {
          exitPorts.forEach((port) => port.close());
          errorPorts.forEach((port) => port.close());
          fail(message.toString());
        }),
      );

      await Future.wait(spawnedIsolates);
      final descriptors = (await Future.wait(descriptorPorts.map((port) => port.first))).map((descriptor) => descriptor as int).toList();
      final Pointer<Int32> descriptorsNative = calloc(descriptors.length * sizeOf<Int32>());
      descriptors.forEachIndexed((index, element) => descriptorsNative[index] = element);
      test_threading_prepare_call_dart_bytes(descriptorsNative, descriptors.length);

      while (test_threading_call_dart_check() != messages * threads * isolates) await Future.delayed(Duration(milliseconds: 1));
      await Future.wait(exitPorts.map((port) => port.first));

      exitPorts.forEach((port) => port.close());
      errorPorts.forEach((port) => port.close());

      test_threading_destroy();
    }),
  );
}

Future<void> _callNativeIsolate(List<dynamic> input) => fork(() async {
      final messages = input[0];
      final threads = input[1];
      final calls = <Future<Pointer<executor_task>>>[];
      final executor = context().broker();
      executor.initialize();
      final producer = executor.producer(TestNativeProducer());
      executor.activate();
      final descriptors = test_threading_executor_descriptors();
      for (var threadId = 0; threadId < threads; threadId++) {
        final descriptor = descriptors + threadId;
        if (descriptor == nullptr) {
          fail("descriptor is null");
        }
        for (var messageId = 0; messageId < messages; messageId++) {
          final message = executor.tasks.allocate();
          message.inputInt = 41;
          calls.add(producer.testThreadingCallNative(descriptor.value, message));
        }
      }
      calloc.free(descriptors);
      (await Future.wait(calls)).forEach((result) {
        if (result.outputInt != 41) {
          throw TestFailure("outputInt != 41");
        }
        executor.tasks.free(result);
      });
      input[2].send(null);
    });

Future<void> _callDartIsolate(List<dynamic> input) => fork(() async {
      final messages = input[0];
      final executor = context().broker();
      executor.initialize();
      var count = 0;
      final completer = Completer();
      executor.consumer(TestNativeConsumer(
        (notification) {
          if (!ListEquality().equals(notification.inputBytes, [1, 2, 3])) {
            completer.completeError(TestFailure("inputBytes != ${[1, 2, 3]}. ${notification.inputSize}: ${notification.inputBytes}"));
            return;
          }
          if (++count == messages) {
            completer.complete();
            return;
          }
        },
      ));
      executor.activate();

      input[1].send(executor.descriptor);

      await completer.future;

      input[2].send(null);
    });
