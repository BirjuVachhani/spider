import '../utils/utils.dart';

/// Represents a top-level flag that does not need to be specified on a command
/// to be executed and are only meant to be used on the main executable itself.
/// Since these flags can execute on their own, they are like commands.
/// e.g. --version, --check-updates, etc.
/// Since it is a flag by definition, this class also contains
/// properties of a flag.
abstract class FlagCommand<T> {
  abstract final String name;
  abstract final String help;

  final String? abbr = null;
  final bool defaultsTo = false;
  final bool negatable = true;
  final List<String> aliases = const [];

  final BaseLogger logger;

  const FlagCommand(this.logger);

  Future<T?> run();
}

/// A base class for this cli to use as parent class.
abstract class BaseFlagCommand extends FlagCommand<void> with LoggingMixin {
  const BaseFlagCommand(super.logger);
}
