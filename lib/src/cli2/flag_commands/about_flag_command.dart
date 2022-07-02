import '../../constants.dart';
import '../models/flag_names.dart';
import 'base_flag_command.dart';

/// Represents the `about` flag command which prints tool information.
/// e.g. Spider --about
class AboutFlagCommand extends BaseFlagCommand {
  @override
  String get name => FlagNames.about;

  @override
  String get help => 'Show tool info.';

  @override
  String get abbr => 'a';

  @override
  bool get negatable => false;

  AboutFlagCommand(super.output, [super.errorSink]);

  @override
  Future<void> run() async => output.writeln(Constants.INFO);
}
