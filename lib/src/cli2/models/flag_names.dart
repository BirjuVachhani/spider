/// Contains the names of the flags available across the CLI.
class FlagNames {
  FlagNames._();

  // Top-level flags.
  static const String about = 'about';
  static const String checkForUpdates = 'check-for-updates';
  static const String docs = 'docs';
  static const String license = 'license';
  static const String verbose = 'verbose';
  static const String version = 'version';

  // shared
  static const String help = 'help';
  static const String path = 'path';

  // build command flags
  static const String smartWatch = 'smart-watch';
  static const String watch = 'watch';

  // Create command flags.
  static const String addInPubspec = 'add-in-pubspec';
  static const String json = 'json';
}
