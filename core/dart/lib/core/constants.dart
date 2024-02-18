import '../core.dart';

const inline = pragma("vm:prefer-inline");

const empty = "";
const unknown = "unknown";
const newLine = "\n";
const slash = "/";
const dot = ".";
const star = "*";
const equalSpaced = " = ";
const openingBracket = "{";
const closingBracket = "}";
const comma = ",";
const parentDirectorySymbol = '..';
const currentDirectorySymbol = './';
const packageConfigJsonFile = "package_config.json";
const pubspecYamlFile = 'pubspec.yaml';
const pubspecYmlFile = 'pubspec.yml';

class CoreErrors {
  CoreErrors._();

  static String systemLibraryLoadError(path) => "Unable to load library ${path}";
  static String systemError(code) => "code = $code, message = ${system_dart_error_to_string(-code)}";
  static const nonLinuxError = "You should use Linux";
  static const unableToFindProjectRoot = "Unable to find project root";
}

class SourcesDirectories {
  const SourcesDirectories._();

  static const assets = "/assets";
  static const package = "/package";
  static const dotDartTool = ".dart_tool";
}

class PackageConfigFields {
  PackageConfigFields._();

  static const rootUri = 'rootUri';
  static const name = 'name';
  static const packages = 'packages';
}

const int intMaxValue = 9223372036854775807;
const soFileExtension = "so";
const nativeDirectory = "native";