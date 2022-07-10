import 'dart:io';

import '../../constants.dart';
import '../../utils.dart';
import '../../version.dart';
import '../models/flag_names.dart';
import 'base_flag_command.dart';

/// A flag command to check for updates for the CLI.
/// e.g. Spider --check-updates.
class CheckUpdatesFlagCommand extends BaseFlagCommand {
  CheckUpdatesFlagCommand(super.logger);

  @override
  String get help => 'Check for updates.';

  @override
  String get name => FlagNames.checkForUpdates;

  @override
  String get abbr => 'u';

  @override
  Future run() async {
    log('Checking for updates...');
    try {
      final latestVersion = await fetchLatestVersion();
      if (packageVersion != latestVersion && latestVersion.isNotEmpty) {
        success(Constants.NEW_VERSION_AVAILABLE
            .replaceAll('X.X.X', packageVersion)
            .replaceAll('Y.Y.Y', latestVersion));
        // TODO: Maybe remove this delay in the future?
        sleep(Duration(seconds: 1));
        return;
      }
      success('No updates available!');
    } catch (err, stacktrace) {
      verbose(err.toString());
      verbose(stacktrace.toString());
      // something wrong happened!
      error('Something went wrong! Unable to check for updates!');
    }
  }
}
