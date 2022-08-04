// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import '../models/flag_names.dart';
import '../utils/utils.dart';
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

  /// Default constructor.
  LicenseFlagCommand(super.logger);

  @override
  Future<void> run() async => Future.sync(() => log(Constants.LICENSE_SHORT));
}
