// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:io';

import '../models/flag_names.dart';
import '../utils/utils.dart';
import 'base_flag_command.dart';

/// Represents the `docs` flag command which opens tool documentation site.
/// e.g. Spider --docs
class DocsFlagCommand extends BaseFlagCommand {
  @override
  String get name => FlagNames.docs;

  @override
  String get help => 'Open tool documentation.';

  @override
  String get abbr => 'd';

  @override
  bool get negatable => false;

  /// Default constructor.
  DocsFlagCommand(super.logger);

  @override
  Future<void> run() async {
    if (Platform.isMacOS) {
      await Process.run('open', [Constants.DOCS_URL]);
      return;
    } else if (Platform.isWindows) {
      await Process.run('explorer', [Constants.DOCS_URL]);
      return;
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [Constants.DOCS_URL]);
      return;
    }
    error(ConsoleMessages.unsupportedPlatform);
  }
}
