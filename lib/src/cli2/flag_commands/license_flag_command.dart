import '../../constants.dart';
import '../models/flag_names.dart';
import 'base_flag_command.dart';

/// Represents the `license` flag command which prints license information.
/// e.g. Spider --license
class LicenseFlagCommand extends BaseFlagCommand {
  @override
  String get name => FlagNames.license;

  @override
  String get help => 'Show license information.';

  @override
  String get abbr => 'l';

  @override
  bool get negatable => false;

  LicenseFlagCommand(super.output, [super.errorSink]);

  @override
  Future<void> run() async => output.writeln(Constants.LICENSE_SHORT);
}
