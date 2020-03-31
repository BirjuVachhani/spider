## 0.4.1

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
