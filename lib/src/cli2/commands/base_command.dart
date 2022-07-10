import 'package:args/command_runner.dart';

import '../utils/utils.dart';

/// A Base class for all the commands created in this cli app.
/// [output] is a sink to which logs are printed.
/// [errorSink] is a sink to which errors are printed.
/// These sinks are to be used by the extending command classes to output
/// the logs and errors to configured place.
/// e.g. console, file, or other sink.
abstract class BaseCommand extends Command<void> with LoggingMixin {
  @override
  final BaseLogger logger;

  BaseCommand(this.logger);
}
