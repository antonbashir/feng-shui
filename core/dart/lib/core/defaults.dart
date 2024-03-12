import 'configuration.dart';
import 'constants.dart';
import 'exceptions.dart';
import 'state.dart';

class CoreDefaults {
  CoreDefaults._();

  static const CoreModuleConfiguration coreConfiguration = CoreModuleConfiguration(
    printLevel: printLevelInformation,
    silent: false,
  );

  static final CoreModuleState coreState = CoreModuleState(
    printer: print,
    errorHandler: defaultErrorHandler,
    exceptionHandler: defaultExceptionHandler,
  );
}