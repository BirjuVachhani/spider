![Banner](https://raw.githubusercontent.com/BirjuVachhani/spider/main/.github/banner.png?raw=true)

# Spider

A small dart library to generate Assets dart code from assets folder. It generates dart class with static const
variables in it which can be used to reference the assets safely anywhere in the flutter app.

[![Build](https://github.com/BirjuVachhani/spider/workflows/Build/badge.svg?branch=main)](https://github.com/BirjuVachhani/spider/actions) [![Tests](https://github.com/BirjuVachhani/spider/workflows/Tests/badge.svg?branch=main)](https://github.com/BirjuVachhani/spider/actions) [![codecov](https://codecov.io/gh/birjuvachhani/spider/branch/main/graph/badge.svg?token=ZTYF9UQJID)](https://codecov.io/gh/birjuvachhani/spider) [![Pub Version](https://img.shields.io/pub/v/spider?label=Pub)](https://pub.dev/packages/spider)

### User Guide: [Spider Docs](https://birjuvachhani.github.io/spider/)

## Breaking Changes since v4.0.0:

- `--info` flag command is now `--about` command.
- `--check-updates` flag command is now `--check-for-updates`.

### Example

#### Before

```dart
Widget build(BuildContext context) {
  return Image(image: AssetImage('assets/background.png'));
}
```

#### After

```dart
Widget build(BuildContext context) {
  return Image(image: AssetImage(Assets.background));
}
```

#### Generated Assets Class

```dart
class Assets {
  static const String background = 'assets/background.png';
}
```

This method allows no error scope for string typos. Also, it provides auto-complete in the IDE which comes very handy
when you have large amount of assets.

## Installation

### Install using pub

This is package is an independent library that is not linked to your project. So there's no need to add it to your
flutter project as it works as a global command line tool for all of your projects.

```shell
pub global activate spider
```

### Install using Homebrew

```shell
brew tap birjuvachhani/spider
brew install spider
```

Run following command to see help:

```shell
spider --help
```

## Usage

#### Create Configuration File

Spider provides a very easy and straight forward way to create a configuration file. Execute following command, and it
will create a configuration file with default configurations in it.

```shell
spider create
```

To append configs in `pubspec.yaml` file, execute following command.

```shell
spider create --add-in-pubspec
```

To use a custom directory path for configuration file, execute following command.

```shell
spider create -p ./directory/path/for/config
```

Now you can modify available configurations and Spider will use those configs when generating dart code.

#### Use JSON config file

Though above command creates `YAML` format for config file, spider also supports `JSON` format for config file. Use this
command to create `JSON` config file instead of `YAML`.

```shell
# Create in root directory
spider create --json

# or

# custom directory path
spider create -p ./directory/path/for/config --json
```

No matter which config format you use, `JSON` or `YAML`, spider automatically detects it and uses it for code
generation.

Here's the default configuration that will be in the config file:

```yaml
# Generated by Spider

# Generates unit tests to verify that the assets exists in assets directory
generate_tests: true

# Use this to remove vcs noise created by the `generated` comments in dart code
no_comments: true

# Exports all the generated file as the one library
export: true

# This allows you to import all the generated references with 1 single import!
use_part_of: true

# Location where all the generated references will be stored
package: resources

groups:
  - path: assets/images
    class_name: Images
    types: [ .png, .jpg, .jpeg, .webp, .webm, .bmp ]
```

### Generate Code

Run following command to generate dart code:

```shell
spider build
```

If you're using custom directory path for the configuration file, then you can specify the config file path like this:

```shell
spider -p ./path/to/config/file/spider.yaml build
```

### Manual

![Manual](https://raw.githubusercontent.com/BirjuVachhani/spider/main/table.png)

<!-- 
| KEY                | TYPE            | DEFAULT VALUE    | SCOPE    | DESCRIPTION                                                                                            |
|-----------------	|--------------	|----------------	|--------	|-------------------------------------------------------------------------------------------------------	|
| `path/paths`*    | String        | None            | GROUP    | Where to locate assets?                                                                                |
| `class_name`*    | String        | None            | GROUP    | What will be the name of generated dart class?                                                            |
| `package`        | String        | resources        | GLOBAL    | Where to generate dart code in the lib folder?                                                            |
| `file_name`        | String        | {class_name}    | GROUP    | What will be the name of the generated dart file?                                                        |
| `prefix`            | String        | None            | GROUP    | What will be the prefix of generated dart references?                                                    |
| `use_underscores`            | bool        | false            | GROUP    | Use underscore instead of camelcase for dart references?                                                    |
| `types`            | List<String>    | All                | GROUP    | Which types of assets should be included?                                                                |
| `generate_test`    | bool            | false            | GLOBAL    | Generate test cases to make sure that assets are still present in the project?                            |
| `no_comments`    | bool            | false            | GLOBAL    | Removes all the `generated` comments from top of all generated dart code.Use this to avoid vcs noise.    |
| `export`            | bool            | true            | GLOBAL    | Generates a dart file exporting all the generated classes. Can be used to avoid multiple exports.        |
| `export_file`    | String        | resources.dart    | GLOBAL    | What will be the name of generated export file?                                                        |
| `use_part_of`    | bool            | false            | GLOBAL    | Allows to opt in for using `part of` instead of exporting generated dart files.                            |
| `use_references_list`    | bool            | false            | GLOBAL    | Generates value list just like enums which contains all the asset references of that class.                            |
 -->

### Watch Directory

Spider can also watch given directory for changes in files and rebuild dart code automatically. Use following command to
watch for changes:

```shell
spider build --watch
```

see help for more information:

```shell
spider build --help
```

### Smart Watch (Experimental)

The normal `--watch` option watches for any kind of changes that happens in the directory. However, this can be improved
my smartly watching the directory. It includes ignoring events that doesn't affect anything like file content changes.
Also, it only watches allowed file types and rebuilds upon changes for those files only.

Run following command to watch directories smartly.

```shell
spider build --smart-watch
```

### Categorizing by File Extension

By default, Spider allows any file to be referenced in the dart code. but you can change that behavior. You can specify
which files you want to be referenced.

```yaml
path: assets
class_name: Assets
package: res
types: [ jpg, png, jpeg, webp, bmp, gif ]
```

### Use Prefix

You can use prefixes for names of the generated dart references. Prefixes will be attached to the formatted reference
names.

```yaml
path: assets
class_name: Assets
package: res
prefix: ic
```

##### Output

```dart
class Assets {
  static const String icCamera = 'assets/camera.png';
  static const String icLocation = 'assets/location.png';
}
```

## Advanced Configuration

Spider provides supports for multiple configurations and classifications. If you want to group your assets by module, type
or anything, you can do that using `groups` in spider.

### Example

Suppose you have both vector(SVGs) and raster images in your project, and you want to me classified separately so that
you can use them with separate classes. You can use groups here. Keep your vector and raster images in separate folder
and specify them in the config file.

`spider.yaml`

```yaml
groups:
  - path: assets/images
    class_name: Images
    package: res
  - path: assets/vectors
    class_name: Svgs
    package: res
```

Here, first item in the list indicates to group assets of `assets/images` folder under class named `Images` and the
second one indicates to group assets of `assets/vectors` directory under class named `Svgs`.

So when you refer to `Images` class, auto-complete suggests raster images only, and you know that you can use them
with `AssetImage` and other one with vector rendering library.

## Multi-path configuration

From Spider `v0.4.0`, multiple paths can be specified for a single group to collect references from multiple directories
and generate all the references under single dart class.

#### Example

```yaml
groups:
  - paths:
      - assets/images
      - assets/more_images/
    class_name: Images
    package: res
    types: [ .png, .jpg, .jpeg, .webp, .webm, .bmp ]
```

By using `paths`, multiple source directories can be specified. Above example will generate references
from `assets/images` and `assets/more_images/` under a single dart class named `Images`.

## Generating Tests

Spider `v0.4.0` adds support for generating test cases for generated dart references to make sure that the asset file is
present in the project. These tests can also be run on CI servers. To enable tests generation, specify `generate_tests`
flag in `spider.yaml` or `spider.json` configuration file as shown below.

```yaml
generate_tests: true
```

This flag will indicate spider to generate tests for all the generated dart references.

## Generate `values` list

Familiar with `Enum.values` list which contains all the enum values? Spider also provides support for generating `values`
list for all the asset references in given dart class. 
Use `use_references_list` global config to enable `values` list generation. This is disabled by default as it can be
overwhelming to have this code-gen if you don't need it.

```yaml
# global config
use_references_list: true
```


## Enable Verbose Logging

Spider prefers not to overwhelm terminal with verbose logs that are redundant for most of the cases. However, those
verbose logs come quite handy when it comes to debug anything. You can enable verbose logging by using `--verbose`
option on build command.

```shell
spider build --verbose

# watching directories with verbose logs
spider build --watch --verbose
```

## Liked spider?

Show some love and support by starring the repository. ⭐

Want to support my work?

<a href="https://github.com/sponsors/BirjuVachhani" target="_blank"><img src="https://raw.githubusercontent.com/BirjuVachhani/spider/main/.github/sponsor.png?raw=true" alt="Sponsor Author" style="!important;width: 600px !important;" ></a>

Or You can

<a href="https://www.buymeacoffee.com/birjuvachhani" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-blue.png" alt="Buy Me A Coffee" style="height: 51px !important;width: 217px !important;" ></a>

## License

```
Copyright © 2020 Birju Vachhani

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
