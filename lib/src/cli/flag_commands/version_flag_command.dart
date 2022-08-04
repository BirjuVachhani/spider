// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import '../../version.dart';
import '../models/flag_names.dart';
import 'base_flag_command.dart';

/// A flag command to print current version of the CLI.
/// e.g. Spider --version
class VersionFlagCommand extends BaseFlagCommand {
  @override
  String get name => FlagNames.version;

  @override
  String get help => 'Show current version of this tool.';

  @override
  String get abbr => 'v';

  @override
  bool get negatable => false;

  /// Default constructor.
  VersionFlagCommand(super.logger);

  @override
  Future<void> run() async => Future.sync(() => log(packageVersion));
}
