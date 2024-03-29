import 'dart:io' as io;
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:transport/transport.dart';
import 'package:test/test.dart';

import 'generators.dart';
import 'latch.dart';
import 'test.dart';
import 'validators.dart';

void testUdpSingle({required int index, required int clients}) {
  test(
    "(single) [clients = $clients]",
    () => runTest(() async {
      final transport = context().transport()..initialize();
      transport.servers.udp(io.InternetAddress("0.0.0.0"), 12345).stream().listen(
        (event) {
          Validators.request(event.takeBytes());
          event.respondSingle(Generators.response());
        },
      );
      final latch = Latch(clients);
      for (var clientIndex = 0; clientIndex < clients; clientIndex++) {
        final client = transport.clients.udp(io.InternetAddress("127.0.0.1"), (transport.descriptor + 1) * 2000 + (clientIndex + 1), io.InternetAddress("127.0.0.1"), 12345);
        client.stream().listen((event) {
          Validators.response(event.takeBytes());
          latch.countDown();
        });
        client.sendSingle(Generators.request());
      }
      await latch.done();
      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}

void testUdpMany({required int index, required int clients, required int count}) {
  test(
    "(many) [clients = $clients, count = $count]",
    () => runTest(() async {
      final transport = context().transport()..initialize();
      final serverRequests = BytesBuilder();
      transport.servers.udp(io.InternetAddress("0.0.0.0"), 12345).stream().listen(
        (responder) {
          serverRequests.add(responder.takeBytes());
          if (serverRequests.length == Generators.requestsSumUnordered(count).length) {
            Validators.requestsSumUnordered(serverRequests.takeBytes(), count);
          }
          responder.respondMany(Generators.responsesUnordered(2));
        },
      );
      for (var clientIndex = 0; clientIndex < clients; clientIndex++) {
        final latch = Latch(1);
        final client = transport.clients.udp(io.InternetAddress("127.0.0.1"), (transport.descriptor + 1) * 2000 + (clientIndex + 1), io.InternetAddress("127.0.0.1"), 12345);
        final clientResults = BytesBuilder();
        client.stream().listen((event) {
          clientResults.add(event.takeBytes());
          if (clientResults.length == Generators.responsesSumUnordered(count * 2).length) {
            Validators.responsesSumUnordered(clientResults.takeBytes(), count * 2);
            latch.countDown();
          }
        });
        client.sendMany(Generators.requestsUnordered(count));
        await latch.done();
      }
      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}
