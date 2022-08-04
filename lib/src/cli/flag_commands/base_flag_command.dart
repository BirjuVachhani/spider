// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import '../utils/utils.dart';

/// Represents a top-level flag that does not need to be specified on a command
/// to be executed and are only meant to be used on the main executable itself.
/// Since these flags can execute on their own, they are like commands.
/// e.g. --version, --check-updates, etc.
/// Since it is a flag by definition, this class also contains
/// properties of a flag.
abstract class FlagCommand<T> {
  /// The name of the flag without initial `--`(double dashes).
  abstract final String name;

  /// Help menu/information for this flag.
  abstract final String help;

  /// a short form of the flag without initial `-`(dash).
  final String? abbr = null;

  /// Represents default value of the flag.
  final bool defaultsTo = false;

  /// Defines whether this flag is toggleable or not.
  /// e.g. if the flag is `--print` then toggled flag would be `--no-print`
  /// which is automatically allowed if this is set to true.
  final bool negatable = true;

  /// Represents alias names for this flag.
  final List<String> aliases = const [];

  /// A logger that is used to output logs, errors and exceptions upon
  /// execution of this flag command.
  final BaseLogger logger;

  /// Default constructor.
  /// [logger] is used to output all kinds of logs that is produce as a result
  /// of the execution of this flag command.
  const FlagCommand(this.logger);

  /// This method is executed upon running this command. Should contain actual
  /// execution code.
  Future<T?> run();
}

/// A base class for this cli to use as parent class.
abstract class BaseFlagCommand extends FlagCommand<void> with LoggingMixin {
  /// Default constructor.
  const BaseFlagCommand(super.logger);
}
