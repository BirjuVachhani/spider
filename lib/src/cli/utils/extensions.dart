// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'package:args/args.dart';
import 'package:collection/collection.dart';

import '../flag_commands/flag_commands.dart';

/// Extension methods for [ArgParser] class.
extension ArgResultsExt on ArgResults {
  /// Returns true if [ArgResults] has a command.
  bool get hasCommand => command != null;

  /// Returns true if the [flag] was passed and its value is true.
  /// For non-negatable flags, this will always return true if they are passed.
  /// For negatable flags, this will return true if the flag is passed and its
  /// value is true, false otherwise.
  bool getFlag(String flag) => wasParsed(flag) && this[flag] == true;

  /// This would return all the flag that are actually parsed in the command.
  List<String> get passedFlags => options.where(wasParsed).toList();
}

/// Extension methods for [FlagCommand] collection.
extension BaseFlagCommandListExt<T extends FlagCommand> on Iterable<T> {
  /// Finds the flag command with where [FlagCommand.name] is [name].
  T? findByName(String name) =>
      firstWhereOrNull((element) => element.name == name);

  /// Returns true [name] is in the flag commands list.
  bool hasFlag(String name) => findByName(name) != null;
}
