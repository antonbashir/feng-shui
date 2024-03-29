import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:transport/transport.dart';
import 'package:test/test.dart';

import 'generators.dart';
import 'test.dart';

void testForceShutdown() {
  test(
    "[force]",
    () => runTest(() async {
      final transport = context().transport();
      final worker = transport;
      transport.initialize();
      final file = File("file");
      if (file.existsSync()) file.deleteSync();

      final serverCompleter = Completer();

      final server = worker.servers.tcp(InternetAddress("0.0.0.0"), 12345, (connection) {
        connection.writeSingle(Generators.request());
        serverCompleter.complete();
      });

      final clients = await worker.clients.tcp(InternetAddress("127.0.0.1"), 12345);
      var fileProvider = worker.files.open(file.path, create: true);

      await serverCompleter.future;
      final futures = [
        server.close(),
        clients.close(),
        fileProvider.close(),
      ];
      await Future.wait(futures);

      if (worker.buffers.used() != 0) throw TestFailure("actual: ${worker.buffers.used()}");
      if (worker.servers.registry.serverConnections.isNotEmpty) throw TestFailure("serverConnections isNotEmpty");
      if (worker.servers.registry.servers.isNotEmpty) throw TestFailure("servers isNotEmpty");
      if (worker.clients.registry.clients.isNotEmpty) throw TestFailure("clients isNotEmpty");
      if (worker.files.registry.files.isNotEmpty) throw TestFailure("files isNotEmpty");

      if (file.existsSync()) file.deleteSync();

      await transport.shutdown();
    }),
  );
}

void testGracefulShutdown({required Duration gracefulTimeout}) {
  test(
    "[gracefulTimeout = ${gracefulTimeout.inSeconds}]",
    () => runTest(() async {
      final transport = context().transport();
      final worker = transport;
      transport.initialize();
      final file = File("file");
      if (file.existsSync()) file.deleteSync();

      final serverCompleter = Completer();
      final fileCompleter = Completer();
      final clientCompleter = Completer();

      final server = worker.servers.tcp(InternetAddress("0.0.0.0"), 12345, (connection) {
        connection.writeSingle(Generators.request());
        serverCompleter.complete();
      });

      final clients = await worker.clients.tcp(InternetAddress("127.0.0.1"), 12345);

      var fileProvider = worker.files.open(file.path, create: true);
      fileProvider.writeSingle(Generators.request());

      fileProvider.load().then((value) {
        fileCompleter.complete();
      });

      clients.select().stream().listen((value) {
        value.release();
        clientCompleter.complete();
      });

      await serverCompleter.future;
      final futures = [
        server.close(gracefulTimeout: gracefulTimeout),
        clients.close(gracefulTimeout: gracefulTimeout),
        fileProvider.close(gracefulTimeout: gracefulTimeout),
      ];
      await Future.wait(futures);
      await fileCompleter.future;
      await clientCompleter.future;

      if (worker.buffers.used() != 0) throw TestFailure("actual: ${worker.buffers.used()}");
      if (worker.servers.registry.serverConnections.isNotEmpty) throw TestFailure("serverConnections isNotEmpty");
      if (worker.servers.registry.servers.isNotEmpty) throw TestFailure("servers isNotEmpty");
      if (worker.clients.registry.clients.isNotEmpty) throw TestFailure("clients isNotEmpty");
      if (worker.files.registry.files.isNotEmpty) throw TestFailure("files isNotEmpty");

      if (file.existsSync()) file.deleteSync();

      await transport.shutdown();
    }),
  );
}
