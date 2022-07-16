## 3.2.0

- Fixes pubspec config detection.
- Fixes watch flag abbr parsing.
- Introduces `ignored_rules` feature which allows to specify ignore rules for generated files.
- Introduces `sub_groups` feature.

## 3.1.0

- Use `flutter_test` imports when generating tests for flutter project.

## 3.0.0

- Fix flag abbr not working for some commands.
- Add support for creating configs in `pubspec.yaml` file.
- Add support for creating config file at custom directory path.
- Add support for specifying custom config file path when running `build` command.
- Build command now displays which config file is being used if there's more than one config file.
- Document new capabilities and commands.

## 2.2.2

- PR[[#45](https://github.com/BirjuVachhani/spider/pull/45)] Sort generated file maps by file basenames by [@WSydnA](https://github.com/WSydnA)

## 2.2.1

- PR[[#41](https://github.com/BirjuVachhani/spider/pull/41)]: values is not formatted in camel case if asset is written in snake case

## 2.2.0

- [[#38]](https://github.com/BirjuVachhani/spider/issues/38): Add option to generate values list just like enums.

## 2.1.0

- Uses official lints package for static analysis.
- Added more code comments.
- Fix lint warnings.
- Fix [#35](https://github.com/BirjuVachhani/spider/issues/35) Constants names have no prefixes.
- Add option to use underscores in reference names.

## 2.0.0

- Migrated to null safety

## 1.1.1

- Fixed part of directive for generated classes.

## 1.1.0

- Added private constructor for generated classes to restrict instantiation
- Format fixes
- Upgraded dependencies

## 1.0.1

- fix dart format warnings
- update dependencies

## 1.0.0

- Added support for exporting generated dart code which is enabled by
default This can be helpful in cases where you want to use a single file
to import all of the generated classes. (Accessible individual classes
when importing)

- Added support to use opt in for usage of `part of` feature of dart. It
allows to avoid false imports when using export option. It makes all the
generated dart code files to behave like one file and one import.
- Added support to remove `Generated by spider...` comment line from all
the generated dart code. Allows to minimize vcs noise.
- `export_file` can be used to provide name of the export file.

#### Breaking Changes

- Instead of providing `package` to every group, now you have to define
global `package` name as it makes more sense. Providing package name for
individual groups won't work.

## 0.5.0

- Added support for `check updates`
- Updated help manuals
- Updated example configs files
- Fixed verbose logs

## 0.4.1
l̥
- Fix build command failing when there's no test generation specified
- Fix embedded version
- Added test to make sure that release version and embedded version matches

## 0.4.0

- Spider now allows to specify multiple paths to generate dart
references under a single class.
- Spider now generates test cases for dart references to make sure that
the file is present in the project.

## 0.3.6

- Fixed issue of creating references for files like `.DS_Store`
- Now Spider shows error if you try to create a group with flutter specific assets directories like `2.0x` and `3.0x`.

## 0.3.5

- fixes common commands execution issue. Now you can execute command anywhere you like.

## 0.3.4

- Fix build command when there are sub-directories in assets directories

## 0.3.3

- Added smart watch feature.
- use `--smart-watch` option when running build command to enable it.

## 0.3.2

- Fix create command

## 0.3.1

- Fix version command.
- Formatted outputs and added more verbose logs.
- Added config validation before processing assets.

## 0.3.0

- Add support for categorization by file types.
- Add support for using prefixes for generated dart references.

## 0.2.1

- Add support for JSON format for config files
- Add flag `--json` to `create` command to create json config file.
- Update readme to add json option for config file.

## 0.2.0

- Add support for multiple assets directories
- Add support for separate class generation
- Uses sample config file config creation

## 0.1.3

- Add support for watching directories for file changes
- Rename `init` command to `create` command
- Implemented verbose flag for build command
- add `build` command

## 0.1.2

- add emojis for console logs

## 0.1.1

- fix issues of pub.dev health report
- refactor code

## 0.1.0

- added dart class generator
- fix pub.dev warnings
- add code documentation

## 0.0.1

- pre-alpha release
- Initial version for demo purpose
- avoid using in production.