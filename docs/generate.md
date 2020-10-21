Now that the configuration file is created, all that left is to run generator. Run following command to generate dart code:

```shell
spider build
```

This will analyze all the asset directories specified in the configuration file and will generate dart references.

**Example Output**

```dart
class Assets {
  static const String icCamera = 'assets/camera.png';
  static const String icLocation = 'assets/location.png';
}
```

checkout [manual](manual.md) for more information on available configurations.