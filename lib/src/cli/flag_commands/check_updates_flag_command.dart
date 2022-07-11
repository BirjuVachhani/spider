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

    final result = await checkForNewVersion(logger);

    if (result.isError) {
      exitWith(result.error);
    }
  }

  static Future<Result<bool>> checkForNewVersion([BaseLogger? logger]) async {
    try {
      final latestVersion = await fetchLatestVersion();
      if (packageVersion != latestVersion && latestVersion.isNotEmpty) {
        logger?.success(Constants.NEW_VERSION_AVAILABLE
            .replaceAll('X.X.X', packageVersion)
            .replaceAll('Y.Y.Y', latestVersion));
        sleep(Duration(seconds: 1));
        return Result.success(true);
      }
      logger?.success('No updates available!');
      return Result.success(false);
    } catch (err, stacktrace) {
      logger?.verbose(err.toString());
      logger?.verbose(stacktrace.toString());
      // something wrong happened!
      return Result.error('Something went wrong! Unable to check for updates!');
    }
  }

  /// A web scraping script to get latest version available for this package
  /// on https://pub.dev.
  /// Returns an empty string if fails to extract it.
  static Future<String> fetchLatestVersion([BaseLogger? logger]) async {
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
      logger?.verbose(error.toString());
      logger?.verbose(stacktrace.toString());
      // unable to get version
      return '';
    }
  }
}
