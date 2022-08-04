// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import '../models/flag_names.dart';
import '../utils/utils.dart';
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

  /// Default constructor.
  /// [logger] is used to output logs, errors and exceptions.
  AboutFlagCommand(super.logger);

  @override
  Future<void> run() async => Future.sync(() => log(Constants.INFO));
}
