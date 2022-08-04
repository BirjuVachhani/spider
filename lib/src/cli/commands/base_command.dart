// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';

import '../utils/utils.dart';

/// A Base class for all the commands created in this cli app.
abstract class BaseCommand extends Command<void> with LoggingMixin {
  @override
  final BaseLogger logger;

  /// Default constructor.
  /// [logger] is used to output all kinds of logs, errors and exceptions.
  /// e.g. [ConsoleLogger] for logging to console.
  BaseCommand(this.logger);
}
