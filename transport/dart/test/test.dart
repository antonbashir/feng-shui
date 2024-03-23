import 'dart:async';

import 'package:transport/transport.dart';
import 'package:test/test.dart';
import 'package:transport/transport/bindings.dart';

import 'buffers.dart';
import 'bulk.dart';
import 'file.dart';
import 'shutdown.dart';
import 'tcp.dart';
import 'timeout.dart';
import 'udp.dart';
import 'unix.dart';

void execute(FutureOr<void> Function() test) => launch([CoreModule(), MemoryModule(), ExecutorModule(), TransportModule()], test);

void main() {
  SystemEnvironment.debug = false;
  final initialization = true;
  final tcp = false;
  final udp = true;
  final unixStream = false;
  final file = false;
  final bulk = false;
  final timeout = false;
  final buffers = false;
  final shutdown = false;

  group("[initialization]", timeout: Timeout(Duration(hours: 1)), skip: !initialization, () {
    testInitialization();
  });
  group("[shutdown]", timeout: Timeout(Duration(hours: 1)), skip: !shutdown, () {
    testForceShutdown();
    testGracefulShutdown(gracefulTimeout: Duration(seconds: 5));
  });
  group("[tcp]", timeout: Timeout(Duration(hours: 1)), skip: !tcp, () {
    final testsCount = 5;
    for (var index = 0; index < testsCount; index++) {
      testTcpSingle(index: index, clientsPool: 1);
      testTcpSingle(index: index, clientsPool: 128);
      testTcpSingle(index: index, clientsPool: 512);
      testTcpMany(index: index, clientsPool: 1, count: 64);
      testTcpMany(index: index, clientsPool: 128, count: 8);
      testTcpMany(index: index, clientsPool: 512, count: 4);
    }
  });
  group("[unix stream]", timeout: Timeout(Duration(hours: 1)), skip: !unixStream, () {
    final testsCount = 5;
    for (var index = 0; index < testsCount; index++) {
      testUnixStreamSingle(index: index, clientsPool: 1);
      testUnixStreamSingle(index: index, clientsPool: 128);
      testUnixStreamSingle(index: index, clientsPool: 512);
      testUnixStreamMany(index: index, clientsPool: 1, count: 64);
      testUnixStreamMany(index: index, clientsPool: 128, count: 8);
      testUnixStreamMany(index: index, clientsPool: 512, count: 4);
    }
  });
  group("[udp]", timeout: Timeout(Duration(hours: 1)), skip: !udp, () {
    final testsCount = 5;
    for (var index = 0; index < testsCount; index++) {
      testUdpSingle(index: index, clients: 1);
      testUdpSingle(index: index, clients: 128);
      testUdpSingle(index: index, clients: 512);
      testUdpMany(index: index, clients: 1, count: 64);
      testUdpMany(index: index, clients: 128, count: 8);
      testUdpMany(index: index, clients: 512, count: 4);
    }
  });
  group("[file]", timeout: Timeout(Duration(hours: 1)), skip: !file, () {
    final testsCount = 5;
    for (var index = 0; index < testsCount; index++) {
      testFileSingle(index: index);
      testFileLoad(index: index, count: 1);
      testFileLoad(index: index, count: 8);
      testFileLoad(index: index, count: 16);
    }
  });
  group("[timeout]", timeout: Timeout(Duration(hours: 1)), skip: !timeout, () {
    testTcpTimeout(connection: Duration(seconds: 1), serverRead: Duration(seconds: 5), clientRead: Duration(seconds: 3));
    testUdpTimeout(serverRead: Duration(seconds: 5), clientRead: Duration(seconds: 3));
  });
  group("[buffers]", timeout: Timeout(Duration(hours: 1)), skip: !buffers, () {
    testTcpBuffers();
    testUdpBuffers();
    testFileBuffers();
    testBuffersOverflow();
  });
  group("[bulk]", timeout: Timeout(Duration(hours: 1)), skip: !bulk, () {
    testBulk();
  });
}

void testInitialization() => test(
      "(initialize)",
      () => execute(() async {
        final transport = context().transport()..initialize();
        await transport.shutdown();
      }),
    );
