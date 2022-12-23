> This feature is introduced in Spider [v4.2.0](/spider/changelog/#420)

Spider now supports code generation for fonts specified in `pubspec.yaml`. It will generate a class with
font family names as `const` strings.


```yaml
# global config
fonts: true
```
This generates font family names in `FontFamily` class in `fonts.dart` file.

If you want to change it, you can do so like this:

```yaml
# global config

fonts:
  class_name: MyFonts
  file_name: custom_fonts
```

After this, just run `spider build` command and it will generate code for font families.

#### Example output

```dart
class FontFamily {
  FontFamily._();

  static const String roboto = 'Roboto';
  static const String openSans = 'Open Sans';
}
```

Specify `--fonts-only` flag to your build command to generate/re-generate only fonts.

```bash
spider build --fonts-only
```