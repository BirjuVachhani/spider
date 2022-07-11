import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import '../../version.dart';
import '../models/flag_names.dart';
import '../utils/utils.dart';
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

  /// A web scraping script to get latest version available for this package
  /// on https://pub.dev.
  /// Returns an empty string if fails to extract it.
  Future<String> fetchLatestVersion() async {
    try {
      final html = await http
          .get(Uri.parse('https://pub.dev/packages/spider'))
          .timeout(Duration(seconds: 3));

      final document = parser.parse(html.body);

      var jsonScript =
          document.querySelector('script[type="application/ld+json"]')!;
      var json = jsonDecode(jsonScript.innerHtml);
      final version = json['version'] ?? '';
      return RegExp(Constants.VERSION_REGEX).hasMatch(version) ? version : '';
    } catch (error, stacktrace) {
      verbose(error.toString());
      verbose(stacktrace.toString());
      // unable to get version
      return '';
    }
  }
}
