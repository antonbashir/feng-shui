import 'package:transport/transport.dart';

import 'codec.dart';
import 'configuration.dart';
import 'constants.dart';

class ReactiveTransportDefaults {
  ReactiveTransportDefaults._();

  static ReactiveTransportConfiguration transport() => ReactiveTransportConfiguration(
        tracer: null,
        gracefulTimeout: null,
        workerConfiguration: TransportDefaults.worker(),
      );

  static ReactiveChannelConfiguration channel() => ReactiveChannelConfiguration(
        initialRequestCount: 1,
        chunksLimit: 8,
        frameMaxSize: 5 * 1024 * 1024,
        fragmentSize: 10 * 1024 * 1024,
      );

  static ReactiveBrokerConfiguration broker() => ReactiveBrokerConfiguration(
        codecs: {
          octetStreamMimeType: ReactiveRawCodec(),
          textMimeType: ReactiveUtf8Codec(),
        },
      );

  static ReactiveSetupConfiguration setup() => ReactiveSetupConfiguration(
        metadataMimeType: octetStreamMimeType,
        dataMimeType: octetStreamMimeType,
        keepAliveInterval: Duration(seconds: 20),
        keepAliveMaxLifetime: Duration(seconds: 90),
        lease: false,
      );
}
