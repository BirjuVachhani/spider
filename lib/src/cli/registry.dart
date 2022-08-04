// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'commands/commands.dart';
import 'flag_commands/flag_commands.dart';
import 'models/command_names.dart';
import 'models/flag_names.dart';
import 'utils/utils.dart';

/// A factory function for creating an instance of [T] with dependency on
/// [BaseLogger].
typedef CommandCreator<T> = T Function(BaseLogger logger);

/// Holds all the available commands for the CLI.
final Map<String, CommandCreator<BaseCommand>> commandsCreatorRegistry = {
  CommandNames.create: CreateCommand.new,
  CommandNames.build: BuildCommand.new,
};

/// Holds all the available flag commands for the CLI.
final Map<String, CommandCreator<BaseFlagCommand>> flagCommandsCreatorRegistry =
    {
  FlagNames.version: VersionFlagCommand.new,
  FlagNames.about: AboutFlagCommand.new,
  FlagNames.checkForUpdates: CheckUpdatesFlagCommand.new,
  FlagNames.license: LicenseFlagCommand.new,
  FlagNames.docs: DocsFlagCommand.new,
};
