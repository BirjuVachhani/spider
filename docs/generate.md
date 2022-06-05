### Build Command

Now that the configuration file is created, all that left is to run generator. Run following command to generate dart code:

```shell
spider build
```

This will analyze all the asset directories specified in the configuration file and will generate dart references.

### Custom configuration path

If you're using custom path for configuration file (e.g. if it is not in the root directory or in `pubspec.yaml` file), then you have point to it in the build command like this:

```shell
spider -p ./configs/spider.yaml build
```

### Example Output

```dart
class Assets {
  static const String icCamera = 'assets/camera.png';
  static const String icLocation = 'assets/location.png';
}
```

checkout [manual](manual.md) for more information on available configurations.