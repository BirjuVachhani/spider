/// Contains the names of the flags available across the CLI.
class FlagNames {
  FlagNames._();

  // Top-level flags.
  static const String version = 'version';
  static const String about = 'about';
  static const String verbose = 'verbose';
  static const String checkUpdates = 'check-updates';

  // shared
  static const String help = 'help';
  static const String path = 'path';

  // build command flags
  static const String watch = 'watch';
  static const String smartWatch = 'smart-watch';

  // Create command flags.
  static const String addInPubspec = 'add-in-pubspec';
  static const String json = 'json';
}
