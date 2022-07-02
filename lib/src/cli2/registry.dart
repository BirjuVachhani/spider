import 'dart:io';

import 'commands/commands.dart';
import 'flag_commands/flag_commands.dart';
import 'models/command_names.dart';
import 'models/flag_names.dart';

typedef CommandCreator<T> = T Function(IOSink output, [IOSink? error]);

final Map<String, CommandCreator<BaseCommand>> commandsCreatorRegistry = {
  CommandNames.create: CreateCommand.new,
  CommandNames.build: BuildCommand.new,
};

final Map<String, CommandCreator<BaseFlagCommand>> flagCommandsCreatorRegistry =
    {
  FlagNames.version: VersionFlagCommand.new,
  FlagNames.about: AboutFlagCommand.new,
  FlagNames.checkUpdates: CheckUpdatesFlagCommand.new,
};
